From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Mon, 01 Jun 2015 16:05:19 +0200
Message-ID: <1433167519.3505.11.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <1706098.2opyZ2hT8S@tachyon.chronox.de>
	 <1433166161.3505.7.camel@sipsolutions.net> <2141601.IbD2v8KjaT@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59093 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbbFAOFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 10:05:23 -0400
In-Reply-To: <2141601.IbD2v8KjaT@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-01 at 15:49 +0200, Stephan Mueller wrote:

> >The contents, now, that's a more interesting question. I believe it can
> >never be all zeroes, since association request frames are not
> >encrypted/protected and thus at least one byte in here must be non-zero.
> >The MAC addresses are also very likely non-zero, but technically
> >00:00:00:00:00:00 is a valid MAC address I believe.
> 
> So, even when having a malicious AP, that value is never zero? The driver of 
> the question is the following code in the patch set:
> 
> +       sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
> 
> ...
> 
> +       aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
> 
> ...
> 
>         crypto_aead_encrypt(aead_req);
> 
> 
> When I played around with the aead_request_set_crypt, I saw a crash in the 
> scatterlist handling of the crypto API when the first SGL entry has a zero 
> length.

Wait, I guess that's a *third* way for this to be "zero" a valid pointer
but zero length data?

Oh, no - you're referring to the CCM/GCM cases only, I guess, i.e. this
part:

-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));

I was looking at GMAC and that has a constant for the length :-)

Ok - here the length is kinda passed a part of the AAD buffer, but this
is really just some arcane code that should be fixed to use a proper
struct. The value there, even though it is __be16 and looks like it came
from the data, is actually created locally, see ccmp_special_blocks()
and gcmp_special_blocks().

johannes
