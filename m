From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Sun, 12 Jun 2016 12:28:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606121141280.2021@ja.home.ssi.bg>
References: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org> <alpine.LFD.2.11.1606120230560.2087@ja.home.ssi.bg> <1465691799.3002631.634954313.3E40DB3C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48840 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752059AbcFLJ2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jun 2016 05:28:22 -0400
In-Reply-To: <1465691799.3002631.634954313.3E40DB3C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 12 Jun 2016, Hannes Frederic Sowa wrote:

> On Sun, Jun 12, 2016, at 02:09, Julian Anastasov wrote:
> > 
> > 	Well, may be the confusion comes from commit 89aef8921bfb
> > ("ipv4: Delete routing cache.") where the 'tos &= IPTOS_RT_MASK;'
> > line is lost from ip_route_input_common. I think, we should
> > add it back, so that we can properly match input routes with rules
> > that specify tos value. Old kernels didn't stored ECN bits in
> > flowi4_tos in the input path, so we should do the same.
> 
> I would love to have done that but was fearing problems with user space
> compatibility. Also IPTOS_RT_MASK is not enough for filtering, we need
> to check for the whole INET_ECN_MASK.

	I checked even 2.4.33 for reference. Nobody sets bit 1
in key->tos but using IPTOS_TOS_MASK on configuration allows
rules with 'tos 2'. I guess, in this case such rule can not be
matched. And the TOS matching was used only under
CONFIG_IP_ROUTE_TOS, so the ip rules were supposed to match only
bits 2..4, not full TOS values.

> > > +	    INET_ECN_ignore(r->tos) != INET_ECN_ignore(fl4->flowi4_tos))
> > >  		return 0;
> > 
> > 	fib4_rule_configure already rejects ECN bits in r->tos,
> > so no need to filter them again in fast path.
> 
> The problem is that IPTOS_TOS_MASK is just the masking of the 0x1 bit,
> not both ECN bits. Thi stems from the pre-DSCP time where it was
> forbidden to use bit 0x1 in TOS.

	I see, I didn't noticed it. If we decide to reject
rules with tos 2 we can break scripts. May be we should just
filter it:

	if (r->tos && ((r->tos & IPTOS_RT_MASK) != fl4->flowi4_tos))

	This will allow the hidden feature 'ip rule add tos 2' to
match properly bits2..4 == 0 :) But may be we should not spend
extra cycles in fast path for such feature. As nobody complained
for problems with 3.6+, it seems match by tos is not used often.
May be we just need to restore the missing 'tos &= IPTOS_RT_MASK;'
line?

Regards
