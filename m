From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers: net: ethernet: intel: e1000: e1000_ethtool.c
 coding style fixes
Date: Sat, 16 Aug 2014 11:41:29 -0700
Message-ID: <1408214489.2683.87.camel@joe-AO725>
References: <1408180328-4827-1-git-send-email-cristos@vipserv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408180328-4827-1-git-send-email-cristos@vipserv.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-08-16 at 11:12 +0200, Krzysztof Majzerowicz-Jaszcz wrote:
> Fixed many errors/warnings and checks in e1000_ethtool.c reported by checkpatch.pl

Hello Krzysztof.

Just some trivial notes:

> diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
[]
> @@ -1,35 +1,30 @@
>  /*******************************************************************************
> -
> -  Intel PRO/1000 Linux driver
> -  Copyright(c) 1999 - 2006 Intel Corporation.
> -
> -  This program is free software; you can redistribute it and/or modify it
> -  under the terms and conditions of the GNU General Public License,
> -  version 2, as published by the Free Software Foundation.
[]
> + * Intel PRO/1000 Linux driver
> + *  Copyright(c) 1999 - 2006 Intel Corporation.
> + *
> + *  This program is free software; you can redistribute it and/or modify it
> + *  under the terms and conditions of the GNU General Public License,
> + *  version 2, as published by the Free Software Foundation.

There's odd space use after the * here.

I think it better to always use a single space not
one for the first line and two for subsequent lines.

> @@ -680,8 +676,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
>  			     u32 mask, u32 write)
>  {
>  	struct e1000_hw *hw = &adapter->hw;
> -	static const u32 test[] =
> -		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
> +	static const u32 test[] = {0x5A5A5A5A, 0xA5A5A5A5,
> +				   0x00000000, 0xFFFFFFFF};

Canonical form is
	struct foo bar[] = {
		...
	};
so
	static const u32 test[] = {
		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
	};

> @@ -792,10 +788,9 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
>  		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
>  		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
>  		value = E1000_RAR_ENTRIES;
> -		for (i = 0; i < value; i++) {
> -			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
> -			                 0xFFFFFFFF);
> -		}
> +		for (i = 0; i < value; i++)
> +			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2),
> +					 0x8003FFFF, 0xFFFFFFFF);

It's OK to keep the braces when a single statement
spans multiple lines.

> @@ -1397,7 +1390,7 @@ static int e1000_check_lbtest_frame(struct sk_buff *skb,
>  	frame_size &= ~1;
>  	if (*(skb->data + 3) == 0xFF) {
>  		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
> -		   (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
> +		    (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
>  			return 0;
>  		}
>  	}

Perhaps these would read better using [] indexing

	if (skb->data[3] == 0xff) {
		if (skb->data[frame_size / 2 + 10] == 0xbe &&
		    skb->data[frame_size / 2 + 12] == 0xaf) {

> @@ -1835,11 +1830,11 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
>  	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
>  		switch (e1000_gstrings_stats[i].type) {
>  		case NETDEV_STATS:
> -			p = (char *) netdev +
> +			p = (char *)netdev +
>  					e1000_gstrings_stats[i].stat_offset;
>  			break;
>  		case E1000_STATS:
> -			p = (char *) adapter +
> +			p = (char *)adapter +
>  					e1000_gstrings_stats[i].stat_offset;
>  			brseak;
>  		}

Maybe use a temporary for &e1000_gstring_stats[i]

Something like: (w/ void * for char *, WARN_ONCE, trigraph->if/else)

static void e1000_get_ethtool_stats(struct net_device *netdev,
				    struct ethtool_stats *stats, u64 *data)
{
	struct e1000_adapter *adapter = netdev_priv(netdev);
	int i;
	void *p = NULL;
	const struct e1000_stats *stat = e1000_gstring_stats;

	e1000_update_stats(adapter);

	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
		switch (stat->type) {
		case NETDEV_STATS:
			p = (void *)netdev + stat->stat_offset;
			break;
		case E1000_STATS:
			p = (void *)adapter + stat->stat_offset;
			break;
		default:
			WARN_ONCE(1, "Invalid E1000 stat type: %u index %d\n",
				  stat->type, i);
			break;
		}

		if (stat->sizeof_stat == sizeof(u64))
			data[i] = *(u64 *)p;
		else
			data[i] = *(u32 *)p;

		stat++;
	}
}

> @@ -1859,7 +1854,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
>  	switch (stringset) {
>  	case ETH_SS_TEST:
>  		memcpy(data, *e1000_gstrings_test,
> -			sizeof(e1000_gstrings_test));
> +		       sizeof(e1000_gstrings_test));

This fits in 80 columns on a single line.

		memcpy(data, *e1000_gstrings_test, sizeof(e1000_gstrings_test));

Not sure why there's what seems a superfluous * though.
Maybe:
		memcpy(data, e1000_gstrings_test, sizeof(e1000_gstrings_test));
