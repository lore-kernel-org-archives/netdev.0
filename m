From: KY Srinivasan <kys@microsoft.com>
Subject: RE: linux-next: manual merge of the char-misc tree with the net-next
 tree
Date: Tue, 6 Sep 2016 05:36:10 +0000
Message-ID: <DM2PR0301MB07835EA7440B54BE9B27A516A0F90@DM2PR0301MB0783.namprd03.prod.outlook.com>
References: <20160905165650.180e6c89@canb.auug.org.au>
 <20160905113353.GB27586@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>
To: Greg KH <greg@kroah.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160905113353.GB27586@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Monday, September 5, 2016 5:04 PM
> To: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Arnd Bergmann <arnd@arndb.de>; David Miller <davem@davemloft.net>;
> Networking <netdev@vger.kernel.org>; linux-next@vger.kernel.org; linux-
> kernel@vger.kernel.org; Stephen Hemminger <sthemmin@microsoft.com>;
> Vitaly Kuznetsov <vkuznets@redhat.com>; KY Srinivasan <kys@microsoft.com>
> Subject: Re: linux-next: manual merge of the char-misc tree with the net-=
next
> tree
>=20
> On Mon, Sep 05, 2016 at 04:56:50PM +1000, Stephen Rothwell wrote:
> > Hi all,
> >
> > Today's linux-next merge of the char-misc tree got a conflict in:
> >
> >   include/linux/hyperv.h
> >
> > between commit:
> >
> >   30d1de08c87d ("hv_netvsc: make inline functions static")
> >
> > from the net-next tree and commit:
> >
> >   bb08d431a914 ("Drivers: hv: ring_buffer: count on wrap around mapping=
s in
> get_next_pkt_raw()")
> >
> > from the char-misc tree.
> >
> > I fixed it up (the former moved the code modified by the latter, so the
> > below patch applies to the new location of the code) and can carry the
> > fix as necessary. This is now fixed as far as linux-next is concerned,
> > but any non trivial conflicts should be mentioned to your upstream
> > maintainer when your tree is submitted for merging.  You may also want
> > to consider cooperating with the maintainer of the conflicting tree to
> > minimise any particularly complex conflicts.
> >
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 5 Sep 2016 16:53:06 +1000
> > Subject: [PATCH] Drivers: hv: ring_buffer: merge fix up for "hv_netvsc:=
 make
> >  inline functions static"
> >
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > ---
> >  drivers/net/hyperv/netvsc.c | 32 +++++++++++---------------------
> >  1 file changed, 11 insertions(+), 21 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> > index 2a9ccc4d9e3c..026df6556068 100644
> > --- a/drivers/net/hyperv/netvsc.c
> > +++ b/drivers/net/hyperv/netvsc.c
> > @@ -42,31 +42,23 @@ static struct vmpacket_descriptor *
> >  get_next_pkt_raw(struct vmbus_channel *channel)
> >  {
> >  	struct hv_ring_buffer_info *ring_info =3D &channel->inbound;
> > -	u32 read_loc =3D ring_info->priv_read_index;
> > +	u32 priv_read_loc =3D ring_info->priv_read_index;
> >  	void *ring_buffer =3D hv_get_ring_buffer(ring_info);
> > -	struct vmpacket_descriptor *cur_desc;
> > -	u32 packetlen;
> >  	u32 dsize =3D ring_info->ring_datasize;
> > -	u32 delta =3D read_loc - ring_info->ring_buffer->read_index;
> > +	/*
> > +	 * delta is the difference between what is available to read and
> > +	 * what was already consumed in place. We commit read index after
> > +	 * the whole batch is processed.
> > +	 */
> > +	u32 delta =3D priv_read_loc >=3D ring_info->ring_buffer->read_index ?
> > +		priv_read_loc - ring_info->ring_buffer->read_index :
> > +		(dsize - ring_info->ring_buffer->read_index) + priv_read_loc;
> >  	u32 bytes_avail_toread =3D (hv_get_bytes_to_read(ring_info) - delta);
> >
> >  	if (bytes_avail_toread < sizeof(struct vmpacket_descriptor))
> >  		return NULL;
> >
> > -	if ((read_loc + sizeof(*cur_desc)) > dsize)
> > -		return NULL;
> > -
> > -	cur_desc =3D ring_buffer + read_loc;
> > -	packetlen =3D cur_desc->len8 << 3;
> > -
> > -	/*
> > -	 * If the packet under consideration is wrapping around,
> > -	 * return failure.
> > -	 */
> > -	if ((read_loc + packetlen + VMBUS_PKT_TRAILER) > (dsize - 1))
> > -		return NULL;
> > -
> > -	return cur_desc;
> > +	return ring_buffer + priv_read_loc;
> >  }
> >
> >  /*
> > @@ -78,16 +70,14 @@ static void put_pkt_raw(struct vmbus_channel
> *channel,
> >  			struct vmpacket_descriptor *desc)
> >  {
> >  	struct hv_ring_buffer_info *ring_info =3D &channel->inbound;
> > -	u32 read_loc =3D ring_info->priv_read_index;
> >  	u32 packetlen =3D desc->len8 << 3;
> >  	u32 dsize =3D ring_info->ring_datasize;
> >
> > -	BUG_ON((read_loc + packetlen + VMBUS_PKT_TRAILER) > dsize);
> > -
> >  	/*
> >  	 * Include the packet trailer.
> >  	 */
> >  	ring_info->priv_read_index +=3D packetlen + VMBUS_PKT_TRAILER;
> > +	ring_info->priv_read_index %=3D dsize;
> >  }
> >
> >  /*
>=20
> Ugh, messy.  Thanks for this.
>=20
> KY, how did this happen?
Thanks Stephen. Greg, sorry about this. We should have split Vitaly's patch=
 to avoid this inter-tree issue. Vitaly and I will work to fix this.

Regards,

K. Y=20

>=20
> greg k-h
