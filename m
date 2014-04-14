From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] filter: prevent nla extensions to peek beyond the
 end of the message
Date: Sun, 13 Apr 2014 23:33:15 -0400 (EDT)
Message-ID: <20140413.233315.1770347585792751275.davem@davemloft.net>
References: <1397406213-15452-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, pablo@netfilter.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbaDNDdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 23:33:17 -0400
In-Reply-To: <1397406213-15452-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 13 Apr 2014 18:23:33 +0200

> The BPF_S_ANC_NLATTR and BPF_S_ANC_NLATTR_NEST extensions fail to check
> for a minimal message length before testing the supplied offset to be
> within the bounds of the message. This allows the subtraction of the nla
> header to underflow and therefore -- as the data type is unsigned --
> allowing far to big offset and length values for the search of the
> netlink attribute.
> 
> The remainder calculation for the BPF_S_ANC_NLATTR_NEST extension is
> also wrong. It has the minuend und subtrahend mixed up, therefore

I translated the German into English here, re: und --> and :-)

> calculates a huge length value, allowing to overrun the end of the
> message while looking for the netlink attribute.
> 
> The following three BPF snippets will trigger the bugs when attached to
> a UNIX datagram socket and parsing a message with length 1, 2 or 3.
> 
>  ,-[ PoC for missing size check in BPF_S_ANC_NLATTR ]--
>  | ld	#0x87654321
>  | ldx	#42
>  | ld	#nla
>  | ret	a
>  `---
> 
>  ,-[ PoC for the same bug in BPF_S_ANC_NLATTR_NEST ]--
>  | ld	#0x87654321
>  | ldx	#42
>  | ld	#nlan
>  | ret	a
>  `---
> 
>  ,-[ PoC for wrong remainder calculation in BPF_S_ANC_NLATTR_NEST ]--
>  | ; (needs a fake netlink header at offset 0)
>  | ld	#0
>  | ldx	#42
>  | ld	#nlan
>  | ret	a
>  `---
> 
> Fix the first issue by ensuring the message length fulfills the minimal
> size constrains of a nla header. Fix the second bug by getting the math
> for the remainder calculation right.
> 
> Fixes: 4738c1db15 ("[SKFILTER]: Add SKF_ADF_NLATTR instruction")
> Fixes: d214c7537b ("filter: add SKF_AD_NLATTR_NEST to look for nested..")
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
> Backporters will find the code in question in the switch block of
> sk_run_filter().

Thanks, applied and queued up for -stable.
