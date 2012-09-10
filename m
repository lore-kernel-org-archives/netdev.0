From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RFC: mac802154 Packet Queueing and Slave
	Devices
Date: Mon, 10 Sep 2012 08:12:27 +0200
Message-ID: <1347257547.1234.1110.camel@edumazet-glaptop>
References: <504D37A7.60109@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <504D37A7.60109-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-09-09 at 20:43 -0400, Alan Ott wrote:
> Hi,
> 
> Tony and I were recently talking about packet queueing on 802.15.4. What
> currently happens (in net/mac802154/tx.c) is that each tx packet (skb)
> is stuck on a work queue, and the worker function then sends each packet
> to the hardware driver in order.
> 
> The problem with this is that it defeats the netif flow control.

And qdisc ability to better control bufferbloat...

By the way, mac802154_tx() looks buggy :

if (!(priv->phy->channels_supported[page] & (1 << chan))) {
	WARN_ON(1);
	// Here, a kfree_skb(skb) is missing.
	return NETDEV_TX_OK;
}
if (skb_cow_head(skb, priv->hw.extra_tx_headroom)) {
	dev_kfree_skb(skb);  // should be kfree_skb(skb)
	return NETDEV_TX_OK;
}
work = kzalloc(sizeof(struct xmit_work), GFP_ATOMIC);
if (!work)
	return NETDEV_TX_BUSY;

NETDEV_TX_BUSY is going to loop. So if there is really no more memory,
its a deadlock. You should instead kfree_skb(skb) and return
NETDEV_TX_OK.

Also mac802154_wpan_xmit() returns NETDEV_TX_OK without kfree_skb(skb)
here :

if (chan == MAC802154_CHAN_NONE ||
    page >= WPAN_NUM_PAGES ||
    chan >= WPAN_NUM_CHANNELS)
	return NETDEV_TX_OK;




------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
