From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Tue, 19 Sep 2006 13:42:43 -0500
Message-ID: <20060919184243.GL29167@austin.ibm.com>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:9377 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750834AbWISSmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 14:42:45 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8JIgimk012238
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 14:42:44 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8JIgiW4170646
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 12:42:44 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8JIghK0023419
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 12:42:44 -0600
To: Stephen Rothwell <sfr@canb.auug.org.au>
Content-Disposition: inline
In-Reply-To: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2006 at 02:54:33PM +1000, Stephen Rothwell wrote:
> 
> On powerpc and ppc, insl_ns and insl are identical as are outsl_ns and
> outsl, so remove the conditional use of insl_ns and outsl_ns.

The rest of this patch might indeed be correct, but the above comment 
bothers me. The "ns" versions of routines are supposed to be
non-byte-swapped versions of the insl/outsl routines (which would
byte-swap on big-endian archs such as powerpc.)

> diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
> index cbdae54..add6381 100644
> --- a/drivers/net/3c509.c
> +++ b/drivers/net/3c509.c
> @@ -879,11 +879,7 @@ #endif
>  	outw(skb->len, ioaddr + TX_FIFO);
>  	outw(0x00, ioaddr + TX_FIFO);
>  	/* ... and the packet rounded to a doubleword. */
> -#ifdef  __powerpc__
> -	outsl_ns(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
> -#else
>  	outsl(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
> -#endif

Dohh, a hack like this to work around some possbile byte-swapping
bug should never have been done in the first place :-(

However, I presume someone added the  __powerpc__ define here
because they picked up a 3c509 at a garage sale, stuck it in 
a powerpc, found out it didn't work due to a byte-swapping bug,
and then patched it as above. I'm disturbed that somehow 
outsl_ns() became identical to outsl() at some point, presumably
breaking this patch.

--linas

