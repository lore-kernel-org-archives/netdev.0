From: Matt Sealey <matt@genesi-usa.com>
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Tue, 19 Sep 2006 20:52:18 +0200
Message-ID: <45103C62.4080003@genesi-usa.com>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, akpm@osdl.org,
	ppc-dev <linuxppc-dev@ozlabs.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mithrandir.softwarenexus.net ([66.98.186.96]:33548 "EHLO
	mail.genesippc.com") by vger.kernel.org with ESMTP id S1750949AbWISSwd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 14:52:33 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060919184243.GL29167@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some northbridges and PCI bridges have "clever" byteswapping in 
hardware, maybe this is just an effect of that. In theory depending on 
the host bridge, you should pass in big endian data and have it swap or 
not swap, not pick that way in the driver, UNLESS your driver expects 
bigendian data, in which case on a bigendian platform you can tell it to 
write without swapping. Voila, two functions.

However the existance of these PCI bridges these days? I haven't seen 
one in years, and when I have nobody has ever enabled the magic swappy 
thing as it's unreliable and can't always tell how you present the data.

One wishes that there was a ntoh and hton style macro in standard use 
for PCI access.. hang on though that jsut wouldn't work would it.

-- 
Matt Sealey <matt@genesi-usa.com>
Genesi, Manager, Developer Relations

Linas Vepstas wrote:
> On Tue, Sep 19, 2006 at 02:54:33PM +1000, Stephen Rothwell wrote:
>> On powerpc and ppc, insl_ns and insl are identical as are outsl_ns and
>> outsl, so remove the conditional use of insl_ns and outsl_ns.
> 
> The rest of this patch might indeed be correct, but the above comment 
> bothers me. The "ns" versions of routines are supposed to be
> non-byte-swapped versions of the insl/outsl routines (which would
> byte-swap on big-endian archs such as powerpc.)
> 
>> diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
>> index cbdae54..add6381 100644
>> --- a/drivers/net/3c509.c
>> +++ b/drivers/net/3c509.c
>> @@ -879,11 +879,7 @@ #endif
>>  	outw(skb->len, ioaddr + TX_FIFO);
>>  	outw(0x00, ioaddr + TX_FIFO);
>>  	/* ... and the packet rounded to a doubleword. */
>> -#ifdef  __powerpc__
>> -	outsl_ns(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
>> -#else
>>  	outsl(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
>> -#endif
> 
> Dohh, a hack like this to work around some possbile byte-swapping
> bug should never have been done in the first place :-(
> 
> However, I presume someone added the  __powerpc__ define here
> because they picked up a 3c509 at a garage sale, stuck it in 
> a powerpc, found out it didn't work due to a byte-swapping bug,
> and then patched it as above. I'm disturbed that somehow 
> outsl_ns() became identical to outsl() at some point, presumably
> breaking this patch.
> 
> --linas
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
