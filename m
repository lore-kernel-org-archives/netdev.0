From: Stefan Berger <stefanb@us.ibm.com>
Subject: Re: [RFC][net-next-2.6 PATCH 0/2] rtnetlink: New =?utf-8?b?SUZMQV9QT1JUX1BST1RPXyo=?= attr
Date: Sun, 12 Dec 2010 03:16:16 +0000 (UTC)
Message-ID: <loom.20101212T041052-354@post.gmane.org>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com> <loom.20101209T141255-700@post.gmane.org> <184D23435BECB444AB6B9D4630C8EC83BD7230@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:43831 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854Ab0LLDQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Dec 2010 22:16:34 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PRcQJ-00076Q-Ql
	for netdev@vger.kernel.org; Sun, 12 Dec 2010 04:16:32 +0100
Received: from pool-74-101-125-124.nycmny.fios.verizon.net ([74.101.125.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 04:16:31 +0100
Received: from stefanb by pool-74-101-125-124.nycmny.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 04:16:31 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Christian Benvenuti (benve)" <benve@cisco.com> wrote on 12/11/2010 07:=
53:44 PM:

[posting via we page since my mail program puts html into the message]

>=20
> (*)
>=20

>=20
> >> So what you are saying is that libvirt should use #ifdef to=20
> >> distinguish between
> >>=20
> >>    if_link.h/pre_new_attributes
> >> and=20
> >>    if_link.h/new_attributes?=20
> >
> > Yes. It looks like you'll have to determine the availability in the=
=20
> > configure script and introduce a new #define there.
>=20
> (*2)
>=20
> I suppose that based on my comment (*) above, this should not be
> necessary because any kernel supported as of today will continue to
> work exactly the same way.
>=20

What I meant is that the user-level code (i.e., libvirt) with your new
attributes will only compile on a system that has their names in the
if_link.h. So, users that compile libvirt with a kernel that doesn't ha=
ve
these new attributes in if_link.h should still be able to compile the
macvtap.c there, but will of course only get support for the old attrib=
utes,
which at least seem to be in working condition  for 802.1Qbg. User who
compile libvirt with a new kernel should then get the support for the o=
ld
attributes and the new attributes compiled in. To cover these cases you=
'd
have to isolate the code dealing with the new attributes with for examp=
le

#ifdef NEW_8021QBGH_ATTRIBUTES=20
[...]=20

#endif=20

where the #define NEW_8021QBGH_ATTRIBUTES would be set through=20
libvirt's configure script that determines it by test-compiling a progr=
am=20
using one of the new attributes and set the #define if one of the new=20
attributes was found to be available.. Ideally your CLUSTER_UUID suppor=
t
would not come too long after the first batch of new attributes, but wo=
uld
be 'covered' with the NEW_8021QBGH_ATTRIBUTES. Along those lines, I hop=
e you
won't have to introduce a VERY_NEW_8021QBGH_ATTRIBUTES #define to cover
anything coming even later.

=20
> >> I guess this would be something similar to what=20
> >> doPortProfileOp8021Qbg (in src/util/macvtap.c) does by checking fo=
r=20
> >> IFLA_VF_PORT_MAX in order to distinguish between=20
> >> 8021Qbh/pre_port_profile and 8021Qbh/post_port_profile.
> >> Is it correct?=20
> >
> > Yes. If you provided the code for 802.1Qbh that'd be great.=20
>=20
> Based on my comment (*2) above we should not need to add any new #ifd=
ef.
>=20
> >> Is this #ifdef based approach the right way to keep track of the
> >> if_link.h/IFLA_PORT_* changes?=20
> >
> >If there's a better way of doing this, let me know. The problem is=20
> >people compiling libvirt may have all kinds of different levels of=20
> >systems, without even macvtap, then with macvtap but without the fir=
st=20
> >set of attributes for port profiles etc. - The progress in the kerne=
l=20
> >is reflected in the code with these #ifdefs... not nice, but I
> > doubt there's a better way of doing this.
>=20
> Well, =E2=80=9Cversioning=E2=80=9D is not a default feature in (RT)Ne=
tlink, and other
> proposals (in slightly different contexts) got rejected in the past.
> (see for example: http://www.spinics.net/lists/netdev/msg127715.html)
>=20
> Since we are changing the attribute scheme, this could be the right
> moment to add versioning to the IFLA_PORT_* attributes group.
> We can consider the current one as being version 1 (or 0) and from
> now on increment the version by 1 each time we apply some changes to
> the IFLA_PORT_* attributes.
> The most likely changes that may take place would be the introduction
> of new attributes (the BH/BG protocols are still evolving).
> This is not the way Netlink is used normally (see Miller's comment
> in the URL I provided above), but it would make libvirt code much
> easier to update and we would not need to populate it with #ifdefs.=20

The thing is that you may have users compiling an application, i.e.,
libvirt, on systems with different versions of the kernel, and with
that the if_link.h, and those users may want to be able to follow the
application source tree and not necessarily the linux tree. After
updating the application source tree they should still get working
802.1Qbg/h support. So requirements on the underlying kernel shouldn't
just 'move'.

I wouldn't like it if I updated my libvirt tree and all of a sudden the
802.1Qbg/h support wouldn't work anymore, due to requirements for new
attributes in libvirt's macvtap.c, after a re-compile of libvirt. From
a libvirt programmer perspective *all* the attributes would *ideally*
appear from one kernel version to the other. So if one kernel version
provides working support for 802.1Qbg/h I would want to be able to foll=
ow the
libvirt tree without having to upgrade the kernel. So that's why I am
proposing the #ifdef's around nearly each step of new attributes being =
added
in the if_link.h, assuming that at each step the technology was working
and new attributes only make it work 'better' than before.

>=20
> The presence of the version would not be an excuse to be allowed to
> make bad changes to the attributes knowing that you can fix them
> later with a newer version (I agree with Miller's comment), but
> simply to help consumers (ie libvirt in this case) to determine
> what level of if_link.h/IFLA_PORT_* they are dealing with, at
> run/time (the idea is that of offering a GET for that version number)=
=2E=20

It's fine by me if we end up sending a message containing old and
new attributes. For dealing with the responses we will have to start
looking for the newest attributes first, then go backwards towards the
first ones. Knowing the version of the supported attributes we could
invoke specific code for the attributes that are expected to be support=
ed.
So I think knowing the version would be advantageous in interpreting
the responses from the kernel.

Nevertheless I would go through the complication of #ifdef'ing
each new major step of new attributes in the libvirt code...

>=20
> Right now (RT)Netlink silently ignores the attributes it does not
> understand (ie, type > maxtype), therefore there are no other
> mechanisms for determining at run-time what version of the attribute
> list the kernel/recipient understands.=20
>=20
> >> We may need to change if_link.h again, for example to add new
> >> IFLA_PORT_* attributes.
> >> Does it mean that in libvirt we will have to add an #ifdef each ti=
me?=20
> >
> >I think so, yes. And since they are enums (rather than #define's=20
> >themselves) you'll have to introduce the #define's name and probe fo=
r=20
> >it by trying to compiling something with it in the configure script.
>=20
> If this is the only option, we can go for that. No problem. We will
> submit the libvirt patches.
>=20
> If however the versioning scheme was accepted, the libvirt code would
> be cleaner and easier to maintain.=20

I agree.=20

> Before to discard this option I would like someone on netdev to
> comment on that.
> Dave, can you confirm us that versioning the IFLA_PORT_* attributes
> (not the all if_link.h header) is not an option?
> >
> >802.1Qbh support has been in libvirt for quite a while. I assume it=20
> >worked without the CLUSTER_UUID attribute that you are introducing o=
nly=20
> >now. I have no 802.1Qbh hardware to verify this, though.
>=20
> Yes, it worked because so far port profiles were global. Now we would
> like to use the concept of CLUSTER_UUID (already in use by most VMM)
> to scope port profiles. This way we can limit the scope of a port
> profile to those hosts belonging to a given cluster.
>=20
> The main purpose of the kernel patches we submitted was to cleanup
> the attribute scheme used for BH/BG, and at the same time make it
> easier to add new attributes if/when needed.
> However, this should not come at the cost of making libvirt support
> a nightmare (#ifdef, etc).=20

The complication comes through *following* an evolving standard rather
than having the *ideal* case where we go from darkness to light from on=
e
kernel version to another -- or make support for the new technology
only public once it's done.

> To me it looks like
>=20
> (1) sending both legacy and new attributes
>  +=20
> (2) using a versioning scheme for the IFLA_PORT_* attributes
>=20
> make it easy/clean for libvirt to adapt to the underlying kernel
> version (ie, if_link.h/IFLA_PORT_* version).
>=20
> - Because of (1) above we are not breaking any current user of the
>   IFLA_PORT_* attributes.
>=20
> - (2) above is optional but it would make updating libvirt easier.
>=20
> Again, if #ifdef is the only option, we will stick to it.=20

Ok.

>=20
> Do you have any comment on the optional attribute IFLA_PORT_DATA
> I proposed in PATCH 0/2 section 8 (at the end of the post)?=20

To quote from there:

"This attribute would allow the use of extra attributes that are not pa=
rt of
the official protocol specs (802.1Qbg/bh for now) or simply allow devic=
e
drivers to start supporting pre-standard parameters that would not be i=
ncluded
in the Netlink scheme before they reach some stability."

Hm, does this sound like an 'experimental' attribute that can change ov=
er time
('some stability')? I hope not, because otherwise you may have mismatch=
es
between what libvirt assumes it needs to pass versus what the evolving =
device
driver expects. If so, we would have to go as far as determining the ve=
rsion of
the device driver to match up libvirt code against it (?).=20

  Regards=20
     Stefan=20

>=20
> Thanks
> /Christian
>=20


