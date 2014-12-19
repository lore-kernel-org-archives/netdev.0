From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 18:39:44 +0000
Message-ID: <CO2PR07MB490962E1E05D146BFD67B66FE6B0@CO2PR07MB490.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20141218232833.3e640164@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0072.outbound.protection.outlook.com ([207.46.100.72]:60134
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752137AbaLSSyQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 13:54:16 -0500
In-Reply-To: <20141218232833.3e640164@urahara>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +
> > +static u32 lio_get_link(struct net_device *dev)
> > +{
> > +	u32 ret;
> > +
> > +	ret = netif_carrier_ok(dev) ? 1 : 0;
> > +	return ret;
> > +}
> > +
> 
> This is unnecessary, this is what the default ethtool handler already does
> if you give a NULL handler.

Okay

> > +	if (linfo->link.s.status) {
> > +		ecmd->speed = linfo->link.s.speed;
> > +		ecmd->duplex = linfo->link.s.duplex;
> > +	} else {
> > +		ecmd->speed = -1;
> > +		ecmd->duplex = -1;
> > +	}
> > +
> 
> You should SPEED_UNKNOWN and DUPLEX_UNKNOWN (not -1).
> and don't set ecmd->speed directly, use
>      ethtool_cmd_speed_sed(ecmd, speed)

Okay

> > +static void
> > +lio_get_ethtool_stats(struct net_device *netdev,
> > +		      struct ethtool_stats *stats, u64 *data)
> > +{
> > +	struct lio *lio = GET_LIO(netdev);
> > +	struct octeon_device *oct_dev = lio->oct_dev;
> > +	int i = 0, j;
> > +	
> > +	data[i++] = jiffies;
> > +	data[i++] = lio->stats.tx_packets;
> > +	data[i++] = lio->stats.tx_bytes;
> > +	data[i++] = lio->stats.rx_packets;
> > +	data[i++] = lio->stats.rx_bytes;
> > +	data[i++] = lio->stats.tx_errors;
> > +	data[i++] = lio->stats.tx_dropped;
> > +	data[i++] = lio->stats.rx_dropped;
> > +
> 
> Do not mirror existing netdevice statistics in ethtool.
> The purpose of ethtool stats is to provide device specific information.

Okay.

> > +/** \brief Network device get stats
> > + * @param netdev    pointer to network device
> > + * @returns pointer stats structure
> > + */
> > +static struct net_device_stats *liquidio_stats(struct net_device *netdev)
> > +{
> > +	return &(GET_LIO(netdev)->stats);
> > +}
> > +
> 
> Unnecessary function, this is what network core does already
> if .ndo_get_stats is NULL;

Okay.

> > +static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int
> cmd)
> > +{
> > +	switch (cmd) {
> > +	case SIOCSHWTSTAMP:
> > +		return hwtstamp_ioctl(netdev, ifr, cmd);
> > +	default:
> > +		return -EINVAL
> 
> Standard error code for unsupported ioctl is -EOPNOTSUPP

Okay.

> > +static int __init liquidio_init(void)
> > +{
> > +	int i;
> > +	struct handshake *hs;
> > +
> > +	pr_info("LiquidIO: Starting Network module version %s\n",
> > +		LIQUIDIO_VERSION);
> > +
> 
> Do you really need to log this. Systems are already too chatty.

Okay. This is available with ethtool anyway.

> > +/**
> > + * \brief Alloc net device
> > + * @param size Size to allocate
> > + * @param nq how many queues
> > + * @returns pointer to net device structure
> > + */	
> > +static inline struct net_device *liquidio_alloc_netdev(int size, int nq)
> > +{
> > +	if (nq > 1)
> > +		return alloc_netdev_mq(size, "lio%d",
> NET_NAME_UNKNOWN,
> > +				       ether_setup, nq);
> > +	else
> > +		return alloc_netdev(size, "lio%d", NET_NAME_UNKNOWN,
> > +				    ether_setup);
> > +}
> 
> There is no need for the (nq > 1) test, just do:
> > +		return alloc_netdev_mq(size, "lio%d",
> NET_NAME_UNKNOWN,
> > +				       ether_setup, nq);
> 
Okay.

> Also, why does this device not have standard ethernet naming?

No good reason. We will follow the p<slot_number>p<port_number> convention.


> > +void process_noresponse_list(struct octeon_device *oct,
> > +			     struct octeon_instr_queue *iq)
> > +{
> > +	uint32_t get_idx;
> > +	struct octeon_soft_command *sc;
> > +	struct octeon_instr_ih *ih;
> 
> All global function names must start with same prefix, driver may not
> always be built as a module.
> 
> In this case oceteon_process_noresponse_list.

Okay. All global symbols will get an octeon_ or lio_ prefix.

We'll reply to the last couple issues separately.

Thanks for all the feedback.
