From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: mlx4_en: fix endianness with blue frame support
Date: Thu, 20 Sep 2012 16:46:51 +0300
Message-ID: <CAJZOPZLAQf8K_+naaGEiNzMN5RtRiupcm+gZSHf87ez2Dp7cYA@mail.gmail.com>
References: <20120918073448.GA32445@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.co.il>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54802 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2ITNqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 09:46:52 -0400
Received: by ieak13 with SMTP id k13so3390353iea.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 06:46:52 -0700 (PDT)
In-Reply-To: <20120918073448.GA32445@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 10:34 AM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> Hello Thadeu Lima de Souza Cascardo,
>
> The patch c5d6136e10d6: "mlx4_en: fix endianness with blue frame
> support" from Oct 10, 2011, leads to the following warning:
> drivers/net/ethernet/mellanox/mlx4/en_tx.c:720 mlx4_en_xmit()
>          warn: potential memory corrupting cast. 4 vs 2 bytes
>
> That patch introduced a call to cpu_to_be32() and added some endian notation.
>         *(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
> But it doesn't make sense because the data type is declared as u16 in
> the header and we would be corrupting the next elements in the struct
> which are ins_vlan and fence_size.
>
> struct mlx4_wqe_ctrl_seg {
>         __be32                  owner_opcode;
>         __be16                  vlan_tag;
>         u8                      ins_vlan;
>         u8                      fence_size;
>
> I guess the reason we get away with it is that the ->doorbell_qpn is
> normally less that 65k. But doorbell_qpn is a u32 type so I think there is a risk here.

Dan,

QP numbers are 24 bit in size, under blue-flame setting the QP number
is written
over the "vlan_tag" field and potentially also the "ins_vlan" field of
the control segment,
we can do a little cleanup here with introducing a modified version of
the mlx4_wqe_ctrl_seg
structure over which the cast is made  under the blue-flame flow.

Or.
