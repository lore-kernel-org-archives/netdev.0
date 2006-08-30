From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 7074] New: Kernel Panic on kernel 2.6.16.1
Date: Wed, 30 Aug 2006 13:24:34 +0200
Message-ID: <44F57572.5070703@trash.net>
References: <20060829203019.c642cb7b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000302080400000507070807"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37363 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750716AbWH3LYh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 07:24:37 -0400
To: eshi@anchiva.com.cn
In-Reply-To: <20060829203019.c642cb7b.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000302080400000507070807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> Obvious question: does it happen with 2.6.17.x or 2.6.18-rc5?
> 
> 
> Begin forwarded message:
> 
> Date: Tue, 29 Aug 2006 19:49:11 -0700
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 7074] New: Kernel Panic on kernel 2.6.16.1
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7074
> 
>            Summary: Kernel Panic on kernel 2.6.16.1
>     Kernel Version: 2.6.16.1
>             Status: NEW
>           Severity: high
>              Owner: laforge@gnumonks.org
>          Submitter: eshi@anchiva.com.cn
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment: P4 3.4G   1G Mem
> Software Environment: FC3 Kernel 2.6.16.1
> Problem Description: 
> 
> kernel BUG at net/ipv4/netfilter/ip_conntrack_proto_tcp.c:911!


This can only happen if something corrupts the packet, probably
within the bridge netfilter code. This patch from Stephen (rediffed
against 2.6.16) fixes such a corruption, please try if it helps.

--------------000302080400000507070807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index de4d397..56ef3cb 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -66,15 +66,25 @@ #endif
 
 /* Only used in br_forward.c */
 static inline
-void nf_bridge_maybe_copy_header(struct sk_buff *skb)
+int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
+	int err;
+
 	if (skb->nf_bridge) {
 		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			err = skb_cow(skb, 18);
+			if (err)
+				return err;
 			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
-		} else
+		} else {
+			err = skb_cow(skb, 16);
+			if (err)
+				return err;
 			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
+		}
 	}
+	return 0;
 }
 
 static inline
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 2d24fb4..dac7f06 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -37,11 +37,15 @@ int br_dev_queue_push_xmit(struct sk_buf
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
 		/* ip_refrag calls ip_fragment, doesn't copy the MAC header. */
-		nf_bridge_maybe_copy_header(skb);
+		if (nf_bridge_maybe_copy_header(skb))
+			kfree_skb(skb);
+		else
 #endif
-		skb_push(skb, ETH_HLEN);
+		{
+			skb_push(skb, ETH_HLEN);
 
-		dev_queue_xmit(skb);
+			dev_queue_xmit(skb);
+		}
 	}
 
 	return 0;

--------------000302080400000507070807--
