From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Wed, 30 Nov 2016 14:25:39 -0500 (EST)
Message-ID: <20161130.142539.1927956259851457047.davem@davemloft.net>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129130945.919372-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Tue, 29 Nov 2016 13:09:45 +0000

> +	/* We only support checksum for IPv4,UDP(over IPv4 or IPv6), TCP(over
> +	 * IPv4 or IPv6) and SCTP but we support many L3(IPv4, IPv6, MPLS,
> +	 * PPPoE etc) and L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.) protocols.
> +	 * We want to filter out L3 and L4 protocols early on for which checksum
> +	 * is not supported.
 ...
> +	 */
> +	l3id = hnae_get_field(flag, HNS_RXD_L3ID_M, HNS_RXD_L3ID_S);
> +	l4id = hnae_get_field(flag, HNS_RXD_L4ID_M, HNS_RXD_L4ID_S);
> +	if ((l3id != HNS_RX_FLAG_L3ID_IPV4) &&
> +	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
> +	     (l4id != HNS_RX_FLAG_L4ID_UDP)) &&
> +	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
> +	     (l4id != HNS_RX_FLAG_L4ID_TCP)) &&
> +	    (l4id != HNS_RX_FLAG_L4ID_SCTP))
> +		return;

I have a hard time understanding this seemingly overcomplicated
check.

It looks like if L3 is IPV4 it will accept any underlying L4 protocol,
but is that what is really intended?  That doesn't match what this new
comment states.

My understanding is that the chip supports checksums for:

	UDP/IPV4
	UDP/IPV6
	TCP/IPV4
	TCP/IPV6
	SCTP/IPV4
	SCTP/IPV6

So the simplest thing is to validate each level one at a time:

	if (l3 != IPV4 && l3 != IPV6)
		return;
	if (l4 != UDP && l4 != TCP && l4 != SCTP)
		return;
