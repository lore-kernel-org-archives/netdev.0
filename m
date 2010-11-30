From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Tue, 30 Nov 2010 15:01:45 +0000
Message-ID: <1291129305.21077.9.camel@bwh-desktop>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52735 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185Ab0K3PBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 10:01:48 -0500
In-Reply-To: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 00:00 -0800, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given
> interface. This is the reworked version of earlier submit (which I
> don't have reference to). By configuring the interface in loopback
> mode in conjunction with a policy route / rule, a userland application
> can stress the egress / ingress path exposing the flows of the change
> in progress and potentially help developer(s) understand the impact of
> those changes without even sending a packet out on the network.

Is the aim to stress the generic egress/ingress code or also to cover
the specific driver in use?

I note that your colleague Laurent Chavey posted a very similar patch
back in April <http://article.gmane.org/gmane.linux.network/157489> but
he emphasised hardware diagnosis.

> Following set of commands illustrates one such example -
>     a) ifconfig eth1 192.168.1.1
>     b) ip -4 rule add from all iif eth1 lookup 250
>     c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>     d) arp -Ds 192.168.1.100 eth1
>     e) arp -Ds 192.168.1.200 eth1
>     f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>     g) sysctl -w net.ipv4.conf.all.accept_local=1
>     # Assuming that the machine has 8 cores
>     h) taskset 000f netserver -L 192.168.1.200
>     i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/ethtool.h |    4 ++++
>  net/core/ethtool.c      |   39 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 6628a50..7523d45 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -678,6 +678,8 @@ struct ethtool_ops {
>                                   struct ethtool_rxfh_indir *);
>         int     (*set_rxfh_indir)(struct net_device *,
>                                   const struct ethtool_rxfh_indir *);
> +       int     (*get_loopback)(struct net_device *, u32 *);
> +       int     (*set_loopback)(struct net_device *, u32);
>  };
>  #endif /* __KERNEL__ */
> 
> @@ -741,6 +743,8 @@ struct ethtool_ops {
>  #define ETHTOOL_GSSET_INFO     0x00000037 /* Get string set info */
>  #define ETHTOOL_GRXFHINDIR     0x00000038 /* Get RX flow hash indir'n table */
>  #define ETHTOOL_SRXFHINDIR     0x00000039 /* Set RX flow hash indir'n table */
> +#define ETHTOOL_SLOOPBACK      0x0000003a /* Enable / Disable Loopback */
[...]

Where should loopback be done, when enabled?  As near as possible to the
host, so it only covers the DMA engines, or as far away as possible, so
it covers most of the MAC/PHY hardware?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

