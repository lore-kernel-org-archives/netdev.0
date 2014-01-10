From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 3/3] atl1: update statistics code
Date: Fri, 10 Jan 2014 22:30:44 +0100
Message-ID: <20140110213044.GA4006@kria>
References: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
 <1389370103-3009-4-git-send-email-sd@queasysnail.net>
 <1389378566.2025.78.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, jcliburn@gmail.com,
	chris.snook@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:60452 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbaAJVa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 16:30:58 -0500
Content-Disposition: inline
In-Reply-To: <1389378566.2025.78.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-10, 18:29:26 +0000, Ben Hutchings wrote:
> On Fri, 2014-01-10 at 17:08 +0100, Sabrina Dubroca wrote:
> > As Ben Hutchings pointed out for the stats in alx, some
> > hardware-specific stats aren't matched to the right net_device_stats
> > field. Also fix the collision field and include errors in the total
> > number of RX/TX packets.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> >  drivers/net/ethernet/atheros/atlx/atl1.c | 16 ++++++++--------
> >  1 file changed, 8 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
> > index 538211d..31d460a 100644
> > --- a/drivers/net/ethernet/atheros/atlx/atl1.c
> > +++ b/drivers/net/ethernet/atheros/atlx/atl1.c
> [...]
> > @@ -1718,23 +1718,18 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
> >  	adapter->soft_stats.tx_trunc += smb->tx_trunc;
> >  	adapter->soft_stats.tx_pause += smb->tx_pause;
> >  
> > -	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
> > -	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
> >  	netdev->stats.rx_bytes = adapter->soft_stats.rx_bytes;
> >  	netdev->stats.tx_bytes = adapter->soft_stats.tx_bytes;
> >  	netdev->stats.multicast = adapter->soft_stats.multicast;
> >  	netdev->stats.collisions = adapter->soft_stats.collisions;
> >  	netdev->stats.rx_errors = adapter->soft_stats.rx_errors;
> > -	netdev->stats.rx_over_errors =
> > -		adapter->soft_stats.rx_missed_errors;
> >  	netdev->stats.rx_length_errors =
> >  		adapter->soft_stats.rx_length_errors;
> >  	netdev->stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
> >  	netdev->stats.rx_frame_errors =
> >  		adapter->soft_stats.rx_frame_errors;
> >  	netdev->stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
> > -	netdev->stats.rx_missed_errors =
> > -		adapter->soft_stats.rx_missed_errors;
> 
> So adapter->soft_stats.rx_missed_errors is set (to something silly) and
> then ignored...

Ignored in netdev->stats, but still used in ethtool stats, as both
rx_over_errors and rx_missed_errors. I don't want to rename or remove
ethtool stats entries, so I could leave it set to 0.


> > +	netdev->stats.rx_dropped = adapter->soft_stats.rx_rrd_ov;
> >  	netdev->stats.tx_errors = adapter->soft_stats.tx_errors;
> >  	netdev->stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
> >  	netdev->stats.tx_aborted_errors =
> > @@ -1743,6 +1738,11 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
> >  		adapter->soft_stats.tx_window_errors;
> >  	netdev->stats.tx_carrier_errors =
> >  		adapter->soft_stats.tx_carrier_errors;
> > +
> > +	netdev->stats.rx_packets = adapter->soft_stats.rx_packets +
> > +				   netdev->stats.rx_errors;
> > +	netdev->stats.tx_packets = adapter->soft_stats.tx_packets +
> > +				   netdev->stats.tx_errors;
> 
> Given that adapter->soft_stats largely mirrors struct net_device_stats,
> would it not make sense to do these additions there so that
> adapter->soft_stats.{rx,tx}_packets include all packets?
> 
> I.e. you could do something like:
> 
> 	delta_rx_errors = (smb->rx_frag + smb->rx_fcs_err +
> 			   smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
> 			   smb->rx_rrd_ov + smb->rx_align_err);
> 	adapter->soft_stats.rx_errors += delta_rx_errors;
> 	adapter->soft_stats.rx_packets += delta_rx_errors;
> 
> (and similarly for TX).
> 
> Basically I think these changes belong further up the function.

Oops, yeah.


I just noticed this bit in atl1_alloc_rx_buffers:

static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
{
<...>
		skb = netdev_alloc_skb_ip_align(adapter->netdev,
						adapter->rx_buffer_len);
		if (unlikely(!skb)) {
			/* Better luck next round */
			adapter->netdev->stats.rx_dropped++;
			break;
		}
<...>
}

Now that netdev->stats.rx_dropped gets overwritten, it should be
changed to a field in soft_stats. soft_stats doesn't have a rx_dropped
field, so rx_rrd_ov? Or do I add rx_dropped to soft_stats?



Thanks a lot Ben!

-- 
Sabrina
