From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 02/12] net/mlx5e: Statistics handling
 refactoring
Date: Mon, 25 Apr 2016 10:58:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4A9357@AcuExch.aculab.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
 <1461351647-27412-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:59640 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519AbcDYK7c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 06:59:32 -0400
In-Reply-To: <1461351647-27412-3-git-send-email-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 22 April 2016 20:01
> Redesign the statistics in the driver:
> 1. Move counters to a separate file (en_stats.h).
> 2. Remove unnecessary dependencies between stats and strings.
> 3. Use counter descriptors which hold a name and offset for each counter,
>    and will be used to decide which counters will be exposed.
> 
> For example when adding a new software counter to ethtool, instead of:
> 1. Add to stats struct.
> 2. Add to strings struct in the same order.
> 3. Change macro defining number of software counters.
> The only thing needed is to link the new counter to a counter descriptor.
...

This looks like a place for some pre-processor magic to define two (or more)
items from the same line of C source.

Taking one definition. Instead of:

> +static const struct counter_desc vport_stats_desc[] = {
> +	{ "rx_error_packets", VPORT_COUNTER_OFF(received_errors.packets) },
> +	{ "rx_error_bytes", VPORT_COUNTER_OFF(received_errors.octets) },
> +	{ "tx_error_packets", VPORT_COUNTER_OFF(transmit_errors.packets) },
> +	{ "tx_error_bytes", VPORT_COUNTER_OFF(transmit_errors.octets) },

Use the following #define to generate both the array of names and the structure.
#define VPORT_STATS_DEFN(RX, TX) \
	RX( "rx_error_packets", packets) \
	RX( "rx_error_bytes", octets) \
	TX( "tx_error_packets", packets) \
	TX( "tx_error_bytes", octets) \
	...

You can then expand it two (or more) ways:

#define STATS_NAMES(name, field) name,
static const char *const vport_stats_names[] = { VPORT_STATS_DEFN(STATS_NAMES, STATS_NAMES) };

#define STAT_FIELD(name, field) uint64_t field;
#define STAT_NONE(name, field)
struct received_errors {
	VPORT_STATS_DEFN(STAT_FIELD, STAT_NONE)
};
struct transmit_errors errors {
	VPORT_STATS_DEFN(STAT_NONE, STAT_FIELD)
};

Adding an extra stat then just requires you add an extra line to VPORT_STATS_DEFN().

	David
