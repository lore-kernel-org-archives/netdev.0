From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: fix xmit recursion detection on ppp channels
Date: Tue, 8 Aug 2017 15:58:27 +0200
Message-ID: <20170808135827.oszy6ikqi2gw5cs7@alphalink.fr>
References: <e45ed6ea02e2665ec8b868279ad9afcb9b34fc81.1502185216.git.g.nault@alphalink.fr>
 <5a62fd3f.e0c3.15dc1fd5f1b.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Liu Jianying <jianying.liu@ikuai8.com>,
        David Miller <davem@davemloft.net>, linux-ppp@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5a62fd3f.e0c3.15dc1fd5f1b.Coremail.gfree.wind@vip.163.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2017 at 09:16:33PM +0800, Gao Feng wrote:
> At 2017-08-08 17:43:24, "Guillaume Nault" <g.nault@alphalink.fr> wrote:
> >--- a/drivers/net/ppp/ppp_generic.c
> >+++ b/drivers/net/ppp/ppp_generic.c
> >@@ -1915,21 +1915,23 @@ static void __ppp_channel_push(struct channel *pch)
> > 	spin_unlock(&pch->downl);
> > 	/* see if there is anything from the attached unit to be sent */
> > 	if (skb_queue_empty(&pch->file.xq)) {
> >-		read_lock(&pch->upl);
> > 		ppp = pch->ppp;
> > 		if (ppp)
> >-			ppp_xmit_process(ppp);
> >-		read_unlock(&pch->upl);
> >+			__ppp_xmit_process(ppp);
> > 	}
> > }
> > 
> > static void ppp_channel_push(struct channel *pch)
> > {
> >-	local_bh_disable();
> >-
> >-	__ppp_channel_push(pch);
> >-
> >-	local_bh_enable();
> >+	read_lock_bh(&pch->upl);
> >+	if (pch->ppp) {
> >+		(*this_cpu_ptr(pch->ppp->xmit_recursion))++;
> >+		__ppp_channel_push(pch);
> >+		(*this_cpu_ptr(pch->ppp->xmit_recursion))--;
> >+	} else {
> >+		__ppp_channel_push(pch);
> >+	}
> >+	read_unlock_bh(&pch->upl);
> 
> If invoked read_lock_bh in ppp_channel_push, it would be unnecessary to invoke read_lock(&pch->upl)
> in the __ppp_channel_push.
> 
But this patch does remove read_lock(&pch->upl) from
__ppp_channel_push(). Or have I misunderstood your point?
