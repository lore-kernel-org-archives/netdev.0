From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled (v2)
Date: Tue, 17 Jun 2008 17:07:18 -0700 (PDT)
Message-ID: <20080617.170718.260234361.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753340AbYFRAHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 20:07:17 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 3 Jun 2008 14:52:00 -0700

> When MD5 signatures are turned on we can end up with syntactically invalid
> packets with a header length < 20 bytes. This is because tcp_header_size
> overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
> SACK option.
> 
> Since we can't fit any SACK blocks in the final 8 bytes of options space, and
> the MD5 signature is more important, we disable including SACK, or even
> advertising it, when MD5 is enabled.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

If this is the case, I think we need to simply prioritize at option
negotiation time and leave it at that.  The data paths don't need
to be modified.

The problematic case is when all 3 of tstamps, wscale, and md5 are
enabled.  To be honest, tstamps are the least valuable of the 3.  The
only way to accurately fill in gaps is to have at least some SACK
information, it is much harder to guestimate than RTTs.

So, actually, we'd need to add logic to limit the amount of SACK
blocks we report when MD5 is present, in the output packet building
code.
