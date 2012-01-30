From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [22/22] Cyclades PC300 driver: omnibus patch from merge up to
 final version (patches 01 through 20 inclusive)
Date: Mon, 30 Jan 2012 11:13:56 +0100
Message-ID: <4F266D64.9030105@suse.cz>
References: <20120130030156.GW10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us,
	Jiri Slaby <jirislaby@gmail.com>
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130030156.GW10262@cronus.persephoneslair.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 04:01 AM, Andrea Shepard wrote:
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -205,10 +205,8 @@ config WANXL_BUILD_FIRMWARE
>  
>  config PC300
>  	tristate "Cyclades-PC300 support (RS-232/V.35, X.21, T1/E1 boards)"
> -	depends on HDLC && PCI && BROKEN
> +	depends on HDLC && PCI

You should do this as the very last in the series. You break the build
by the very first patch.

> --- a/drivers/net/wan/pc300.h
> +++ b/drivers/net/wan/pc300.h
...
> @@ -143,13 +150,28 @@
>   * Memory access functions/macros      *
>   * (required to support Alpha systems) *
>   ***************************************/
> -#define cpc_writeb(port,val)	{writeb((u8)(val),(port)); mb();}
> -#define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
> -#define cpc_writel(port,val)	{writel((u32)(val),(port)); mb();}
> +#ifdef __KERNEL__

Why is this in a header from drivers/ ? Perhaps you should move the
header if it is an interface. User does not need to see cpc_writeb et
al. anyway. And u8 and others are not defined there.

> +#define cpc_writeb(port, val)	{writeb((u8)(val), \
> +				(void __iomem *)(port)); mb(); }
> +#define cpc_writew(port, val)	{writew((u16)(val), \
> +				(void __iomem *)(port)); mb(); }
> +#define cpc_writel(port, val)	{writel((u32)(val), \
> +				(void __iomem *)(port)); mb(); }
> +
> +#define cpc_readb(port)		readb((void __iomem *)(port))
> +#define cpc_readw(port)		readw((void __iomem *)(port))
> +#define cpc_readl(port)		readl((void __iomem *)(port))
>  
> -#define cpc_readb(port)		readb(port)
> -#define cpc_readw(port)		readw(port)
> -#define cpc_readl(port)		readl(port)
> +#else /* __KERNEL__ */
> +#define cpc_writeb(port, val)	(*((u8 *)(port)) = (u8)(val))
> +#define cpc_writew(port, val)	(*((u16 *)(port)) = (u16)(val))
> +#define cpc_writel(port, val)	(*((u32 *)(port)) = (u32)(val))
> +
> +#define cpc_readb(port)		(*((u8 *)(port)))
> +#define cpc_readw(port)		(*((u16 *)(port)))
> +#define cpc_readl(port)		(*((u32 *)(port)))
> +
> +#endif /* __KERNEL__ */
>  
>  /****** Data Structures *****************************************************/
>  
> @@ -291,16 +349,31 @@ typedef struct pc300patterntst {
>  	u16 num_errors;
>  } pc300patterntst_t;
>  
> +#ifdef __KERNEL__
> +
>  typedef struct pc300dev {
>  	struct pc300ch *chan;
>  	u8 trace_on;
>  	u32 line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
>  	u32 line_off;
> +#ifdef __KERNEL__

Double ifdef?

>  	char name[16];
> -	struct net_device *dev;
> +	hdlc_device *hdlc;
> +	struct net_device *netdev;
> +
> +	void *private;
> +	struct sk_buff *tx_skb;
> +
> +	enum {
> +	  CPC_DMA_FULL,
> +	  CPC_DMA_ERROR,
> +	  TRANSMISSION_ACTIVE,
> +	  CHANNEL_CLOSED
> +	} reason_stopped;
>  #ifdef CONFIG_PC300_MLPPP
>  	void *cpc_tty;	/* information to PC300 TTY driver */
>  #endif
> +#endif /* __KERNEL__ */
>  }pc300dev_t;
...
> @@ -346,6 +450,8 @@ typedef struct pc300chconf {
>  	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
>  } pc300chconf_t;
>  
> +#ifdef __KERNEL__
> +
>  typedef struct pc300ch {
>  	struct pc300 *card;
>  	int channel;
> @@ -365,8 +471,10 @@ typedef struct pc300 {
>  	spinlock_t card_lock;
>  } pc300_t;
>  
> +#endif /* __KERNEL__ */
> +
>  typedef struct pc300conf {
> -	pc300hw_t hw;
> +	struct pc300hw_user hw;
>  	pc300chconf_t conf;
>  } pc300conf_t;
>  
> @@ -430,7 +538,19 @@ enum pc300_loopback_cmds {
>  #define PC300_TX_QUEUE_LEN	100
>  #define	PC300_DEF_MTU		1600
>  
> -/* Function Prototypes */
> -int cpc_open(struct net_device *dev);
> +#ifdef __KERNEL__
> +
> +int cpc_open(struct net_device *);
> +
> +#ifdef CONFIG_PC300_MLPPP
> +void cpc_tty_init(pc300dev_t *);
> +void cpc_tty_unregister_service(pc300dev_t *);
> +void cpc_tty_receive(pc300dev_t *);
> +void cpc_tty_trigger_poll(pc300dev_t *);
> +void cpc_tty_reset_var(void);
> +#endif /* CONFIG_PC300_MLPP */
> +
> +#endif /* __KERNEL__ */
>  
>  #endif	/* _PC300_H */
> +

ETOOMANYIFDEFS. You should split the header. One part with the interface
-> include/, the other with internal structures -> leave here.

> --- a/drivers/net/wan/pc300_drv.c
> +++ b/drivers/net/wan/pc300_drv.c
> @@ -1,6 +1,6 @@
>  #define	USE_PCI_CLOCK
>  static const char rcsid[] =
> -"Revision: 3.4.5 Date: 2002/03/07 ";
> +"Revision: 4.1.0 Date: 2004/02/20 ";

This is useless, isn't it? It doesn't mean anything after some time as
kernel evolves.

> @@ -16,6 +16,13 @@ static const char rcsid[] =
>   *	2 of the License, or (at your option) any later version.
>   *	
>   *	Using tabstop = 4.
> + *
> + * Cyclades version 4.1.0 merged in, with new portability fixes,
> + * and ported to recent kernels by Andrea Shepard <andrea@persephoneslair.org>

No, we have git log.

> + * Due to changes in certain ioctls necessary for portability, this
> + * version requires a new version of pc300utils, which may be found
> + * at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
>   * 
>   * $Log: pc300_drv.c,v $
>   * Revision 3.23  2002/03/20 13:58:40  henrique

Another piece of cvs.

> @@ -238,21 +246,22 @@ static const char rcsid[] =
>  
>  #include "pc300.h"
>  
> -#define	CPC_LOCK(card,flags)		\
> -		do {						\
> -		spin_lock_irqsave(&card->card_lock, flags);	\
> -		} while (0)
> +#define	CPC_LOCK(card, flags) \
> +		{ \
> +		    spin_lock_irqsave(&((card)->card_lock), (flags)); \
> +		}

Nah. do-while has its meaning. Try this:
if (1)
  CPC_LOCK(card,flags);
else
  return;

Overall, you don't need these macros at all.

> -#define CPC_UNLOCK(card,flags)			\
> -		do {							\
> -		spin_unlock_irqrestore(&card->card_lock, flags);	\
> -		} while (0)
> +#define CPC_UNLOCK(card, flags) \
> +		{ \
> +		    spin_unlock_irqrestore(&((card)->card_lock), (flags)); \
> +		}
...
> @@ -279,53 +288,128 @@ MODULE_DEVICE_TABLE(pci, cpc_pci_dev_id);
...
> -static void rx_dma_buf_check(pc300_t * card, int ch)
> +static void rx_dma_buf_check(pc300_t *card, int ch)
>  {
> -	volatile pcsca_bd_t __iomem *ptdescr;
> +	pcsca_bd_t __iomem *ptdescr;
>  	int i;
>  	u16 first_bd = card->chan[ch].rx_first_bd;
>  	u16 last_bd = card->chan[ch].rx_last_bd;
>  	int ch_factor;
>  
>  	ch_factor = ch * N_DMA_RX_BUF;
> -	printk("#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
> -	for (i = 0, ptdescr = (card->hw.rambase +
> -					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
> -	     i < N_DMA_RX_BUF; i++, ptdescr++) {
> +	printk(KERN_DEBUG
> +		"#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
> +	for (
> +		i = 0,
> +		ptdescr = (pcsca_bd_t *)
> +			(card->hw.rambase + DMA_RX_BD_BASE +
> +			 ch_factor * sizeof(pcsca_bd_t));
> +
> +		i < N_DMA_RX_BUF;
> +
> +		i++,
> +		ptdescr++
> +		) {

This is horrible.

>  		if (cpc_readb(&ptdescr->status) & DST_OSB)
> -			printk ("\n CH%d RX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
> -				 ch, i, cpc_readl(&ptdescr->next),
> -				 cpc_readl(&ptdescr->ptbuf),
> -				 cpc_readb(&ptdescr->status),
> -				 cpc_readw(&ptdescr->len));
> +			printk(KERN_DEBUG
> +				"\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
> +				ch, i, (u32) cpc_readl(&ptdescr->next),
> +				(u32) cpc_readl(&ptdescr->ptbuf),
> +				cpc_readb(&ptdescr->status),
> +				cpc_readw(&ptdescr->len));
>  	}
> -	printk("\n");
> +	printk(KERN_DEBUG "\n");
>  }
...
> -static void falc_intr_enable(pc300_t * card, int ch)
> +static void falc_intr_enable(pc300_t *card, int ch)
>  {
>  	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
>  	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
>  	falc_t *pfalc = (falc_t *) & chan->falc;
> -	void __iomem *falcbase = card->hw.falcbase;
> +	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);

Why is that?

> @@ -1940,18 +2212,19 @@ static void cpc_net_rx(struct net_device *dev)
>  			continue;
>  		}
>  
> -		dev->stats.rx_bytes += rxb;
> +		stats->rx_bytes += rxb;
>  
>  #ifdef PC300_DEBUG_RX
> -		printk("%s R:", dev->name);
> +		printk(KERN_DEBUG "%s R:", dev->name);
>  		for (i = 0; i < skb->len; i++)
> -			printk(" %02x", *(skb->data + i));
> -		printk("\n");
> +			printk(KERN_DEBUG " %02x", *(skb->data + i));
> +		printk(KERN_DEBUG "\n");

print_hex_dump_bytes();

> @@ -2486,73 +2847,157 @@ static void cpc_sca_status(pc300_t * card, int ch)
...
>  static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> -	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
> +	pc300dev_t *d = (pc300dev_t *) (dev_to_hdlc(dev))->priv;
>  	pc300ch_t *chan = (pc300ch_t *) d->chan;
>  	pc300_t *card = (pc300_t *) chan->card;
>  	pc300conf_t conf_aux;
>  	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
>  	int ch = chan->channel;
> -	void __user *arg = ifr->ifr_data;
> +	void *arg = (void *) ifr->ifr_data;

But it is a userspace ptr!

> @@ -3361,47 +3897,67 @@ static void cpc_init_card(pc300_t * card)
...
> -			printk (" #%d, %dKB of RAM at 0x%08x, IRQ%d, channel %d.\n",
> -				 board_nbr, card->hw.ramsize / 1024,
> -				 card->hw.ramphys, card->hw.irq, i + 1);
> +#ifdef CONFIG_PHYS_ADDR_T_64BIT
> +			printk(KERN_INFO " #%d, %dKB of RAM at 0x%016lx, IRQ %d, channel %d.\n",
> +			       board_nbr, card->hw.ramsize / 1024,
> +			       (unsigned long)(card->hw.ramphys),
> +			       card->hw.irq, i + 1);
> +#else /* !CONFIG_PHYS_ADDR_T_64BIT */
> +			printk(KERN_INFO " #%d, %dKB of RAM at 0x%08x, IRQ %d, channel %d.\n",
> +			       board_nbr, card->hw.ramsize / 1024,
> +			       (unsigned int)(card->hw.ramphys),
> +			       card->hw.irq, i + 1);
> +#endif /* CONFIG_PHYS_ADDR_T_64BIT */

What about just a cast to ull?

> @@ -3495,29 +4081,63 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
...
> -	card->hw.plxbase = ioremap(card->hw.plxphys, card->hw.plxsize);
> -	card->hw.rambase = ioremap(card->hw.ramphys, card->hw.alloc_ramsize);
> -	card->hw.scabase = ioremap(card->hw.scaphys, card->hw.scasize);
> +	err = pci_enable_device(pdev);
> +	if (err != 0)
> +		goto err_release_sca;
> +
> +	card->hw.plxbase =
> +		(void __iomem *) ioremap(card->hw.plxphys, card->hw.plxsize);

Why do you need the cast? You may use pci_ioremap_bar anyway.

> --- a/drivers/net/wan/pc300_tty.c
> +++ b/drivers/net/wan/pc300_tty.c
> @@ -481,11 +502,35 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
>  		return -EINVAL; 
>  	}
>  
> -	if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*)buf, count)) { 
> -	   /* failed to send */
> -	   CPC_TTY_DBG("%s: trasmition error\n", cpc_tty->name);
> -	   return 0;
> +	if (from_user) {

Nowadays, it is always a kernel buffer. This check was removed years ago
already I suppose. Please do not re-add crap from out of tree drivers.

> +		unsigned char *buf_tmp;
> +
> +		buf_tmp = cpc_tty->buf_tx;
> +		if (copy_from_user(buf_tmp, buf, count)) {
> +			/* failed to copy from user */
> +			CPC_TTY_DBG("%s: error in copy from user\n",
> +					cpc_tty->name);
> +			return -EINVAL;
> +		}
> +
> +		if (cpc_tty_send_to_card(cpc_tty->pc300dev,
> +					(void *)buf_tmp, count)) {
> +			/* failed to send */
> +			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
> +			return 0;
> +		}
> +	} else {
> +		if (
> +				cpc_tty_send_to_card(cpc_tty->pc300dev,
> +					(void *)buf,
> +					count)
> +				) {
> +			/* failed to send */
> +			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
> +			return 0;
> +		}
>  	}
> +
>  	return count; 
>  } 
>  
...
> @@ -618,9 +666,18 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
>  
>  	CPC_TTY_DBG("%s: call wake_up_interruptible\n",cpc_tty->name);
>  
> -	tty_wakeup(tty);	
> -	return; 
> -} 
> +	wake_up_interruptible(&tty->write_wait);
> +
> +	if (
> +			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
> +			tty->ldisc &&
> +			tty->ldisc->ops && tty->ldisc->ops->write_wakeup
> +			) {
> +		CPC_TTY_DBG("%s: call line disc. wake up\n",
> +				cpc_tty->name);
> +		tty->ldisc->ops->write_wakeup(tty);
> +	}
> +}

Another instance of such crap.

> @@ -665,35 +722,35 @@ static void cpc_tty_hangup(struct tty_struct *tty)
>   */
>  static void cpc_tty_rx_work(struct work_struct *work)
>  {
> -	st_cpc_tty_area *cpc_tty;
> -	unsigned long port;
>  	int i, j;
> -	volatile st_cpc_rx_buf *buf;
> -	char flags=0,flg_rx=1; 
> -	struct tty_ldisc *ld;
> +	unsigned long port;
> +	st_cpc_tty_area *cpc_tty;
> +	st_cpc_rx_buf *buf;
> +	char flags = 0, flg_rx = 1;
>  
>  	if (cpc_tty_cnt == 0) return;
> -	
> -	for (i=0; (i < 4) && flg_rx ; i++) {
> -		flg_rx = 0;
>  
> +	for (i = 0; (i < 4) && flg_rx; i++) {
> +		flg_rx = 0;
>  		cpc_tty = container_of(work, st_cpc_tty_area, tty_rx_work);
>  		port = cpc_tty - cpc_tty_area;
>  
> -		for (j=0; j < CPC_TTY_NPORTS; j++) {
> +		for (j = 0; j < CPC_TTY_NPORTS; j++) {
>  			cpc_tty = &cpc_tty_area[port];
> -		
> -			if ((buf=cpc_tty->buf_rx.first) != NULL) {
> -				if (cpc_tty->tty) {
> -					ld = tty_ldisc_ref(cpc_tty->tty);
> -					if (ld) {
> -						if (ld->ops->receive_buf) {
> -							CPC_TTY_DBG("%s: call line disc. receive_buf\n",cpc_tty->name);
> -							ld->ops->receive_buf(cpc_tty->tty, (char *)(buf->data), &flags, buf->size);
> -						}
> -						tty_ldisc_deref(ld);
> -					}
> -				}	
> +			buf = cpc_tty->buf_rx.first;
> +			if (buf != NULL) {
> +				if (cpc_tty->tty && cpc_tty->tty->ldisc &&
> +				    cpc_tty->tty->ldisc->ops &&
> +				    cpc_tty->tty->ldisc->ops->receive_buf) {

Third instance of crap. NACK!

> +					CPC_TTY_DBG(
> +					  "%s: call line disc. receive_buf\n",
> +					  cpc_tty->name);
> +					cpc_tty->tty->
> +					  ldisc->ops->
> +					  receive_buf(cpc_tty->tty,
> +						(char *)(buf->data),
> +						&flags, buf->size);
> +				}
>  				cpc_tty->buf_rx.first = cpc_tty->buf_rx.first->next;
>  				kfree((void *)buf);
>  				buf = cpc_tty->buf_rx.first;
...
> @@ -789,13 +848,13 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
>  		} 
>  		
>  		new = kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
> -		if (!new) {
> +		if (new == 0) {

Nah.

> @@ -821,8 +880,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
>  						cpc_tty->name);
>  				cpc_tty_rx_disc_frame(pc300chan);
>  				rx_len = 0;
> -				kfree(new);
> -				new = NULL;
> +				kfree((unsigned char *)new);

Nah. Isn't the assignment necessary (I didn't check)?

> @@ -831,15 +889,14 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
>  				cpc_tty_rx_disc_frame(pc300chan);
>  				stats->rx_dropped++; 
>  				rx_len = 0; 
> -				kfree(new);
> -				new = NULL;
> +				kfree((unsigned char *)new);

Nah.

> @@ -892,15 +950,29 @@ static void cpc_tty_tx_work(struct work_struct *work)
>  {
>  	st_cpc_tty_area *cpc_tty =
>  		container_of(work, st_cpc_tty_area, tty_tx_work);
> -	struct tty_struct *tty; 
> +	struct tty_struct *tty;
>  
>  	CPC_TTY_DBG("%s: cpc_tty_tx_work init\n",cpc_tty->name);
>  	
> -	if ((tty = cpc_tty->tty) == NULL) { 
> -		CPC_TTY_DBG("%s: the interface is not opened\n",cpc_tty->name);
> +	tty = cpc_tty->tty;
> +	if (tty == 0) {
> +		CPC_TTY_DBG("%s: the interface is not opened\n",
> +				cpc_tty->name);
>  		return; 
>  	}
> -	tty_wakeup(tty);
> +
> +	if (
> +			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
> +			tty->ldisc &&
> +			tty->ldisc->ops &&
> +			tty->ldisc->ops->write_wakeup
> +			) {
> +		CPC_TTY_DBG("%s:call line disc. wakeup\n",
> +				cpc_tty->name);
> +		tty->ldisc->ops->write_wakeup(tty);
> +	}
> +
> +	wake_up_interruptible(&tty->write_wait);

No!

> @@ -1032,38 +1108,40 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
>  	ulong flags;
>  	int res;
>  
> -	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == NULL) {
> -		CPC_TTY_DBG("%s: interface is not TTY\n", pc300dev->dev->name);
> +	cpc_tty = (st_cpc_tty_area *) pc300dev->cpc_tty;
> +	if (cpc_tty == 0) {

This is a pointer. 0 is *not* NULL in C.

>  	if (--cpc_tty_cnt == 0) { 
> -		if (serial_drv.refcount) {
> -			CPC_TTY_DBG("%s: unregister is not possible, refcount=%d",
> -							cpc_tty->name, serial_drv.refcount);
> -			cpc_tty_cnt++;
> -			cpc_tty_unreg_flag = 1;
> -			return;
> -		} else { 
> -			CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
> -			if ((res=tty_unregister_driver(&serial_drv))) { 
> -				CPC_TTY_DBG("%s: ERROR ->unregister the tty driver error=%d\n",
> -								cpc_tty->name,res);
> -			}
> +		CPC_TTY_DBG("%s: unregister the tty driver\n",
> +				cpc_tty->name);
> +		res = tty_unregister_driver(&serial_drv);
> +		if (res) {
> +			CPC_TTY_DBG(
> +				"%s: ERROR ->unregister the tty driver error=%d\n",
> +				cpc_tty->name, res);

You may ignore the retval.

As you could see, I NACK the series. Please fix the issues.

thanks,
-- 
js
suse labs
