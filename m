From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH] Fix kernel unaligned access with r8169 on sparc64
Date: Tue, 10 Jul 2007 11:39:19 +1000
Message-ID: <4692E347.3060200@snapgear.com>
References: <200707061502.49146.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:42759 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756725AbXGJCAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 22:00:05 -0400
In-Reply-To: <200707061502.49146.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> Hi all,
> 
> When using the r8169 gigabit ethernet network driver under a Sun Entreprise 
> 450, you will encounter a lot of kernel unaligned access on ip_rcv and 
> ip_fast_csum. The full report is available here : 
> http://www.mail-archive.com/debian-bugs-dist%40lists.debian.org/msg363433.htm

Try the patches at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/
I think patches 0012 and/or 0017 will fix this.


> The following patch against 2.6.22-rc6 will fix this problem.
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 5ec7752..5095dbe 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -69,6 +69,7 @@ VERSION 2.2LK	<2005/01/25>
>  #include <asm/system.h>
>  #include <asm/io.h>
>  #include <asm/irq.h>
> +#include <asm/unaligned.h>
>  
>  #ifdef CONFIG_R8169_NAPI
>  #define NAPI_SUFFIX	"-NAPI"
> @@ -224,7 +225,9 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
>  
>  MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
>  
> +#if !defined(__sparc__)
>  static int rx_copybreak = 200;
> +#endif
>  static int use_dac;
>  static struct {
>  	u32 msg_enable;
> @@ -465,8 +468,10 @@ MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
>  MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
>  module_param_array(media, int, &num_media, 0);
>  MODULE_PARM_DESC(media, "force phy operation. Deprecated by ethtool (8).");
> +#if !defined(__sparc__)
>  module_param(rx_copybreak, int, 0);
>  MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
> +#endif
>  module_param(use_dac, int, 0);
>  MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
>  module_param_named(debug, debug.msg_enable, int, 0);
> @@ -2486,10 +2491,25 @@ static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
>  {
>  	int ret = -1;
>  
> -	if (pkt_size < rx_copybreak) {
> +#if defined(__sparc__)
> +	if (pkt_size) {
>  		struct sk_buff *skb;
> +		int i;
> +
> +		skb = dev_alloc_skb(pkt_size + 4);
> +
> +		/* align the data to the ip header - should be faster than copying the entire packet to the stack */
> +		for (i = pkt_size - (pkt_size % 4); i >= 0; i -= 4) {
> +			put_unaligned(*((u32 *) (skb->data + i)), (u32 *) (skb->data + i + 2));
> +		}
> +		skb->data += 2;
> +		skb->tail += 2;
> +#else
> +	if (pkt_size < rx_copybreak) {
> +                struct sk_buff *skb;
>  
>  		skb = dev_alloc_skb(pkt_size + align);
> +#endif
>  		if (skb) {
>  			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
>  			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);

