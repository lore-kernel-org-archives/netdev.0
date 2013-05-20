From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Mon, 20 May 2013 23:37:28 +0200
Message-ID: <20130520213728.GA28252@electric-eye.fr.zoreil.com>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45696 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757072Ab3ETVhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 17:37:36 -0400
Content-Disposition: inline
In-Reply-To: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> :
> This patch cures transmit timeout's with DHCP observed
> while running under KVM. When the transmit ring is cleaned out,
> the Byte Queue Limit values need to be reset.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/drivers/net/ethernet/realtek/8139cp.c	2013-05-20 09:29:49.689900862 -0700
> +++ b/drivers/net/ethernet/realtek/8139cp.c	2013-05-20 09:29:50.857880563 -0700
> @@ -1141,6 +1141,7 @@ static void cp_clean_rings (struct cp_pr
>  			cp->dev->stats.tx_dropped++;
>  		}
>  	}
> +	netdev_reset_queue(cp->dev);
>  
>  	memset(cp->rx_ring, 0, sizeof(struct cp_desc) * CP_RX_RING_SIZE);
>  	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);

It's a good catch but I believe that you are not telling us the whole
story. :o)

Where does cp_clean_rings get called ?

- error path of cp_refill_rx
  - cp_init_rings
    - cp_alloc_rings
      - cp_open
        - in cp_change_mtu, after cp_close, whence cp_stop_hw
    - cp_tx_timeout
      -> after cp_stop_hw
- cp_free_rings
  - error path of cp_open
    -> after cp_stop_hw
  - cp_close
    -> after cp_stop_hw
- cp_tx_timeout
  -> after cp_stop_hw

cp_stop_hw includes netdev_reset_queue.

You have imho exhibited a start_xmit after cp_stop_hw race - not sure if
it happens in cp_tx_timeout or cp_change_mtu. Reverting the analysis above,
I have not found a place where cp_stop_hw could be called without being
followed by a cp_clean_rings. The netdev_reset_queue in cp_stop_hw, now
useless, should thus be removed.

Does it make sense ?

-- 
Ueimor
