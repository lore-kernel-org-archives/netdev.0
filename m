From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 5 Nov 2015 20:13:21 +0200
Message-ID: <CAHp75VfiV6DVb-2piCxmEWFP4Gi-+n0qNhhscvd=UsqXrivVYg@mail.gmail.com>
References: <20151104232100.GJ14575@oracle.com>
	<20151105.103126.148818796422971143.davem@davemloft.net>
	<20151105.110506.1901401372160830603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105.110506.1901401372160830603.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 5, 2015 at 6:05 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 05 Nov 2015 10:31:26 -0500 (EST)
>
>> I'll see if I can cook something up.
>
> How does this look?

I like it, though couple of style related comments.

>
> ====================
> net: Add eth_platform_get_mac_address() helper.
>
> A repeating pattern in drivers has become to use OF node information
> and, if not found, platform specific host information to extract the
> ethernet address for a given device.
>
> Currently this is done with a call to of_get_mac_mac_address() and
> then some ifdef'd stuff for SPARC.
>
> Consolidate this into a portable routine, and provide the
> arch_get_platform_mac_address() weak function hook for all
> architectures to implement if they want.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/arch/sparc/kernel/idprom.c b/arch/sparc/kernel/idprom.c
> index 6bd7501..f95dd11 100644
> --- a/arch/sparc/kernel/idprom.c
> +++ b/arch/sparc/kernel/idprom.c
> @@ -9,6 +9,7 @@
>  #include <linux/types.h>
>  #include <linux/init.h>
>  #include <linux/export.h>
> +#include <linux/etherdevice.h>
>
>  #include <asm/oplib.h>
>  #include <asm/idprom.h>
> @@ -60,6 +61,12 @@ static void __init display_system_type(unsigned char machtype)
>  {
>  }
>  #endif
> +
> +unsigned char *arch_get_platform_mac_address(void)
> +{
> +       return idprom->id_ethaddr;
> +}
> +
>  /* Calculate the IDPROM checksum (xor of the data bytes). */
>  static unsigned char __init calc_idprom_cksum(struct idprom *idprom)
>  {
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index eb049c6..37ff4a6 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -29,6 +29,9 @@
>  #include <asm/bitsperlong.h>
>
>  #ifdef __KERNEL__
> +struct device;
> +int eth_platform_get_mac_address(struct device *dev, u8 *mac_addr);
> +unsigned char *arch_get_platform_get_mac_address(void);
>  u32 eth_get_headlen(void *data, unsigned int max_len);
>  __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev);
>  extern const struct header_ops eth_header_ops;
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 9e63f25..1cb9204f 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -52,6 +52,8 @@
>  #include <linux/errno.h>
>  #include <linux/init.h>
>  #include <linux/if_ether.h>
> +#include <linux/of_net.h>
> +#include <linux/pci.h>
>  #include <net/dst.h>
>  #include <net/arp.h>
>  #include <net/sock.h>
> @@ -485,3 +487,33 @@ static int __init eth_offload_init(void)
>  }
>
>  fs_initcall(eth_offload_init);
> +
> +unsigned char * __weak arch_get_platform_mac_address(void)
> +{
> +       return NULL;
> +}
> +
> +int eth_platform_get_mac_address(struct device *dev, u8 *mac_addr)
> +{
> +       const unsigned char *addr;
> +       struct device_node *dp;
> +
> +       if (dev_is_pci(dev))
> +               dp = pci_device_to_OF_node(to_pci_dev(dev));
> +       else
> +               dp = dev->of_node;
> +
> +       addr = NULL;

Maybe we can use definition block for this assignment?

> +       if (dp)
> +               addr = of_get_mac_address(dp);
> +       if (!addr)
> +               addr = arch_get_platform_mac_address();
> +
> +       if (addr) {

What about

if (!addr)
 return -ENODATA;

(Yes, ENODATA looks suitable for me)

> +               ether_addr_copy(mac_addr, addr);
> +               return 0;
> +       }
> +
> +       return -ENODEV;
> +}
> +EXPORT_SYMBOL(eth_platform_get_mac_address);



-- 
With Best Regards,
Andy Shevchenko
