From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Thu, 10 Nov 2011 01:29:00 +0100
Message-ID: <1320884940.5825.34.camel@edumazet-laptop>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
	 <1320876183.3272.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62563 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab1KJA3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 19:29:05 -0500
Received: by wwi18 with SMTP id 18so1818wwi.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 16:29:04 -0800 (PST)
In-Reply-To: <1320876183.3272.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 23:03 +0100, Eric Dumazet a =C3=A9c=
rit :

> BTW, on my bnx2x adapter, even small UDP frames use more than PAGE_SI=
ZE
> bytes :
>=20
> skb->truesize=3D4352 len=3D26 (payload only)
>=20

> I wonder if we shouldnt increase SK_MEM_QUANTUM a bit to avoid
> ping/pong...
>=20
> -#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
> +#define SK_MEM_QUANTUM ((int)PAGE_SIZE * 2)
>=20

=46ollowing patch also helps a lot, even with only two cpus (one handli=
ng
device interrupts, one running the application thread)

[PATCH net-next] bnx2x: reduce skb truesize by ~50%

bnx2x uses following formula to compute its rx_buf_sz :

dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8

Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
skb_shared_info))

=46inal allocated size for skb head on x86_64 (L1_CACHE_BYTES =3D 64,
MTU=3D1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.

Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot of
false sharing because of mem_reclaim in UDP stack.

One possible way to half truesize is to lower the need by 64 bytes (211=
2
-> 2048 bytes)

This way, skb->truesize is lower than SK_MEM_QUANTUM and we get better
performance.

(760.000 pps on a rx UDP monothread benchmark, instead of 720.000 pps)


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/=
ethernet/broadcom/bnx2x/bnx2x.h
index aec7212..ebbdc55 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1185,9 +1185,14 @@ struct bnx2x {
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
=20
-	/* Max supported alignment is 256 (8 shift) */
-#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
-					 L1_CACHE_SHIFT : 8)
+/* Max supported alignment is 256 (8 shift)
+ * It should ideally be min(L1_CACHE_SHIFT, 8)
+ * Choosing 5 (32 bytes) permits to get skb heads of 2048 bytes
+ * instead of 4096 bytes.
+ * With SLUB/SLAB allocators, data will be cache line aligned anyway.
+ */
+#define BNX2X_RX_ALIGN_SHIFT		5
+
 	/* FW use 2 Cache lines Alignment for start packet and size  */
 #define BNX2X_FW_RX_ALIGN		(2 << BNX2X_RX_ALIGN_SHIFT)
 #define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
