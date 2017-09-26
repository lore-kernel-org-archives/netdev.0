From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Tue, 26 Sep 2017 20:01:36 +0200
Message-ID: <20170926180136.GD3325@lunn.ch>
References: <20170926174837.15999-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:56664 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965237AbdIZSBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 14:01:40 -0400
Content-Disposition: inline
In-Reply-To: <20170926174837.15999-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 01:48:37PM -0400, Vivien Didelot wrote:
> mv88e6xxx_g2_irq_free locks the registers mutex, but not
> mv88e6xxx_g1_irq_free, which results in a stack trace from
> assert_reg_lock when unloading the mv88e6xxx module. Fix this.
> 
> Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index c6678aa9b4ef..b4359e4e5165 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -338,9 +338,11 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
>  	int irq, virq;
>  	u16 mask;
>  
> +	mutex_lock(&chip->reg_lock);
>  	mv88e6xxx_g1_read(chip, MV88E6XXX_G1_CTL1, &mask);
>  	mask |= GENMASK(chip->g1_irq.nirqs, 0);
>  	mv88e6xxx_g1_write(chip, MV88E6XXX_G1_CTL1, mask);
> +	mutex_unlock(&chip->reg_lock);
>  
>  	free_irq(chip->irq, chip);
>  

Hi Vivien

static int mv88e6xxx_probe(struct mdio_device *mdiodev)
{

...

out_g1_irq:
	if (chip->irq > 0) {
		mutex_lock(&chip->reg_lock);
		mv88e6xxx_g1_irq_free(chip);
		mutex_unlock(&chip->reg_lock);
	}

It looks like this will deadlock?

In general, i tried to keep the mutex out of the interrupt code.  That
is not totally possible, the IRQ thread handler needs it. But
otherwise, the IRQ code assumes it is called with the mutex taken.

So i think it is better to hold the mutex in mv88e6xxx_remove() when
calling mv88e6xxx_g1_irq_free().

   Andrew
