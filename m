From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 07/41: arp_tables: unfold two critical loops in
 arp_packet_match()
Date: Tue, 24 Mar 2009 22:17:17 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet> <20090324140312.31401.89168.sendpatchset@x2.localnet> <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49C94B6A.5020304@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2009-03-24 22:06, Eric Dumazet wrote:
>>> +/*
>>> + * Unfortunatly, _b and _mask are not aligned to an int (or long int)
>>> + * Some arches dont care, unrolling the loop is a win on them.
>>> + */
>>> +static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
>>> +{
>>> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>>> +	const unsigned long *a = (const unsigned long *)_a;
>>> +	const unsigned long *b = (const unsigned long *)_b;
>> 
>> I think we can at least give some help for the platforms which
>> require alignment.
>> 
>> We can, for example, assume 16-bit alignment and thus loop
>> over u16's
>
>Right. How about this incremental patch ?
>
>Thanks
>
>[PATCH] arp_tables: ifname_compare() can assume 16bit alignment
>
>Arches without efficient unaligned access can still perform a loop
>assuming 16bit alignment in ifname_compare()

Allow me some skepticism, but the code looks pretty much like a
standard memcmp.

> 	unsigned long ret = 0;
>+	const u16 *a = (const u16 *)_a;
>+	const u16 *b = (const u16 *)_b;
>+	const u16 *mask = (const u16 *)_mask;
> 	int i;
> 
>-	for (i = 0; i < IFNAMSIZ; i++)
>-		ret |= (_a[i] ^ _b[i]) & _mask[i];
>+	for (i = 0; i < IFNAMSIZ/sizeof(u16); i++)
>+		ret |= (a[i] ^ b[i]) & mask[i];
> #endif
> 	return ret;
> }
