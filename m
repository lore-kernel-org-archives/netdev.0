From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: Tue, 12 Sep 2006 12:07:49 +0200
Message-ID: <1158055669.3032.11.camel@laptopd505.fenrus.org>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
	 <1158051351.14448.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jgarzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:24253 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S964943AbWILKIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 06:08:20 -0400
To: Zang Roy-r61911 <tie-fei.zang@freescale.com>
In-Reply-To: <1158051351.14448.97.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-12 at 16:55 +0800, Zang Roy-r61911 wrote:
> The driver for tsi108/9 on chip Ethernet port

Hi,

I have some review comments about your driver; please consider them for
fixing....

> +
> +#undef DEBUG
> +#ifdef DEBUG
> +#define DBG(fmt...) do { printk(fmt); } while(0)
> +#else
> +#define DBG(fmt...) do { } while(0)
> +#endif

please don't do this, there is pr_debug and dev_dbg() for a reason
already. No reason to add a copy.

> +
> +typedef struct net_device net_device;
> +typedef struct sk_buff sk_buff;

Please don't do this...



> +	TSI108_ETH_WRITE_PHYREG(TSI108_MAC_MII_ADDR,
> +				(data->phy << TSI108_MAC_MII_ADDR_PHY) |
> +				(reg << TSI108_MAC_MII_ADDR_REG));
> +	mb();
> +	TSI108_ETH_WRITE_PHYREG(TSI108_MAC_MII_CMD, 0);
> +	mb();
> +	TSI108_ETH_WRITE_PHYREG(TSI108_MAC_MII_CMD, TSI108_MAC_MII_CMD_READ);
> +	mb();

what is this mb() for? do you want them to be an io memory barrier?

> +	while (TSI108_ETH_READ_REG(TSI108_MAC_MII_IND) &
> +	       TSI108_MAC_MII_IND_BUSY) ;

do you want this to be an infinate loop? At minimum the ";" needs to be
a cpu_relax() to avoid the cpu from burning up but it'd be a lot nicer
if this loop wasn't infinite




> +
> +static irqreturn_t tsi108_irq(int irq, void *dev_id, struct pt_regs *regs)
> +{
> +	if (irq == NO_IRQ)
> +		return IRQ_NONE;	/* Not our interrupt */
> +
> +	return tsi108_irq_one(dev_id);
> +}

hi this IRQ_NONE just looks odd, was this really needed?



> +	mb();
> +	while (tsi108_read_mii(data, PHY_CTRL, NULL) & PHY_CTRL_AUTONEG_START)
> +		;

another infinite loop that wants cpu_relax() for sure

> +		spin_unlock_irq(&phy_lock);
> +		msleep(10);
> +		spin_lock_irq(&phy_lock);
> +	}

hmm some places take phy_lock with disabling interrupts, while others
don't. I sort of fear "the others" may be buggy.... are you sure those
are ok?



Greetings,
   Arjan van de Ven

