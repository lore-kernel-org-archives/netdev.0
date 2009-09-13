From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Sun, 13 Sep 2009 16:09:57 +0930
Message-ID: <20090913160957.64ea2111@opy.nosense.org>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	<20090910190703.25d14533@nehalam>
	<1252638163.4355.35.camel@Joe-Laptop.home>
	<20090911.121542.45333246.davem@davemloft.net>
	<1252700442.15292.62.camel@Joe-Laptop.home>
	<20090911141554.0072d365@nehalam>
	<1252717067.29420.22.camel@Joe-Laptop.home>
	<20090913094409.2dd88212@opy.nosense.org>
	<20090913100342.4f6a2417@opy.nosense.org>
	<1252802686.4400.19.camel@Joe-Laptop.home>
	<20090913131752.462abc01@opy.nosense.org>
	<1252822152.4400.108.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:38487 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbZIMGkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 02:40:07 -0400
In-Reply-To: <1252822152.4400.108.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Sep 2009 23:09:12 -0700
Joe Perches <joe@perches.com> wrote:

> On Sun, 2009-09-13 at 13:17 +0930, Mark Smith wrote:
> > On Sat, 12 Sep 2009 17:44:46 -0700
> > Joe Perches <joe@perches.com> wrote:
> > > Avoiding an initial octet of "02", which is partially
> > > assigned to 3Com and others, might be useful.
> > I wouldn't necessarily disagree. I would say that if that path was
> > taken, then you'd probably also want to be avoiding all the other
> > well known mac addresses that do or can fall within the locally
> > assigned range e.g. DECnet 0xAA addresses, Microsoft's  use of
> > 02:01:00:00:00:00 and similar addresses for their Network Load
> > Balancing software, the unicast version of the CF:00:00:00:00:00
> > multicast address use for ECTP, the unicast version of the
> > 33:33:xx:xx:xx:xx IPv6 ND multicast ranges etc.
> 
> The existing code already has the first wire bit cleared so it
> is not multicast

Agreed. However I think that if there is a well-known multicast address
that has 0x02 set, there is a future, slight possibility that unicast
addresses might be assigned out of that same LA space, and so they're
worth avoiding. It probably seems a bit paranoid, but LAs are supposed
to be private use only in the first place, and not supposed to be seen
outside of the organisation or entity assigning them (e.g. Microsoft
should have got an OUI to use with their NLB product). If people are
crossing those privacy boundaries with LA multicast addresses, I'd
suggest they might be willing to do it with LA unicast addresses in the
future too - and hopefully they'd restrict themselves to the OUI bytes
they've used for their multicast addresses.

> and has the locally assigned bit set so the
> first octet is a multiple of 2.
> 
> The suggested patch requires an initial octet >= 0x04.
> 
> Skipping AA seems a good idea.
> 
> > Having thought about this issue a bit before, another thought might be
> > to have somebody get the Linux kernel its own OUI,
> 
> That's been suggested.
> 
> > > Not drawing from entropy I think useful, but it's debatable.
> > I'm guessing there are other things in the kernel that would be taking
> > away far more entropy, far more often. IIRC, TCP connection initial
> > sequence number selection would be one example.
> 
> These MAC assignments are generally done at system startup
> when entropy often isn't available and possibly should be
> conserved.
> 
> Maybe this:
> 

I'd suggest documenting in the comment why 0x02 or 0xaa are special
values that have been avoided.

> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 3d7a668..40233db 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -118,12 +118,30 @@ static inline int is_valid_ether_addr(const u8 *addr)
>   *
>   * Generate a random Ethernet address (MAC) that is not multicast
>   * and has the local assigned bit set.
> + * Does not assign a leading octet of 0x02 or 0xaa.
>   */
>  static inline void random_ether_addr(u8 *addr)
>  {
> -	get_random_bytes (addr, ETH_ALEN);
> -	addr [0] &= 0xfe;	/* clear multicast bit */
> -	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
> +	u32 val;
> +
> +	/* not calling get_random_bytes to avoid using entropy */
> +	do {
> +		val = random32();
> +		addr[0] = val;
> +		addr[0] &= 0xfe;	/* clear multicast bit */
> +		addr[0] |= 0x02;	/* set local assignment bit (IEEE802) */
> +	} while (addr[0] == 0x02 || addr[0] == 0xaa);
> +
> +	val >>= 8;
> +	addr[1] = val;
> +	val >>= 8;
> +	addr[2] = val;
> +	val >>= 8;
> +	addr[3] = val;
> +	val = random32();
> +	addr[4] = val;
> +	val >>= 8;
> +	addr[5] = val;
>  }
>  
>  /**
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
