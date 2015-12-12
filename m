From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Fri, 11 Dec 2015 19:40:07 -0500 (EST)
Message-ID: <20151211.194007.319007965520990838.davem@davemloft.net>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
	<CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
	<1449601252.2824.101.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shannon.nelson@intel.com, kan.liang@intel.com,
	netdev@vger.kernel.org, bwh@kernel.org, jesse.brandeburg@intel.com,
	andi@firstfloor.org, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbbLLAkM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 19:40:12 -0500
In-Reply-To: <1449601252.2824.101.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 08 Dec 2015 19:00:52 +0000

> On Tue, 2015-12-08 at 10:02 -0800, Shannon Nelson wrote:
>> On Mon, Dec 7, 2015 at 8:42 PM,=A0=A0<kan.liang@intel.com> wrote:
>> > From: Kan Liang <kan.liang@intel.com>
>> >=20
>> > Intrdouce "queue" option for coalesce getting and setting.
> [...]
>> > --- a/net/core/ethtool.c
>> > +++ b/net/core/ethtool.c
>> > @@ -1123,10 +1123,16 @@ static noinline_for_stack int ethtool_get_=
coalesce(struct net_device *dev,
>> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0void __user *useraddr)
>> > =A0{
>> > =A0=A0=A0=A0=A0=A0=A0=A0struct ethtool_coalesce coalesce =3D { .cm=
d =3D ETHTOOL_GCOALESCE };
>> > +=A0=A0=A0=A0=A0=A0=A0struct ethtool_coalesce tmp =3D { .queue =3D=
 -1 };
>> >=20
>> > =A0=A0=A0=A0=A0=A0=A0=A0if (!dev->ethtool_ops->get_coalesce)
>> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EOPNOTSUPP=
;
>> >=20
>> > +=A0=A0=A0=A0=A0=A0=A0if (copy_from_user(&tmp, useraddr, sizeof(co=
alesce)))
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EFAULT;
>> > +
>> > +=A0=A0=A0=A0=A0=A0=A0coalesce.queue =3D tmp.queue;
>> > +
>>=20
>> Is this going to do what you expect when you have an older ethtool
>> program?=A0=A0It seems to me that the older ethtool program will hav=
e the
>> original coalesce struct without the new queue field, so when you do
> [...]
>=20
> Indeed, it's not safe to extend UAPI structures like this.

Agreed, and this is really very far from what I suggested.

Please, make a new ethtool command entirely, that is a container.
Name is 'ETHTOOL_PERQUEUE' or something like that.

It's base type is a structure that describes what queue the
encapsulated operation is to be applied to.

struct ethtool_per_queue_op {
	u32	queue_mask[BITS_TO_LONGS(WHATEVER)];
	u32	sub_command;
	char	data[];
};

Then sub_command can be ETHTOOL_SCOALESCE, or any other ethtool
command that might be valid to be specified on a per-queue basis.
And then at 'data' you have and array of objects, whose type is of
the sub-command's expected type, and has one entry for each bit
set in queue_mask.

If you limit this facility to only ETHTOOL_{S,G}COALESCE now, believe
me you'll regret it.
