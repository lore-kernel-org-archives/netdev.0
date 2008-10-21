From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [RFC 1/2] igb: statistic optimization
Date: Tue, 21 Oct 2008 12:30:11 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0810211224440.2736@jbrandeb-desk.amr.corp.intel.com>
References: <20081021120935.1b3cea8d@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jeffery.t.kirsher@intel.com" <jeffery.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36736 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148AbYJUTbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 15:31:14 -0400
In-Reply-To: <20081021120935.1b3cea8d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2008, Stephen Hemminger wrote:
> The network statistics were being updated by multiple CPU's causing cache
> line bounces. Since this driver already keeps statistics per ring, use
> those to compute the bytes/packet statistics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Yeah, this is code we developed for e1000(e) and that was for only one 
queue, it should be a problem, and we should fix it one way or another.

Thanks Stephen, everything seems good after a quick review, except for one 
note: see below.

> Compile tested only, evaluation in progress

okay

> --- a/drivers/net/igb/igb_main.c        2008-10-21 08:57:11.000000000 -0700
> +++ b/drivers/net/igb/igb_main.c        2008-10-21 09:05:43.000000000 -0700
> @@ -3029,9 +3029,27 @@ static struct net_device_stats *
>  igb_get_stats(struct net_device *netdev)
>  {
>         struct igb_adapter *adapter = netdev_priv(netdev);
> +       struct net_device_stats *stats = &adapter->net_stats;
> +       int i;
> +
> +       stats->tx_bytes = 0;
> +       stats->tx_packets = 0;
> +       for (i = 0; i < adapter->num_tx_queues; i++) {
> +               struct igb_ring *tx_ring = &adapter->tx_ring[i];
> +               stats->tx_bytes += tx_ring->tx_stats.bytes;
> +               stats->tx_packets += tx_ring->tx_stats.packets;
> +       }
> +       stats->rx_bytes = 0;
> +       stats->rx_packets = 0;
> +       for (i = 0; i < adapter->num_rx_queues; i++) {
> +               struct igb_ring *rx_ring = &adapter->rx_ring[i];
> +               stats->rx_bytes += rx_ring->rx_stats.bytes;
> +               stats->rx_packets += rx_ring->rx_stats.packets;
> +       }
> +
> +       igb_update_stats(adapter);

I don't think you want to put this in the code that can be called directly 
from IOCTL from userspace.  This function can take a lot of cycles and 
some silly applications like gkrellm call it quite frequently.  The 
update_stats function will be called as part of the watchdog anyway, and 
you already got the interesting stats for realtime with the tx and rx 
bytes/packets.

> -       /* only return the current stats */
> -       return &adapter->net_stats;
> +       return stats;
>  }
> 
>  /**
> @@ -3711,8 +3729,6 @@ done_cleaning:
>         tx_ring->total_packets += total_packets;
>         tx_ring->tx_stats.bytes += total_bytes;
>         tx_ring->tx_stats.packets += total_packets;
> -       adapter->net_stats.tx_bytes += total_bytes;
> -       adapter->net_stats.tx_packets += total_packets;
>         return retval;
>  }
> 
> @@ -3953,8 +3969,6 @@ next_desc:
>         rx_ring->total_bytes += total_bytes;
>         rx_ring->rx_stats.packets += total_packets;
>         rx_ring->rx_stats.bytes += total_bytes;
> -       adapter->net_stats.rx_bytes += total_bytes;
> -       adapter->net_stats.rx_packets += total_packets;
>         return cleaned;
>  }

The same thing should be done to ixgbe too, but I'm just mentioning it for 
posterity, not because I'd expect you to do so.
