From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Performance problem with bond interface
Date: Mon, 21 Apr 2014 07:23:04 -0700 (PDT)
Message-ID: <5e9e32bb-b60e-44d1-82be-28c4d6ec82d5@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	Rama Nichanamatlu <rama.nichanamatlu@oracle.com>,
	Sergey Linetskiy <sergey.linetskiy@oracle.com>,
	Vadim Makhervaks <vadim.makhervaks@oracle.com>,
	Guangyu Sun <guangyu.sun@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26530 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaDUOXH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 10:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We see a performance problem when the slaves of the bond=20
don't support checksum offload features. What we see is
tcp_sendmsg's skb_add_data_nocache ending up not using the
csum_and_copy_from_user which would have computed the
checksum while copying from user buffer to kernel buffer.
Instead it computes later in dev_hard_start_xmit when it
figures out the slave doesn't support checksum offload and
ends up expensive .=20

The bonding interface's "features" has =A0NETIF_F_HW_CSUM=20
(or NETIF_F_NO_CSUM in 2.6.39) set which makes the=20
stack think checksum need not be computed in software.
/*
* Check whether we can use HW checksum.
*/
if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
=A0=A0=A0=A0 skb->ip_summed =3D CHECKSUM_PARTIAL;

But later in dev_hard_start_xmit it finds out the slave does not
support checksumming and decides to compute in software.

/* If packet is not checksummed and device does not
* support checksumming for this protocol, complete
* checksumming here.
*/
if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
=A0=A0=A0=A0=A0=A0 =A0=A0skb_set_transport_header(skb,
=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0skb_checksum_start_offset(skb))=
;
=A0=A0=A0=A0=A0=A0=A0=A0if (!(features & NETIF_F_ALL_CSUM) &&
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0skb_checksum_help(skb))
=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0goto out_kfree_skb;
}

We see this problem after this commit:
commit 1742f183fc218798dab6fcf0ded25b6608fc0a48
Author: Micha=C5<82> Miros=C5<82>aw <mirq-linux@rere.qmqm.pl>
Date:=A0=A0 Fri Apr 22 06:31:16 2011 +0000

=A0=A0=A0 net: fix netdev_increment_features()

=A0=A0=A0 Simplify and fix netdev_increment_features() to conform to wh=
at is
=A0=A0=A0 stated in netdevice.h comments about NETIF_F_ONE_FOR_ALL.
=A0=A0=A0 Include FCoE segmentation and VLAN-challedged flags in comput=
ation.

=A0=A0=A0 Signed-off-by: Micha=C5<82> Miros=C5<82>aw <mirq-linux@rere.q=
mqm.pl>
=A0=A0=A0 Signed-off-by: David S. Miller <davem@davemloft.net>

Prior to that the below code in netdev_increment_features was helping i=
n
turning off NETIF_F_NO_CSUM on bond when the slaves don't support it:=20
/* If device needs checksumming, downgrade to it. */
if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
=A0=A0=A0=A0=A0=A0=A0 all ^=3D NETIF_F_NO_CSUM | (one & NETIF_F_ALL_CSU=
M);

The slaves are Mellanox IB adapters. This is on x86_64 platform.

Please let us know if you need any additional information.

Thanks.

Venkat
