From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 05:56:21 -0700
Message-ID: <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150322114204.GA5010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37023 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbCVM4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 08:56:24 -0400
Received: by igcqo1 with SMTP id qo1so19835596igc.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 05:56:23 -0700 (PDT)
In-Reply-To: <20150322114204.GA5010@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-22 at 22:42 +1100, Herbert Xu wrote:
> Hi Dave:
> 
> While googling I found the 2011 discussion on changing the arp_hash
> function.  I must say that I'm not really impressed by the new
> function that replaced jhash :)
> 
> 	u32 key = *(const u32 *)pkey;
> 	u32 val = key ^ hash32_ptr(dev);
> 
> 	return val * hash_rnd[0];
> 
> Here pkey is the IP address (controllable by the attacker).  It
> gets xored with the device pointer hash, which on x86-64 looks
> like (0xffffffff ^ ptr) where ptr is a 32-bit value.  As ptr
> must be aligned to at least 8 bytes (I think 16 is probably required
> but I haven't checked), that means the bottom three bits of ptr
> are 000 and hence the bottom three bits of hash32_ptr(dev) are
> always 111.
> 
> So the attacker just has to use only addresses with the bottom
> 3 bits set to 111 and voila, the bottom three bits of val are
> always 000.  So you've just cut down your search space by a factor
> of 8.  If my assumption above of the 16-byte alignment is correct
> then you can cut it down by a factor of 16.
> 
> If the attacker can somehow get the pointer value of the device
> then all is lost since they could set any number of the low bits
> of val to zero.

On x86_64, hash32_ptr(ptr) is not (0xffffffff ^ ptr) please look again.

Anyway, trying to avoid ARP 'attacks' is a lost battle.

Adding jhash() or whatever crypto will not fundamentally avoid the issue
there. 
