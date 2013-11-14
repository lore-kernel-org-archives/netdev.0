From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Test program for SIOC{G,S}HWTSTAMP
Date: Thu, 14 Nov 2013 02:46:24 +0000
Message-ID: <1384397184.29151.44.camel@bwh-desktop.uk.level5networks.com>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24874 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab3KNCqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:46:34 -0500
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I used this to exercise the two ioctls.

Ben.

---
/* Test program for SIOC{G,S}HWTSTAMP - bhutchings@solarflare.com, 2013 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/socket.h>
#include <sys/ioctl.h>

#include <linux/if.h>
#include <linux/net_tstamp.h>
#include <linux/sockios.h>

#ifndef SIOCGHWTSTAMP
#define SIOCGHWTSTAMP 0x89b1
#endif

static int
lookup_value(const char **names, int size, const char *name)
{
    int value;

    for (value = 0; value < size; value++)
	if (names[value] && strcasecmp(names[value], name) == 0)
	    return value;

    return -1;
}

static const char *
lookup_name(const char **names, int size, int value)
{
    return (value >= 0 && value < size) ? names[value] : NULL;
}

static void list_names(FILE *f, const char **names, int size)
{
    int value;

    for (value = 0; value < size; value++)
	if (names[value])
	    fprintf(f, "    %s\n", names[value]);
}

static const char *tx_types[] = {
#define TX_TYPE(name) [HWTSTAMP_TX_ ## name] = #name
    TX_TYPE(OFF),
    TX_TYPE(ON),
    TX_TYPE(ONESTEP_SYNC)
#undef TX_TYPE
};
#define N_TX_TYPES ((int)(sizeof(tx_types) / sizeof(tx_types[0])))

static const char *rx_filters[] = {
#define RX_FILTER(name) [HWTSTAMP_FILTER_ ## name] = #name
    RX_FILTER(NONE),
    RX_FILTER(ALL),
    RX_FILTER(SOME),
    RX_FILTER(PTP_V1_L4_EVENT),
    RX_FILTER(PTP_V1_L4_SYNC),
    RX_FILTER(PTP_V1_L4_DELAY_REQ),
    RX_FILTER(PTP_V2_L4_EVENT),
    RX_FILTER(PTP_V2_L4_SYNC),
    RX_FILTER(PTP_V2_L4_DELAY_REQ),
    RX_FILTER(PTP_V2_L2_EVENT),
    RX_FILTER(PTP_V2_L2_SYNC),
    RX_FILTER(PTP_V2_L2_DELAY_REQ),
    RX_FILTER(PTP_V2_EVENT),
    RX_FILTER(PTP_V2_SYNC),
    RX_FILTER(PTP_V2_DELAY_REQ),
#undef RX_FILTER
};
#define N_RX_FILTERS ((int)(sizeof(rx_filters) / sizeof(rx_filters[0])))

static void usage(void)
{
    fputs("Usage: hwtstamp_config if_name [tx_type rx_filter]\n"
	  "tx_type is any of (case-insensitive):\n",
	  stderr);
    list_names(stderr, tx_types, N_TX_TYPES);
    fputs("rx_filter is any of (case-insensitive):\n", stderr);
    list_names(stderr, rx_filters, N_RX_FILTERS);
}

int main(int argc, char **argv)
{
    struct ifreq ifr;
    struct hwtstamp_config config;
    const char *name;
    int sock;

    if ((argc != 2 && argc != 4) || (strlen(argv[1]) >= IFNAMSIZ)) {
	usage();
	return 2;
    }

    if (argc == 4) {
	config.flags = 0;
	config.tx_type = lookup_value(tx_types, N_TX_TYPES, argv[2]);
	config.rx_filter = lookup_value(rx_filters, N_RX_FILTERS, argv[3]);
	if (config.tx_type < 0 || config.rx_filter < 0) {
	    usage();
	    return 2;
	}
    }

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
	perror("socket");
	return 1;
    }

    strcpy(ifr.ifr_name, argv[1]);
    ifr.ifr_data = (caddr_t)&config;

    if (ioctl(sock, (argc == 2) ? SIOCGHWTSTAMP : SIOCSHWTSTAMP, &ifr)) {
	perror("ioctl");
	return 1;
    }

    printf("flags = %#x\n", config.flags);
    name = lookup_name(tx_types, N_TX_TYPES, config.tx_type);
    if (name)
	printf("tx_type = %s\n", name);
    else
	printf("tx_type = %d\n", config.tx_type);
    name = lookup_name(rx_filters, N_RX_FILTERS, config.rx_filter);
    if (name)
	printf("rx_filter = %s\n", name);
    else
	printf("rx_filter = %d\n", config.rx_filter);

    return 0;
}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
