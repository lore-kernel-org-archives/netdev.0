From: David Miller <davem@davemloft.net>
Subject: vrf saddr selection
Date: Sat, 29 Aug 2015 16:40:30 -0700 (PDT)
Message-ID: <20150829.164030.1189207364184023707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbbH2Xkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 19:40:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the output path we go:

	struct flowi4 fl4 = {
		/* needed to match OIF rule */
		.flowi4_oif = vrf_dev->ifindex,
		.flowi4_iif = LOOPBACK_IFINDEX,
		.flowi4_tos = RT_TOS(ip4h->tos),
		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
		.daddr = ip4h->daddr,
	};

	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
		goto err;

	if (!ip4h->saddr) {
		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
					       RT_SCOPE_LINK);
	}

So in the case where the source address is needed, this
inet_select_addr() call looks like useless work.

The route lookup already filled in fl4.saddr for you, why don't we
just use that?
