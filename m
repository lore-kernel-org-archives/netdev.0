From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] xfrm ip6ip6
Date: Sun, 01 Jun 2003 01:30:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030601.013040.116362760.davem@redhat.com>
References: <87fzmv5ejc.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <87fzmv5ejc.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Sun, 01 Jun 2003 00:20:07 +0900

Hello Mitsuru-san!

   +	t->id.spi = xfrm6_tunnel_addr_hash((xfrm_address_t *)&x->props.saddr);

You misunderstood what I tried to explain to you.

Consider, how do you guarentee that this t->id.spi value is unique
across all xfrm6_tunnel tunnels using the same t->id.daddr and
t->id.prot?  The answer is that you cannot.

You must generate fake "spi" values, they have no meaning outside of
xfrm6_tunnel.c They serve purpose only to map 128-bit ipv6 address to
32-bit "xfrm6_tunnel" SPI value.

I would suggest following implementation:

1) Implement something similar to xfrm_alloc_spi(t, 1, ~(u32)0)

   It just needs to allocate unique SPI numbers local to
   xfrm6_tunnel.c   We mark "SPI" value zero as reserved and
   to indicate failed lookup.

2) Create hash table, it is keyed by ipv6 address and hash table
   entries give SPI values.

So on input you would say something like:

	u32 spi;

	spi = spihash_lookup(&iph->saddr);
	if (!spi)
		goto drop;
	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
			      IPPROTO_IPV6, AF_INET6);

Is the idea more clear now?

Once you fix this up I'll apply your xfrm6_tunnel.c work.

Thank you.
