From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Patch RFC net-next] net: usb: r8152: Fix rx_bytes/tx_bytes to
 include FCS
Date: Wed, 17 May 2017 15:28:38 -0700
Message-ID: <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
References: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, hayeswang <hayeswang@realtek.com>,
        Mario Limonciello <mario_limonciello@dell.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33090 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754113AbdEQW2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 18:28:44 -0400
Received: by mail-wr0-f196.google.com with SMTP id w50so3768045wrc.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 15:28:43 -0700 (PDT)
In-Reply-To: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2017 01:23 PM, Andrew Lunn wrote:
> The statistics counters rx_bytes and tx_bytes don't include the
> Ethernet Frame Check Sequence. The hardware appears to calculate it on
> send, so it is not part of the URB passed to the device, and on
> receive it was not being copied into the skb.
> 
> Fix the rx_bytes/tx_bytes counters, and copy the FCS into the skb so
> tools like wireshark can see it.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> RFC for the following points:
> 
> I run automatic tests on Ethernet switches supported by DSA. I have a
> test host with many Ethernet interfaces which i connect to switch
> ports. Some are quad Ethernet PCIe cards, using the Intel e1000e
> driver. Some are USB-Ethernet dongles using the asix driver. And i
> have some USB-Ethernet dongles using the r8152. The e1000e, asix and
> DSA itself all give consistent rx_bytes and tx_bytes statistics. The
> r8152 consistently returns counters which are 4 bytes per frame lower,
> which results in some test failures.
> 
> Is it defined somewhere what should be included in rx_bytes/tx_bytes?
> Should the FCS be included?
> 
> This is considered a user API change? The meaning of the counters are
> going to be slightly different after this patch. I could be breaking
> somebody else's tests :-(

I am afraid that we won't be able to enforce a consistent behavior,
because the HW itself is not consistent, both on the NIC and on the
switch side.

For instance, whether your switch's MIB counters do include FCS, Marvell
tags, or not is going to be highly dependent on how the HW is designed,
whether the MIB counter logic is before, or after in the packet ingress
path.

Some NICs also allow passing the CRC frame up the stack (e.g:
NETIF_F_RXFCS), in which case, we should probably report the FCS as part
of skb->len, because that's what the stack is going to be given.

So I am afraid that as far as your tests are going to work, you will
need to have some logic that knows what kind of switch driver/HW is
used, whether to expect FCS/tag lengths reported, just like you will
have to have the same thing on the initiator of the tests....

> ---
>  drivers/net/usb/r8152.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index ddc62cb69be8..4081a2cd8b1b 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1228,7 +1228,7 @@ static void write_bulk_callback(struct urb *urb)
>  		stats->tx_errors += agg->skb_num;
>  	} else {
>  		stats->tx_packets += agg->skb_num;
> -		stats->tx_bytes += agg->skb_len;
> +		stats->tx_bytes += agg->skb_len + CRC_SIZE;
>  	}
> 
>  	spin_lock(&tp->tx_lock);
> @@ -1826,7 +1826,6 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  			if (urb->actual_length < len_used)
>  				break;
> 
> -			pkt_len -= CRC_SIZE;
>  			rx_data += sizeof(struct rx_desc);
> 
>  			skb = napi_alloc_skb(napi, pkt_len);
> @@ -1850,7 +1849,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  			}
> 
>  find_next_rx:
> -			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
> +			rx_data = rx_agg_align(rx_data + pkt_len);
>  			rx_desc = (struct rx_desc *)rx_data;
>  			len_used = (int)(rx_data - (u8 *)agg->head);
>  			len_used += sizeof(struct rx_desc);
> --
> 2.11.0
> ---
>  drivers/net/usb/r8152.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index ddc62cb69be8..4081a2cd8b1b 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1228,7 +1228,7 @@ static void write_bulk_callback(struct urb *urb)
>  		stats->tx_errors += agg->skb_num;
>  	} else {
>  		stats->tx_packets += agg->skb_num;
> -		stats->tx_bytes += agg->skb_len;
> +		stats->tx_bytes += agg->skb_len + CRC_SIZE;
>  	}
>  
>  	spin_lock(&tp->tx_lock);
> @@ -1826,7 +1826,6 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  			if (urb->actual_length < len_used)
>  				break;
>  
> -			pkt_len -= CRC_SIZE;
>  			rx_data += sizeof(struct rx_desc);
>  
>  			skb = napi_alloc_skb(napi, pkt_len);
> @@ -1850,7 +1849,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  			}
>  
>  find_next_rx:
> -			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
> +			rx_data = rx_agg_align(rx_data + pkt_len);
>  			rx_desc = (struct rx_desc *)rx_data;
>  			len_used = (int)(rx_data - (u8 *)agg->head);
>  			len_used += sizeof(struct rx_desc);
> 


-- 
Florian
