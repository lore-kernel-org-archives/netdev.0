From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Tue, 24 Jun 2008 15:58:33 -0700
Message-ID: <48617C19.3010005@broadcom.com>
References: <20080621113406.5f89ae8d.billfink@mindspring.com>
 <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20080623180439.GA18829@orion.carnet.hr>
 <20080623213657.GA26447@orion.carnet.hr>
 <48602847.1020203@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "'Bill Fink'" <billfink@mindspring.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4949 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869AbYFXW4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 18:56:53 -0400
In-Reply-To: <48602847.1020203@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> I will send Josip another patch to print more SKB fields.  I can
> even save all the SKB fields and see which other ones are modified besides
> the nr_frags.  May be that will give us a better clue.
> 
Please try this patch, which should go on top of the last debug patch.
Thanks.


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f7ecd07..52756b6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2476,6 +2476,22 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 	return cons;
 }
 
+static void
+bnx2_dump_mem(void *ptr, int size)
+{
+	u32 *p = ptr;
+	int i;
+
+	for (i = 0; i < size; i += 4) {
+		if ((i % 32) == 0)
+			printk(KERN_ALERT);
+		printk("%08x ", *p++);
+		if ((i % 32) == 28 || i == (size - 4))
+			printk("\n");
+	}
+	printk(KERN_ALERT "\n");
+}
+
 static int
 bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 {
@@ -2500,6 +2516,15 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 					  " should be %d\n",
 					  skb_shinfo(skb)->nr_frags,
 					  tx_buf->nr_frags);
+			printk(KERN_ALERT "original skb:\n");
+			bnx2_dump_mem(&bp->tx_skb_ring[sw_ring_cons],
+					sizeof(struct sk_buff));
+			bnx2_dump_mem(&bp->tx_skb_sh_ring[sw_ring_cons],
+					sizeof(struct skb_shared_info));
+			printk(KERN_ALERT "Corrupted skb:\n");
+			bnx2_dump_mem(skb, sizeof(*skb));
+			bnx2_dump_mem(skb_shinfo(skb),
+				sizeof(struct skb_shared_info));
 		}
 		/* partial BD completions possible with TSO packets */
 		if (skb_is_gso(skb)) {
@@ -5866,6 +5891,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	last_frag = skb_shinfo(skb)->nr_frags;
 
 	tx_buf->nr_frags = last_frag;
+	bp->tx_skb_ring[ring_prod] = *skb;
+	bp->tx_skb_sh_ring[ring_prod] = *skb_shinfo(skb);
 
 	for (i = 0; i < last_frag; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index aa9fa6f..91569dd 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6649,6 +6649,9 @@ struct bnx2 {
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
 
+	struct sk_buff		tx_skb_ring[TX_DESC_CNT];
+	struct skb_shared_info	tx_skb_sh_ring[TX_DESC_CNT];
+
 	/* End of fields used in the performance code paths. */
 
 	char			*name;

