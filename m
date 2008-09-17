From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH 2/3] enic: add main netdev file with moduleinfrastructure
Date: Tue, 16 Sep 2008 18:49:44 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809161821580.31710@palito_client100.nuovasystems.com>
References: <1221248871.3244.69.camel@achroite>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="279719954-829960017-1221616184=:31710"
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:55674 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752524AbYIQBud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 21:50:33 -0400
In-Reply-To: <1221248871.3244.69.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--279719954-829960017-1221616184=:31710
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: 8BIT

Thanks for the feedback Ben.  Responses inline.

On Fri, 12 Sep 2008, Ben Hutchings wrote:

> On Mon, 2008-09-08 at 20:57 -0700, Scott Feldman wrote:
> [...]
>> diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/drivers/net/enic/enic_main.c linux-2.6.26.3-enic/drivers/net/enic/enic_main.c
>> --- linux-2.6.26.3/drivers/net/enic/enic_main.c	1969-12-31 16:00:00.000000000 -0800
>> +++ linux-2.6.26.3-enic/drivers/net/enic/enic_main.c	2008-09-08 15:16:23.000000000 -0700
> [...]
>> +static int enic_set_rx_csum(struct net_device *netdev, u32 data)
>> +{
>> +	struct enic *enic = netdev_priv(netdev);
>> +
>> +	enic->csum_rx_enabled =
>> +		(data && ENIC_SETTING(enic, RXCSUM)) ? 1 : 0;
>> +
>> +	return 0;
>> +}
>
> This should return an error code if it can't enable RX checksum:
>
> 	if (data && !ENIC_SETTING(enic, RXCSUM))
> 		return -EOPNOTSUPP;
> 	enic->csum_rx_enabled = !!data;
> 	return 0;
>
> (I'm not sure what the correct error code is in this situation though.)

Fixed

>> +static int enic_set_tx_csum(struct net_device *netdev, u32 data)
>> +{
>> +	struct enic *enic = netdev_priv(netdev);
>> +
>> +	if (data && ENIC_SETTING(enic, TXCSUM))
>> +		netdev->features |= NETIF_F_HW_CSUM;
>> +	else
>> +		netdev->features &= ~NETIF_F_HW_CSUM;
>> +
>> +	return 0;
>> +}
>
> Similarly here.

Fixed.

> [...]
>> +static struct ethtool_ops enic_ethtool_ops = {
>> +	.get_settings = enic_get_settings,
>> +	.get_drvinfo = enic_get_drvinfo,
>> +	.get_msglevel = enic_get_msglevel,
>> +	.set_msglevel = enic_set_msglevel,
>> +	.get_link = ethtool_op_get_link,
>> +	.get_strings = enic_get_strings,
>> +	.get_stats_count = enic_get_stats_count,
>
> get_stats_count is deprecated; you should implement get_sset_count.

Not changed yet...need to figure out the backward compatibility story.

>> +/* dev_base_lock rwlock held, nominally process context */
>> +static struct net_device_stats *enic_get_stats(struct net_device *netdev)
>> +{
>> +	struct enic *enic = netdev_priv(netdev);
>> +	struct vnic_stats *stats;
>> +
>> +	spin_lock(&enic->devcmd_lock);
>> +	vnic_dev_stats_dump(enic->vdev, &stats);
>> +	spin_unlock(&enic->devcmd_lock);
>> +
>> +	enic->net_stats.tx_packets = stats->tx.tx_frames_ok;
>> +	enic->net_stats.tx_bytes = stats->tx.tx_bytes_ok;
>> +	enic->net_stats.tx_errors = stats->tx.tx_errors;
>> +	enic->net_stats.tx_dropped = stats->tx.tx_drops;
>> +
>> +	enic->net_stats.rx_packets = stats->rx.rx_frames_ok;
>> +	enic->net_stats.rx_bytes = stats->rx.rx_bytes_ok;
>> +	enic->net_stats.rx_errors = stats->rx.rx_errors;
>> +	enic->net_stats.multicast = stats->rx.rx_multicast_frames_ok;
>> +	enic->net_stats.rx_crc_errors = stats->rx.rx_crc_errors;
>> +	enic->net_stats.rx_dropped = stats->rx.rx_no_bufs;
>> +
>> +	return &enic->net_stats;
>> +}
>
> Why not use netdev->stats?

Another backward compatibility issue.  I think I'll leave this one as-is.

>> +static int enic_get_skb_header(struct sk_buff *skb, void **iphdr,
>> +	void **tcph, u64 *hdr_flags, void *priv)
>> +{
>> +	struct cq_enet_rq_desc *cq_desc = priv;
>> +	unsigned int ip_len;
>> +	struct iphdr *iph;
>> +
>> +	u8 type, color, eop, sop, ingress_port, vlan_stripped;
>> +	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
>> +	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
>> +	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
>> +	u8 packet_error;
>> +	u16 q_number, completed_index, bytes_written, vlan, checksum;
>> +	u32 rss_hash;
>> +
>> +	cq_enet_rq_desc_dec(cq_desc,
>> +		&type, &color, &q_number, &completed_index,
>> +		&ingress_port, &fcoe, &eop, &sop, &rss_type,
>> +		&csum_not_calc, &rss_hash, &bytes_written,
>> +		&packet_error, &vlan_stripped, &vlan, &checksum,
>> +		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
>> +		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
>> +		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
>> +		&fcs_ok);
>
> I don't know where that function is defined, but it's badly designed.
> It will be easy to get the order of arguments wrong and the compiler
> will probably not help because most of them have the same type.  It is
> probably better to define a structure to hold all these attributes.

I know it's not ideal as-is but a structure overlay on the descriptor 
doesn't work either because some of the fields are bit-fields and a 
structure with bit-fields isn't that portable.

+		/* Buffer overflow
>> +		 */
>> +
>> +		dev_kfree_skb_any(skb);
>> +	}
>
> Why so much vertical whitespace?  It doesn't make this easier to read;
> on the contrary, it's harder to see the whole function.

I'm snickering because I've been accused in the past of using too little 
whitepace.  It is the longest function and I didn't want to pack it to 
help with readability.  I guess I failed.

> [...]
>> +static void enic_notify_timer(unsigned long data)
>> +{
>> +	struct enic *enic = (struct enic *)data;
>> +
>> +	enic_notify_check(enic);
>> +
>> +	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERIOD));
>
> You want ÿÿround_jiffies_relative() not round_jiffies().

No, I want round_jiffies().


>> +	case VNIC_DEV_INTR_MODE_MSI:
>> +		mod_timer(&enic->notify_timer, jiffies);
>
> Do you really want this to run immediately?

Yes.

>> +static int enic_change_mtu(struct net_device *netdev, int new_mtu)
>> +{
>> +	struct enic *enic = netdev_priv(netdev);
>> +	int running = netif_running(netdev);
>> +
>> +	if (running)
>> +		enic_stop(netdev);
>> +
>> +	if (new_mtu < ENIC_MIN_MTU)
>> +		new_mtu = ENIC_MIN_MTU;
>> +	if (new_mtu > ENIC_MAX_MTU)
>> +		new_mtu = ENIC_MAX_MTU;
>
> Don't silently adjust an MTU that's out of the supported range; return
> -EINVAL.

Fixed.

>> +	if (!netif_running(enic->netdev))
>> +		return;
>> +
>> +	rtnl_lock();
>> +
>> +	spin_lock(&enic->devcmd_lock);
>> +	vnic_dev_hang_notify(enic->vdev);
>> +	spin_unlock(&enic->devcmd_lock);
>> +
>> +	enic_stop(enic->netdev);
>> +	enic_dev_soft_reset(enic);
>
> What if the soft reset fails?

If soft_reset fails, it's pretty much game over.

-scott
--279719954-829960017-1221616184=:31710--
