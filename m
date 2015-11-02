From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v4 6/8] dpaa_eth: add ethtool statistics
Date: Mon, 02 Nov 2015 12:39:48 -0800
Message-ID: <1446496788.24485.69.camel@perches.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-7-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	scottwood@freescale.com, igal.liberman@freescale.com,
	roy.pledge@freescale.com, ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, gregkh@linuxfoundation.org,
	Ioana Ciornei <ioana.ciornei@freescale.com>
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0143.hostedemail.com ([216.40.44.143]:35275 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752533AbbKBUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:39:53 -0500
In-Reply-To: <1446485500-9782-7-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> Add a series of counters to be exported through ethtool:
> - add detailed counters for reception errors;
> - add detailed counters for QMan enqueue reject events;
> - count the number of fragmented skbs received from the stack;
> - count all frames received on the Tx confirmation path;
> - add congestion group statistics;
> - count the number of interrupts for each CPU.
[]
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
[]
> +static void dpa_get_strings(struct net_device *net_dev, u32 stringset, u8 *data)
> +{
> +	unsigned int i, j, num_cpus, size;
> +	char string_cpu[ETH_GSTRING_LEN];
> +	u8 *strings;
> +
> +	strings   = data;
> +	num_cpus  = num_online_cpus();
> +	size      = DPA_STATS_GLOBAL_LEN * ETH_GSTRING_LEN;
> +
> +	for (i = 0; i < DPA_STATS_PERCPU_LEN; i++) {
> +		for (j = 0; j < num_cpus; j++) {
> +			snprintf(string_cpu, ETH_GSTRING_LEN, "%s [CPU %d]",
> +				 dpa_stats_percpu[i], j);
> +			memcpy(strings, string_cpu, ETH_GSTRING_LEN);
> +			strings += ETH_GSTRING_LEN;
> +		}
> +		snprintf(string_cpu, ETH_GSTRING_LEN, "%s [TOTAL]",
> +			 dpa_stats_percpu[i]);
> +		memcpy(strings, string_cpu, ETH_GSTRING_LEN);
> +		strings += ETH_GSTRING_LEN;
> +	}
> +	memcpy(strings, dpa_stats_global, size);
> +}

This leaks uninitialized stack via a memcpy of uninitialized
string_cpu bytes into user-space.

Using
	char string_cpu[ETH_GSTRING_LEN] = {};
or a memset before each snprintf would fix it.
