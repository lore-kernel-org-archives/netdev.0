From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 09:43:58 -0500
Message-ID: <20111114144358.GB27284@hmsreliant.think-freely.org>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
 <20111114114700.GA27284@hmsreliant.think-freely.org>
 <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42385 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab1KNOoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 09:44:07 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 01:32:04PM +0100, Dave Taht wrote:
> On Mon, Nov 14, 2011 at 12:47 PM, Neil Horman <nhorman@tuxdriver.com>=
 wrote:
> > On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote:
> >> Data Center Bridging environments are currently somewhat limited i=
n their
> >> ability to provide a general mechanism for controlling traffic pri=
ority.
> >> Specifically they are unable to administratively control the prior=
ity at which
> >> various types of network traffic are sent.
> >>
> >> Currently, the only ways to set the priority of a network buffer a=
re:
> >>
> >> 1) Through the use of the SO_PRIORITY socket option
> >> 2) By using low level hooks, like a tc action
> >>
> >> (1) is difficult from an administrative perspective because it req=
uires that the
> >> application to be coded to not just assume the default priority is=
 sufficient,
> >> and must expose an administrative interface to allow priority adju=
stment. =A0Such
> >> a solution is not scalable in a DCB environment
> >>
> >> (2) is also difficult, as it requires constant administrative over=
sight of
> >> applications so as to build appropriate rules to match traffic bel=
onging to
> >> various classes, so that priority can be appropriately set. It is =
further
> >> limiting when DCB enabled hardware is in use, due to the fact that=
 tc rules are
> >> only run after a root qdisc has been selected (DCB enabled hardwar=
e may reserve
> >> hw queues for various traffic classes and needs the priority to be=
 set prior to
> >> selecting the root qdisc)
> >>
> >>
> >> I've discussed various solutions with John Fastabend, and we saw a=
 cgroup as
> >> being a good general solution to this problem. =A0The network prio=
rity cgroup
> >> allows for a per-interface priority map to be built per cgroup. =A0=
Any traffic
> >> originating from an application in a cgroup, that does not explici=
tly set its
> >> priority with SO_PRIORITY will have its priority assigned to the v=
alue
> >> designated for that group on that interface. =A0This allows a user=
 space daemon,
> >> when conducting LLDP negotiation with a DCB enabled peer to create=
 a cgroup
> >> based on the APP_TLV value received and administratively assign ap=
plications to
> >> that priority using the existing cgroup utility infrastructure.
> >>
> >> Tested by John and myself, with good results
> >>
> >> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >> CC: John Fastabend <john.r.fastabend@intel.com>
> >> CC: Robert Love <robert.w.love@intel.com>
> >> CC: "David S. Miller" <davem@davemloft.net>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
> >>
> >
> > Bump, any other thoughts here? =A0Dave T. has some reasonable thoug=
hts regarding
> > the use of skb->priority, but IMO they really seem orthogonal to th=
e purpose of
> > this change. =A0Any other reviews would be welcome.
>=20
> Well, in part I've been playing catchup in the hope that lldp and
> openlldp and/or this dcb netlink layer that I don't know anything
> about (pointers please?) could help somehow to resolve the semantic
> mess skb->priority has become in the first place.
>=20
> I liked what was described here.
>=20
> "What if we did at least carve out the DCB functionality away from
> skb->priority?  Since, AIUI, we're only concerning ourselves with
> locally generated traffic here, we're talking
> about skbs that have a socket attached to them.  We could, instead of=
 indexing
> the prio_tc_map with skb->priority, we could index it with
> skb->dev->priomap[skb->sk->prioidx] (as provided by this patch).  The=
 cgroup
> then could be, instead of a strict priority cgroup, a queue_selector =
cgroup (or
> something more appropriately named), and we don't have to touch skb->=
priority at
> all.  I'd really rather not start down that road until I got more opi=
nions and
> consensus on that, but it seems like a pretty good solution, one that=
 would
> allow hardware queue selection in systems that use things like DCB to=
 co-exist
> with software queueing features."
>=20
I was initially ok with this, but the more I think about it, the more I=
 think
its just not needed (see further down in this email for my reasoning). =
 John,
Rob, do you have any thoughts here?

> The piece that still kind of bothered me about the original proposal
> (and perhaps this one) was that setting SO_PRIORITY in an app means
> 'give my packets more mojo'.
>=20
> Taking something that took unprioritized packets and assigned them an=
d
> *them only* to a hardware queue struck me as possibly deprioritizing
> the 'more mojo wanted' packets in the app(s), as they would end up in
> some other, possibly overloaded, hardware queue.
>=20
I don't really see what you mean by this at all.  Taking packets with n=
o
priority and assigning them a priority doesn't really have an effect on
pre-prioritized packets.  Or rather it shouldn't.  You can certainly cr=
eate a
problem by having apps prioritized according to conflicting semantic ru=
les, but
that strikes me as administrative error.  Garbage in...Garbage out.

> So a cgroup that moves all of the packets from an application into a
> given hardware queue, and then gets scheduled normally according to
> skb->priority and friends (software queue, default of pfifo_fast,
> etc), seems to make some sense to me. (I wouldn't mind if we had
> abstractions for software queues, too, like, I need a software queue
> with these properties, find me a place for it on the hardware - but
> I'm dreaming)
>=20
> One open question is where do packets generated from other subsystems
> end up, if you are using a cgroup for the app? arp, dns, etc?
>=20
The overriding rule is the association of an skb to a socket.  If a tra=
nsmitted
frame has skb->sk set in dev_queue_xmit, then we interrogate its priori=
ty index
as set when we passed through the sendmsg code at the top of the stack.
Otherwise its behavior is unchanged from its current standpoint.

> So to rephrase your original description from this:
>=20
> >> Any traffic originating from an application in a cgroup, that does=
 not explicitly set its
> >> priority with SO_PRIORITY will have its priority assigned to the v=
alue
> >> designated for that group on that interface.  This allows a user s=
pace daemon,
> >> when conducting LLDP negotiation with a DCB enabled peer to create=
 a cgroup
> >> based on the APP_TLV value received and administratively assign ap=
plications to
> >> that priority using the existing cgroup utility infrastructure.
> > John, Robert, if you're supportive of these changes, some Acks woul=
d be
> > appreciated.
>=20
> To this:
>=20
> "Any traffic originating from an application in a cgroup,  will have
> its hardware queue  assigned to the value designated for that group o=
n
> that interface.  This allows a user space daemon, when conducting LLD=
P
> negotiation with a DCB enabled peer to create a cgroup based on the
> APP_TLV value received and administratively assign applications to
> that hardware queue using the existing cgroup utility infrastructure.=
"
>=20
As above, I'm split brained about this.  I'm ok with the idea of making=
 this a
queue selection cgroup, and separating it from priority, but at the sam=
e time,
in the context of DCB, we really are assigning priority here, so it see=
ms a bit
false to do something that is not priority.  I also like the fact that =
it
provides administrative control in a way that netfilter and tc don't re=
ally
enable.=20

> Assuming we're on the same page here, what the heck is APP_TLV?
>=20
LLDP does layer 2 discovery with peer networking devices. It does so us=
ing sets
of Type/length/value tuples.  The types carry various bits of informati=
on, such
as which priority groups are available on the network.  The APP tlv con=
veys
application or feature specific information.  for instance, There is an=
 ISCSI
app tlv that tells the host that  "on the interface you received this t=
lv, iscsi
traffic must be sent at priority X".  The idea being that, on receipt o=
f this
tlv, the DCB daemon can create an ISCSI network priority cgroup instanc=
e, and
augment the cgroup rules file such that, when the user space iscsi daem=
on is
started, its traffic automatically transmits at the appropriate priorit=
y.

Actually, as I sit here thinking about it, I'm less supportive of separ=
ating the
assignment of hw queue / root qdisc from priority.  I say that because =
its
really just not necessecary, at least not in a DCB environment.  In a d=
cb
environment, we use priority exclusively to select the root qdisc and t=
he
associated hardware queue.  Any software queue policing/grooming that t=
akes
place after that by definition can't make any decisions based on skb->p=
riority,
as the priority will be the same for each frame in the given parent que=
ue (since
we used skb->priority to assign the parent queue).  You can still use R=
ED or
some other queue discipline to manage queue length, but you have to und=
erstand
that priority won't be a packet-differentiating factor there.  If you m=
ade this
a separate queue selection variable, you could manipulate priority inde=
pendenty,
but it would be non-sensical, because the intent would still be to send=
 all
packets on that queue at the same priority, since thats what that hardw=
are queue
is configured for.

In the alternate, if you don't use DCB, then this cgroup becomes somewh=
at
worthless anyway, because no-one has a need to select a specific hardwa=
re queue.
If you want to categorize traffic into classes you can already use the =
net_cls
cgroup, which works quite well for bandwidth allocation, and that still=
 frees up
the skb->prioirty assignment to use as you see fit.

In the end, I think its just plain old more useful to assign priorty he=
re than
some new thing.

Neil
=20
> > John, Robert, if you're supportive of these changes, some Acks woul=
d be
> > appreciated.
>=20
>=20
> >
> >
> > Regards
> > Neil
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
> >
>=20
>=20
>=20
> --=20
> Dave T=E4ht
> SKYPE: davetaht
> US Tel: 1-239-829-5608
> FR Tel: 0638645374
> http://www.bufferbloat.net
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
