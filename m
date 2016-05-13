From: Guy Harris <guy@alum.mit.edu>
Subject: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time stamping?
Date: Fri, 13 May 2016 16:12:52 -0700
Message-ID: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:39143 "EHLO d.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbcEMXXr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:23:47 -0400
Received: from [192.168.42.66] (173-228-4-107.dsl.dynamic.fusionbroadband.com [173.228.4.107])
	(authenticated bits=0)
	by d.mail.sonic.net (8.15.1/8.15.1) with ESMTPSA id u4DNCrHd007819
	(version=TLSv1 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:12:53 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libpcap offers the ability to request hardware time stamping for packets and to inquire which forms of hardware time stamping, if any, are supported for an interface.

The Linux implementation currently implements the inquiry by doing a ETHTOOL_GET_TS_INFO SIOETHTOOL ioctl and looking at the so_timestamping bits, if the linux/ethtool.h header defines ETHTOOL_GET_TS_INFO and the ioctl succeeds on the device.

This is inadequate - as libpcap requests hardware time stamping for all packets, it should also check whether HWTSTAMP_FILTER_ALL is set in rx_filters, and only offer hardware time stamping if it's set.

The code in ixgbe_ptp.c does:

	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
	case HWTSTAMP_FILTER_ALL:
		/* The X550 controller is capable of timestamping all packets,
		 * which allows it to accept any filter.
		 */
		if (hw->mac.type >= ixgbe_mac_X550) {
			tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_ALL;
			config->rx_filter = HWTSTAMP_FILTER_ALL;
			adapter->flags |= IXGBE_FLAG_RX_HWTSTAMP_ENABLED;
			break;
		}
		/* fall through */
	default:
		/*
		 * register RXMTRL must be set in order to do V1 packets,
		 * therefore it is not possible to time stamp both V1 Sync and
		 * Delay_Req messages and hardware does not support
		 * timestamping all packets => return error
		 */
		adapter->flags &= ~(IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
				    IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
		config->rx_filter = HWTSTAMP_FILTER_NONE;
		return -ERANGE;

which seems to indicate that only the X550 controller supports time stamping all packets in hardware.

However, the code in ixgbe_ethtool.c does:

	switch (adapter->hw.mac.type) {
	case ixgbe_mac_X550:
	case ixgbe_mac_X550EM_x:
	case ixgbe_mac_X540:
	case ixgbe_mac_82599EB:
		info->so_timestamping =
			SOF_TIMESTAMPING_TX_SOFTWARE |
			SOF_TIMESTAMPING_RX_SOFTWARE |
			SOF_TIMESTAMPING_SOFTWARE |
			SOF_TIMESTAMPING_TX_HARDWARE |
			SOF_TIMESTAMPING_RX_HARDWARE |
			SOF_TIMESTAMPING_RAW_HARDWARE;

		if (adapter->ptp_clock)
			info->phc_index = ptp_clock_index(adapter->ptp_clock);
		else
			info->phc_index = -1;

		info->tx_types =
			(1 << HWTSTAMP_TX_OFF) |
			(1 << HWTSTAMP_TX_ON);

		info->rx_filters =
			(1 << HWTSTAMP_FILTER_NONE) |
			(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
		break;
	default:
		return ethtool_op_get_ts_info(dev, info);
	}

which draws no distinction between the X550 controller and the X540 and 82599, and doesn't say *any* of them support HWTSTAMP_FILTER_ALL.

Is it the case that only the ixgbe_mac_X550 and ixgbe_mac_X550EM_x controllers support HWTSTAMP_FILTER_ALL?  If so, shouldn't ixgbe_get_ts_info() be doing something such as:

	switch (adapter->hw.mac.type) {
	case ixgbe_mac_X550:
	case ixgbe_mac_X550EM_x:
	case ixgbe_mac_X540:
	case ixgbe_mac_82599EB:
		info->so_timestamping =
			SOF_TIMESTAMPING_TX_SOFTWARE |
			SOF_TIMESTAMPING_RX_SOFTWARE |
			SOF_TIMESTAMPING_SOFTWARE |
			SOF_TIMESTAMPING_TX_HARDWARE |
			SOF_TIMESTAMPING_RX_HARDWARE |
			SOF_TIMESTAMPING_RAW_HARDWARE;

		if (adapter->ptp_clock)
			info->phc_index = ptp_clock_index(adapter->ptp_clock);
		else
			info->phc_index = -1;

		info->tx_types =
			(1 << HWTSTAMP_TX_OFF) |
			(1 << HWTSTAMP_TX_ON);

		info->rx_filters =
			(1 << HWTSTAMP_FILTER_NONE) |
			(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
		if (adapter->hw.mac.type >= ixgbe_mac_X550)
			info->rx_filters |= (1 << HWTSTAMP_FILTER_ALL);
		break;
	default:
		return ethtool_op_get_ts_info(dev, info);
	}

>From a quick scan of drivers/net, it looks as if

	drivers/net/ethernet/cavium/liquidio

also support HWTSTAMP_FILTER_ALL but don't advertise it, 

	drivers/net/ethernet/chelsio/cxgb4

doesn't set rx_filters (or tx_types) and thus doesn't appear to advertise support for *any* filters, 

	drivers/net/ethernet/freescale/gianfar*.c

reports HWTSTAMP_FILTER_ALL even if the device doesn't have FSL_GIANFAR_DEV_HAS_TIMER set so that it claims that devices without a timer can do hardware timestamping,

	drivers/net/ethernet/stmicro/stmmac/

appears to advertise a whole bunch of HWTSTAMP_FILTER_ types regardless of whether the device supports "IEEE 1588-2008 Advanced Time Stamp", but, if it doesn't support that, it maps all supports filters other than HWTSTAMP_FILTER_NONE to HWTSTAMP_FILTER_PTP_V1_L4_EVENT (which is misleading), and

	drivers/net/ethernet/cavium/octeon

	drivers/net/ethernet/neterion/vxge/

	drivers/net/ethernet/tile/tilegx.c

don't even provide their own get_ts_info routines and thus doesn't advertise hardware timestamping at all.
