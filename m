From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mlx4_en: fix endianness with blue frame support
Date: Mon, 24 Sep 2012 22:42:35 +0300
Message-ID: <20120924194235.GK13767@mwanda>
References: <20120918073448.GA32445@elgon.mountain>
 <CAJZOPZLAQf8K_+naaGEiNzMN5RtRiupcm+gZSHf87ez2Dp7cYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35179 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757570Ab2IXTnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:43:07 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZLAQf8K_+naaGEiNzMN5RtRiupcm+gZSHf87ez2Dp7cYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 04:46:51PM +0300, Or Gerlitz wrote:
> On Tue, Sep 18, 2012 at 10:34 AM, Dan Carpenter
> <dan.carpenter@oracle.com> wrote:
> > Hello Thadeu Lima de Souza Cascardo,
> >
> > The patch c5d6136e10d6: "mlx4_en: fix endianness with blue frame
> > support" from Oct 10, 2011, leads to the following warning:
> > drivers/net/ethernet/mellanox/mlx4/en_tx.c:720 mlx4_en_xmit()
> >          warn: potential memory corrupting cast. 4 vs 2 bytes
> >
> > That patch introduced a call to cpu_to_be32() and added some endian notation.
> >         *(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
> > But it doesn't make sense because the data type is declared as u16 in
> > the header and we would be corrupting the next elements in the struct
> > which are ins_vlan and fence_size.
> >
> > struct mlx4_wqe_ctrl_seg {
> >         __be32                  owner_opcode;
> >         __be16                  vlan_tag;
> >         u8                      ins_vlan;
> >         u8                      fence_size;
> >
> > I guess the reason we get away with it is that the ->doorbell_qpn is
> > normally less that 65k. But doorbell_qpn is a u32 type so I think there is a risk here.
> 
> Dan,
> 
> QP numbers are 24 bit in size, under blue-flame setting the QP number
> is written
> over the "vlan_tag" field and potentially also the "ins_vlan" field of
> the control segment,
> we can do a little cleanup here with introducing a modified version of
> the mlx4_wqe_ctrl_seg
> structure over which the cast is made  under the blue-flame flow.
> 
> Or.

Actually 24 bit big endian would mean they almost always over-write
the fence_size field.  It's the highest byte of vlan_tag which would
not be modified.

I'm not sure how this ever worked.  Something is confusing here.

regards,
dan carpenter
