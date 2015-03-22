From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: arp_hash
Date: Sun, 22 Mar 2015 22:42:04 +1100
Message-ID: <20150322114204.GA5010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland@purestorage.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36252 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbbCVLmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 07:42:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

While googling I found the 2011 discussion on changing the arp_hash
function.  I must say that I'm not really impressed by the new
function that replaced jhash :)

	u32 key = *(const u32 *)pkey;
	u32 val = key ^ hash32_ptr(dev);

	return val * hash_rnd[0];

Here pkey is the IP address (controllable by the attacker).  It
gets xored with the device pointer hash, which on x86-64 looks
like (0xffffffff ^ ptr) where ptr is a 32-bit value.  As ptr
must be aligned to at least 8 bytes (I think 16 is probably required
but I haven't checked), that means the bottom three bits of ptr
are 000 and hence the bottom three bits of hash32_ptr(dev) are
always 111.

So the attacker just has to use only addresses with the bottom
3 bits set to 111 and voila, the bottom three bits of val are
always 000.  So you've just cut down your search space by a factor
of 8.  If my assumption above of the 16-byte alignment is correct
then you can cut it down by a factor of 16.

If the attacker can somehow get the pointer value of the device
then all is lost since they could set any number of the low bits
of val to zero.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
