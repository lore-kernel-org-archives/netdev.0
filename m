From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] sha512: make it work, undo percpu message schedule
Date: Sun, 15 Jan 2012 12:43:04 +1100
Message-ID: <20120115014303.GA27370@gondor.apana.org.au>
References: <20120111003611.GA12257@gondor.apana.org.au> <20120112235514.GA5065@p183.telecom.by> <20120113070813.GA20068@gondor.apana.org.au> <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com> <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120114182024.GA4207@p183.telecom.by> <20120114182737.GB4207@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, security@kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120114182737.GB4207@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 09:27:37PM +0300, Alexey Dobriyan wrote:
> commit f9e2bca6c22d75a289a349f869701214d63b5060
> aka "crypto: sha512 - Move message schedule W[80] to static percpu area"
> created global message schedule area.
> 
> If sha512_update will ever be entered twice, hash will be silently
> calculated incorrectly.
> 
> Probably the easiest way to notice incorrect hashes being calculated is
> to run 2 ping floods over AH with hmac(sha512):
> 
> 	#!/usr/sbin/setkey -f
> 	flush;
> 	spdflush;
> 	add IP1 IP2 ah 25 -A hmac-sha512 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025;
> 	add IP2 IP1 ah 52 -A hmac-sha512 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052;
> 	spdadd IP1 IP2 any -P out ipsec ah/transport//require;
> 	spdadd IP2 IP1 any -P in  ipsec ah/transport//require;
> 
> XfrmInStateProtoError will start ticking with -EBADMSG being returned
> from ah_input(). This never happens with, say, hmac(sha1).
> 
> With patch applied (on BOTH sides), XfrmInStateProtoError does not tick
> with multiple bidirectional ping flood streams like it doesn't tick
> with SHA-1.
> 
> After this patch sha512_transform() will start using ~750 bytes of stack on x86_64.
> This is OK for simple loads, for something more heavy, stack reduction will be done
> separatedly.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: stable@vger.kernel.org

OK, I've applied patches 1-2 to crypto and patch 3 to cryptodev.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
