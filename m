From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-2.6] tg3: Fix phylib locking strategy
Date: Mon, 5 Oct 2009 14:29:57 -0700
Message-ID: <1254778197.8559.2.camel@HP1>
References: <1254777182.18287@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Felix Radensky" <felix@embedded-sol.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1867 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753760AbZJEVjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 17:39:39 -0400
In-Reply-To: <1254777182.18287@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-10-05 at 14:09 -0700, Matt Carlson wrote:
> Felix, can you verify this solves your problem?
> 
> ---
> 
> Felix Radensky noted that chip resets were generating stack trace dumps.
> This is because the driver is attempting to acquire the mdio bus mutex
> while holding the tp->lock spinlock.  The fix is to change the code such
> that every phy access takes the tp->lock spinlock instead.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/tg3.c |   37 ++++++++++++-------------------------
>  drivers/net/tg3.h |    1 -
>  2 files changed, 12 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index f09bc5d..8afc60e 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -902,11 +902,12 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
>  	struct tg3 *tp = bp->priv;
>  	u32 val;
>  
> -	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
> -		return -EAGAIN;
> +	spin_lock(&tp->lock);
>  

Matt, do we need spin_lock_bh() here?  The tp->lock can be taken in NAPI
poll BH context.

>  	if (tg3_readphy(tp, reg, &val))
> -		return -EIO;
> +		val = -EIO;
> +
> +	spin_unlock(&tp->lock);
>  
>  	return val;
>  }
> @@ -914,14 +915,16 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
>  static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
>  {
>  	struct tg3 *tp = bp->priv;
> +	u32 ret = 0;
>  
> -	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
> -		return -EAGAIN;
> +	spin_lock(&tp->lock);
>  
>  	if (tg3_writephy(tp, reg, val))
> -		return -EIO;
> +		ret = -EIO;
>  
> -	return 0;
> +	spin_unlock(&tp->lock);
> +
> +	return ret;
>  }
>  
>  static int tg3_mdio_reset(struct mii_bus *bp)
> @@ -1011,12 +1014,6 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
>  
>  static void tg3_mdio_start(struct tg3 *tp)
>  {
> -	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
> -		mutex_lock(&tp->mdio_bus->mdio_lock);
> -		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
> -		mutex_unlock(&tp->mdio_bus->mdio_lock);
> -	}
> -
>  	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
>  	tw32_f(MAC_MI_MODE, tp->mi_mode);
>  	udelay(80);
> @@ -1041,15 +1038,6 @@ static void tg3_mdio_start(struct tg3 *tp)
>  		tg3_mdio_config_5785(tp);
>  }
>  
> -static void tg3_mdio_stop(struct tg3 *tp)
> -{
> -	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
> -		mutex_lock(&tp->mdio_bus->mdio_lock);
> -		tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_PAUSED;
> -		mutex_unlock(&tp->mdio_bus->mdio_lock);
> -	}
> -}
> -
>  static int tg3_mdio_init(struct tg3 *tp)
>  {
>  	int i;
> @@ -1141,7 +1129,6 @@ static void tg3_mdio_fini(struct tg3 *tp)
>  		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_INITED;
>  		mdiobus_unregister(tp->mdio_bus);
>  		mdiobus_free(tp->mdio_bus);
> -		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_PAUSED;
>  	}
>  }
>  
> @@ -6392,8 +6379,6 @@ static int tg3_chip_reset(struct tg3 *tp)
>  
>  	tg3_nvram_lock(tp);
>  
> -	tg3_mdio_stop(tp);
> -
>  	tg3_ape_lock(tp, TG3_APE_LOCK_GRC);
>  
>  	/* No matching tg3_nvram_unlock() after this because
> @@ -8698,6 +8683,8 @@ static int tg3_close(struct net_device *dev)
>  
>  	del_timer_sync(&tp->timer);
>  
> +	tg3_phy_stop(tp);
> +
>  	tg3_full_lock(tp, 1);
>  #if 0
>  	tg3_dump_state(tp);
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index 524691c..bab7940 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2748,7 +2748,6 @@ struct tg3 {
>  #define TG3_FLG3_5701_DMA_BUG		0x00000008
>  #define TG3_FLG3_USE_PHYLIB		0x00000010
>  #define TG3_FLG3_MDIOBUS_INITED		0x00000020
> -#define TG3_FLG3_MDIOBUS_PAUSED		0x00000040
>  #define TG3_FLG3_PHY_CONNECTED		0x00000080
>  #define TG3_FLG3_RGMII_STD_IBND_DISABLE	0x00000100
>  #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200


