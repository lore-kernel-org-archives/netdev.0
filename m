From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xen-netfront: pull on receive skb may need to happen
 earlier
Date: Fri, 05 Jul 2013 10:32:41 +0100
Message-ID: <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	"Dion Kant" <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130704150137.GW7483@zion.uk.xensource.com>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to commit 3683243b ("xen-netfront: use __pskb_pull_tail to ensure
linear area is big enough on RX") xennet_fill_frags() may end up
filling MAX_SKB_FRAGS + 1 fragments in a receive skb, and only reduce
the fragment count subsequently via __pskb_pull_tail(). That's a
result of xennet_get_responses() allowing a maximum of one more slot to
be consumed (and intermediately transformed into a fragment) if the
head slot has a size less than or equal to RX_COPY_THRESHOLD.

Hence we need to adjust xennet_fill_frags() to pull earlier if we
reached the maximum fragment count - due to the described behavior of
xennet_get_responses() this guarantees that at least the first fragment
will get completely consumed, and hence the fragment count reduced.

In order to not needlessly call __pskb_pull_tail() twice, make the
original call conditional upon the pull target not having been reached
yet, and defer the newly added one as much as possible (an alternative
would have been to always call the function right before the call to
xennet_fill_frags(), but that would imply more frequent cases of
needing to call it twice).

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: stable@vger.kernel.org (3.6 onwards)

--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -831,6 +831,15 @@ static RING_IDX xennet_fill_frags(struct
 			RING_GET_RESPONSE(&np->rx, ++cons);
 		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
 
+		if (nr_frags == MAX_SKB_FRAGS) {
+			unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
+
+			BUG_ON(pull_to <= skb_headlen(skb));
+			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+			nr_frags = shinfo->nr_frags;
+		}
+		BUG_ON(nr_frags >= MAX_SKB_FRAGS);
+
 		__skb_fill_page_desc(skb, nr_frags,
 				     skb_frag_page(nfrag),
 				     rx->offset, rx->status);
@@ -929,7 +938,8 @@ static int handle_incoming_queue(struct 
 	while ((skb = __skb_dequeue(rxq)) != NULL) {
 		int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
 
-		__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+		if (pull_to > skb_headlen(skb))
+			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
 
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, dev);
