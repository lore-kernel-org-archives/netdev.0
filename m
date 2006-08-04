From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 04 Aug 2006 12:09:18 +0200
Message-ID: <44D31CCE.7020301@trash.net>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11984 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030329AbWHDKLL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:11:11 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804100121.GA17239@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Aug 04, 2006 at 11:27:11AM +0200, Patrick McHardy wrote:
> 
>>-static u32 esp4_get_max_size(struct xfrm_state *x, int mtu)
>>+static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
>> {
>> 	struct esp_data *esp = x->data;
>>-	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
>>+	u32 align = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
>> 
>>-	if (x->props.mode) {
>>-		mtu = ALIGN(mtu + 2, blksize);
>>-	} else {
>>-		/* The worst case. */
>>-		mtu = ALIGN(mtu + 2, 4) + blksize - 4;
>>-	}
>>-	if (esp->conf.padlen)
>>-		mtu = ALIGN(mtu, esp->conf.padlen);
>>+	if (esp->conf.padlen > align)
>>+		align = esp->conf.padlen;
>> 
>>-	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
>>+	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
>>+	mtu &= ~(align - 1);
>>+	mtu -= 2;
>>+
>>+	return mtu;
> 
> 
> I haven't actually done the math, but I don't think this can be right
> from a quick look.  The reason is that transport mode is fundamentally
> different from tunnel mode in that the IP options are not encrypted and
> therefore do not contribute to the encryption block padding.
> 
> So as the code doesn't distinguish between transport mode and tunnel
> mode, you might be producing an overestimate for transport mode.


I was wondering why the old code distinguished between transport mode
and tunnel mode, I couldn't spot anything that would be affected. I'll
look into the transport mode case again.

