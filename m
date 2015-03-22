From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 08:56:12 +1100
Message-ID: <20150322215612.GA8274@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33347 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbbCVV4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 17:56:15 -0400
Content-Disposition: inline
In-Reply-To: <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 05:56:21AM -0700, Eric Dumazet wrote:
> On Sun, 2015-03-22 at 22:42 +1100, Herbert Xu wrote:
> > 
> > While googling I found the 2011 discussion on changing the arp_hash
> > function.  I must say that I'm not really impressed by the new
> > function that replaced jhash :)
> > 
> > 	u32 key = *(const u32 *)pkey;
> > 	u32 val = key ^ hash32_ptr(dev);
> > 
> > 	return val * hash_rnd[0];

In fact this function is worse than I thought.  Because the IP
address is stored in big-endian, the low bits correspond to the
first octet.  So in any network smaller than a /8 everything
hashes the same value.

Try running the following program with say 4096.

If this really didn't matter why don't you guys just use a linked
list? Surely that is going to be faster than doing a multiply :)

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

typedef unsigned char u8;
typedef unsigned int u32;

static inline u32 hash32_ptr(const void *ptr)
{
        unsigned long val = (unsigned long)ptr;

        val ^= (val >> 32);
        return (u32)val;
}

static inline u32 arp_hashfn(const void *pkey, const void *dev, u32 hash_rnd)
{
        u32 key = *(const u32 *)pkey;
        u32 val = key ^ hash32_ptr(dev);

        return val * hash_rnd;
}

int main(int argc, char **argv)
{
        int i;
        union {
                void *s;
                void *t;
                u32 l;
                in_addr_t a;
        } k = { .s = 0 };
        int total;

        total = atoi(argv[1]);

        k.a = inet_addr("10.0.0.0");

        for (i = 0; i < total; i++) {
                k.l = htonl(ntohl(k.l) + 1);
                printf("%s 0x%x\n", inet_ntoa(k.a), arp_hashfn(&k, (void *)0xffff88043d760000, 12345) & (total - 1));
        }

        return 0;
}

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
