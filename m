From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Fri, 20 Mar 2015 21:54:21 +1100
Message-ID: <20150320105421.GA18148@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53346 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbCTKyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:54:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series of patches introduces the inlined rhashtable interface.

The idea is to make all the function pointers visible to the compiler
by providing the rhashtable_params structure explicitly to each
inline rhashtable function.  For example, instead of doing

	obj = rhashtable_lookup(ht, key);

you would now do

	obj = rhashtable_lookup_fast(ht, key, params);

Where params is the same data that you would give to rhashtable_init.
In particular, within rhashtable.c itself we would simply supply
ht->p.

So to convert users over, you simply have to make params globally
accessible, e.g., by placing it in a static const variable, which
can then be used at each inlined call site, as well as by the
rhashtable_init call.

The only ticky bit is that some users (i.e., netfilter) has a
dynamic key length.  This is dealt with by using params.key_len
in the inline functions when it is non-zero, and otherwise falling
back on ht->p.key_len.

Note that I've only tested this on one compiler, gcc 4.7.2.  So
please test this with your compilers as well and make sure that
the code is actually inlined without indirect function calls.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
