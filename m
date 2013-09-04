From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Query about TX BD Reclaim in Napi poll path (was Re: [PATCH v3] ethernet/arc/arc_emac
 - Add new driver)
Date: Wed, 4 Sep 2013 17:44:30 +0530
Message-ID: <52272426.2040504@synopsys.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com> <20130613221946.GA16632@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	<netdev@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130613221946.GA16632@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

Resurrecting an old thread.

On 06/14/2013 03:49 AM, Francois Romieu wrote:
>> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
>> > +{
>> > +	struct net_device *ndev = dev_instance;
>> > +	struct arc_emac_priv *priv = netdev_priv(ndev);
>> > +	struct net_device_stats *stats = &priv->stats;
>> > +	unsigned int status;
>> > +
>> > +	status = arc_reg_get(priv, R_STATUS);
>> > +	status &= ~MDIO_MASK;
>> > +
>> > +	/* Reset all flags except "MDIO complete"*/
>> > +	arc_reg_set(priv, R_STATUS, status);
>> > +
>> > +	if (status & RXINT_MASK) {
>> > +		if (likely(napi_schedule_prep(&priv->napi))) {
>> > +			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
>> > +			__napi_schedule(&priv->napi);
>> > +		}
>> > +	}
>> > +
>> > +	if (status & TXINT_MASK) {
> You may consider moving everything into the napi poll handler.

I has to revisit this now-mainlined driver recently for fixing a bug. Per your
suggestion above, the TX BD reclaim was moved from interrupt context to NAPI
context. I was wondering if that is the right thing to do (I'm not a networking
expert but have worked on this driver heavily before it was mainlined by Alexey).

In case of large burst transfers by networking stack (say a large file copy over
NFS) will it not delay the TX BD reclaim possibly dropping more packets. Ofcourse
doing this requires enabling Tx interrupts which adds to overall cost from a
system perspective, but assuming the controller can coalesce the Tx interrupts,
will it not be better.

I did a quick hack to move the TX reclaim in intr path and it seems to be doing
slightly better than the current code - so the advantages are not sky high, but I
want to understand the implications nevertheless.

TIA,
-Vineet
