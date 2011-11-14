From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 12:24:04 -0500
Message-ID: <20111114172404.GC27284@hmsreliant.think-freely.org>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
 <20111114114700.GA27284@hmsreliant.think-freely.org>
 <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com>
 <20111114144358.GB27284@hmsreliant.think-freely.org>
 <DBFB1B45AF80394ABD1C807E9F28D157077D7D8D5F@BLRX7MCDC203.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dave.taht@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	davem@davemloft.net
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34669 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab1KNRYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 12:24:32 -0500
Content-Disposition: inline
In-Reply-To: <DBFB1B45AF80394ABD1C807E9F28D157077D7D8D5F@BLRX7MCDC203.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 10:13:37PM +0530, Shyam_Iyer@Dell.com wrote:
>=20
>=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Neil Horman
> > Sent: Monday, November 14, 2011 9:44 AM
> > To: Dave Taht
> > Cc: netdev@vger.kernel.org; John Fastabend; Robert Love; David S.
> > Miller
> > Subject: Re: net: Add network priority cgroup
> >=20
> > On Mon, Nov 14, 2011 at 01:32:04PM +0100, Dave Taht wrote:
> > > On Mon, Nov 14, 2011 at 12:47 PM, Neil Horman <nhorman@tuxdriver.=
com>
> > wrote:
> > > > On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote:
> > > >> Data Center Bridging environments are currently somewhat limit=
ed
> > in their
> > > >> ability to provide a general mechanism for controlling traffic
> > priority.
> > > >> Specifically they are unable to administratively control the
> > priority at which
> > > >> various types of network traffic are sent.
> > > >>
> > > >> Currently, the only ways to set the priority of a network buff=
er
> > are:
> > > >>
> > > >> 1) Through the use of the SO_PRIORITY socket option
> > > >> 2) By using low level hooks, like a tc action
> > > >>
> > > >> (1) is difficult from an administrative perspective because it
> > requires that the
> > > >> application to be coded to not just assume the default priorit=
y is
> > sufficient,
> > > >> and must expose an administrative interface to allow priority
> > adjustment. =A0Such
> > > >> a solution is not scalable in a DCB environment
> > > >>
> > > >> (2) is also difficult, as it requires constant administrative
> > oversight of
> > > >> applications so as to build appropriate rules to match traffic
> > belonging to
> > > >> various classes, so that priority can be appropriately set. It=
 is
> > further
> > > >> limiting when DCB enabled hardware is in use, due to the fact =
that
> > tc rules are
> > > >> only run after a root qdisc has been selected (DCB enabled
> > hardware may reserve
> > > >> hw queues for various traffic classes and needs the priority t=
o be
> > set prior to
> > > >> selecting the root qdisc)
> > > >>
> > > >>
> > > >> I've discussed various solutions with John Fastabend, and we s=
aw a
> > cgroup as
> > > >> being a good general solution to this problem. =A0The network
> > priority cgroup
> > > >> allows for a per-interface priority map to be built per cgroup=
=2E
> > =A0Any traffic
> > > >> originating from an application in a cgroup, that does not
> > explicitly set its
> > > >> priority with SO_PRIORITY will have its priority assigned to t=
he
> > value
> > > >> designated for that group on that interface. =A0This allows a =
user
> > space daemon,
> > > >> when conducting LLDP negotiation with a DCB enabled peer to cr=
eate
> > a cgroup
> > > >> based on the APP_TLV value received and administratively assig=
n
> > applications to
> > > >> that priority using the existing cgroup utility infrastructure=
=2E
> > > >>
> > > >> Tested by John and myself, with good results
> > > >>
> > > >> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > >> CC: John Fastabend <john.r.fastabend@intel.com>
> > > >> CC: Robert Love <robert.w.love@intel.com>
> > > >> CC: "David S. Miller" <davem@davemloft.net>
> > > >> --
> > > >> To unsubscribe from this list: send the line "unsubscribe netd=
ev"
> > in
> > > >> the body of a message to majordomo@vger.kernel.org
> > > >> More majordomo info at =A0http://vger.kernel.org/majordomo-inf=
o.html
> > > >>
> > > >
> > > > Bump, any other thoughts here? =A0Dave T. has some reasonable
> > thoughts regarding
> > > > the use of skb->priority, but IMO they really seem orthogonal t=
o
> > the purpose of
> > > > this change. =A0Any other reviews would be welcome.
> > >
> > > Well, in part I've been playing catchup in the hope that lldp and
> > > openlldp and/or this dcb netlink layer that I don't know anything
> > > about (pointers please?) could help somehow to resolve the semant=
ic
> > > mess skb->priority has become in the first place.
> > >
> > > I liked what was described here.
> > >
> > > "What if we did at least carve out the DCB functionality away fro=
m
> > > skb->priority?  Since, AIUI, we're only concerning ourselves with
> > > locally generated traffic here, we're talking
> > > about skbs that have a socket attached to them.  We could, instea=
d of
> > indexing
> > > the prio_tc_map with skb->priority, we could index it with
> > > skb->dev->priomap[skb->sk->prioidx] (as provided by this patch). =
 The
> > cgroup
> > > then could be, instead of a strict priority cgroup, a queue_selec=
tor
> > cgroup (or
> > > something more appropriately named), and we don't have to touch s=
kb-
> > >priority at
> > > all.  I'd really rather not start down that road until I got more
> > opinions and
> > > consensus on that, but it seems like a pretty good solution, one =
that
> > would
> > > allow hardware queue selection in systems that use things like DC=
B to
> > co-exist
> > > with software queueing features."
> > >
> > I was initially ok with this, but the more I think about it, the mo=
re I
> > think
> > its just not needed (see further down in this email for my reasonin=
g).
> > John,
> > Rob, do you have any thoughts here?
> >=20
> > > The piece that still kind of bothered me about the original propo=
sal
> > > (and perhaps this one) was that setting SO_PRIORITY in an app mea=
ns
> > > 'give my packets more mojo'.
> > >
> > > Taking something that took unprioritized packets and assigned the=
m
> > and
> > > *them only* to a hardware queue struck me as possibly deprioritiz=
ing
> > > the 'more mojo wanted' packets in the app(s), as they would end u=
p in
> > > some other, possibly overloaded, hardware queue.
> > >
> > I don't really see what you mean by this at all.  Taking packets wi=
th
> > no
> > priority and assigning them a priority doesn't really have an effec=
t on
> > pre-prioritized packets.  Or rather it shouldn't.  You can certainl=
y
> > create a
> > problem by having apps prioritized according to conflicting semanti=
c
> > rules, but
> > that strikes me as administrative error.  Garbage in...Garbage out.
> >=20
> > > So a cgroup that moves all of the packets from an application int=
o a
> > > given hardware queue, and then gets scheduled normally according =
to
> > > skb->priority and friends (software queue, default of pfifo_fast,
> > > etc), seems to make some sense to me. (I wouldn't mind if we had
> > > abstractions for software queues, too, like, I need a software qu=
eue
> > > with these properties, find me a place for it on the hardware - b=
ut
> > > I'm dreaming)
> > >
> > > One open question is where do packets generated from other subsys=
tems
> > > end up, if you are using a cgroup for the app? arp, dns, etc?
> > >
> > The overriding rule is the association of an skb to a socket.  If a
> > transmitted
> > frame has skb->sk set in dev_queue_xmit, then we interrogate its
> > priority index
> > as set when we passed through the sendmsg code at the top of the st=
ack.
> > Otherwise its behavior is unchanged from its current standpoint.
> >=20
> > > So to rephrase your original description from this:
> > >
> > > >> Any traffic originating from an application in a cgroup, that =
does
> > not explicitly set its
> > > >> priority with SO_PRIORITY will have its priority assigned to t=
he
> > value
> > > >> designated for that group on that interface.  This allows a us=
er
> > space daemon,
> > > >> when conducting LLDP negotiation with a DCB enabled peer to cr=
eate
> > a cgroup
> > > >> based on the APP_TLV value received and administratively assig=
n
> > applications to
> > > >> that priority using the existing cgroup utility infrastructure=
=2E
> > > > John, Robert, if you're supportive of these changes, some Acks
> > would be
> > > > appreciated.
> > >
> > > To this:
> > >
> > > "Any traffic originating from an application in a cgroup,  will h=
ave
> > > its hardware queue  assigned to the value designated for that gro=
up
> > on
> > > that interface.  This allows a user space daemon, when conducting
> > LLDP
> > > negotiation with a DCB enabled peer to create a cgroup based on t=
he
> > > APP_TLV value received and administratively assign applications t=
o
> > > that hardware queue using the existing cgroup utility
> > infrastructure."
> > >
> > As above, I'm split brained about this.  I'm ok with the idea of ma=
king
> > this a
> > queue selection cgroup, and separating it from priority, but at the
> > same time,
> > in the context of DCB, we really are assigning priority here, so it
> > seems a bit
> > false to do something that is not priority.  I also like the fact t=
hat
> > it
> > provides administrative control in a way that netfilter and tc don'=
t
> > really
> > enable.
> >=20
> > > Assuming we're on the same page here, what the heck is APP_TLV?
> > >
> > LLDP does layer 2 discovery with peer networking devices. It does s=
o
> > using sets
> > of Type/length/value tuples.  The types carry various bits of
> > information, such
> > as which priority groups are available on the network.  The APP tlv
> > conveys
> > application or feature specific information.  for instance, There i=
s an
> > ISCSI
> > app tlv that tells the host that  "on the interface you received th=
is
> > tlv, iscsi
> > traffic must be sent at priority X".  The idea being that, on recei=
pt
> > of this
> > tlv, the DCB daemon can create an ISCSI network priority cgroup
> > instance, and
> > augment the cgroup rules file such that, when the user space iscsi
> > daemon is
> > started, its traffic automatically transmits at the appropriate
> > priority.
>=20
> Love this !
>=20
> I guess if this is integrated to libvirt via libcgroups VMs could be =
assigned a network priority..
>=20
As the patch stand currently, absolutely.  Just drop a qemu process int=
o the
approriate cgroup, and (assuming you're using a tun/tap type device), a=
ll the
traffic from that vm will get assigned the corresponding priority.  You=
 can do
the same thing with classification using net_cls already.  I did a vide=
o of it
here:
http://www.youtube.com/watch?v=3DKX5QV4LId_c
Neil

> http://linuxplumbersconf.org/2010/ocw/proposals/843
>=20
>=20
>=20
