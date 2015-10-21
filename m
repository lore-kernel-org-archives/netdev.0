From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 17:57:24 +0200
Message-ID: <4129407.LpDXnpSZOL@wuerfel>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net> <5627A792.3020201@roeck-us.net> <20151021.083311.2193871332944250588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021.083311.2193871332944250588.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 21 October 2015 08:33:11 David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Wed, 21 Oct 2015 07:56:18 -0700
> 
> >> @@ -57,6 +57,11 @@ extern int of_dma_get_range(struct device_node *np,
> >> u64 *dma_addr,
> >>                              u64 *paddr, u64 *size);
> >>   extern bool of_dma_is_coherent(struct device_node *np);
> >>   #else /* CONFIG_OF_ADDRESS */
> >> +static inline u64 of_translate_address(struct device_node *np, const
> >> __be32 *addr)
> >> +{
> >> +    return 0;
> > 
> > Maybe return OF_BAD_ADDR ?
> 
> The thing to really do on sparc, is just return the address raw untranslated
> because that just works.
> 

We still need to check #address-cells, right?

Something like this?

static inline u64 of_translate_address(struct device_node *np, const __be32 *addr)
{
#if defined(CONFIG_SPARC) || defined(CONFIG_M68K)
	int pna = of_n_addr_cells(np);
	u64 ret = be32_to_cpu(addr[pna - 1]);

	if (pna > 1)
		ret += (u64)be32_to_cpu(addr[pna - 2]) << 32;

	return ret;
#else
	return OF_BAD_ADDR;
#endif
}

	Arnd
