From: Ralph Loader <suckfish@ihug.co.nz>
Subject: Buglet in net/pkt_cls.h pointer handling.
Date: Thu, 16 Dec 2010 21:56:27 +1300
Message-ID: <20101216215627.43f34977.suckfish@ihug.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfilter4.ihug.co.nz ([203.109.136.4]:58593 "EHLO
	mailfilter4.ihug.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab0LPJGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 04:06:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

tcf_valid_offset() in net/pkt_cls.h appears to have a couple of 
problems (obvious patch below):

(a) there is no check for overflow in the pointer arithmetic.
(b) the pointers are presumably likely to be normally valid, so the
    hint should be 'likely()' not 'unlikely()'.

The offsets used to construct the arguments to that function, e.g., as
called in net/sched/em_u32.c, I think come from user-space & in theory
could be crafted to cause an invalid pointer deref if ptr+len overflows?

Possibly the '<' and '>' in that function should be '<=' and '>='
also.  I'm not familiar enough with the data-structures to be sure.

Also a question:  in em_u32.c em_u32_match(), and in cls_u32.c
u32_classify(), we dereference pointers that have had an offset
(originally from user space) added to them.  I can't see anything that
keeps those pointers aligned.  Is that a problem on architectures that
don't support unaligned pointers, or am I missing something?

Cheers,
Ralph.


diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index dd3031a..99a2d7b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -323,7 +323,7 @@ static inline unsigned char * tcf_get_base_ptr(struct sk_buff *skb, int layer)
 static inline int tcf_valid_offset(const struct sk_buff *skb,
                                   const unsigned char *ptr, const int len)
 {
-       return unlikely((ptr + len) < skb_tail_pointer(skb) && ptr > skb->head);
+       return likely((ptr + len) < skb_tail_pointer(skb) && ptr > skb->head && ptr <= ptr + len);
 }
 
 #ifdef CONFIG_NET_CLS_IND
