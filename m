From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Thu, 28 Jun 2007 11:45:39 +0200
Message-ID: <1183023939.4769.76.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-p9wP7CzjXM8b3POoVcba"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182986681.5155.55.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-p9wP7CzjXM8b3POoVcba
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-06-27 at 19:24 -0400, jamal wrote:
> On Tue, 2007-26-06 at 00:40 +0200, Johannes Berg wrote:
>=20
> > I wonder if we should hold off on this API until we've worked out the
> > multicast issue.
>=20
> Even if the ACPI thing goes in first, you will have to change a few
> others that are existing in-kernel that need to be changed sooner or
> later. So either way is fine.

No, the controller is the only other generic netlink multicast user
according to what I've found. :)

> heres some feedback:
> - I think you should use the same approach as we use for ops.=20
> a) i.e other than the reserved group for controller (which you seem to
> be taking care of), every other genetlink user has to explicitly
> register when they need a mcast group.=20

Alright. I think that most likely this will happen right at setup, but I
can change it.

> b) While the names may vary on a per-family basis, the Grpids should be
> unique (e.g when you run out of group ids - it would take a lot more
> allocations than there are families; 32 bit vs 16 bit for that to
> happen)

actually didn't you just say that groups don't run out at 32-bit because
the groups bitmap can be extended? You wouldn't be able to sign up for
the groups >31 at bind() time but with ioctls you can bind higher group
numbers after the fact. And the dynamic groups mean you need to bind
later anyway since you don't know the ID when you create the socket.

> c) Use a global hash table to store all the genl_multicast_groups;
> I think this (handwaving) should be searchable by i) name ii)ID and iii)
> family.=20

Yeah, makes sense, I never liked the bitmap stuff I did there.


> Add the list constructs on the struct - look at the way commands are
> done.
> We do use hash tables for global storage of families for example.

Right, with dynamic registration that's basically a given.
=20
> > +static unsigned long mcast_group_start =3D 0x3;
> > +static unsigned long *multicast_groups =3D &mcast_group_start;
> > +static unsigned long multicast_group_bits =3D BITS_PER_LONG;
>=20
> I think if you used a hash table you wont need to keep track of the
> above; maybe not - You may still need the above to keep track of which
> IDs are in use and where holes in multicast group ID space exist
> (assuming some are going to be unregistered over time etc)=20

Ah, holes are a good point. I'll think about it.

>  we use a simple scheme in the case of families; once all
> IDs are consumed we dont alloc more - in the case of mcast grps this is
> not necessary IMO i.e it doesnt matter if there is collision when you
> run out. You return errors at the moment.

Are you saying I should double-allocate groups? I really don't want that
since I plan to add permission checks on top of this.

> > --- wireless-dev.orig/include/linux/genetlink.h	2007-06-25 23:56:19.895=
732308 +0200
> > +++ wireless-dev/include/linux/genetlink.h	2007-06-26 00:33:36.78573230=
8 +0200
> > @@ -52,6 +52,9 @@ enum {
> >  	CTRL_ATTR_HDRSIZE,
> >  	CTRL_ATTR_MAXATTR,
> >  	CTRL_ATTR_OPS,
> > +	CTRL_ATTR_MCAST_GROUPS,
> > +	CTRL_ATTR_MCAST_GRP_NAME,
> > +	CTRL_ATTR_MCAST_GRP_ID,
>=20
> Dont think those last two belong in the same namespace. i.e  they should
> be a separate enum; even more the name/id pair probably belong in one
> TLV under the struct genl_multicast_group that is exported to user
> space.

Hm? Not sure I understand this. These are attributes for the generic
netlink controller messages, where else should I put them? Why give them
numbers from a different namespace because they're used inside nested
attributes?

> Overall: I think you are on the right path. Good stuff.
> I see user space doing a discovery of which groups a family belongs to
> or even doing a bind-by-name in which the underlying user-space code
> does a discovery to find the id, then does a bind to that id.

Yeah, that's what I was thinking of, although the bind-by-name needs
(family-id, group-name) and nost just group-name

johannes

--=-p9wP7CzjXM8b3POoVcba
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGg4ND/ETPhpq3jKURArmmAJ964XcRUjnnTWHtf4rMnE0y4GqY3ACdHUxo
3M93jSU4tgWgTouaEmbZc3o=
=tydY
-----END PGP SIGNATURE-----

--=-p9wP7CzjXM8b3POoVcba--

