From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Date: Tue, 22 Apr 2008 22:30:25 +0200
Message-ID: <200804222230.25743.tomasz@grobelny.oswiecenia.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804192242.33632.tomasz@grobelny.oswiecenia.net> <20080422173050.GC6039@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2845 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbYDVUat convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 16:30:49 -0400
In-Reply-To: <20080422173050.GC6039@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Tuesday 22 of April 2008, Gerrit Renker napisa=B3:
> | > | While we are developing in the test tree compatibility is not
> | > | important at all. But real world needs compatibility, especiall=
y if
> | > | it's not that expensive. Otherwise people will get weird behavi=
our
> | > | without any messages indicating what is wrong. And it's certain=
ly not
> | > | how code should be written. It can't be that binary package of =
VLC
> | > | (or any other streaming server) cannot use newer kernel version
> | > | because we added a new field.
> | >
> | > True, but we need to get something working first. There is no poi=
nt
> | > exporting an API which only works half.
> |
> | You can never assume that the API is feature complete. Even if it "=
works
> | half" at the beginning (which is I guess quite normal) it should be=
 easy
> | to make it "work full" without breaking compatibility when it's not
> | necessary.
>
> No I don't agree. Things that work half are worse than constant failu=
res,
> since it is never clear when they will fail next. But maybe you didn'=
t mean
> that.
>
I mean that what we are currently discussing (only priorities) is in it=
self=20
useful ("works half"). Adding more features (expiry times) would be a n=
ice=20
but non essential feature ("work full").

(a bit of reordering)
> So we can reduce this to the other question "is 32 bit enough for pri=
ority
> information".
>
That is an important question. But I'm afraid the answer is no (even th=
ough I=20
thought otherwise when writing previous mail). When we want to add pack=
et=20
expiry times we will need a field for timestamp. Which is quite big (64=
=20
bits?). But note that it is only needed for in-kernel implemetation.=20
Userspace can write this information on as low as 16 bits. This leads m=
e to=20
conclusions stated below.

> | > Semantically there is no restriction of what the u32 number repre=
sents.
> | > And it is a large space. I don't think that a larger size is requ=
ired.
> |
> | Ok, for now 32 bits are enough and I can't think of the need to use=
 more
> | bits. I wouldn't be so sure about future though. But ok, if it turn=
s up
> | that we need more space in the future then we will see, there is no=
 need
> | to worry about it now. We can indeed assume 32 bits for now.
>
> So it only remains to see whether to use a field in dccp_skb_cb, or t=
o
> use skb->priority. I think the latter has advantages, since this fiel=
d
> is only set/used for the SO_PRIORITY field (in socket(7)).
>
I think we should distingish two things:
1. How do we pass data along with each packet from userspace to kernels=
pace.
2. How do we store data in in-kernel skb for internal use.
I'm afraid there was no such separation in my patches and mixing those =
two=20
things causes a lots misunderstandings.

Ad 1. In this case we need not care about sizes etc. Clean and extensib=
le=20
interface is very important. We can also have very different priority d=
ata=20
representantion from what is later stored in skb.
Ad 2. In this case sizes do matter. We can use whichever fields we want=
=2E In=20
particular we need not keep all the data passed from userspace applicat=
ion in=20
one chunk but we can distribute it among arbitrary skb fields.

So this could look like that:
Userspace application fills in a structure:
struct dccp_packet_info {
	s8 priority; //as it is now
	u16 expire_after; //up to 65s with 1ms accuracy
}
and passes it to sendmsg(..., struct dccp_packet_info pktinfo), which p=
asses=20
it to qpolicy_push which passes it to qpolicy_prio_push which does the =
tricky=20
stuff with CMSG and does:
skb->priority=3Dpktinfo->priority;
skb->tstamp=3Dnow()+pktinfo->expire_after;
(possibly other things that could potentially store data in dccp_skb_cb=
)

This would allow us to:
1. Use existing skb fields in a clean way. I mean according to their na=
mes=20
(priority, tstamp).
2. Have a clean userspace interface not affected by internal kernel=20
implementation details.

What do you think of such decoupling?
--=20
Regards,
Tomasz Grobelny
