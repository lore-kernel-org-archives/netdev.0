From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Thu, 3 May 2007 18:38:34 +0200
Message-ID: <4561c9f5d97ee3ed3d2ec661068cdd08@kernel.crashing.org>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org> <4638F0C4.2000406@freescale.com> <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org> <4638F734.2040809@freescale.com> <41B347BE-06AA-4346-BEFB-19DFB52AC533@kernel.crashing.org> <463902EB.8070401@freescale.com> <Pine.LNX.4.64.0705022109350.1690@localhost.localdomain> <463A0732.2060802@freescale.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linuxppc-dev@ozlabs.org,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-01.arcor-online.net ([151.189.21.41]:33525 "EHLO
	mail-in-01.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767498AbXECQtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 12:49:40 -0400
In-Reply-To: <463A0732.2060802@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> So what about some thing like this where we do the read only once?
>>
>> - k
>>
>> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
>> index a06d8d1..9cd7d1e 100644
>> --- a/drivers/net/gianfar.c
>> +++ b/drivers/net/gianfar.c
>> @@ -1438,31 +1438,35 @@ int gfar_clean_rx_ring(struct net_device 
>> *dev, int rx_work_limit)
>>  {
>>  	struct rxbd8 *bdp;
>>  	struct sk_buff *skb;
>> -	u16 pkt_len;
>> +	u16 pkt_len, status;
>> +	u32 bd_info;
>
>
> I suggested that on IRC yesterday, and Segher was concerned that the
> compiler might, in theory, "optimize" it into to two lhz instructions.

Yes.  The same is true of the original code btw, but since
you test only one bit there, all is fine.

> I'm rather skeptical that it would actually do so (even if it needs to
> load twice due to register pressure, why not just use lwz both times?),

Sure.  That doesn't make this code correct though.

> and there's probably many other places that would break if it did,

Most other network drivers read from an MMIO reg to see
which RX ring entries are kernel owned AFAICS.

> but I wasn't up for digging around GCC to prove otherwise.

It doesn't matter what current GCC does -- simply look
at what it is *allowed* to do instead.

If you want a 32-bit read to be atomic, you should
do the read via a (volatile u32 *).  Doing this with
a cast in the places where you need the atomic access
makes sure you don't get unnecessary rereads.

> Plus, that wouldn't synchronize the bd_info read with the buffer data 
> reads.

Yes, you still need the rmb().


Segher

