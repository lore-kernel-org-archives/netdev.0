From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH wireless-2.6 10/12] Host AP: Use void * instead of unsigned
 long with {read,write}{b,w}
Date: Tue, 09 Nov 2004 02:29:25 -0500
Message-ID: <419071D5.8070208@pobox.com>
References: <20041108070156.GA1076@jm.kir.nu> <20041108071630.GK1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20041108071630.GK1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> Start using void * instead of unsigned long with {read,write}{b,w} to
> silence compiler warning with Linux 2.6.9-rc2.
> 
> Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>
> 
> 
> diff -Nru a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
> --- a/drivers/net/wireless/hostap/hostap_pci.c	2004-11-07 22:39:06 -08:00
> +++ b/drivers/net/wireless/hostap/hostap_pci.c	2004-11-07 22:39:06 -08:00
> @@ -56,7 +56,7 @@
>  
>  	spin_lock_irqsave(&local->lock, flags);
>  	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
> -	writeb(v, dev->mem_start + a);
> +	writeb(v, (void *) dev->mem_start + a);
>  	spin_unlock_irqrestore(&local->lock, flags);
>  }
>  
> @@ -68,7 +68,7 @@
>  	u8 v;
>  
>  	spin_lock_irqsave(&local->lock, flags);
> -	v = readb(dev->mem_start + a);
> +	v = readb((void *) dev->mem_start + a);
>  	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
>  	spin_unlock_irqrestore(&local->lock, flags);
>  	return v;
> @@ -82,7 +82,7 @@
>  
>  	spin_lock_irqsave(&local->lock, flags);
>  	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
> -	writew(v, dev->mem_start + a);
> +	writew(v, (void *) dev->mem_start + a);
>  	spin_unlock_irqrestore(&local->lock, flags);
>  }
>  
> @@ -94,7 +94,7 @@
>  	u16 v;
>  
>  	spin_lock_irqsave(&local->lock, flags);
> -	v = readw(dev->mem_start + a);
> +	v = readw((void *) dev->mem_start + a);
>  	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
>  	spin_unlock_irqrestore(&local->lock, flags);
>  	return v;
> @@ -109,12 +109,14 @@
>  
>  #else /* PRISM2_IO_DEBUG */
>  
> -#define HFA384X_OUTB(v,a) writeb((v), dev->mem_start + (a))
> -#define HFA384X_INB(a) (u8) readb(dev->mem_start + (a))
> -#define HFA384X_OUTW(v,a) writew((v), dev->mem_start + (a))
> -#define HFA384X_INW(a) (u16) readw(dev->mem_start + (a))
> -#define HFA384X_OUTW_DATA(v,a) writew(cpu_to_le16(v), dev->mem_start + (a))
> -#define HFA384X_INW_DATA(a) (u16) le16_to_cpu(readw(dev->mem_start + (a)))
> +#define HFA384X_OUTB(v,a) writeb((v), (void *) dev->mem_start + (a))
> +#define HFA384X_INB(a) (u8) readb((void *) dev->mem_start + (a))
> +#define HFA384X_OUTW(v,a) writew((v), (void *) dev->mem_start + (a))
> +#define HFA384X_INW(a) (u16) readw((void *) dev->mem_start + (a))
> +#define HFA384X_OUTW_DATA(v,a) \
> +	writew(cpu_to_le16(v), (void *) dev->mem_start + (a))
> +#define HFA384X_INW_DATA(a) (u16) \
> +	le16_to_cpu(readw((void *) dev->mem_start + (a)))

Two comments:

1) that should be "void __iomem *" not "void *" for MMIO memory pointers

2) don't bother using dev->mem_start, that is normally used for passing 
options or an ISA memory address from userland to the kernel.  Store the 
result of ioremap() in a private 'void __iomem *' pointer instead.



> diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
> --- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-07 22:39:06 -08:00
> +++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-07 22:39:06 -08:00
> @@ -247,7 +247,7 @@
>  
>  	/* Set sreset bit of COR and clear it after hold time */
>  
> -	if (local->attr_mem == 0) {
> +	if (local->attr_mem == NULL) {
>  		/* TMD7160 - COR at card's first I/O addr */
>  		corsave = inb(local->cor_offset);
>  		outb(corsave | COR_SRESET, local->cor_offset);
> @@ -271,7 +271,7 @@
>  {
>  	unsigned char corsave;
>  
> -	if (local->attr_mem == 0) {
> +	if (local->attr_mem == NULL) {
>  		/* TMD7160 - COR at card's first I/O addr */
>  		corsave = inb(local->cor_offset);
>  		outb(corsave | COR_SRESET, local->cor_offset);
> @@ -306,7 +306,7 @@
>  };
>  
>  
> -static int prism2_plx_check_cis(unsigned long attr_mem, int attr_len,
> +static int prism2_plx_check_cis(void *attr_mem, int attr_len,
>  				unsigned int *cor_offset,
>  				unsigned int *cor_index)
>  {
> @@ -401,7 +401,7 @@
>  	unsigned int pccard_ioaddr, plx_ioaddr;
>  	unsigned long pccard_attr_mem;
>  	unsigned int pccard_attr_len;
> -	unsigned long attr_mem = 0;
> +	void *attr_mem = NULL;
>  	unsigned int cor_offset, cor_index;
>  	u32 reg;
>  	local_info_t *local = NULL;

void __iomem *


> @@ -422,7 +422,7 @@
>  
>  	if (tmd7160) {
>  		/* TMD7160 */
> -		attr_mem = 0; /* no access to PC Card attribute memory */
> +		attr_mem = NULL; /* no access to PC Card attribute memory */
>  
>  		printk(KERN_INFO "TMD7160 PCI/PCMCIA adapter: io=0x%x, "
>  		       "irq=%d, pccard_io=0x%x\n",
> @@ -448,9 +448,8 @@
>  			goto fail;
>  
>  
> -		attr_mem = (unsigned long) ioremap(pccard_attr_mem,
> -						   pccard_attr_len);
> -		if (!attr_mem) {
> +		attr_mem = ioremap(pccard_attr_mem, pccard_attr_len);
> +		if (attr_mem == NULL) {
>  			printk(KERN_ERR "%s: cannot remap attr_mem\n",
>  			       dev_info);
>  			goto fail;
> @@ -532,7 +531,7 @@
>  		free_irq(dev->irq, dev);
>  
>  	if (attr_mem)
> -		iounmap((void *) attr_mem);
> +		iounmap(attr_mem);
>  
>  	pci_disable_device(pdev);
>  
> @@ -550,7 +549,7 @@
>  	hfa384x_disable_interrupts(dev);
>  
>  	if (iface->local->attr_mem)
> -		iounmap((void *) iface->local->attr_mem);
> +		iounmap(iface->local->attr_mem);
>  	if (dev->irq)
>  		free_irq(dev->irq, dev);
>  
> diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
> --- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:39:06 -08:00
> +++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:39:06 -08:00
> @@ -895,7 +895,7 @@
>  #endif /* PRISM2_PCCARD */
>  
>  #ifdef PRISM2_PLX
> -	unsigned long attr_mem;
> +	void *attr_mem;
>  	unsigned int cor_offset;
>  #endif /* PRISM2_PLX */

void __iomem *
