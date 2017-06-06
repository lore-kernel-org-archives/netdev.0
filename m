From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Stmmac: fix for hw timestamp of GMAC 3 unit
Date: Tue, 6 Jun 2017 07:43:43 +0200
Message-ID: <d1c335a8-7236-faac-bf52-1465979849ad@st.com>
References: <trinity-32054cc5-4d62-4e1d-a846-3c34dcf24545-1496700699842@3capp-webde-bap31>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Mario Molitor <Mario_Molitor@web.de>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:55376 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750718AbdFFFns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 01:43:48 -0400
In-Reply-To: <trinity-32054cc5-4d62-4e1d-a846-3c34dcf24545-1496700699842@3capp-webde-bap31>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mario

thanks for your tests, and, at first glance, your patches seem to be 
sensible so,
please, send the changes as patches for net.git kernel.

Regards
Peppe


On 6/6/2017 12:11 AM, Mario Molitor wrote:
> Dear stmmac maintainer group,
>
> I have found an problem in stmmac driver of linux kernel and I hope for a fix in the mainline kernel.
> At the moment I have two patch files which fix this problem for me.
> The problem seems created with the commit d2042052a0aa6a54f01a0c9e14243ec040b100e2 and ba1ffd74df74a9efa5290f87632a0ed55f1aa387 has breakage the functionality of GMAC3 unit.
> I assume that these commits were only tested with a GMAC4 unit.
> I have got seen this problem with execution of ptp4l daemon on system with linux 4.11 Kernel.
>
> ===============================================================================
> root@QuantumXsoc:~ ptp4l -f /etc/ptp.cfg -i eth0 -m
> ptp4l[47.928]: selected /dev/ptp0 as PTP clock
> ptp4l[47.937]: port 1: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[47.938]: port 0: INITIALIZING to LISTENING on INITIALIZE
> ptp4l[47.938]: port 1: link up
> [   48.282709] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> [   48.316316] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> [   48.340260] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> [   48.456738] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> ptp4l[48.457]: port 1: received DELAY_REQ without timestamp
> [   48.488442] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> [   48.495599] socfpga-dwmac ff702000.ethernet eth0: get valid RX hw timestamp 0
> ptp4l[48.489]: port 1: received SYNC without timestamp
> ....
> ================================================================================
>
> I have found two kind of problems and for this two patches (based on the 4.11 kernel) which fix this problem.
>
> 1.) PTP_TCR_SNAPTYPSEL_1
>
> The first problem was for my point of view the change of definition PTP_TCR_SNAPTYPSEL_1.  I think according the
> CYCLON V documention only the bit 16 of snaptypesel should be set. (more information see Table 17-20 (cv_5v4.pdf) : Timestamp Snapshot Dependency on Register Bits)
> I believe that the GMAC4 have another necessary definition.
>
> ( patch 0001-stmmac-fix-ptp-header-for-GMAC3-hw-timestamp.patch )
> ================================================================================================
> >From 2d54d58dc8548d98572eb5fbfe488ec59b4c0ef5 Mon Sep 17 00:00:00 2001
> From: Mario Molitor <mario_molitor@web.de>
> Date: Mon, 5 Jun 2017 18:58:49 +0200
> Subject: [PATCH 1/2] stmmac: fix ptp header for GMAC3 hw timestamp
>
> According the CYCLON V documention only the bit 16 of snaptypesel should set.
> (more information see Table 17-20 (cv_5v4.pdf) : Timestamp Snapshot Dependency on Register Bits)
>
> fixed: d2042052a0aa6a54f01a0c9e14243ec040b100e2
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 15 ++++++++++++---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |  3 ++-
>   2 files changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 4498a38..13a1ac9 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -471,7 +471,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
>   			/* PTP v1, UDP, any kind of event packet */
>   			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
>   			/* take time stamp for all event messages */
> -			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
> +			if (priv->plat->has_gmac4)
> +				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
> +			else
> +				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
>   
>   			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
>   			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
> @@ -503,7 +506,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
>   			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
>   			ptp_v2 = PTP_TCR_TSVER2ENA;
>   			/* take time stamp for all event messages */
> -			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
> +			if (priv->plat->has_gmac4)
> +				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
> +			else
> +				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
>   
>   			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
>   			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
> @@ -537,7 +543,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
>   			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
>   			ptp_v2 = PTP_TCR_TSVER2ENA;
>   			/* take time stamp for all event messages */
> -			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
> +			if (priv->plat->has_gmac4)
> +				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
> +			else
> +				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
>   
>   			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
>   			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
> index 48fb72f..f4b31d6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
> @@ -59,7 +59,8 @@
>   /* Enable Snapshot for Messages Relevant to Master */
>   #define	PTP_TCR_TSMSTRENA	BIT(15)
>   /* Select PTP packets for Taking Snapshots */
> -#define	PTP_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
> +#define	PTP_TCR_SNAPTYPSEL_1	BIT(16)
> +#define	PTP_GMAC4_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
>   /* Enable MAC address for PTP Frame Filtering */
>   #define	PTP_TCR_TSENMACADDR	BIT(18)
>   
