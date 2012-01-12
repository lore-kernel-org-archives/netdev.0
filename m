From: Ben Hutchings <bhutchings@solarflare.com>
Subject: skb_checksum_help() vs GSO
Date: Thu, 12 Jan 2012 20:42:10 +0000
Message-ID: <1326400930.2740.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31128 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755606Ab2ALUmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:42:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_checksum_help() does:

	if (unlikely(skb_shinfo(skb)->gso_size)) {
		/* Let GSO fix up the checksum. */
		goto out_set_summed;
	}
...
out_set_summed:
	skb->ip_summed = CHECKSUM_NONE;
out:
	return ret;

but skb_gso_segment() requires that skb->ip_summed == CHECKSUM_PARTIAL
and WARNs if not.  I don't think there's any case where it's valid to
call both.  Shouldn't skb_checksum_help() also WARN and return an error
code instead of muddling on?

Inspecting the callers of skb_checksum_help(), it looks like sch_netem's
'corrupt' option and xt_CHECKSUM might trigger this case.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
