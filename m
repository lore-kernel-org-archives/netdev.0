From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel BUG at net/core/skbuff.c:1028!
Date: Thu, 08 May 2003 10:20:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.102010.90804594.davem@redhat.com>
References: <20030507.042003.26512841.davem@redhat.com>
	<20030508012101.36E012C01B@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, axboe@suse.de, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030508012101.36E012C01B@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Thu, 08 May 2003 11:20:27 +1000

   Yep, culprit is obvious stupid bug.  This indicates a serious lack of
   testing on my part 8(
   
   Jens, does this help?

There were two cases of the same bug, you fixed only one
instance :-)

Jens, try this patch instead.

--- net/ipv4/netfilter/ip_nat_core.c.~1~	Thu May  8 11:23:22 2003
+++ net/ipv4/netfilter/ip_nat_core.c	Thu May  8 11:25:56 2003
@@ -861,6 +861,7 @@
 	} *inside;
 	unsigned int i;
 	struct ip_nat_info *info = &conntrack->nat.info;
+	int hdrlen;
 
 	if (!skb_ip_make_writable(pskb,(*pskb)->nh.iph->ihl*4+sizeof(*inside)))
 		return 0;
@@ -868,10 +869,12 @@
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
-	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY
-	    && (u16)csum_fold(skb_checksum(*pskb, (*pskb)->nh.iph->ihl*4,
-					   (*pskb)->len, 0)))
-		return 0;
+	if ((*pskb)->ip_summed != CHECKSUM_UNNECESSARY) {
+		hdrlen = (*pskb)->nh.iph->ihl * 4;
+		if ((u16)csum_fold(skb_checksum(*pskb, hdrlen,
+						(*pskb)->len - hdrlen, 0)))
+			return 0;
+	}
 
 	/* Must be RELATED */
 	IP_NF_ASSERT((*pskb)->nfct
@@ -948,10 +951,12 @@
 	}
 	READ_UNLOCK(&ip_nat_lock);
 
+	hdrlen = (*pskb)->nh.iph->ihl * 4;
+
 	inside->icmp.checksum = 0;
-	inside->icmp.checksum = csum_fold(skb_checksum(*pskb,
-						       (*pskb)->nh.iph->ihl*4,
-						       (*pskb)->len, 0));
+	inside->icmp.checksum = csum_fold(skb_checksum(*pskb, hdrlen,
+						       (*pskb)->len - hdrlen,
+						       0));
 	return 1;
 
  unlock_fail:
