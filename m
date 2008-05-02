From: Michael Abbott <michael@araneidae.co.uk>
Subject: Re: [PATCH] DM9000: Restore MII physical polling timer.
Date: Fri, 2 May 2008 07:23:53 +0000 (GMT)
Message-ID: <20080501063432.E18144@saturn.araneidae.co.uk>
References: <20080424095217.P51356@saturn.araneidae.co.uk>
 <20080428151411.GF16284@fluff.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@gver.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20080428151411.GF16284@fluff.org.uk>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Apr 2008, Ben Dooks wrote:
> On Thu, Apr 24, 2008 at 10:12:59AM +0000, Michael Abbott wrote:
>> From: Michael Abbott <michael.abbott@diamond.ac.uk>
>>
>> DM9000: Restore MII physical polling timer.
>>
>> In commit fcfa81aa3e8d885356139122fcb281487b983468 the timer for polling the
>> MII physical layer was removed because of conflicts with newly added mutexes.
>> Unfortunately a side effect of this change is that the corresponding ethernet
>> layer is permanently reported as down: there is no other way to read the link
>> status.
>>
>> This commit restores the timer, but uses the default work queue for polling.
>
> I've already submitted a similar patch to netdev@vger.kernel.org

I presume you mean the patch at
 	http://marc.info/?l=linux-netdev&m=120818415110509&w=2
?

If so, I think there's something not quite right with your timer 
cancellation -- as far as I can tell (the workqueue code seems to have 
been under quite a bit of flux, and the comments are sparse) we should be 
using cancel_delayed_work_sync() -- this appears to be the correct routine 
for cancelling a self retriggering workqueue timer.

If this change is made (and the corresponding simplifications made -- for 
example, it also appears to be defined that container_of can be used 
directly on the work_struct*, since delayed_work is defined to place the 
work_struct at the start -- then your patch becomes effectively identical 
to my patch below.


>
>> Signed-off-by: Michael Abbott <michael.abbott@diamond.ac.uk>
>> ---
>>  drivers/net/dm9000.c |   21 +++++++++++++++++++++
>>  1 files changed, 21 insertions(+), 0 deletions(-)
>>
>> This patch is against 2.6.25, and has been tested with the Colibri PXA270
>> board (patch follows separately).
>>
>> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
>> index d63cc93..9ad9499 100644
>> --- a/drivers/net/dm9000.c
>> +++ b/drivers/net/dm9000.c
>> @@ -43,6 +43,7 @@
>>  /* Board/System/Debug information/definition ---------------- */
>>
>>  #define DM9000_PHY		0x40	/* PHY address 0x01 */
>> +#define DM9000_TIMER_WUT	(HZ*2)	/* timer wakeup time : 2 second */
>>
>>  #define CARDNAME "dm9000"
>>  #define PFX CARDNAME ": "
>> @@ -117,6 +118,8 @@ typedef struct board_info {
>>
>>  	struct mutex	 addr_lock;	/* phy and eeprom access lock */
>>
>> +	struct delayed_work timer;	/* Interface status timer. */
>> +
>>  	spinlock_t lock;
>>
>>  	struct mii_if_info mii;
>> @@ -144,6 +147,7 @@ static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
>>  static int dm9000_stop(struct net_device *);
>>  static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
>>
>> +static void dm9000_timer(struct work_struct * work);
>>  static void dm9000_init_dm9000(struct net_device *);
>>
>>  static irqreturn_t dm9000_interrupt(int, void *);
>> @@ -762,6 +766,10 @@ dm9000_open(struct net_device *dev)
>>  	mii_check_media(&db->mii, netif_msg_link(db), 1);
>>  	netif_start_queue(dev);
>>
>> +	/* Start the media status timer running. */
>> +	INIT_DELAYED_WORK(&db->timer, dm9000_timer);
>> +	schedule_delayed_work(&db->timer, DM9000_TIMER_WUT);
>> +
>>  	return 0;
>>  }
>>
>> @@ -876,6 +884,9 @@ dm9000_stop(struct net_device *ndev)
>>  {
>>  	board_info_t *db = (board_info_t *) ndev->priv;
>>
>> +	/* Delete the timer and make sure it's not running right now! */
>> +	cancel_delayed_work_sync(&db->timer);
>> +
>>  	if (netif_msg_ifdown(db))
>>  		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
>>
>> @@ -965,6 +976,16 @@ dm9000_interrupt(int irq, void *dev_id)
>>  	return IRQ_HANDLED;
>>  }
>>
>> +
>> +/* Two second timer to poll the media status -- the DM9000 doesn't provide a
>> + * status interrupt, so this has to be polled. */
>> +static void dm9000_timer(struct work_struct * work)
>> +{
>> +	board_info_t *db = container_of(work, board_info_t, timer);
>> +	mii_check_media(&db->mii, netif_msg_link(db), 0);
>> +	schedule_delayed_work(&db->timer, DM9000_TIMER_WUT);
>> +}
>> +
>>  struct dm9000_rxhdr {
>>  	u8	RxPktReady;
>>  	u8	RxStatus;
>> --
>> 1.5.5
