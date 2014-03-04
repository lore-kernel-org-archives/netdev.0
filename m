From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/12] r8152: support rx checksum
Date: Tue, 04 Mar 2014 16:32:42 -0500 (EST)
Message-ID: <20140304.163242.1756502150027525045.davem@davemloft.net>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1393934464-23675-8-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-8-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 4 Mar 2014 20:00:59 +0800

> @@ -1453,11 +1491,19 @@ static void rx_bottom(struct r8152 *tp)
>  			pkt_len -= CRC_SIZE;
>  			rx_data += sizeof(struct rx_desc);
>  
> +			checksum = r8152_rx_csum(tp, rx_desc);
> +			if (checksum == RTL_CHECKSUM_FAIL) {
> +				stats->rx_errors++;
> +				goto find_next_rx;
> +			}
> +

It is not for the driver to make this policy decision and drop the
packet.  It is not a device RX error event.

In fact you do not know what corrupted the checksum, or even if
the device verified it correctly.  Anything is possible.

You must therefore still pass the packet up into the networking
stack using CHECKSUM_NONE, and let the protocols double-check
the checksum(s) in software and bump the appropriate statistic
counter if the checksum is really bad.

This allows allows network taps to see the packet, so that the
administrator can analyze the situation.
