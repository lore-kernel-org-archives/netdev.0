From: Darren Williams <dsw@gelato.unsw.edu.au>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Fri, 7 Jan 2005 16:30:09 +1100
Message-ID: <20050107053009.GI17027@cse.unsw.EDU.AU>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU> <20041220161552.2b88aa3d.davem@davemloft.net> <16839.30796.413939.333935@wombat.chubb.wattle.id.au> <20050106151910.4d51673e.davem@davemloft.net> <20050107001743.GH17027@cse.unsw.EDU.AU> <20050106194838.0909020a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050106194838.0909020a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David

On Thu, 06 Jan 2005, David S. Miller wrote:

> On Fri, 7 Jan 2005 11:17:44 +1100
> Darren Williams <dsw@gelato.unsw.edu.au> wrote:
> 
> > No, if I revert back to an earlier driver the link comes
> > up OK printing:
> >   tg3: eth0: Link is up at 1000 Mbps, full duplex.
> >   tg3: eth0: Flow control is off for TX and off for RX.
> > after a short delay. With the current dirver I do not
> > see any prinks from tg3_link_report about the state
> > of the link.
> 
> Is the working verion with Peter's patch applied?
No see below.

> 
> In any case, please try this one instead which is a variant
> of the second patch Peter proposed plus some signedness fixes
> I've done.
> 
No still no link. The patch that I have working is:
tg3.c:v2.9 (March 8, 2004)
that I took from 2.6.7

> Thanks.
> 
> --- ../linus-2.6/drivers/net/tg3.c	2005-01-06 19:23:03.000000000 -0800
> +++ drivers/net/tg3.c	2005-01-06 19:22:53.000000000 -0800
> @@ -60,8 +60,8 @@
>  
>  #define DRV_MODULE_NAME		"tg3"
>  #define PFX DRV_MODULE_NAME	": "
> -#define DRV_MODULE_VERSION	"3.14"
> -#define DRV_MODULE_RELDATE	"November 15, 2004"
> +#define DRV_MODULE_VERSION	"3.15"
> +#define DRV_MODULE_RELDATE	"January 6, 2005"
>  
>  #define TG3_DEF_MAC_MODE	0
>  #define TG3_DEF_RX_MODE		0
> @@ -493,7 +493,8 @@
>  static int tg3_readphy(struct tg3 *tp, int reg, u32 *val)
>  {
>  	u32 frame_val;
> -	int loops, ret;
> +	unsigned int loops;
> +	int ret;
>  
>  	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
>  		tw32_f(MAC_MI_MODE,
> @@ -512,7 +513,7 @@
>  	tw32_f(MAC_MI_COM, frame_val);
>  
>  	loops = PHY_BUSY_LOOPS;
> -	while (loops-- > 0) {
> +	while (loops != 0) {
>  		udelay(10);
>  		frame_val = tr32(MAC_MI_COM);
>  
> @@ -521,10 +522,11 @@
>  			frame_val = tr32(MAC_MI_COM);
>  			break;
>  		}
> +		loops -= 1;
>  	}
>  
>  	ret = -EBUSY;
> -	if (loops > 0) {
> +	if (loops != 0) {
>  		*val = frame_val & MI_COM_DATA_MASK;
>  		ret = 0;
>  	}
> @@ -540,7 +542,8 @@
>  static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
>  {
>  	u32 frame_val;
> -	int loops, ret;
> +	unsigned int loops;
> +	int ret;
>  
>  	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
>  		tw32_f(MAC_MI_MODE,
> @@ -558,7 +561,7 @@
>  	tw32_f(MAC_MI_COM, frame_val);
>  
>  	loops = PHY_BUSY_LOOPS;
> -	while (loops-- > 0) {
> +	while (loops != 0) {
>  		udelay(10);
>  		frame_val = tr32(MAC_MI_COM);
>  		if ((frame_val & MI_COM_BUSY) == 0) {
> @@ -566,10 +569,11 @@
>  			frame_val = tr32(MAC_MI_COM);
>  			break;
>  		}
> +		loops -= 1;
>  	}
>  
>  	ret = -EBUSY;
> -	if (loops > 0)
> +	if (loops != 0)
>  		ret = 0;
>  
>  	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
> @@ -1557,7 +1561,9 @@
>  	bmsr = 0;
>  	for (i = 0; i < 100; i++) {
>  		tg3_readphy(tp, MII_BMSR, &bmsr);
> -		tg3_readphy(tp, MII_BMSR, &bmsr);
> +		if (tg3_readphy(tp, MII_BMSR, &bmsr))
> +			bmsr = 0;
> +
>  		if (bmsr & BMSR_LSTATUS)
>  			break;
>  		udelay(40);
> @@ -1640,7 +1646,9 @@
>  		tg3_phy_copper_begin(tp);
>  
>  		tg3_readphy(tp, MII_BMSR, &tmp);
> -		tg3_readphy(tp, MII_BMSR, &tmp);
> +		if (tg3_readphy(tp, MII_BMSR, &tmp))
> +			tmp = 0;
> +
>  		if (tmp & BMSR_LSTATUS)
>  			current_link_up = 1;
>  	}
> @@ -7209,7 +7217,8 @@
>  		u32 bmsr, adv_reg, tg3_ctrl;
>  
>  		tg3_readphy(tp, MII_BMSR, &bmsr);
> -		tg3_readphy(tp, MII_BMSR, &bmsr);
> +		if (tg3_readphy(tp, MII_BMSR, &bmsr))
> +			bmsr = 0;
>  
>  		if (bmsr & BMSR_LSTATUS)
>  			goto skip_phy_reset;
--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
