From: Chris Leech <christopher.leech@intel.com>
Subject: Re: skb_padto and small fragmented transmits
Date: 06 Feb 2003 11:22:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1044559370.4620.36.camel@localhost.localdomain>
References: <BD9B60A108C4D511AAA10002A50708F20BA2AAD1@orsmsx118.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <BD9B60A108C4D511AAA10002A50708F20BA2AAD1@orsmsx118.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-02-06 at 03:58, David S. Miller wrote:

> skb_padto() only works on linear skb.

The result is always a linear skb.  Given that skb_padto() takes into
account data_len (incorrectly, but still) and skb_pad() contains a
comment about non-linear skb always having zero tailroom, it certainly
looks like these were written with the attempt to work for non-linear
buffers.

I fail to see how the statement "skb->len + skb->data_len" has any
usable meaning, or how it can be anything other than a bug.

The checksum issue I mentioned is not as clear.  I haven't looked at all
the callers of skb_copy_expand() and copy_skb_header() to see what
effect copying ip_summed in one of those calls might have elsewhere.

> And if you look at all the drivers where it is used, they
> do not enable things like scatter-gather.

So because the problem is not currently exposed, it's acceptable for the
code to be incorrect?

-- Chris


diff -aur a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2003-01-13 12:45:20.000000000 -0800
+++ b/include/linux/skbuff.h	2003-02-05 12:25:38.000000000 -0800
@@ -1102,7 +1102,7 @@
  
 static inline struct sk_buff *skb_padto(struct sk_buff *skb, unsigned int len)
 {
-	unsigned int size = skb->len + skb->data_len;
+	unsigned int size = skb->len;
 	if (likely(size >= len))
 		return skb;
 	return skb_pad(skb, len-size);
