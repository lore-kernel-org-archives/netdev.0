From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: [ROUTE]: FIB_RES_PREFSRC() selects wrong source in some cases
Date: Mon, 21 Apr 2008 16:29:15 +0400
Message-ID: <480C889B.3060203@odu.neva.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:41044 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974AbYDUM3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 08:29:16 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTP id 4B4917804D
	for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 16:29:15 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider an interface with two (or more) IP addresses, connected to a
LAN segment with two (or more) networks. In such a case the source IP is
not unique, it should be chosen depending on the destionation IP. Under
some circumstances this choice is incorrect.

Consider the example (an interface in two networks, trying to reach
"scope link" destinations):

> # ifdown eth0
> # ip link set up dev eth0
> # ip addr add 192.168.0.1/24 dev eth0
> # ip addr add 172.18.0.1/24 dev eth0
> # ip route show dev eth0
> 172.18.0.0/24  proto kernel  scope link  src 172.18.0.1
> 192.168.0.0/24  proto kernel  scope link  src 192.168.0.1

now we have two routes with preferred src specified

> # ip route get 192.168.0.2
> 192.168.0.2 dev eth0  src 192.168.0.1
>     cache  mtu 1500 advmss 1460 hoplimit 64
> # ip route get 172.18.0.2
> 172.18.0.2 dev eth0  src 172.18.0.1
>     cache  mtu 1500 advmss 1460 hoplimit 64

Becasue of the preferred src, the actual source IP is chosen right.

Now let's flush all the routes, and then add them manually.
(Certainly such a usage is a corner case, but sometimes some admins
prefer to set all the routes explicitly, rather than implicitly by
"proto kernel" etc.)

> # ip route flush dev eth0
> #
> # ip route add 192.168.0.0/24 dev eth0
> # ip route add 172.18.0.0/24 dev eth0
> # ip route show dev eth0
> 172.18.0.0/24  scope link
> 192.168.0.0/24  scope link

Now the same as above, but no more preferred src...

> # ip route get 192.168.0.2
> 192.168.0.2 dev eth0  src 192.168.0.1
>     cache  mtu 1500 advmss 1460 hoplimit 64

right...

> # ip route get 172.18.0.2
> 172.18.0.2 dev eth0  src 192.168.0.1
>     cache  mtu 1500 advmss 1460 hoplimit 64

Oops. Now wrong.

...and set up the test iface back:
> # ip addr flush dev eth0
> # ip link set down dev eth0
> # ifup eth0

In summary: we have an interface with two IP: 192.168.0.1 and
172.18.0.1, and have:

172.18.0.0/24  scope link
192.168.0.0/24  scope link

routes. The actual "src" is chosen wrong.


The correspond kernel code fragment seems to be in
net/ipv4/route.c:ip_route_output_slow():

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=blob;f=net/ipv4/route.c;h=7b5e8e1d94be2eb19764880c99597854f34657f3;hb=HEAD#l2419

>         if (!fl.fl4_src)
>                 fl.fl4_src = FIB_RES_PREFSRC(res);

The FIB_RES_PREFSR macro is:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=blob;f=include/net/ip_fib.h;h=8b12667f7a2bccad312fc0e63e679dfd02ec3509;hb=HEAD#l140

> #define FIB_RES_PREFSRC(res)            ((res).fi->fib_prefsrc ? : __fib_res_prefsrc(&res))

since preferred source is not set  in the example above, the
"fib_prefsrc" is zero, hence __fib_res_prefsrc() is called, which  is
actually:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=blob;f=net/ipv4/fib_semantics.c;h=a13c84763d4c10e503e418f2e6afef3e353193c3;hb=HEAD#l941

> __be32 __fib_res_prefsrc(struct fib_result *res)
> {
>         return inet_select_addr(FIB_RES_DEV(*res), FIB_RES_GW(*res), res->scope);
> }

and since we worked with the "scope link" destinations and have not
specified any "gateways" for it, the "FIB_RES_GW(*res)" is zero.

When inet_select_addr():

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=blob;f=net/ipv4/devinet.c;h=87490f7bb0f72a47db2a3e8a28ce3816cd236032;hb=HEAD#l877

> __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
> {

is called with "dst == 0", it chose just the first IP seen on the
interface (i.e. 192.168.0.1 in the example) ...


Whether it is possible (and applicable) to change the code someway, to
call inet_select_addr() with the proper destination IP ?

Actually, it is a long standing issue (at least since 1999), probably
it is even "feature" now :), but it seems strange that the kernel have
all the data to make the right choice, but does not any attemptfor it...


Regards,
Dmitry Butskoy
http://www.fedoraproject.org/wiki/DmitryButskoy



