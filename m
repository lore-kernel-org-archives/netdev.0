From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 13:29:01 -0400
Message-ID: <4BB234DD.9040800@garzik.org>
References: <20100328154448.701c89ee@nehalam>	<20100329174727.4654e19c@nehalam> <20100329175352.38008e05@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:55089 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443Ab0C3R3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 13:29:06 -0400
Received: by pva18 with SMTP id 18so2909394pva.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 10:29:05 -0700 (PDT)
In-Reply-To: <20100329175352.38008e05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2010 08:53 PM, Stephen Hemminger wrote:
> Add support for RXHASH flag in ethtool offload.
> Update to current net-next sanitized version of ethtool.h
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> ---
>   ethtool-copy.h |   32 +++++++++++++++++++++++++-------
>   ethtool.8      |    4 ++++
>   ethtool.c      |   42 +++++++++++++++++++++++++++++++++++++-----
>   3 files changed, 66 insertions(+), 12 deletions(-)
>
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 8681f5e..0cf8f33 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -36,7 +36,7 @@ struct ethtool_cmd {
>   	__u32	reserved[2];
>   };
>
> -static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
> +static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
>   						__u32 speed)
>   {
>
> @@ -44,7 +44,7 @@ static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
>   	ep->speed_hi = (__u16)(speed>>  16);
>   }
>
> -static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
> +static __inline__ __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
>   {
>   	return (ep->speed_hi<<  16) | ep->speed;
>   }
> @@ -61,6 +61,13 @@ struct ethtool_drvinfo {
>   				/* For PCI devices, use pci_name(pci_dev). */
>   	char	reserved1[32];
>   	char	reserved2[12];
> +				/*
> +				 * Some struct members below are filled in
> +				 * using ops->get_sset_count().  Obtaining
> +				 * this info from ethtool_drvinfo is now
> +				 * deprecated; Use ETHTOOL_GSSET_INFO
> +				 * instead.
> +				 */
>   	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
>   	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
>   	__u32	testinfo_len;
> @@ -253,6 +260,17 @@ struct ethtool_gstrings {
>   	__u8	data[0];
>   };
>
> +struct ethtool_sset_info {
> +	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
> +	__u32	reserved;
> +	__u64	sset_mask;	/* input: each bit selects an sset to query */
> +				/* output: each bit a returned sset */
> +	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
> +				   in sset_mask.  One bit implies one
> +				   __u32, two bits implies two
> +				   __u32's, etc. */
> +};
> +
>   enum ethtool_test_flags {
>   	ETH_TEST_FL_OFFLINE	= (1<<  0),	/* online / offline */
>   	ETH_TEST_FL_FAILED	= (1<<  1),	/* test passed / failed */
> @@ -292,6 +310,7 @@ struct ethtool_perm_addr {
>   enum ethtool_flags {
>   	ETH_FLAG_LRO		= (1<<  15),	/* LRO is enabled */
>   	ETH_FLAG_NTUPLE		= (1<<  27),	/* N-tuple filters enabled */
> +	ETH_FLAG_RXHASH		= (1<<  28),
>   };
>
>   /* The following structures are for supporting RX network flow
> @@ -389,8 +408,6 @@ struct ethtool_rx_ntuple_flow_spec {
>   #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
>   };
>
> -#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
> -#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
>   struct ethtool_rx_ntuple {
>   	__u32					cmd;
>   	struct ethtool_rx_ntuple_flow_spec	fs;
> @@ -408,6 +425,7 @@ struct ethtool_flash {
>   	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>   };
>
> +
>   /* CMDs currently supported */
>   #define ETHTOOL_GSET		0x00000001 /* Get settings. */
>   #define ETHTOOL_SSET		0x00000002 /* Set settings. */
> @@ -463,9 +481,9 @@ struct ethtool_flash {
>   #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
>   #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
>   #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
> -
> -#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
> -#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
> +#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
> +#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
> +#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
>

NAK - you broke the build.  You should also know not to combine patches 
like this.  Linux 101: separate changes, separate patches.

By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY 
and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed, 
breaking the ethtool build.

Furthermore, I just pulled net-next and did my own sync, and those 
s/inline/__inline__/ substitutions are not present.

I went ahead and made sure everything is sync'd correctly and building 
correctly, in the ethtool git repo.  Please resubmit a patch DIRECTLY 
and ONLY related to RXHASH flag support.  If you decide to do any other 
work, that belongs in a separate patch.

	Jeff




