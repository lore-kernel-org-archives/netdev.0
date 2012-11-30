From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: iputils: ping -I <iface>
Date: Sat, 01 Dec 2012 04:04:06 +0900
Message-ID: <50B90326.2010302@linux-ipv6.org>
References: <50B76D5B.8010804@redhat.com> <50B7BC0F.6000709@candelatech.com> <50B84CCB.7000502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59267 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751691Ab2K3TFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 14:05:12 -0500
In-Reply-To: <50B84CCB.7000502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012=E5=B9=B411=E6=9C=8830=E6=97=A5 15:06), Jan Synacek wrote:
> On 11/29/2012 08:48 PM, Ben Greear wrote:
>> On 11/29/2012 06:12 AM, Jan Synacek wrote:
>>> Hello,
>>>
>>> There seems to be a bug(?) when calling ping with -I lo:
>>>
>>> $ ping -I lo kernel.org
>>>
>>> PING kernel.org (149.20.4.69) from 192.168.1.10 lo: 56(84) bytes of=
 data.
>>> ^C
>>>
>>> Note that 192.168.1.10 is my primary interface's address (em1). How=
ever, no
>>> replies are coming back.
>>>
>>> $ ping -I em1 kernel.org
>>>
>>> PING kernel.org (149.20.4.69) from 192.168.1.10 em1: 56(84) bytes o=
f data.
>>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=3D1 ttl=3D42 =
time=3D202 ms
>>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=3D2 ttl=3D42 =
time=3D187 ms
>>> ^C
>>>
>>> Works as expected.
>>>
>>> I know that binding to loopback probably doesn't make much sense, b=
ut I think
>>> that ping should be able to cope with that.
>>
>> I think it would be wrong if ping worked as you suggest.  Binding to=
 an
>> interface means use that interface as the source of your packets, an=
d having
>> it bind hard helps when using systems with multiple NICs on same sub=
net
>> (or possibly, same IP).
>=20
> I just wanted to point out that if I call ping with -I lo, its 'from'=
 address is
> wrong (in my case 192.168.1.10) and nothing happens (that's, I guess,=
 expected
> if it really bound to loopback). If I call ping with the -I <the same=
 address>
> or -I em1 (the same address again), it works as expected. I'm sorry i=
f I wasn't
> clear enough.
>=20
>>
>>> Also, it would be nice to mention the difference between -I <ip> an=
d -I <iface>
>>> in the manpage.
>>
>> In my opinion, -I <iface> should use SO_BINDTODEVICE, but at least i=
n
>> older versions of ping it did not.
>=20
> Ping does use SO_BINDTODEVICE.

So far, -I device is related to source address selection (using
SO_BINDTODEVICE) and outgoing device (using in_pktinfo).
On the other hand, -I addr is, in fact, related to source
address selection (and it is enfoced by bind), only.

Something like this:

       -I interface
              interface is either an address, or an interface name.  If
              interface is an address, it sets source address to
              specified interface address.   If  interface
              in  an  interface name, it tells the command to use that
              interface.  For ping6, when doing ping to a link-local
              scope address, link specification (by the
              '%'-notation in destination, or by this option) is
              required.

BUT, even with -I device, net/ipv4/dev_inet.c:inet_select_addr()
may select an address from other interfaces, AFAIK).

Should we check if the selected source address blongs to the actual
device?

--yoshfuji
