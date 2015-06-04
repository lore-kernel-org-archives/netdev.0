From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/2] Renesas Ethernet AVB driver proper
Date: Wed, 03 Jun 2015 20:12:04 -0700 (PDT)
Message-ID: <20150603.201204.761049104805679684.davem@davemloft.net>
References: <1752433.KgeJV8aUGv@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1752433.KgeJV8aUGv@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 02 Jun 2015 23:44:10 +0300

> +		/* Received network control queue */
> +		if (ris0 & RIS0_FRF1) {
> +			ravb_write(ndev, ~RIS0_FRF1, RIS0);
> +			/* Timestamp of network control packets that is based
> +			 * on IEEE802.1AS, is used time synchronization of PTP.
> +			 * It should not be handled by NAPI scheduling, because
> +			 * it needs to be received as soon as possible.
> +			 */
> +			ravb_rx(ndev, NULL, RAVB_NC);
> +			result = IRQ_HANDLED;
> +		}

Nobody else makes this distinction, all packets should be processed
via your NAPI path.

When I see people conditionally invoking netif_rx()
vs. netif_receive_skb() in their packet receive routine, like
conditional locking, it's a big red flag.

Furthermore, you should pass the NAPI context into ravb_rx() and use
it so that you can invoke napi_gro_receive() on all of the packets and
therefore support GRO.
