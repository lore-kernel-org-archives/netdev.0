From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Fri, 14 Oct 2011 15:32:31 -0700
Message-ID: <CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
 <4E931A46.1040905@hp.com> <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
 <4E98981D.6080908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:11655 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab1JNWcy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 18:32:54 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p9EMWqol013424
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 15:32:53 -0700
Received: from vws18 (vws18.prod.google.com [10.241.21.146])
	by wpaz1.hot.corp.google.com with ESMTP id p9EMP4UZ019314
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 15:32:51 -0700
Received: by vws18 with SMTP id 18so2314081vws.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 15:32:51 -0700 (PDT)
In-Reply-To: <4E98981D.6080908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2011 at 13:14, Brian Haley <brian.haley@hp.com> wrote:
> Playing devil's advocate here, isn't this a brain-dead ISP? =A0If the=
y're
> giving=A0you a global IPv6 address you should get Internet connectivi=
ty
> with it. =A0If not,=A0you probably knew it up front, or you're going =
to find
> another provider that=A0does. =A0It's like they're giving you a site-=
local
> address...

I wouldn't say they're a brain-dead carrier, because they also give you
true IPv6 connectivity on another interface. The phone will deactivate
this interface when bringing up wifi, because wifi is usually cheaper a=
nd
faster.=A0However, the carrier interface needs to stay up all the time
in order to do such things as provisioning, send and receive SMS
messages, handle voice over IP calls, and so on. So you will have
cases where the phone's primary Internet connection is over wifi, but
the phone still has a global unicast IPv6 address on the carrier interf=
ace.

> So are you talking about being able to dynamically change the scope
> of an=A0address? =A0Wifi comes up - change provider addreses to host-
> local, wifi goes down=A0- change it back to global. =A0That looks lik=
e a
> hack.

What I'm suggesting is to have the carrier interface be created with
site scope and stay up forever (or as long as the phone is on the cell
network). If an application wants to use the carrier interface, it will=
 create
host routes that explicitly specify the carrier interface and the sourc=
e
address of the carrier interface.

Applications that don't use the carrier interface will not have to do
anything special; if you set the carrier interface to site scope,
the kernel should just do the right thing.

> A default route with only a link-local address isn't very useful. =A0=
Will the
> kernel ever use this interface with the global address of your carrie=
r -
> isn't=A0it going to prefer the interface that address is configured o=
n?

No, it will use the carrier address, because RFC3484 says "avoid
deprecated addresses" (rule 3) before it says "prefer outgoing interfac=
e"
(rule 5).

> That's a pretty small window where the address is in tentative state =
(< 2 sec),=A0and re-trying shortly after will work.

That's true, but as the application you don't know that. You just call
connect(), and sit there and hang. There's a lot of applications that w=
ant
to reconnect as soon as they see that wifi has come up, and they all
get stuck.

> You can also use routing rules, like anyone that does dual-homed
> with IPv4 does =A0- only use 1.2.3.4 on eth0, and only use 4.3.2.1 on
> eth1.

That doesn't work, because when the kernel creates a new TCP
connection, its source address is empty, so no source-based rules
match. More specifically, if I do (assume the carrier IP address is
2001:db8::1/64):

ip -6 rule add prio 100 from 2001:db8::/64 lookup 100
ip -6 route add table 100 unreachable default
ip -6 route add default via fe80::1 dev wlan0

the system will still use the address from the carrier interface. I thi=
nk
this is by design though.

> And there's also gai.conf, although I haven't played with that in a
> while.

gai.conf only handles destination address selection; the kernel
handles source address selection.

> The other trick/hack is to change the preferred lifetime of an addres=
s
> to zero,=A0which should mark it deprecated, moving it down in the
> selection list.

That will work, but I think it's more of a hack than setting scope to
site. The carrier address is not deprecated, it's perfectly
functional. It just can't reach the Internet, but only a part of it.
So I think that calling it scoped is the solution that makes the most
sense.

> What else will break though? =A0If I configure fe80::1/64 and set the
> scope to=A0global, do applications know to look at ifa_scope and not
> just the address=A0itself to determine the scope? =A0Should they?

If the application treats scoped addresses specially, it will treat
fe80::1 as link-local scope, and will do things like check
sin6_scope_id to see if it's unique. On balance, I think that's the
right thing to do for an application in this situation, since, as
above, it's the network that truly decides what scope an address is
unique in, not the application or the kernel, and I would expect the
rest of the network to treat fe80::/64 as link-local (for example,
routers won't forward it, and so on).

The kernel, on the other hand, will try to use fe80::1 as if it were a
global address for the purposes of source address selection, but after
all, that's what you asked it to do, so you can't really blame it.

Make sense?
