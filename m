From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 10:20:46 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7475@saturn3.aculab.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <dev@openvswitch.org>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	"Thomas Graf" <tgraf@redhat.com>
To: "Francesco Fusco" <ffusco@redhat.com>, <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34980 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752628Ab3LJKVo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:21:44 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20831-07 for <netdev@vger.kernel.org>;
 Tue, 10 Dec 2013 10:21:43 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francesco Fusco
...
> One possible direction to achieve higher performance consists
> of replacing jhash2() with an architecture specific hash
> function pretty much like the Intel folks have proposed in
> DPDK. DPDK provides a very fast hash function that leverages
> the 32bit crc32l instruction part of the Intel SSE4.2
> instruction set.
...

IIRC the cpu can execute multiple crc32l instructions in parallel.
If you use a software lookup table to crc (say) 256 zero bytes
it should be possible to crc chunks of a large buffer in parallel.

> +#ifdef CONFIG_X86_64

Why not also i386?

> +static inline u32 ovs_flow_hash_crc_4b(u32 crc, u32 val)
> +{
> +	asm ("crc32l %[val], %[crc]\n"
> +		: [crc] "+r" (crc)
> +		: [val] "rm" (val));
> +	return crc;
> +}
> +
> +static inline u32 ovs_flow_hash_crc(const u32 *data, u32 len, u32 seed)
> +{
> +	const u32 *p32 = (const u32 *) data;
> +	u32 i, tmp = 0;
> +
> +	for (i = 0; i < len; i++)
> +		seed = ovs_flow_hash_crc_4b(*p32++, seed);

Doesn't that have the arguments if the wrong order ?
Maybe it doesn't affect the result, but the asm pattern works better
the other way around.

> +	switch (3 - ((len * 4) & 0x03)) {

This looked like an obscure way to calculate the remainder,
then I noticed the 'len *4' which means it is always 3
(no residual).

> +	case 0:
> +		tmp |= *((const u8 *) p32 + 2) << 16;
> +		/* Fallthrough */
> +	case 1:
> +		tmp |= *((const u8 *) p32 + 1) << 8;
> +		/* Fallthrough */
> +	case 2:
> +		tmp |= *((const u8 *) p32);
> +		seed = ovs_flow_hash_crc_4b(tmp, seed);
> +	default:
> +		break;
> +	}
> +
> +	return seed;
> +}
> +#endif

	David
