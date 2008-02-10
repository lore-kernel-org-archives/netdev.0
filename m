From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] [resend] 3c509: convert to isa_driver and pnp_driver v4
Date: Sun, 10 Feb 2008 01:10:07 +0100
Message-ID: <200802100110.09301.linux@rainbow-software.org>
References: <200801312012.43447.linux@rainbow-software.org> <200802092233.10239.linux@rainbow-software.org> <20080209134805.29cbc8ae@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757588AbYBJAKl@vger.kernel.org>
In-Reply-To: <20080209134805.29cbc8ae@extreme>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 09 February 2008 22:48:05 Stephen Hemminger wrote:
> On Sat, 9 Feb 2008 22:33:07 +0100
>
> Ondrej Zary <linux@rainbow-software.org> wrote:
> > Hello,
> > this patch converts 3c509 driver to isa_driver and pnp_driver. The result
> > is that autoloading using udev and hibernation works with ISA PnP cards.
> > It also adds hibernation support for non-PnP ISA cards.
> >
> > xcvr module parameter was removed as its value was not used.
> >
> > Tested using 3 ISA cards in various combinations of PnP and non-PnP
> > modes. EISA and MCA only compile-tested.
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> >
> > --- linux-2.6.24-orig/drivers/net/3c509.c	2008-01-27 19:48:19.000000000
> > +0100 +++ linux-2.6.24-pentium/drivers/net/3c509.c	2008-02-07
> > 17:58:45.000000000 +0100 @@ -54,25 +54,24 @@
> >  		v1.19a 28Oct2002 Davud Ruggiero <jdr@farfalle.com>
> >  			- Increase *read_eeprom udelay to workaround oops with 2 cards.
> >  		v1.19b 08Nov2002 Marc Zyngier <maz@wild-wind.fr.eu.org>
> > -		    - Introduce driver model for EISA cards.
> > +			- Introduce driver model for EISA cards.
> > +		v1.20  04Feb2008 Ondrej Zary <linux@rainbow-software.org>
> > +			- convert to isa_driver and pnp_driver and some cleanups
> >  */
>
> Don't bother with comment, kernel uses git change log to figure out
> who to blame.
>
> >  #define DRV_NAME	"3c509"
> > -#define DRV_VERSION	"1.19b"
> > -#define DRV_RELDATE	"08Nov2002"
> > +#define DRV_VERSION	"1.20"
> > +#define DRV_RELDATE	"04Feb2008"
> >
> >  /* A few values that may be tweaked. */
> >
> >  /* Time in jiffies before concluding the transmitter is hung. */
> >  #define TX_TIMEOUT  (400*HZ/1000)
> > -/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
> > -static int max_interrupt_work = 10;
> >
> >  #include <linux/module.h>
> > -#ifdef CONFIG_MCA
> >  #include <linux/mca.h>
> > -#endif
> > -#include <linux/isapnp.h>
> > +#include <linux/isa.h>
> > +#include <linux/pnp.h>
> >  #include <linux/string.h>
> >  #include <linux/interrupt.h>
> >  #include <linux/errno.h>
> > @@ -97,10 +96,6 @@
> >
> >  static char version[] __initdata = DRV_NAME ".c:" DRV_VERSION " "
> > DRV_RELDATE " becker@scyld.com\n";
> >
> > -#if defined(CONFIG_PM) && (defined(CONFIG_MCA) || defined(CONFIG_EISA))
> > -#define EL3_SUSPEND
> > -#endif
> > -
> >  #ifdef EL3_DEBUG
> >  static int el3_debug = EL3_DEBUG;
> >  #else
> > @@ -111,6 +106,7 @@
> >   * a global variable so that the mca/eisa probe routines can increment
> >   * it */
> >  static int el3_cards = 0;
> > +#define EL3_MAX_CARDS 8
> >
> >  /* To minimize the size of the driver source I only define operating
> >     constants if they are used several times.  You'll need the manual
> > @@ -119,7 +115,7 @@
> >  #define EL3_DATA 0x00
> >  #define EL3_CMD 0x0e
> >  #define EL3_STATUS 0x0e
> > -#define	 EEPROM_READ 0x80
> > +#define	EEPROM_READ 0x80
> >
> >  #define EL3_IO_EXTENT	16
> >
> > @@ -168,23 +164,31 @@
> >   */
> >  #define SKB_QUEUE_SIZE	64
> >
> > +typedef enum { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA } el3_cardtype;
> > +
>
> No typedef please (see checkpatch)

Is there any standard way to solve this without a typedef? I added 
el3_dev_fill() function which fills that card type value according to a 
parameter passed to it. "int" could be used instead and "#define EL3_ISA 
0", "#define EL3_PNP 1" - but I think that's ugly.

>
> >  struct el3_private {
> >  	struct net_device_stats stats;
>
> Use network device stats in net_device now

OK, looks like the driver will need some more patches.

> > -	struct net_device *next_dev;
> >  	spinlock_t lock;
> >  	/* skb send-queue */
> >  	int head, size;
> >  	struct sk_buff *queue[SKB_QUEUE_SIZE];
>
> What about sk_buff_head (linked list instead)?

I don't know anything about this, maybe in next patch.

>
> > -	enum {
> > -		EL3_MCA,
> > -		EL3_PNP,
> > -		EL3_EISA,
> > -	} type;						/* type of device */
> > -	struct device *dev;
> > +	el3_cardtype type;
> >  };
> > -static int id_port __initdata = 0x110;	/* Start with 0x110 to avoid new
> > sound cards.*/ -static struct net_device *el3_root_dev;
> > +static int id_port;
> > +static int current_tag;
> > +static struct net_device *el3_devs[EL3_MAX_CARDS];
>
> I know is only ISA, but having a limit seems silly, can't the device just
> use allocated space like other drivers.

EL3_MAX_CARDS is also used as a parameter to isa_register_driver(). The irq[] 
array (see below) is limited to 8 devices too. And finally, the card itself 
can use one of 8 different IRQs (3,5,7,2/9,10,11,12,15). So I think that it's 
not worth adding more code to support more cards.
The original driver will do bad things with more than 8 cards too - read 
beyond the end of irq[] array.

> > +
> > +/* Parameters that may be passed into the module. */
> > +static int debug = -1;
> > +static int irq[] = {-1, -1, -1, -1, -1, -1, -1, -1};
> > +/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
> > +static int max_interrupt_work = 10;
> > +#ifdef CONFIG_PNP
> > +static int nopnp;
> > +#endif

-- 
Ondrej Zary
