From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: An example scenario ([RFC / (sort of) PATCH - 2.6.10-rc3]
 Structured locally generated Ethernet addresses)
Date: Sun, 19 Dec 2004 11:52:11 +1030
Message-ID: <20041219115211.1a3f205f.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20041218235126.4a77a127.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20041218235126.4a77a127.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've realised I didn't really provide a good scenario where this is
useful.

I've been using Qemu to emulate multiple PCs, am then running Linux on
them, and then running Quagga routing daemons within each instance. Qemu
can create tun tap/tun style interfaces on the host kernel,
corresponding to the virtual NE2K NICs within the Qemu instance. I've
been bridging these tun interfaces together to interconnect the Qemu
instaces, creating a "virtual" LAN between them (don't you love it when
you have to overload a word to make it more generic :-) ).

I occured to me that I could also add a real, physical ethernet
interface to these tun bridge groups, which would then make the random,
locally assigned MAC addresses, assigned to the tun interfaces, visible
to devices outside of the host kernel running the Qemu instances. (With
multiple Qemu tun bridge groups, it could be possible to bridge in a
vlan subinterface, rather than the main ethernet interface. I'll give
that a try soon.)

I don't think the structure or values of of the random ethernet
addresses matters much if they are only visible within a host. However,
when they start being visible to devices outside of the host, such as
the above scenario, I think having them come from the same, random OUI
would be useful.

Thanks,
Mark.


On Sat, 18 Dec 2004 23:51:26 +1030
Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org> wrote:

> Hi,
> 
> I've been playing around with quite a number of interfaces which are
> using locally generated MAC addresses, via the random_ether_addr()
> function.
> 
> Although these random ethernet addresses work fine, I thought it might
> be more useful if they were more structured, by having a common, random,
> local OUI, and then using an incremental serial number. It would help
> identify MAC addresses belonging to the same host in things such as
> bridge / switch station caches, or ARP tables. It is also closer to how 
> vendors user their officially assigned OUIs.
> 
> I've put together a patch against 2.6.10-rc3. I've modified the dummy
> interface code to use it. I'll admit straight up that I don't know much
> about kernel programming, so I may be doing things wrong. However, I
> think it is ok, and it seems to be working alright.
> 
> A few other drivers would need to be modified to use it, the tun/tap one
> as an example. Prior to developing this patch I discovered that the
> tun/tap driver wasn't using random_ether_addr() either, so I've fixed
> that and sent a patch off to the maintainer. Multiple tun interfaces is
> the main application where I've been dealing with a number of random,
> local ethernet addresses.
> 
> I think it would be useful to have something similar to this
> incorporated into the Linux kernel.
> 
> I'm interested in any comments, including those as to why this might not
> be a good idea. I think you can learn as much from finding out what is
> wrong to do as what is right to do.
> 
> The patch is below.
> 
> Thanks,
> Mark.
> 
> diff -ur linux-2.6.10-rc3/drivers/net/dummy.c linux-2.6.10-rc3-mrs/drivers/net/dummy.c
> --- linux-2.6.10-rc3/drivers/net/dummy.c	2004-12-18 23:01:16.000000000 +1030
> +++ linux-2.6.10-rc3-mrs/drivers/net/dummy.c	2004-12-18 23:00:10.000000000 +1030
> @@ -72,7 +72,10 @@
>  	dev->flags |= IFF_NOARP;
>  	dev->flags &= ~IFF_MULTICAST;
>  	SET_MODULE_OWNER(dev);
> -	random_ether_addr(dev->dev_addr);
> +
> +	/* random_ether_addr(dev->dev_addr); - MRS */
> +
> +	locally_assigned_ether_addr(dev->dev_addr);
>  }
>  
>  static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
> diff -ur linux-2.6.10-rc3/include/linux/etherdevice.h linux-2.6.10-rc3-mrs/include/linux/etherdevice.h
> --- linux-2.6.10-rc3/include/linux/etherdevice.h	2004-10-19 07:25:06.000000000 +0930
> +++ linux-2.6.10-rc3-mrs/include/linux/etherdevice.h	2004-12-18 23:06:27.000000000 +1030
> @@ -78,6 +78,18 @@
>  	addr [0] &= 0xfe;	/* clear multicast bit */
>  	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
>  }
> +
> +/**
> + * locally_assigned_ether_addr - Generate locally assigned Ethernet address
> + * using an occasionally generated random local OUI, and then an incrementing
> + * serial number
> + * @addr: Pointer to a six-byte array containing the Ethernet address
> + *
> + * Mark Smith <markzzzsmith@yahoo.com.au>
> + */
> +
> +extern void locally_assigned_ether_addr(u8 *addr);
> +
>  #endif
>  
>  #endif	/* _LINUX_ETHERDEVICE_H */
> diff -ur linux-2.6.10-rc3/include/linux/if_ether.h linux-2.6.10-rc3-mrs/include/linux/if_ether.h
> --- linux-2.6.10-rc3/include/linux/if_ether.h	2004-10-19 07:24:37.000000000 +0930
> +++ linux-2.6.10-rc3-mrs/include/linux/if_ether.h	2004-12-18 19:02:19.000000000 +1030
> @@ -27,6 +27,7 @@
>   */
>  
>  #define ETH_ALEN	6		/* Octets in one ethernet addr	 */
> +#define ETH_OUILEN	3		/* Octets in OUI part of eth addr */
>  #define ETH_HLEN	14		/* Total octets in header.	 */
>  #define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
>  #define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
> diff -ur linux-2.6.10-rc3/Makefile linux-2.6.10-rc3-mrs/Makefile
> --- linux-2.6.10-rc3/Makefile	2004-12-18 23:00:44.000000000 +1030
> +++ linux-2.6.10-rc3-mrs/Makefile	2004-12-18 17:28:45.000000000 +1030
> @@ -1,7 +1,7 @@
>  VERSION = 2
>  PATCHLEVEL = 6
>  SUBLEVEL = 10
> -EXTRAVERSION =-rc3
> +EXTRAVERSION =-rc3-mrs
>  NAME=Woozy Numbat
>  
>  # *DOCUMENTATION*
> diff -ur linux-2.6.10-rc3/net/ethernet/eth.c linux-2.6.10-rc3-mrs/net/ethernet/eth.c
> --- linux-2.6.10-rc3/net/ethernet/eth.c	2004-12-18 23:01:48.000000000 +1030
> +++ linux-2.6.10-rc3-mrs/net/ethernet/eth.c	2004-12-18 23:09:01.000000000 +1030
> @@ -306,3 +306,67 @@
>  	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
>  }
>  EXPORT_SYMBOL(alloc_etherdev);
> +
> +/**
> + * locally_assigned_ether_addr - Generate locally assigned Ethernet address
> + * using an occasionally generated random local OUI, then an incrementing
> + * serial number
> + * @addr: Pointer to a six-byte array containing the Ethernet address
> + *
> + * Make sure that random OUI has multicast bit reset, and has locally
> + * assigned bit set. Note that the random OUI is very occasionally generated ie.
> + * most of the time, it will be the same for calls to this function.
> + * All interfaces on host will then have nearly the same OUI, and only
> + * vary in their serial number.
> + * This will make identifying a single Linux host with multiple
> + * generated MAC addresses easier in things such as ARP tables
> + * and bridge / switch station caches.
> + *
> + * This probably should be called within a lock / semaphore; I know what they 
> + * are, I know what they're for, I just don't know how to make sure they
> + * are being used or how to check for them yet :-( 
> + * Oh well, you've got to start somewhere.
> + *
> + * Mark Smith <markzzzsmith@yahoo.com.au>
> + */
> +
> +void locally_assigned_ether_addr(u8 *addr)
> +{
> +
> +	static u8 random_OUI[ETH_OUILEN]; /* Just FYI, OUIs are 3 octets */
> +	static u8 random_OUI_generated = 0;
> +	static u16 serial_number = 0;
> +	u16 serial_num_hton;
> +
> +	if (random_OUI_generated == 0) {
> +		get_random_bytes(&random_OUI[0], ETH_OUILEN);
> +		random_OUI[0] &= 0xfe;	/* clear multicast bit */
> +		random_OUI[0] |= 0x02;	/* set local assignment bit (IEEE802) */
> +		random_OUI_generated = 1;
> +	}
> +
> +	/* Copy OUI into addr */
> +	memcpy(addr, random_OUI, ETH_OUILEN);
> +
> +	/* now the 4th octet */
> +	addr[3] = 0x00;
> +
> +	serial_number++;
> +	serial_num_hton = htons(serial_number);
> +	/* now octets 5 and 6 */
> +	memcpy(&addr[4], &serial_num_hton, sizeof(u16));
> +
> +	/* We might have run out of serial numbers, so pick a new OUI
> +	 * next time we're called.
> +	 * (Unlikely, supposedly we've now generated at 2^16 local
> +	 *  addresses. Still, need to handle this corner case, there are some
> +	 *  crazy networking people out there, must be caffeine poisoning.) */
> +
> +	if (serial_number == 0xffff) {
> +		random_OUI_generated = 0;
> +		serial_number = 0;
> +	}
> +		
> +}
> +
> +EXPORT_SYMBOL(locally_assigned_ether_addr);


-- 
