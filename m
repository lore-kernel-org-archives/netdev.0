From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug with IPv6-UDP address binding
Date: Wed, 08 Aug 2012 22:59:51 +0200
Message-ID: <1344459591.28967.271.camel@edumazet-glaptop>
References: <1344458238.3069.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61683 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759243Ab2HHU74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 16:59:56 -0400
Received: by bkwj10 with SMTP id j10so456470bkw.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 13:59:55 -0700 (PDT)
In-Reply-To: <1344458238.3069.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-08 at 22:37 +0200, Jesper Dangaard Brouer wrote:
> Hi NetDev
> 
> I think I have found a problem/bug with IPv6-UDP address binding.
> 
> I found this problem while playing with IPVS and IPv6-UDP, but its also
> present in more basic/normal situations.
> 
> If you have two IPv6 addresses, within the same IPv6 subnet, then one
> of the IPv6 addrs takes precedence over the other (for UDP only).
> 
> Meaning that, if connecting to the "secondary" IPv6 via UDP, will
> result in userspace see/bind the connection as being created to the
> "primary" IP, even-though tcpdump shows that the IPv6-UDP packets are
> dest the "secondary".
> 
> The result is; that only the first IPv6-UDP packet is delivered to
> userspace, and the next packets are denied by the kernel as the UDP
> socket is "established" with the "primary" IPv6 addr.
> 
> I would appreciate some hints to where in the IPv6 code I should look
> for this bug.  If any one else wants to fix it, I'm also fine with
> that ;-)
> 
> 
> Its quite easy to reproduce, using netcat (nc).
> 
> Add two addresses to the "server" e.g.:
>  ip addr add fee0:cafe::102/64 dev eth0
>  ip addr add fee0:cafe::bad/64 dev eth0
> 
> Run a netcat listener on "server":
>  nc -6 -u -l 2000
> (Notice restart the listener between runs, due to limitation in nc)
> 
> On the client add an IPv6 addr e.g.:
>  ip addr add fee0:cafe::101/64 dev eth0
> 
> Run a netcat UDP-IPv6 producer on "client":
>   nc -6 -u fee0:cafe::bad 2000
> 
> Notice that first packet, will get through, but second packets will
> not (nc: Write error: Connection refused).  Running a tcpdump shows
> that the kernel is sending back ICMP6, destination unreachable,
> unreachable port.
> 
> Its also possible to see the problem, simply running "netstat -uan" on
> "server", which will show that the "established" UDP connection, is
> bound to the wrong "Local Address".
> 
> (Tested on both latest net-next kernel at commit 79cda75a1, and also
> on RHEL6 approx 2.6.32)
> 

Hi Jesper

Thats because the "nc -6 -u -l 2000" on server does :

bind(3, {sa_family=AF_INET6, sin6_port=htons(2000), inet_pton(AF_INET6,
"::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0

recvfrom(3, "\n", 1024, MSG_PEEK, {sa_family=AF_INET6,
sin6_port=htons(53696), inet_pton(AF_INET6, "fee0:cafe::101",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 1

connect(3, {sa_family=AF_INET6, sin6_port=htons(53696),
inet_pton(AF_INET6, "fee0:cafe::101", &sin6_addr), sin6_flowinfo=0,
sin6_scope_id=0}, 28) = 0

And the kernel automatically chooses a SOURCE address (fee0:cafe::102)
that is not what you expected (fee0:cafe::bad)

So its a bug in the application.

UDP connect() is tricky : In this case, nc should learn on what IP
address the client sent the frame. (using recvmsg() and appropriate
ancillary message)

Then nc should bind a new socket on this address, then do the connect()
