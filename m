From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH 2/3] bnx2x: Casting page alignment
Date: Tue, 10 Mar 2009 21:48:15 -0600
Message-ID: <200903102148.15826.bjorn.helgaas@hp.com>
References: <1236595937.11030.13.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Alex Chiang" <achiang@hp.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:28117 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbZCKDtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 23:49:35 -0400
In-Reply-To: <1236595937.11030.13.camel@lb-tlvb-eliezer>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 March 2009 4:52:17 am Eilon Greenstein wrote:
> Subject: [PATCH 2/3] bnx2x: Casting page alignment
>
> Adding a proper cast to the argument of PAGE_ALIGN macro so that the output
> won't depend on its original type. Without this cast aligned value will be
> truncated to the size of the argument type.

I tested these patches (1 & 2) in the SLES11 RC5 kernel and verified
that they fix https://bugzilla.novell.com/show_bug.cgi?id=481074

However, I'm not 100% comfortable with this patch:

> diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
> index 15a5cf0..3cf2b92 100644
> --- a/drivers/net/bnx2x.h
> +++ b/drivers/net/bnx2x.h
> @@ -152,7 +152,7 @@ struct sw_rx_page {
>  #define PAGES_PER_SGE			(1 << PAGES_PER_SGE_SHIFT)
>  #define SGE_PAGE_SIZE			PAGE_SIZE
>  #define SGE_PAGE_SHIFT			PAGE_SHIFT
> -#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN(addr)
> +#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN((typeof(PAGE_SIZE))addr)

For one thing, we started with SGE_PAGE_SIZE,SHIFT,ALIGN being
exact duplicates of PAGE_SIZE,SHIFT,ALIGN, which makes me wonder
why we need the SGE_ variety.

But more importantly, the patch adds a cast in SGE_PAGE_ALIGN to
ensure that its argument doesn't get truncated in the process of
being rounded up.  This could happen anywhere, not just in bnx2x,
so my question is whether the cast should be done in PAGE_ALIGN
itself so we don't trip over this again somewhere else.

Bjorn
