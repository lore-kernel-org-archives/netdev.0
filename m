From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 1/1] xen-netfront: do not cast grant
 table reference to signed short
Date: Mon, 31 Oct 2016 01:47:56 -0600
Message-ID: <5817053C020000780011AE8F@prv-mh.provo.novell.com>
References: <1477892309-7150-1-git-send-email-dongli.zhang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <xen-devel@lists.xenproject.org>,
        <boris.ostrovsky@oracle.com>, "Juergen Gross" <JGross@suse.com>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Dongli Zhang" <dongli.zhang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:43347 "EHLO
        prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761745AbcJaHsA (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:5:2>);
        Mon, 31 Oct 2016 03:48:00 -0400
In-Reply-To: <1477892309-7150-1-git-send-email-dongli.zhang@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 31.10.16 at 06:38, <dongli.zhang@oracle.com> wrote:
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -304,7 +304,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
>  		queue->rx_skbs[id] = skb;
>  
>  		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
> -		BUG_ON((signed short)ref < 0);
> +		WARN_ON_ONCE(IS_ERR_VALUE((unsigned long)ref));

You really need to cast to plain (or signed) long here - casting to
unsigned long will work only in 32-bit configurations, as otherwise
you lose the sign of the value.

And then just issuing a warning here is insufficient, I think: Either
you follow David's line of thought assuming that no failure here is
possible at all (in which case the BUG_ON() can be ditched without
replacement), or you follow your original one (which matches mine)
that we can't exclude an error here because of a bug elsewhere,
in which case this either needs to stay BUG_ON() or should be
followed by some form of bailing out (so that the bad ref won't get
stored, preventing its later use from causing further damage).

Jan
