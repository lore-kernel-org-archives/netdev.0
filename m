From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] br2684: don't send frames on not-ready vcc
Date: Wed, 28 Nov 2012 00:51:29 +0100
Message-ID: <20121127235129.GA20080@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <1354055783.2534.18.camel@shinybook.infradead.org>
 <1354058916.2534.25.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354058916.2534.25.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 11:28:36PM +0000, David Woodhouse wrote:
> Avoid submitting patches to a vcc which is being closed. Things go badly
> wrong when the ->pop method gets later called after everything's been
> torn down.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
> On Tue, 2012-11-27 at 22:36 +0000, David Woodhouse wrote:
> > Nathan, does this help? 
> 
> I think that's necessary, but not sufficient. You'll want something like
> this too... I can now kill br2684ctl while there's a flood of outgoing
> packets, and get a handful of the printks that I had in here until a few
> seconds ago when I edited it out of the patch in my mail client... and
> no more panic.
> 
> I do also now have Krzysztof's patch 1/7 (detach protocol before closing
> vcc) but I don't think it actually matters any more. 

If you do this actually it's better to don't use patch 1/7 because
it introduces race condition that you found earlier.

> 
> --- a/net/atm/br2684.c~	2012-11-23 23:14:29.000000000 +0000
> +++ b/net/atm/br2684.c	2012-11-27 23:09:18.502403881 +0000
> @@ -249,6 +249,12 @@ static int br2684_xmit_vcc(struct sk_buf
>  	skb_debug(skb);
>  
>  	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
> +	if (test_bit(ATM_VF_RELEASED, &atmvcc->flags)
> +	    || test_bit(ATM_VF_CLOSE, &atmvcc->flags)
> +	    || !test_bit(ATM_VF_READY, &atmvcc->flags)) {
> +		dev_kfree_skb(skb);
> +		return 0;
> +	}
>  	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
>  	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
>  	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
> 

With this patch you have still theoretical race that was fixed in patches
5 and 8 in pppoatm series, but I never seen that in practice.

Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>

Krzysiek
