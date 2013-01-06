From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sat, 05 Jan 2013 17:51:26 -0800
Message-ID: <1357437086.1678.5135.camel@edumazet-glaptop>
References: <20130105214958.GA19814@1wt.eu>
	 <1357427926.1678.4771.camel@edumazet-glaptop>
	 <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357436430.1678.5111.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-01-05 at 17:40 -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 02:30 +0100, Willy Tarreau wrote:
> 
> > Ah interesting because these were some of the mm patches that I had
> > tried to revert.
> 
> Hmm, or we should fix __skb_splice_bits()
> 
> I'll send a patch.
> 

Could you try the following ?

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3ab989b..c5246be 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1768,14 +1768,15 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
+	struct page *page = virt_to_page(skb->data);
+	unsigned int poff = skb->data - (unsigned char *)page_address(page);
 
 	/* map the linear part :
 	 * If skb->head_frag is set, this 'linear' part is backed by a
 	 * fragment, and if the head is not shared with any clones then
 	 * we can avoid a copy since we own the head portion of this page.
 	 */
-	if (__splice_segment(virt_to_page(skb->data),
-			     (unsigned long) skb->data & (PAGE_SIZE - 1),
+	if (__splice_segment(page, poff,
 			     skb_headlen(skb),
 			     offset, len, skb, spd,
 			     skb_head_is_locked(skb),
