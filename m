From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 21:03:30 +0200
Message-ID: <1340823810.26242.81.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM,
	James Chapman <jchapman@katalix.com>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64250 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab2F0TDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 15:03:35 -0400
Received: by eaak11 with SMTP id k11so534496eaa.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 12:03:33 -0700 (PDT)
In-Reply-To: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 13:00 +0100, Tom Parkin wrote:
> This patch fixes a race condition in l2tp when updating tunnel and
> session statistics.  Previously it was possible for multiple threads
> to concurrently call u64_stats_update*(), which lead to statistics
> readers blocking forever.
> 
> This race was discovered on an AMD64 SMP machine running a 32bit
> kernel.  Running "ip l2tp" while sending data over an Ethernet
> pseudowire resulted in an occasional soft lockup in
> u64_stats_fetch_begin() called from l2tp_nl_session_send().
> 
> For safe lockless update of l2tp stats, data is now stored in per-cpu
> variables.  These per-cpu datasets are then summed at read time via.
> an extra helper function l2tp_stats_copy() which has been added to
> l2tp_core.c.
> 

Do we really need 64bits stats on 32bit arches for l2tp ?

> Signed-off-by: Tom Parkin <tparkin@katalix.com>
> Signed-off-by: James Chapman <jchapman@katalix.com>
> ---
>  net/l2tp/l2tp_core.c    |  286 ++++++++++++++++++++++++++++-------------------
>  net/l2tp/l2tp_core.h    |   44 ++++++--
>  net/l2tp/l2tp_debugfs.c |   42 ++++---
>  net/l2tp/l2tp_netlink.c |   64 ++++-------
>  net/l2tp/l2tp_ppp.c     |   75 ++++++++-----
>  5 files changed, 301 insertions(+), 210 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 32b2155..ab2ffc0 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -320,6 +320,43 @@ struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth)
>  }
>  EXPORT_SYMBOL_GPL(l2tp_tunnel_find_nth);
>  
> +/*
> + * Sum tunnel/session statistics across all CPUs
> + */
> +int l2tp_stats_copy(struct l2tp_stats *cpustats, struct l2tp_stats *dest)
> +{
> +	int i;
> +	unsigned int start;
> +
> +	if (!cpustats || !dest)
> +		return 1;
> +
> +	memset(dest, 0, sizeof(struct l2tp_stats));
> +
> +	for_each_possible_cpu(i) {
> +		struct l2tp_stats *stats = per_cpu_ptr(cpustats, i);
> +
> +		do {
> +			start = u64_stats_fetch_begin(&stats->tx.syncp);
> +			dest->tx.packets += stats->tx.packets;
> +			dest->tx.bytes += stats->tx.bytes;
> +			dest->tx.errors += stats->tx.errors;

You cant do the sum in 'dest', since if loop is restarted, you'll have
accumulation of all values.

> +		} while (u64_stats_fetch_retry(&stats->tx.syncp, start));
> +
> +		do {
> +			start = u64_stats_fetch_begin(&stats->rx.syncp);
> +			dest->rx.packets += stats->rx.packets;
> +			dest->rx.bytes += stats->rx.bytes;
> +			dest->rx.errors += stats->rx.errors;
> +			dest->rx.seq_discards += stats->rx.seq_discards;
> +			dest->rx.oos_packets += stats->rx.oos_packets;

same problem

> +		} while (u64_stats_fetch_retry(&stats->rx.syncp, start));
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(l2tp_stats_copy);
> +


>  
>  static void pppol2tp_copy_stats(struct pppol2tp_ioc_stats *dest,
> -				struct l2tp_stats *stats)
> +				struct l2tp_stats *cpustats)
>  {
> -	dest->tx_packets = stats->tx_packets;
> -	dest->tx_bytes = stats->tx_bytes;
> -	dest->tx_errors = stats->tx_errors;
> -	dest->rx_packets = stats->rx_packets;
> -	dest->rx_bytes = stats->rx_bytes;
> -	dest->rx_seq_discards = stats->rx_seq_discards;
> -	dest->rx_oos_packets = stats->rx_oos_packets;
> -	dest->rx_errors = stats->rx_errors;
> +	struct l2tp_stats tmp;
> +
> +	if (0 != l2tp_stats_copy(cpustats, &tmp))
> +		return;

	if (l2tp_stats_copy(cpustats, &tmp) != 0)
		return;

> +
> +	dest->tx_packets = tmp.tx.packets;
> +	dest->tx_bytes = tmp.tx.bytes;
> +	dest->tx_errors = tmp.tx.errors;
> +	dest->rx_packets = tmp.rx.packets;
> +	dest->rx_bytes = tmp.rx.bytes;
> +	dest->rx_seq_discards = tmp.rx.seq_discards;
> +	dest->rx_oos_packets = tmp.rx.oos_packets;
> +	dest->rx_errors = tmp.rx.errors;
>  
