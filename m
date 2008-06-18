From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled (v2)
Date: Tue, 17 Jun 2008 17:45:52 -0700
Message-ID: <396556a20806171745k63bb3516s5971593ecf216bc4@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
	 <20080617.170718.260234361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:2538 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759369AbYFRApy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 20:45:54 -0400
Received: by wf-out-1314.google.com with SMTP id 27so13245wfd.4
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 17:45:52 -0700 (PDT)
In-Reply-To: <20080617.170718.260234361.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 5:07 PM, David Miller <davem@davemloft.net> wrote:
> The problematic case is when all 3 of tstamps, wscale, and md5 are
> enabled.  To be honest, tstamps are the least valuable of the 3.  The
> only way to accurately fill in gaps is to have at least some SACK
> information, it is much harder to guestimate than RTTs.

So, have a population of Linux hosts out there which will send corrupt
packets when MD5+SACK is enabled. So we want to fix that problem all
at once, hopefully.

How's this:

If we receive a SYN packet with MD5 + SACK + TS was assume that it's
from an older kernel and reply with MD5 + TS. Not including SACK means
that it won't send us corrupt packets and since we couldn't previously
do SACK with these packets anyway, we're not loosing anything.

However, by default we send MD5 + SACK. If we are talking to an old
kernel, that means that they are sending corrupt packets if they have
> 2 SACK blocks (the current logic limits them to 4 I believe).
Hopefully this is pretty rare (and, again, better than we are
currently doing). It also means that we have MD5 + SACK between new
hosts, which is optimal.

I was actually writing a patch to implement
http://tools.ietf.org/html/draft-eddy-tcp-loo-03 (Long Options), which
involved pulling all the options logic into a single function for SYN
and one more for normal packets (rather than the duplication which we
have now). I'll probably send a draft patch for comments later today
(PST).

Pulling all the options logic together makes it a lot easier to make
these changes (once we've worked the bugs out of the change
initially). Possibly I should split it from the long options stuff and
make it a separate patch. It already solves this MD5+SACK bug and
other where MD5 signatures are accounted for twice in the MSS
calculations.

Cheers,


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
