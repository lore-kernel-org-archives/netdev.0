From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets
 between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 2 May 2014 15:47:09 +0100
Message-ID: <5363AFED.5080601@citrix.com>
References: <395225650.20140430124506@eikelenboom.it> <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it> <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it> <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it> <198418193.20140501213951@eikelenboom.it> <5363A508.1000602@citrix.com> <653156457.20140502160632@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------070103090602010402090701"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:47166 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaEBOrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 10:47:22 -0400
In-Reply-To: <653156457.20140502160632@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------070103090602010402090701
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 02/05/14 15:06, Sander Eikelenboom wrote:
>
> Friday, May 2, 2014, 4:00:40 PM, you wrote:
>
>>>> Let's see what that does different and if that gives an insight in what is going
>>>> wrong.
>>>
>>> The debug patch that i used is attached.
>>> Here is some of the output, skb->data_len size sometimes varies slightly as does skb->truesize (is that allowed to become > 64k ?).
>> Yes, truesize can be over 64K, as it includes the aligned size of the
>> data itself (64k max), struct skbuff and struct shared_info.
>> However my calculation for the truesize might be wrong: I count all the
>> frags as full sized pages (skb->truesize += i * PAGE_SIZE), but the last
>> page is not necessarily used entirely by that frag.
>> I had the idea that truesize should include the size of the whole page
>> as we reserved it with alloc_page for this skb, but it might not be true.
> Btw. with you "skb->>truesize -= nskb->data_len;" version truesize should
>> end up around 128k, something entirely wrong. Can you try with
> "skb->>truesize -= nskb->data_len;" in that line?
>> My repro env is underway in the meantime ...
>
> Erhmm i don't get this last part, first you entitle
> "skb->truesize -= nskb->data_len;" as being "entirely wrong" (which is probably true)
>
> Then you want me to try just that ? .. or did you mean something else ?

Sorry, I was misleading and wrong. Can you try out this scenario with 
the attached patch?

Thanks,

Zoli


--------------070103090602010402090701
Content-Type: text/x-patch; name="truesize.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="truesize.patch"

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7666540..c761910 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1365,8 +1365,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 	vif->tx_frag_overflow++;
 
 	xenvif_fill_frags(vif, nskb);
-	/* Subtract frags size, we will correct it later */
-	skb->truesize -= skb->data_len;
+	skb->truesize += nskb->len;
 	skb->len += nskb->len;
 	skb->data_len += nskb->len;
 
@@ -1379,7 +1378,6 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
 		if (!page) {
 			int j;
-			skb->truesize += skb->data_len;
 			for (j = 0; j < i; j++)
 				put_page(frags[j].page.p);
 			return -ENOMEM;
@@ -1402,7 +1400,6 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
 	       frags,
 	       i * sizeof(skb_frag_t));
 	skb_shinfo(skb)->nr_frags = i;
-	skb->truesize += i * PAGE_SIZE;
 
 	/* remove traces of mapped pages and frag_list */
 	skb_frag_list_init(skb);

--------------070103090602010402090701--
