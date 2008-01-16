From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 08:52:11 -0500
Message-ID: <1200491531.4457.91.camel@localhost>
References: <478A038B.4090900@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:42851 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbYAPNwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 08:52:16 -0500
Received: by py-out-1112.google.com with SMTP id u52so396421pyb.10
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 05:52:15 -0800 (PST)
In-Reply-To: <478A038B.4090900@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Timo,

Thanks for the effort you are putting on this.
I would just speak to the concepts instead of the code - hopefully that
would simulate a discussion (and shorten my email)

On Sun, 2008-13-01 at 14:26 +0200, Timo Ter=E4s wrote:
> Hi all,
>=20
> The problem with IPsec SP/SA dumping is that they don't work well wit=
h large SPD/SADB:s.=20
> In netlink the dumping code is O(n^2) and can miss some entries/dump =
duplicates if the DB=20
> is changed between the recv() calls to read the dump entries. This is=
 due to the entry=20
> index counting done in xfrm_user code. With af_key the dump entries a=
re just dropped=20
> when the socket receive queue is filled.

nod to the above

> I tried to address all these problems, and added the xfrm_policy and =
xfrm_state structure=20
> to a new linked list that is used solely for dumping. This way the du=
mps can be done in O(n)=20
> and have an iterator point to them. I also modified to af_key to stop=
 dumping when receive=20
> queue is filling up and continue it from a callback at recvfrom() whe=
n there's more room.
>=20
> This patch is against 2.6.23 vanilla. I wanted to get some feedback b=
efore I make it against=20
> the git tree.
>=20
> But I'd like to hear about:
> - if the approach is ok (adding the entries in one more list)?
> - if the new/modified variables, structures and function names are ok=
?
> - if I should port these against net-2.6 or net-2.6.25 git tree?
> - if I should split this to more than one commit? (maybe xfrm core, x=
frm user and af_key parts?)
>=20

To answer your last 2 questions:
There are two issues that are inter-mingled in there. The most importan=
t
is pf_key not being robust on dump. The other being the accurracy of
netlink dumping - this has much broader implications. I think you need
to separate the patches into those two at least and prioritize on the
pf_key as a patch that you push in. I would also try to make the pf_key
dumping approach to mirror what netlink does today - in the worst case
it would be as innacurate as netlink; which is not bad. I think youll
find no resistance getting such a patch in.

To answer your first 2 questions:

My main dilema with your approach is the policy of maintaining such a
list in the kernel and memory consumption needed vs the innacuracy of
netlink dumps. I have run a system with >400K SPD entries and >100K SAD
entries on a running system and i needed a few Gig of RAM to just make
sure my other apps dont get hit by oom at some point or other.  With
your approach of maintaining extra SA/P D, i would need double the RAM
amount. RAM is relatively cheap these days, but latency involved is not
(and one could argue that CPU cycles are much much cheaper).

Netlink dumping gives up accuracy[1], uses 50% of the memory you are
proposing but abuses more cpu cycles. User space could maintain the lis=
t
you are proposing instead - and compensate for the innaccuracies by
watching events[2]
Of course that shifts the accuracy to events which could be lost on
their way to user space. This issue is alleviated a little more with
your approach of keeping the list in the kernel and adding new updates
to the tail of the dump list (which, btw, your patch didnt seem to do);
however, even if you solve that:=20
** you are still will be faced with challenges of not being atomic on
updates; example an entry already on your dump list could be deleted
before being read by user space. I cant see you solving that without
abusing a _lot_ more cpu (trying to find the entry on the dump list tha=
t
may have gotten updated or deleted). Theres also the issue of how long
to keep the dump list before aging it out and how to deal with multiple
users.

Ok, lets say you throw in the computation in there to walk the dump lis=
t
and find the proper entry and find out it only consumes 62% cpu of what
current netlink dump approach does, you are still using twice the RAM
needs. And hence it becomes a policy choice and what would be needed is=
=20
some knob for me to select "i dont care about abusing more memory; i
want more accuracy dammit". I can tell you based on my current
experience i would rather use less RAM - but thats a matter of choice a=
t
the moment because i havent come across scenarios of the conflicts wher=
e
user space wasnt able to resolve.=20

I apologize for the long email, it would have been longer if i commente=
d
on the code.

I hope you find my comments useful and dont see them as rocks being
thrown at you - rather look at them as worth at least 2-cents Canadian
and will stimulate other people speak out.

cheers,
jamal

[1] In cases where a dump happens to not complete while SAD/SPD are
getting concurently updated, it is feasible that a dump list will have
innacurate details.

[2] Racoon for example doesnt do this, hence it needs to dump from the
kernel when purging SAs. =20

