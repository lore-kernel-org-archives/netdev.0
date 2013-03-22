From: Ben Collins <benmcollins13@gmail.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 10:50:38 -0400
Message-ID: <63463136-FE5B-462D-9259-53DD5AC61BDB@gmail.com>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com> <1363962193.4431.59.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363962193.4431.59.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mar 22, 2013, at 10:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2011-07-13 at 08:52 -0500, Andy Fleming wrote:
>> The QDisc code does a bunch of locking which is unnecessary if
>> you have hardware which handles all of the queueing. Add
>> support for this, and skip over all of the queueing code if
>> the feature is enabled on a given device, which breaks QDisc
>> support on dpaa_eth, and also coopts the FCOE feature bit.
>> 
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> Signed-off-by: Ben Collins <ben.c@servergy.com>
>> Cc: netdev@vger.kernel.org
>> ---
>> include/linux/netdev_features.h | 2 ++
>> net/core/dev.c                  | 6 ++++++
>> 2 files changed, 8 insertions(+)
>> 
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index 3dd3934..ffb4587 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -56,6 +56,7 @@ enum {
>> 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
>> 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
>> 	NETIF_F_RXALL_BIT,		/* Receive errored frames too */
>> +	NETIF_F_HW_QDISC_BIT,		/* Supports hardware Qdisc */
>> 
>> 	/*
>> 	 * Add your fresh new feature above and remember to update
>> @@ -80,6 +81,7 @@ enum {
>> #define NETIF_F_GSO_ROBUST	__NETIF_F(GSO_ROBUST)
>> #define NETIF_F_HIGHDMA		__NETIF_F(HIGHDMA)
>> #define NETIF_F_HW_CSUM		__NETIF_F(HW_CSUM)
>> +#define NETIF_F_HW_QDISC	__NETIF_F(HW_QDISC)
>> #define NETIF_F_HW_VLAN_FILTER	__NETIF_F(HW_VLAN_FILTER)
>> #define NETIF_F_HW_VLAN_RX	__NETIF_F(HW_VLAN_RX)
>> #define NETIF_F_HW_VLAN_TX	__NETIF_F(HW_VLAN_TX)
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index dffbef7..6818b18 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2743,6 +2743,12 @@ int dev_queue_xmit(struct sk_buff *skb)
>> 
>> 	skb_update_prio(skb);
>> 
>> +	if (dev->features & NETIF_F_HW_QDISC) {
>> +		txq = netdev_pick_tx(dev, skb);
>> +		rc = dev_hard_start_xmit(skb, dev, txq);
>> +		goto out;
>> +	}
>> +
>> 	txq = netdev_pick_tx(dev, skb);
>> 	q = rcu_dereference_bh(txq->qdisc);
>> 
> 
> Nobody forces you to use a qdisc.
> 
> And if your device really is lockless, it can use NETIF_F_LLTX feature.


        NETIF_F_LLTX_BIT,               /* LockLess TX - deprecated. Please */
                                        /* do not use LLTX in new drivers */

--
Servergy  : http://www.servergy.com/
SwissDisk : http://www.swissdisk.com/
Ubuntu    : http://www.ubuntu.com/
My Blog   : http://ben-collins.blogspot.com/
