From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] NET: Add ezchip ethernet driver
Date: Thu, 11 Jun 2015 15:43:06 -0700 (PDT)
Message-ID: <20150611.154306.1641662434579350039.davem@davemloft.net>
References: <1433853863-6704-1-git-send-email-noamc@ezchip.com>
	<1434011629-31257-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com,
	giladb@ezchip.com, cmetcalf@ezchip.com, talz@ezchip.com
To: noamc@ezchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434011629-31257-1-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>
Date: Thu, 11 Jun 2015 11:33:49 +0300

> +#define NPS_ENET_INT_MASK		(sizeof(u32) - 1)
> +#define NPS_ENET_INT_OFFSET		2
> +#define NPS_ENET_WORDS_NUM(length)	((length + NPS_ENET_INT_MASK) >> 2)

This is a bit obfuscating in my opinion.

First of all "NPS_ENET_INT_OFFSET" is not an "offset", which you would
add or subtract from a value, but rather it is a "shift".  All of
the uses would look clearer as "X / sizeof(u32)" rather than the
"X >> NPS_ENET_INET_OFFSET".

Same for NPS_ENET_WORDS_NUM(), this is simply "DIV_ROUND_UP(x, sizeof_u32))"
which is much more easy to understand.

And I would just say "sizeof(u32) - 1" outright for the mask as well.

So basically what I'm saying is that these macros make the code harder
to read and understand rather than making it easier.

> +
> +			/* to accommodate word-unaligned address of "reg"
> +			 * we have to do memcpy() instead of simple "="
> +			 */
> +			memcpy(reg, &buf, sizeof(buf));

This is not guaranteed to work.  'ret' is a "u32 *" type therefore the
compiler is allowed to assume the pointer is properly aligned and
therefore emit a 32-bit load/store sequence inline for the memcpy()
call.

Which means all of this unaligned handling code is going to accomplish
nothing at all.  The code will still make unaligned accesses.

> +	netif_rx(skb);

Please implement proper NAPI support for your driver so that receive
packets are processed via the ->poll() handler in software interrupt
context rather than via netif_rx() in hardware interrupt context.

> +static void nps_enet_tx_irq_handler(struct net_device *netdev,
> +				    struct nps_enet_tx_ctl tx_ctrl)
> +{

Likewise for TX completion handling.
> +static struct net_device_stats *nps_enet_get_stats(struct net_device *ndev)
> +{
> +	return &ndev->stats;
> +}

If this is all that your get_stats() method does, you can leave it unspecified
in nps_netdev_ops, and the core code will do the right thing by default.
