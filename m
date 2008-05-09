From: Michael Abbott <michael@araneidae.co.uk>
Subject: Re: FW: DM9000: Use delayed work to update MII PHY state
Date: Fri, 9 May 2008 07:19:36 +0000 (GMT)
Message-ID: <20080509064046.L67628@saturn.araneidae.co.uk>
References: <4854F2500EA8C4478A508D2D92973E5215401A@EXCHANGE25.fed.cclrc.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Daniel Mack <daniel@caiaq.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from araneidae.co.uk ([62.3.233.233]:2063 "EHLO mail.araneidae.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbYEIHfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 03:35:01 -0400
In-Reply-To: <4854F2500EA8C4478A508D2D92973E5215401A@EXCHANGE25.fed.cclrc.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 8 May 2008 11:36:42 +0100
> Ben Dooks <ben-linux@fluff.org> wrote:
> 
> > Periodically check the MII PHY status to ensure that the
> > network layer's link status is updated and the user informed
> > of any changes.
> > 
> > Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> > 
> > Index: linux-2.6.25-rc9-quilt2/drivers/net/dm9000.c
> > ===================================================================
> > --- linux-2.6.25-rc9-quilt2.orig/drivers/net/dm9000.c	2008-04-14 16:41:12.000000000 +0100
> > +++ linux-2.6.25-rc9-quilt2/drivers/net/dm9000.c	2008-04-15 00:33:08.000000000 +0100
> > @@ -117,6 +117,9 @@ typedef struct board_info {
> >  
> >  	struct mutex	 addr_lock;	/* phy and eeprom access lock */
> >  
> > +	struct delayed_work phy_poll;
> > +	struct net_device  *ndev;
> > +
> >  	spinlock_t lock;
> >  
> >  	struct mii_if_info mii;
> > @@ -297,6 +300,10 @@ static void dm9000_set_io(struct board_i
> >  	}
> >  }
> >  
> > +static void dm9000_schedule_poll(board_info_t *db)
> > +{
> > +	schedule_delayed_work(&db->phy_poll, HZ * 2);
> > +}
> >  
> >  /* Our watchdog timed out. Called by the networking layer */
> >  static void dm9000_timeout(struct net_device *dev)
> > @@ -465,6 +472,17 @@ static const struct ethtool_ops dm9000_e
> >   	.set_eeprom		= dm9000_set_eeprom,
> >  };
> >  
> > +static void
> > +dm9000_poll_work(struct work_struct *w)
> > +{
> > +	struct delayed_work *dw = container_of(w, struct delayed_work, work);
> > +	board_info_t *db = container_of(dw, board_info_t, phy_poll);
> > +
> > +	mii_check_media(&db->mii, netif_msg_link(db), 0);
> > +	
> > +	if (netif_running(db->ndev))
> > +		dm9000_schedule_poll(db);
> > +}
> >  
> >  /* dm9000_release_board
> >   *
> > @@ -532,10 +550,14 @@ dm9000_probe(struct platform_device *pde
> >  	memset(db, 0, sizeof (*db));
> >  
> >  	db->dev = &pdev->dev;
> > +	db->ndev = ndev;
> >  
> >  	spin_lock_init(&db->lock);
> >  	mutex_init(&db->addr_lock);
> >  
> > +	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
> > +
> > +
> >  	if (pdev->num_resources < 2) {
> >  		ret = -ENODEV;
> >  		goto out;
> > @@ -761,6 +783,8 @@ dm9000_open(struct net_device *dev)
> >  
> >  	mii_check_media(&db->mii, netif_msg_link(db), 1);
> >  	netif_start_queue(dev);
> > +	
> > +	dm9000_schedule_poll(db);
> >  
> >  	return 0;
> >  }
> > @@ -879,6 +903,8 @@ dm9000_stop(struct net_device *ndev)
> >  	if (netif_msg_ifdown(db))
> >  		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
> >  
> > +	cancel_delayed_work(&db->phy_poll);
> > +
> >  	netif_stop_queue(ndev);
> >  	netif_carrier_off(ndev);
> >  
> 
> The above patch breaks dm9000-restore-mii-physical-polling-timer.patch,
> below.
> 
> Perhaps they both fix the same thing?

That is precisely correct.  

In fact, the only practical difference between the two patches is the 
mechanism for cancelling the timer.  My patch below relies on the promise 
by cancel_delayed_work_sync that it will successfully cancel a self 
retriggering timer (that is, I am assuming that it will 1/ wait for the 
job to finish running if it's already started; and 2/ ensure that it never 
runs again, even if it retriggers).

Ben Dooks' patch appears to take an extra precaution inside the timer 
routine:

+	if (netif_running(db->ndev))
+		dm9000_schedule_poll(db);

but I'm not convinced that his patch properly synchronises with the status 
timer (as it uses cancel_delayed_work instead).

> 
> From: Michael Abbott <michael.abbott@diamond.ac.uk>
> 
> In commit fcfa81aa3e8d885356139122fcb281487b983468 the timer for polling the
> MII physical layer was removed because of conflicts with newly added mutexes. 
> Unfortunately a side effect of this change is that the corresponding ethernet
> layer is permanently reported as down: there is no other way to read the link
> status.
> 
> This commit restores the timer, but uses the default work queue for polling.
> 
> Signed-off-by: Michael Abbott <michael.abbott@diamond.ac.uk>
> Cc: Daniel Mack <daniel@caiaq.org>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/dm9000.c |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff -puN drivers/net/dm9000.c~dm9000-restore-mii-physical-polling-timer drivers/net/dm9000.c
> --- a/drivers/net/dm9000.c~dm9000-restore-mii-physical-polling-timer
> +++ a/drivers/net/dm9000.c
> @@ -43,6 +43,7 @@
>  /* Board/System/Debug information/definition ---------------- */
>  
>  #define DM9000_PHY		0x40	/* PHY address 0x01 */
> +#define DM9000_TIMER_WUT	(HZ*2)	/* timer wakeup time : 2 second */
>  
>  #define CARDNAME "dm9000"
>  #define PFX CARDNAME ": "
> @@ -117,6 +118,8 @@ typedef struct board_info {
>  
>  	struct mutex	 addr_lock;	/* phy and eeprom access lock */
>  
> +	struct delayed_work timer;	/* Interface status timer. */
> +
>  	spinlock_t lock;
>  
>  	struct mii_if_info mii;
> @@ -144,6 +147,7 @@ static int dm9000_start_xmit(struct sk_b
>  static int dm9000_stop(struct net_device *);
>  static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
>  
> +static void dm9000_timer(struct work_struct * work);
>  static void dm9000_init_dm9000(struct net_device *);
>  
>  static irqreturn_t dm9000_interrupt(int, void *);
> @@ -762,6 +766,10 @@ dm9000_open(struct net_device *dev)
>  	mii_check_media(&db->mii, netif_msg_link(db), 1);
>  	netif_start_queue(dev);
>  
> +	/* Start the media status timer running. */
> +	INIT_DELAYED_WORK(&db->timer, dm9000_timer);
> +	schedule_delayed_work(&db->timer, DM9000_TIMER_WUT);
> +
>  	return 0;
>  }
>  
> @@ -876,6 +884,9 @@ dm9000_stop(struct net_device *ndev)
>  {
>  	board_info_t *db = (board_info_t *) ndev->priv;
>  
> +	/* Delete the timer and make sure it's not running right now! */
> +	cancel_delayed_work_sync(&db->timer);
> +
>  	if (netif_msg_ifdown(db))
>  		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
>  
> @@ -965,6 +976,16 @@ dm9000_interrupt(int irq, void *dev_id)
>  	return IRQ_HANDLED;
>  }
>  
> +
> +/* Two second timer to poll the media status -- the DM9000 doesn't provide a
> + * status interrupt, so this has to be polled. */
> +static void dm9000_timer(struct work_struct * work)
> +{
> +	board_info_t *db = container_of(work, board_info_t, timer);
> +	mii_check_media(&db->mii, netif_msg_link(db), 0);
> +	schedule_delayed_work(&db->timer, DM9000_TIMER_WUT);
> +}
> +
>  struct dm9000_rxhdr {
>  	u8	RxPktReady;
>  	u8	RxStatus;
> _
> 
> <DIV><FONT size="1" color="gray">This e-mail and any attachments may contain confidential, copyright and or privileged material, and are for the use of the intended addressee only. If you are not the intended addressee or an authorised recipient of the addressee please notify us of receipt by returning the e-mail and do not use, copy, retain, distribute or disclose the information in or attached to the e-mail.
> Any opinions expressed within this e-mail are those of the individual and not necessarily of Diamond Light Source Ltd. 
> Diamond Light Source Ltd. cannot guarantee that this e-mail or any attachments are free from viruses and we cannot accept liability for any damage which you may sustain as a result of software viruses which may be transmitted in or with the message.
> Diamond Light Source Limited (company no. 4375679). Registered in England and Wales with its registered office at Diamond House, Harwell Science and Innovation Campus, Didcot, Oxfordshire, OX11 0DE, United Kingdom
> </FONT></DIV> 
> 
