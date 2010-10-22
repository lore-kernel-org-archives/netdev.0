From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: Fix some corner cases in
 dev_can_checksum()
Date: Fri, 22 Oct 2010 15:18:58 +0100
Message-ID: <1287757138.2316.18.camel@achroite.uk.solarflarecom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	 <1287618974-4714-5-git-send-email-jesse@nicira.com>
	 <1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
	 <AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
	 <1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51671 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757087Ab0JVOTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 10:19:01 -0400
In-Reply-To: <1287756739.2316.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Of the following tests, the current implementation fails
'test_no_2vlan_ob_ip' and 'test_vlan_ib_unknown'.

Ben.

#include <assert.h>
#include <stdbool.h>
#include <string.h>

/* Dummy definitions */

typedef unsigned short __be16, __u16, u16;

static inline __be16 htons(u16 value)
{
	return value >> 8 | value << 8;
}

struct net_device {
	unsigned long		features;
#define NETIF_F_SG		1	/* Scatter/gather IO. */
#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
	unsigned long vlan_features;
};

struct sk_buff {
	__be16 protocol;
	__u16			vlan_tci;
	void *data;
};

#define ETH_ALEN 6

struct ethhdr {
	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
	__be16		h_proto;		/* packet type ID field	*/
};

struct vlan_ethhdr {
	unsigned char	h_dest[ETH_ALEN];
	unsigned char	h_source[ETH_ALEN];
	__be16		h_vlan_proto;
	__be16		h_vlan_TCI;
	__be16		h_vlan_encapsulated_proto;
};

#define ETH_P_IP	0x0800		/* Internet Protocol packet	*/
#define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
#define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */

#define VLAN_CFI_MASK		0x1000 /* Canonical Format Indicator */
#define VLAN_TAG_PRESENT	VLAN_CFI_MASK

#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)

/* Functions to test */

static bool can_checksum_protocol(unsigned long features, __be16 protocol)
{
	return ((features & NETIF_F_GEN_CSUM) ||
		((features & NETIF_F_IP_CSUM) &&
		 protocol == htons(ETH_P_IP)) ||
		((features & NETIF_F_IPV6_CSUM) &&
		 protocol == htons(ETH_P_IPV6)) ||
		((features & NETIF_F_FCOE_CRC) &&
		 protocol == htons(ETH_P_FCOE)));
}

static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
{
       __be16 protocol = skb->protocol;
       int features = dev->features;

       if (vlan_tx_tag_present(skb)) {
               features &= dev->vlan_features;
       } else if (protocol == htons(ETH_P_8021Q)) {
               struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
               protocol = veh->h_vlan_encapsulated_proto;
               features &= dev->vlan_features;
       }

       return can_checksum_protocol(features, protocol);
}

/* Test suite */

struct test_data {
	union {
		struct ethhdr eh;
		struct vlan_ethhdr veh;
	};
	struct sk_buff skb;
	struct net_device dev;
};

typedef void test_fn(struct test_data *);

static void test_unknown(struct test_data *data)
{
	data->dev.features = NETIF_F_IP_CSUM;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_no_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_IP);
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_IP);
	data->dev.features = NETIF_F_IP_CSUM;
	assert(dev_can_checksum(&data->dev, &data->skb));
}

static void test_vlan_ob_unknown(struct test_data *data)
{
	data->skb.vlan_tci = VLAN_CFI_MASK | 1;
	data->dev.features = NETIF_F_GEN_CSUM;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_no_vlan_ob_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_IP);
	data->skb.vlan_tci = VLAN_CFI_MASK | 1;
	data->dev.features = NETIF_F_IP_CSUM;
	data->dev.vlan_features = 0;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_vlan_ob_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_IP);
	data->skb.vlan_tci = VLAN_CFI_MASK | 1;
	data->dev.features = NETIF_F_IP_CSUM;
	data->dev.vlan_features = NETIF_F_IP_CSUM;
	assert(dev_can_checksum(&data->dev, &data->skb));
}

static void test_vlan_ib_unknown(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_8021Q);
	data->dev.features = NETIF_F_GEN_CSUM;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_no_vlan_ib_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_8021Q);
	data->veh.h_vlan_encapsulated_proto = htons(ETH_P_IP);
	data->dev.features = NETIF_F_IP_CSUM;
	data->dev.vlan_features = 0;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static void test_vlan_ib_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_8021Q);
	data->veh.h_vlan_encapsulated_proto = htons(ETH_P_IP);
	data->dev.features = NETIF_F_IP_CSUM;
	data->dev.vlan_features = NETIF_F_IP_CSUM;
	assert(dev_can_checksum(&data->dev, &data->skb));
}

static void test_no_2vlan_ob_ip(struct test_data *data)
{
	data->skb.protocol = htons(ETH_P_8021Q);
	data->skb.vlan_tci = VLAN_CFI_MASK | 1;
	data->veh.h_vlan_encapsulated_proto = htons(ETH_P_IP);
	data->dev.features = NETIF_F_IP_CSUM;
	data->dev.vlan_features = NETIF_F_IP_CSUM;
	assert(!dev_can_checksum(&data->dev, &data->skb));
}

static test_fn *tests[] = {
	test_unknown, test_no_ip, test_ip,
	test_vlan_ob_unknown, test_no_vlan_ob_ip, test_vlan_ob_ip,
	test_vlan_ib_unknown, test_no_vlan_ib_ip, test_vlan_ib_ip,
	test_no_2vlan_ob_ip,
};

int main(void)
{
	struct test_data data;
	test_fn **test;

	for (test = tests;
	     test != tests + sizeof(tests) / sizeof(tests[0]);
	     ++test) {
		memset(&data, 0, sizeof(data));
		data.skb.data = &data.eh;
		(**test)(&data);
	}

	return 0;
}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

