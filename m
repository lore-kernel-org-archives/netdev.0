From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mlx4_en: fix endianness with blue frame support
Date: Tue, 18 Sep 2012 10:34:48 +0300
Message-ID: <20120918073448.GA32445@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:28649 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082Ab2IRHes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 03:34:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thadeu Lima de Souza Cascardo,

The patch c5d6136e10d6: "mlx4_en: fix endianness with blue frame 
support" from Oct 10, 2011, leads to the following warning:
drivers/net/ethernet/mellanox/mlx4/en_tx.c:720 mlx4_en_xmit()
	 warn: potential memory corrupting cast. 4 vs 2 bytes

That patch introduced a call to cpu_to_be32() and added some endian
notation.

	*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);

But it doesn't make sense because the data type is declared as u16 in
the header and we would be corrupting the next elements in the struct
which are ins_vlan and fence_size.

struct mlx4_wqe_ctrl_seg {
        __be32                  owner_opcode;
        __be16                  vlan_tag;
        u8                      ins_vlan;
        u8                      fence_size;

I guess the reason we get away with it is that the ->doorbell_qpn is
normally less that 65k. But doorbell_qpn is a u32 type so I think there
is a risk here.

regards,
dan carpenter
