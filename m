From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skb_pull_rcsum - Fatal exception in interrupt
Date: Wed, 15 Aug 2007 19:54:31 +0400
Message-ID: <20070815155431.GA28761@2ka.mipt.ru>
References: <18115.5803.588114.372952@wylie.me.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Alan J. Wylie" <alan@wylie.me.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45703 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762574AbXHOPye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 11:54:34 -0400
Content-Disposition: inline
In-Reply-To: <18115.5803.588114.372952@wylie.me.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan.

On Wed, Aug 15, 2007 at 04:07:23PM +0100, Alan J. Wylie (alan@wylie.me.uk) wrote:
> EIP: [<c02b6fb2>] skb_pull_rcsum+0x6d/0x71 SS:ESP 09068:c03e1ea4
> Kernel panic - not syncing: Fatal exception in interrupt

At least with this patch it should not panic.
More correct solution might be to use pskb_may_pull() or check aditional
length in llc_fixup_skb().
Actually if dmesg will show that there is something in fragments, it
should use pskb_may_pull(). The same bug exist in bridge and vlan, btw,
so it might be a solution to remove bug_on from skb_pull_rcsum() and
instead call may_pull?

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/802/psnap.c b/net/802/psnap.c
index 04ee43e..5f410e9 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -60,13 +60,24 @@ static int snap_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (proto) {
 		/* Pass the frame on. */
 		skb->transport_header += 5;
+		if (skb->len < 5 || skb->len - 5 < skb->data_len) {
+			if (net_ratelimit())
+				printk(KERN_NOTICE "Short packet: len: %u, "
+						"data_len: %u.\n",
+					skb->len, skb->data_len);
+			goto err_out;
+		}
 		skb_pull_rcsum(skb, 5);
 		rc = proto->rcvfunc(skb, dev, &snap_packet_type, orig_dev);
-	} else {
-		skb->sk = NULL;
-		kfree_skb(skb);
-		rc = 1;
 	}
+	
+	rcu_read_unlock();
+	return rc;
+
+err_out:
+	skb->sk = NULL;
+	kfree_skb(skb);
+	rc = 1;
 
 	rcu_read_unlock();
 	return rc;


-- 
	Evgeniy Polyakov
