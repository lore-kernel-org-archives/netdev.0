From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 15:02:53 +0200
Message-ID: <1349442173.21172.66.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349441509.28867.17.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349441509.28867.17.camel@sakura.staff.proxad.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 14:51 +0200, Maxime Bizon wrote:

> > New convention would be : pass number of needed bytes after current
> > tail, not after current end.
> 
> Fully agree on this
> 

Here is the proposal :

Change all occurrences of :

pskb_expand_head(skb, 0, 0, gfp)

to

pskb_realloc_head(skb, gfp)   
[ an inline calling a common function ]



And few other pskb_expand_head() calls a new function

pskb_may_expand_head(skb, nhead, ntail, gfp) 
[ an inline calling same common function ]


nhead : number of needed bytes before [data,tail] portion
         (might be already < skb_headroom(skb))

ntail : number of needed bytes after [data,tail] portion
        (might be already > skb_tailroom(skb))

For example, net/xfrm/xfrm_output.c would be like the following :

(Note how all the various ugly tests will be centralized in the common
function)

And the common function would now know the caller intent.


diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 95a338c..15760df 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -24,18 +24,10 @@ static int xfrm_output2(struct sk_buff *skb);
 static int xfrm_skb_check_space(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
-		- skb_headroom(skb);
-	int ntail = dst->dev->needed_tailroom - skb_tailroom(skb);
-
-	if (nhead <= 0) {
-		if (ntail <= 0)
-			return 0;
-		nhead = 0;
-	} else if (ntail < 0)
-		ntail = 0;
-
-	return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
+	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev);
+	int ntail = dst->dev->needed_tailroom;
+
+	return pskb_may_expand_head(skb, nhead, ntail, GFP_ATOMIC);
 }
 
 static int xfrm_output_one(struct sk_buff *skb, int err)
