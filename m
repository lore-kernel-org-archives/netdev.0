From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: multicast, interfaces, kernel 3.0+...
Date: Sat, 22 Sep 2012 08:21:52 +0400
Message-ID: <505D3CE0.2050603@msgid.tls.msk.ru>
References: <505CB607.7080207@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:42362 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187Ab2IVEVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 00:21:55 -0400
In-Reply-To: <505CB607.7080207@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.09.2012 22:46, Michael Tokarev wrote:
> Hello.
> 
> We found some, well, interesting behavour of kernels
> 3.0 and later, while 2.6.32 (previous long-stable
> series) worked fine.  I'm not sure when it "broke",
> since this is a production machine and we've difficult
> time diagnosing it, and the app causing it is, well,
> large.
> 
> The short story.  A big java app uses multicast group
> to register one component and find it later.
> 
> The machine in question has 3 active network interfaces:
> usual lo, eth0, and virtual (tap, pointopoint) tinc.
> Tinc interface is marked as "multicast off".
> 
> When the app starts on 2.6.32 kernel, netstat -g shows
> that multicast group on 2 interfaces: lo and eth0, but
> not on tinc, which is sort of expected:
> 
> $ netstat -g
> IPv6/IPv4 Group Memberships
> Interface       RefCnt Group
> --------------- ------ ---------------------
> lo              4      228.5.6.7
> lo              1      all-systems.mcast.net
> eth0            4      228.5.6.7
> eth0            1      all-systems.mcast.net
> tinc            1      all-systems.mcast.net
> 
> 
> But when the same app (actually the same userspace) is
> booted on the same machine but on 3.0+ kernel, the same
> multicast group is registered also on 2 interfaces, but
> this time these are lo (as before) and tinc, but not eth0:
> 
> $ netstat -g
> IPv6/IPv4 Group Memberships
> Interface       RefCnt Group
> --------------- ------ ---------------------
> lo              4      228.5.6.7
> lo              1      all-systems.mcast.net
> eth0            1      all-systems.mcast.net
> tinc            4      228.5.6.7
> tinc            1      all-systems.mcast.net
> 
> Now, on 3.0+ kernel, parts of this app can't find each
> other.  The "client" tries to send a datagram packet
> to this address, 228.5.6.7, but receives no reply.
> 
> On 2.6.32 kernel, when eth0 is used instead of tinc,
> it all works as expected.

Now this is interesting, questionable, and is a change
in behavour, albiet, well, again, questionable ;)

I looked at straces, and found this.

The app looks at all interfaces on the host, and for
each interface found, it calls IP_ADD_MEMBERSHIP.

But.

On this machine, for years, we had the same address on
eth0 and on tinc interfaces (that's long story).

Now, the difference in behavour between 3.0+ and 2.6.32
is that for this one IP address, corresponding IP_ADD_MEMBERSHIP
call on one kernel adds one iface to the group, while on
another kernel it is another iface.  That's the whole
difference.

Why I said it is a "questionable question".  The IP_ADD_MEMBERSHIP
interface is apparently misdefined, because it accepts an
IP address of an interface, instead of an ifindex, or
ifname, or something like this, since there's no, obviously,
1:1 correspondence between ifaces and addresses, an iface
can have no addresses assotiated with it, or two ifaces can
share one IP address like in my case.  But the "questionable"
part is the "usualness" of this setup I have here, with two
ifaces having the same IP address.

I've no idea why the app does this thing to start with,
why it can't use wildcard address with IP_ADD_MEMBERSHIP,
or why it messes with that stuff at all.  It is a different
question.

So, should IP_ADD_MEMBERSHIP use some more iface-centric
interface, instead of relying on IP addresses?  And why
3.0+ changed order here?

Thanks!

/mjt
