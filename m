From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] ehea: NAPI multi queue TX/RX path for SMP
Date: Tue, 27 Feb 2007 17:53:28 +0100
Message-ID: <45E46208.3000003@trash.net>
References: <200702271732.51829.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35527 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbXB0Qxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 11:53:31 -0500
In-Reply-To: <200702271732.51829.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch provides a functionality that allows parallel 
> RX processing on multiple RX queues by using dummy netdevices.
> 
>  
> +static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
> +{
> +	u32 tmp;
> +	if ((skb->nh.iph->protocol == IPPROTO_TCP)
> +	    && skb->protocol == ETH_P_IP) {

skb->protocol has network byte order. The ETH_P_IP test should also
logically come before checking the IP protocol.

> +		tmp = (skb->h.th->source + (skb->h.th->dest << 16)) % 31;

Only locally generated packets have a valid h.th pointer.

> +		tmp += skb->nh.iph->daddr % 31;
> +		return tmp % num_qps;
> +	}
> +	else
> +		return 0;
> +}
> +
>  static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct ehea_port *port = netdev_priv(dev);
> @@ -1796,9 +1818,18 @@ static int ehea_start_xmit(struct sk_buf
>  	unsigned long flags;
>  	u32 lkey;
>  	int swqe_index;
> -	struct ehea_port_res *pr = &port->port_res[0];
> +	struct ehea_port_res *pr;
> +
> +	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
> +

