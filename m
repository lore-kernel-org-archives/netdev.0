From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Add network priority cgroup
Date: Wed, 9 Nov 2011 16:09:43 -0500
Message-ID: <20111109210943.GA23766@hmsreliant.think-freely.org>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
 <CAA93jw7G90kGBu2JnaEdWv3J0OSPO8eg55TMrZZCWPD-pdRf_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47741 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932818Ab1KIVJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 16:09:56 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw7G90kGBu2JnaEdWv3J0OSPO8eg55TMrZZCWPD-pdRf_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 09:27:08PM +0100, Dave Taht wrote:
> On Wed, Nov 9, 2011 at 8:57 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> >
> > Data Center Bridging environments are currently somewhat limited in=
 their
> > ability to provide a general mechanism for controlling traffic prio=
rity.
>=20
>=20
>=20
> >
> > Specifically they are unable to administratively control the priori=
ty at which
> > various types of network traffic are sent.
> >
> > Currently, the only ways to set the priority of a network buffer ar=
e:
> >
> > 1) Through the use of the SO_PRIORITY socket option
> > 2) By using low level hooks, like a tc action
> >
> 2), above is a little vague.
>=20
> There are dozens of ways to control the relative priorities of networ=
k
> streams in addition to priority notably diffserv, various forms of
> fair queuing, and active queue management tecniques like RED, Blue,
> etc.
>=20
I'm referring explicitly to skb->prioroity here.  Sorry If I wasn't cle=
ar.

> The priority field within the Linux skb is used for multiple purposes
> - in addition to SO_PRIORITY it is also used for queue selection
> within tc for a variety of queuing disciplines. Certain bands are
> reserved for vlan and wireless queueing, (these features are rarely
> used)
>=20
Yes.

> Twiddling with it on one level or creating a controller for it can an=
d
> will still be messed up by attempts to sanely use it elsewhere in the
> stack.
>=20
Why?  Its not like it can't already be twiddled with via SO_PRIORITY.  =
This does
exactly the same thing, it just lets us do it via an administrative int=
erface
rather than a programatic one.  I don't disagree that the use of skb->p=
rioirty
is complex, but this doesn't add any complexity that isn't already ther=
e.  It
just gives us a general way to assign priorities for those that know ho=
w to use
it consistently, in a way that doesn't require application modification=
=2E  Thats
something that DCB needs.

> >
> > (1) is difficult from an administrative perspective because it requ=
ires that the
> > application to be coded to not just assume the default priority is =
sufficient,
> > and must expose an administrative interface to allow priority adjus=
tment. =A0Such
> > a solution is not scalable in a DCB environment
> >
>=20
> Nor any other complex environment. Or even a simple one.
Yes.

>=20
> >
> > (2) is also difficult, as it requires constant administrative overs=
ight of
> > applications so as to build appropriate rules to match traffic belo=
nging to
>=20
> Yes, your description of option 2, as simplified above, is difficult.
>=20
> However certain algorithms are intended to improve fairness between
> flows that do not require as much oversight and classification.
>=20
Yes, but DCB is orthogonal to software traffic control.  Its hardware q=
ueueing=20
based on the priority value of an skb.  As such, when a DCB enabled mul=
tiqueue
adapter selects the output queues in dev_pick_tx, it needs to have the
skb->priority value set properly.  Since we don't run any of the tc fil=
ters or
classifiers until after thats complete, we can't use those to adjust th=
e skb
priority, as the root qdisc is already selected.

> However, even when RED or a newer queue management algorithm such as
> QFQ or DRR is applied, classes of traffic exist that benefit from mor=
e
> specialized diffserv or diffserv-like behavior.
>=20
I understand, but again, DCB is orthogonal to that.  DCB is a hardware =
based
solution that steers traffic to various output queues in the NIC based =
on the
skb->priority value.  Take a look at ixgbe_select_queue for an example.

> However, the evidence for something more complex in server
> environments than simple priority management is compelling at this
> point.
>=20
> > various classes, so that priority can be appropriately set. It is f=
urther
> > limiting when DCB enabled hardware is in use, due to the fact that =
tc rules are
> > only run after a root qdisc has been selected (DCB enabled hardware=
 may reserve
> > hw queues for various traffic classes and needs the priority to be =
set prior to
> > selecting the root qdisc)
> >
>=20
> Multiple applications (somewhat) rightly set priorities according to
> their view of the world.
>=20
> background traffic and immediate traffic often set the appropriate
> diffserv bits, other traffic can do the same, and at least a few apps
> set the priority field also in the hope that that will do some good,
> and perhaps more should.
>=20
Agreed, and this patch respects that.  It only sets the priority of an =
skb that
doesn't already have its priority set.  See skb_update_prio.

>=20
> >
> > I've discussed various solutions with John Fastabend, and we saw a =
cgroup as
> > being a good general solution to this problem. =A0The network prior=
ity cgroup
>=20
> Not if you are wanting to apply queue management further down the sta=
ck!
>=20
I'm not saying you can use the two together! I understand that this sol=
ution
interferes with the use of skb->priority in various queuing disciplines=
 (just
like a program using SO_PRIORITY would), but the way those disciplines =
work is
incompatible with DCB at the moment.  You wouldn't use them all at the =
same
time.  I'd be happy to add some documentation to my patch to reflect th=
at if you
like.

> >
> > allows for a per-interface priority map to be built per cgroup. =A0=
Any traffic
> > originating from an application in a cgroup, that does not explicit=
ly set its
> > priority with SO_PRIORITY will have its priority assigned to the va=
lue
> > designated for that group on that interface.
>=20
> > This allows a user space daemon,
> > when conducting LLDP negotiation with a DCB enabled peer to create =
a cgroup
> > based on the APP_TLV value received and administratively assign app=
lications to
> > that priority using the existing cgroup utility infrastructure.
>=20
> I would like it if the many uses of the priority field were reduced t=
o
> one use per semantic grouping.
>=20
> You are adding a controller to something that is already
> ill-controlled and ill-defined, overly overloaded and both under and
> over used, to be managed in userspace by code to designed later, and
> then re-mapped once it exits a vm into another host or hardware queue
> management system which may or may not share similar assumptions.
>=20
> Don't get me wrong, I LIKE the controller idea, but think the priorit=
y
> field needs to be un-overloaded first to avoid ill-effects elsewhere
> in the users of the down-stream subsystems.
>=20
We can certainly discuss the idea of separating the various semantic us=
es of
skb->priority out, but I don't think this patch is the place to do it. =
The
DCB use case for priority already exists (it specifically uses the prio=
_tc_map
as indexed by skb->priority in __skb_tx_hash).  I'm just adding a means=
 of
controlling it more easily and reliably.=20

> > Tested by John and myself, with good results
>=20
> With what?
>=20
What else?  and ixgbe adapter and ping.  I created a test netprio cgrou=
p, assigned a
priority value to it, and did a did a cgexec -g net_prio:test ping www.=
yahoo.com
with a printk in the ixgbe tx method to valiedate that the proper queue=
 mapping
was selected.

Neil

> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: John Fastabend <john.r.fastabend@intel.com>
> > CC: Robert Love <robert.w.love@intel.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>=20
>=20
>=20
> --
> Dave T=E4ht
> SKYPE: davetaht
>=20
> http://www.bufferbloat.net
>=20
