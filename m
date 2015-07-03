From: Thomas Graf <tgraf@suug.ch>
Subject: Summary lightweight tunnel discussion at NFWS
Date: Fri, 3 Jul 2015 12:00:23 +0200
Message-ID: <20150703100023.GH26182@pox.localdomain>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33226 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbbGCKAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:00:32 -0400
Received: by wiwl6 with SMTP id l6so221924378wiw.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:00:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
> +#ifdef CONFIG_LWTUNNEL
> +		if (fi->fib_nh->nh_lwtstate) {
> +			struct lwtunnel_state *lwtstate;
> +
> +			lwtstate = fi->fib_nh->nh_lwtstate;
> +			if (nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type))
> +				goto nla_put_failure;
> +			lwtunnel_fill_encap(skb, lwtstate);
> +		}
>  	}
> +#endif

Misplaced #endif ;-)

Other than that I managed to rebase my changes onto yours and it
looks clean.

Since we also discussed this a bit at NFWS, I'm enclosing a quick
summary:

 * Overall consensus that a lightweight flow based encapsulation
   makes sense.
 * Realization that what we actually want is stackable skb metadata
   between layers without over engineering it.
 * Consensus to avoid adding it to skb_shared_info and try to reuse
   the skb dst field.
 * New dst_metadata type similar to xfrm_dst which can carry metadata
   such as encapsulation instructions/information.
 * Can be made stackable to implement nested encapsulation if needed.
   Left out in the beginning to keep it simple.
 * Possible optimization option by putting the dst_metadata into a
   per cpu scratch buffer or stack without taking a reference and
   only force the reference & allocation when the skb is about to
   be queued. The regular fast path should never queue a skb with
   dst metadata attached.
