From: "Leech, Christopher" <christopher.leech@intel.com>
Subject: skb_padto length wrong when nonlinear
Date: Thu, 16 Jan 2003 15:54:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BD9B60A108C4D511AAA10002A50708F207317658@orsmsx118.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The recently introduced skb_padto calculates the size of an sk_buff as
skb->len + skb->data_len.  My understanding was that the total length is in
fact skb->len, and the linear portion needs to be calculated as
skb->len - skb->data_len (as done by skb_headlen).  

It looks like skb_padto could mistakenly fail to linearize and 0-pad a
buffer
when (skb->len < len) && (skb->len + skb->data_len >= len).

I realize this is an unlikely situation, but for the sake of correctness.

- Chris Leech


diff -ur linux-2.5/include/linux/skbuff.h b/include/linux/skbuff.h
--- linux-2.5/include/linux/skbuff.h    2003-01-13 12:45:20.000000000 -0800
+++ b/include/linux/skbuff.h    2003-01-16 15:02:20.000000000 -0800
@@ -1102,7 +1102,7 @@

 static inline struct sk_buff *skb_padto(struct sk_buff *skb, unsigned int
len)
 {
-       unsigned int size = skb->len + skb->data_len;
+       unsigned int size = skb->len;
        if (likely(size >= len))
                return skb;
        return skb_pad(skb, len-size);
