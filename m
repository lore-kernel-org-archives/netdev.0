From: Robert Olsson <robert@herjulf.net>
Subject: [PATCH 1/2] net: add IFF_SKB_TX_SHARED flag to priv_flags
Date: Thu, 28 Jul 2011 10:15:57 +0200
Message-ID: <20017.6845.709352.510592@gargle.gargle.HOWL>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
	<1311696338-4739-2-git-send-email-nhorman@tuxdriver.com>
Reply-To: robert@herjulf.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert.olsson@its.uu.se>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:52534 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839Ab1G1ILv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:11:51 -0400
In-Reply-To: <1311696338-4739-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Yes seems like good solution to disable this feature individually for "unsupported" drivers
Maybe Dave has some additional comments.

Thanks for fixing this.

Cheers.
						--ro

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
	       	      


Neil Horman writes:
 > Pktgen attempts to transmit shared skbs to net devices, which can't be used by
 > some drivers as they keep state information in skbs.  This patch adds a flag
 > marking drivers as being able to handle shared skbs in their tx path.  Drivers
 > are defaulted to being unable to do so, but calling ether_setup enables this
 > flag, as 90% of the drivers calling ether_setup touch real hardware and can
 > handle shared skbs.  A subsequent patch will audit drivers to ensure that the
 > flag is set properly
 > 
 > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
 > Reported-by: Jiri Pirko <jpirko@redhat.com>
 > CC: Robert Olsson <robert.olsson@its.uu.se>
 > CC: Eric Dumazet <eric.dumazet@gmail.com>
 > CC: Alexey Dobriyan <adobriyan@gmail.com>
 > CC: David S. Miller <davem@davemloft.net>
 > ---
 >  include/linux/if.h |    2 ++
 >  net/core/pktgen.c  |    8 +++++---
 >  net/ethernet/eth.c |    1 +
 >  3 files changed, 8 insertions(+), 3 deletions(-)
 > 
 > diff --git a/include/linux/if.h b/include/linux/if.h
 > index 3bc63e6..03489ca 100644
 > --- a/include/linux/if.h
 > +++ b/include/linux/if.h
 > @@ -76,6 +76,8 @@
 >  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
 >  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
 >  					 * datapath port */
 > +#define IFF_TX_SKB_SHARING	0x10000	/* The interface supports sharing
 > +					 * skbs on transmit */
 >  
 >  #define IF_GET_IFACE	0x0001		/* for querying only */
 >  #define IF_GET_PROTO	0x0002
 > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
 > index f76079c..e35a6fb 100644
 > --- a/net/core/pktgen.c
 > +++ b/net/core/pktgen.c
 > @@ -1070,7 +1070,9 @@ static ssize_t pktgen_if_write(struct file *file,
 >  		len = num_arg(&user_buffer[i], 10, &value);
 >  		if (len < 0)
 >  			return len;
 > -
 > +		if ((value > 0) &&
 > +		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
 > +			return -ENOTSUPP;
 >  		i += len;
 >  		pkt_dev->clone_skb = value;
 >  
 > @@ -3555,7 +3557,6 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 >  	pkt_dev->min_pkt_size = ETH_ZLEN;
 >  	pkt_dev->max_pkt_size = ETH_ZLEN;
 >  	pkt_dev->nfrags = 0;
 > -	pkt_dev->clone_skb = pg_clone_skb_d;
 >  	pkt_dev->delay = pg_delay_d;
 >  	pkt_dev->count = pg_count_d;
 >  	pkt_dev->sofar = 0;
 > @@ -3563,7 +3564,6 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 >  	pkt_dev->udp_src_max = 9;
 >  	pkt_dev->udp_dst_min = 9;
 >  	pkt_dev->udp_dst_max = 9;
 > -
 >  	pkt_dev->vlan_p = 0;
 >  	pkt_dev->vlan_cfi = 0;
 >  	pkt_dev->vlan_id = 0xffff;
 > @@ -3575,6 +3575,8 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 >  	err = pktgen_setup_dev(pkt_dev, ifname);
 >  	if (err)
 >  		goto out1;
 > +	if (pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)
 > +		pkt_dev->clone_skb = pg_clone_skb_d;
 >  
 >  	pkt_dev->entry = proc_create_data(ifname, 0600, pg_proc_dir,
 >  					  &pktgen_if_fops, pkt_dev);
 > diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
 > index 5cffb63..4866330 100644
 > --- a/net/ethernet/eth.c
 > +++ b/net/ethernet/eth.c
 > @@ -339,6 +339,7 @@ void ether_setup(struct net_device *dev)
 >  	dev->addr_len		= ETH_ALEN;
 >  	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
 >  	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 > +	dev->priv_flags		= IFF_TX_SKB_SHARING;
 >  
 >  	memset(dev->broadcast, 0xFF, ETH_ALEN);
 >  
 > -- 
 > 1.7.6
 > 
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
