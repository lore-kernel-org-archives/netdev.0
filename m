From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH net-next 3/5] netxen: make 64 bit stats safe on 32 bit
 platform
Date: Mon, 20 Jun 2011 15:18:32 -0700 (PDT)
Message-ID: <1528961426.419.1308608312735.JavaMail.root@tahiti.vyatta.com>
References: <1308606738.2701.203.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37859 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab1FTWSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 18:18:35 -0400
In-Reply-To: <1308606738.2701.203.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mon, 2011-06-20 at 13:35 -0700, Stephen Hemminger wrote:
> 
> > Use stats_update wrapper to avoid problems where 64 bit statistic
> > update is not atomic on 32 bit platform.
> [...]
> > @@ -2115,11 +2117,17 @@ static struct rtnl_link_stats64 *netxen_
> >  						      struct rtnl_link_stats64 *stats)
> >  {
> >  	struct netxen_adapter *adapter = netdev_priv(netdev);
> > + unsigned int start;
> > + + do {
> > + start = u64_stats_fetch_begin(&adapter->stats.syncp);
> > + + stats->rx_packets = adapter->stats.rx_pkts +
> > adapter->stats.lro_pkts; + stats->tx_packets =
> > adapter->stats.xmitfinished; + stats->rx_bytes =
> > adapter->stats.rxbytes; + stats->tx_bytes = adapter->stats.txbytes;
> > + } while (u64_stats_fetch_retry(&adapter->stats.syncp, start));
> >
> > - stats->rx_packets = adapter->stats.rx_pkts +
> > adapter->stats.lro_pkts; - stats->tx_packets =
> > adapter->stats.xmitfinished; - stats->rx_bytes =
> > adapter->stats.rxbytes; - stats->tx_bytes = adapter->stats.txbytes;
> >  	stats->rx_dropped = adapter->stats.rxdropped;
> >  	stats->tx_dropped = adapter->stats.txdropped;
> 
> netxen_nic_get_ethtool_stats() should also be fixed.
> 
> The 'txdropped' and 'csummed' stats are also 64-bit and updated on the
> data path. ('rxdropped' isn't updated at all, AFAICS.)

Since they are error counters, just changing them to unsigned long is
easier.
