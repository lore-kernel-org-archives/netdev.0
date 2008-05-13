From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
 invalid state
Date: Mon, 12 May 2008 22:15:13 -0700 (PDT)
Message-ID: <20080512.221513.178144312.davem@davemloft.net>
References: <1209924962.3655.8.camel@johannes.berg>
	<1210002047.8245.31.camel@johannes.berg>
	<1210003274.8245.35.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756418AbYEMFPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 01:15:19 -0400
In-Reply-To: <1210003274.8245.35.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 05 May 2008 18:01:14 +0200

> On Mon, 2008-05-05 at 17:41 +0200, Johannes Berg wrote:
> > [23194.608077] [ccf9bba0] [c02735a0] pskb_expand_head+0x58/0x1f8 (unreliable)
> > [23194.608082] [ccf9bbc0] [c02737a4] __pskb_pull_tail+0x64/0x374
> 
> It's actually not really a false positive. What is happening is that
> __pskb_pull_tail does (follow 'eat'):
 ...
> which of course changes the true size of the skb without accounting it
> to the socket. Now, the reason this hasn't been known before is that the
> data size doesn't change because the stuff that is copied into the
> header is removed from the data_len... or something like that, I think.

FWIW, the only practical case where this can occur is for an SG+CSUM
device which cannot handle DMA'ing highmem pages, and we get such a
page via sendfile() or similar.

All other cases are extremely rare, such as the route changing
mid-connection from a device that can, to a device which cannot do
SG+CSUM.

I think we need to do some more fixups and auditing before we can
enable this pskb_expand_head() assertion, and the same goes for
your more-accurate skb_truesize_check().
