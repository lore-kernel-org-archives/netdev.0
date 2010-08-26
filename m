From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:57:58 -0700
Message-ID: <20100826085758.04ac4b44@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39270 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026Ab0HZP6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 11:58:01 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> +static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
> +		 struct pch_gbe_tx_ring *tx_ring, struct sk_buff *skb)
> +{
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	struct pch_gbe_tx_desc *tx_desc;
> +	struct pch_gbe_buffer *buffer_info;
> +	struct sk_buff *tmp_skb;
> +	unsigned int frame_ctrl;
> +	unsigned int ring_num;
> +	unsigned long flags;
> +
> +	PCH_GBE_DEBUG("%s\n", __func__);
> +
> +
> +	/*-- Set frame control --*/
> +	frame_ctrl = 0;
> +	if (unlikely(skb->len < PCH_GBE_SHORT_PKT))
> +		frame_ctrl |= PCH_GBE_TXD_CTRL_APAD;
> +	if (unlikely(adapter->tx_csum == FALSE))
> +		frame_ctrl |= PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
> +
> +	/* Performs checksum processing */
> +	/*
> +	 * It is because the hardware accelerator does not support a checksum,
> +	 * when the received data size is less than 64 bytes.
> +	 */
> +	if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum == TRUE)) {
> +		frame_ctrl |=
> +			PCH_GBE_TXD_CTRL_APAD | PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
> +		if (skb->protocol == htons(ETH_P_IP)) {
> +			struct iphdr *iph = ip_hdr(skb);
> +			unsigned int offset;
> +			iph->check = 0;
> +			iph->check = ip_fast_csum((u8 *) iph, iph->ihl);
> +			offset = skb_transport_offset(skb);
> +			if (iph->protocol == IPPROTO_TCP) {
> +				skb->csum = 0;
> +				tcp_hdr(skb)->check = 0;
> +				skb->csum =
> +					skb_checksum(skb, offset,
> +						skb->len - offset, 0);
> +				tcp_hdr(skb)->check =
> +					csum_tcpudp_magic(iph->saddr,
> +							iph->daddr,
> +							skb->len - offset,
> +							IPPROTO_TCP, skb->csum);
> +			} else if (iph->protocol == IPPROTO_UDP) {
> +				skb->csum = 0;
> +				udp_hdr(skb)->check = 0;
> +				skb->csum =
> +					skb_checksum(skb, offset,
> +						skb->len - offset, 0);
> +				udp_hdr(skb)->check =
> +					csum_tcpudp_magic(iph->saddr,
> +							iph->daddr,
> +							skb->len - offset,
> +							IPPROTO_UDP, skb->csum);
> +			}
> +		}
> +	}


Why not something simpler using skb_checksum_help which is
safer since it handles case of shared skb correctly.

	if (skb->ip_summed = CHECKSUM_COMPLETE &&
            skb->len < PCH_GBE_SHORT_PKT) {
		frame_ctrl |=
			PCH_GBE_TXD_CTRL_APAD | PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
		skb->ip_summed = CHECKSUM_NONE;
                if (skb_checksum_help(skb))
                      goto drop;  /* could not expand header to find space */
        }



-- 
