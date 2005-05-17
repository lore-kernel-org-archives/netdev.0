From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: Interdomain/interpartition communication without a checksum
Date: Tue, 17 May 2005 11:34:20 -0500
Message-ID: <20050517163420.GA19251@us.ibm.com>
References: <20050511183554.GA28298@us.ibm.com> <20050516.130737.77060495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdmason@us.ibm.com, netdev@oss.sgi.com, niv@us.ibm.com,
        habanero@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050516.130737.77060495.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2005 at 01:07:37PM -0700, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Date: Wed, 11 May 2005 13:35:54 -0500
> 
> > I have been working on a Xen project to remove unnecessary TCP/UDP
> > checksums for local (interdomain) communication, while still having the
> > checksum for all external network communication.  
> 
> I have no objections to this idea.  But let's think about
> the implementation.

Fantastic!  

What I am attempting to do is identify the packets that have no
checksum, and checksum them (either by hardware or software).  There is
already an existing infrastructure for checksumming the packets by
using HW_CSUM.

I've been mostly looking into the bridging case, but I would
like an implimentation which works for every packet forwarding case.
Here are the problems I see (there might be more):

1. skb->h.raw is set to skb->data in netif_receive_skb() (which prevents
the forwarding/backend driver from setting it to the proper value, so it 
must be set on the output).

2. skb->ip_summed is set to CHECKSUM_NONE in both routing and bridging, 
thereby preventing the forwarding driver from setting CHECKSUM_HW.

I would prefer to set the proper values for skb->h.raw and
skb->ip_summed in the forwarding/backend driver.


> > +	/* If packet is forwarded to a device that needs a checksum and not 
> > +	 * checksummed, correct the pointers and enable checksumming in the 
> > +	 * next function.
> > +	 */
> > +	if (!(dev->features & NETIF_F_FWD_NO_CSUM) && skb->csum) {
> > +		skb->ip_summed = CHECKSUM_HW;
> > +		skb->h.raw = (void *)skb->nh.iph + (skb->nh.iph->ihl * 4);
> > +	}
> > +
> 
> This means that every packet which the networking tries to checksum
> offload will pass this test, superfluously doing these assignments.

Even worse, every packet which comes from the local system and has a
checksum already will pass this test. I hit this problem last week, 
and had to redo the implimentation.  Silly mistake on my part, and 
very obvious once I went looking for the cause of my problem.  

> It also assumes ipv4.  ipv6 is possible, and for NETIF_F_CHECKSUM_HW
> any protocol could be creating the packets as this flag indicates
> that the card implements a totally generic 16-bit two's complement
> checksum.

Yes, anything which encapsulates TCP/UDP packets is valid.  Good catch.
I'll have to look at way to fix that.

After fixing the former problem,  I came up with the code below
(with no fix for the latter problem yet).  It was created against the
2.6.11.8 kernel. 

Let me know what you think.

Thanks,
Jon

--- ../xen-unstable-pristine/linux-2.6.11-xen0/include/linux/skbuff.h	2005-03-02 01:38:38.000000000 -0600
+++ linux-2.6.11-xen0/include/linux/skbuff.h	2005-05-13 10:43:08.000000000 -0500
@@ -37,6 +37,10 @@
 #define CHECKSUM_HW 1
 #define CHECKSUM_UNNECESSARY 2
 
+#define SKB_CLONED	1
+#define SKB_NOHDR	2
+#define SKB_FDW_NO_CSUM	4
+
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
 #define SKB_MAX_ORDER(X, ORDER)	(((PAGE_SIZE << (ORDER)) - (X) - \
@@ -238,7 +242,7 @@ struct sk_buff {
 				mac_len,
 				csum;
 	unsigned char		local_df,
-				cloned,
+				flags,
 				pkt_type,
 				ip_summed;
 	__u32			priority;
@@ -370,7 +374,7 @@ static inline void kfree_skb(struct sk_b
  */
 static inline int skb_cloned(const struct sk_buff *skb)
 {
-	return skb->cloned && atomic_read(&skb_shinfo(skb)->dataref) != 1;
+	return (skb->flags & SKB_CLONED) && atomic_read(&skb_shinfo(skb)->dataref) != 1;
 }
 
 /**
--- ../xen-unstable-pristine/linux-2.6.11-xen0/net/core/skbuff.c	2005-03-02 01:38:17.000000000 -0600
+++ linux-2.6.11-xen0/net/core/skbuff.c	2005-05-13 11:47:51.000000000 -0500
@@ -240,7 +240,7 @@ static void skb_clone_fraglist(struct sk
 
 void skb_release_data(struct sk_buff *skb)
 {
-	if (!skb->cloned ||
+	if (!(skb->flags & SKB_CLONED) ||
 	    atomic_dec_and_test(&(skb_shinfo(skb)->dataref))) {
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
@@ -352,7 +352,7 @@ struct sk_buff *skb_clone(struct sk_buff
 	C(data_len);
 	C(csum);
 	C(local_df);
-	n->cloned = 1;
+	n->flags = skb->flags | SKB_CLONED;
 	C(pkt_type);
 	C(ip_summed);
 	C(priority);
@@ -395,7 +395,7 @@ struct sk_buff *skb_clone(struct sk_buff
 	C(end);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
-	skb->cloned = 1;
+	skb->flags |= SKB_CLONED;
 
 	return n;
 }
@@ -603,7 +603,7 @@ int pskb_expand_head(struct sk_buff *skb
 	skb->mac.raw += off;
 	skb->h.raw   += off;
 	skb->nh.raw  += off;
-	skb->cloned   = 0;
+	skb->flags    &= SKB_CLONED;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
 
--- ../xen-unstable-pristine/linux-2.6.11-xen0/net/core/dev.c	2005-03-02 01:38:09.000000000 -0600
+++ linux-2.6.11-xen0/net/core/dev.c	2005-05-13 11:47:01.000000000 -0500
@@ -98,6 +98,7 @@
 #include <linux/stat.h>
 #include <linux/if_bridge.h>
 #include <linux/divert.h>
+#include <net/ip.h> 
 #include <net/dst.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
@@ -1182,7 +1183,7 @@ int __skb_linearize(struct sk_buff *skb,
 	skb->data    += offset;
 
 	/* We are no longer a clone, even if we were. */
-	skb->cloned    = 0;
+	skb->flags    &= ~SKB_CLONED;
 
 	skb->tail     += skb->data_len;
 	skb->data_len  = 0;
@@ -1236,6 +1237,15 @@ int dev_queue_xmit(struct sk_buff *skb)
 	    __skb_linearize(skb, GFP_ATOMIC))
 		goto out_kfree_skb;
 
+	/* If packet is forwarded to a device that needs a checksum and not 
+	 * checksummed, correct the pointers and enable checksumming in the 
+	 * next function.
+	 */
+	if (skb->flags & SKB_FDW_NO_CSUM) {
+		skb->ip_summed = CHECKSUM_HW;
+		skb->h.raw = (void *)skb->nh.iph + (skb->nh.iph->ihl * 4);
+	}
+
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
