From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Fri, 27 Feb 2009 04:16:19 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902270414290.14912@fbirervta.pbzchgretzou.qr>
References: <20090226175247.5e56910f@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:60988 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbZB0DQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 22:16:23 -0500
In-Reply-To: <20090226175247.5e56910f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-02-27 02:52, Stephen Hemminger wrote:
>+static bool strict_mt(const struct sk_buff *skb, const struct xt_match_param *par)
>+{
>+	struct in_device *in_dev;
>+	bool ret;
>+
>+	rcu_read_lock();
>+	in_dev = __in_dev_get_rcu(skb->dev);
>+	ret = (in_dev && inet_addr_onlink(in_dev, ip_hdr(skb)->daddr, 0));
>+	rcu_read_unlock();
>+
>+	return ret;
>+}

This looks easy enough to also do for IPv6. Would you?

>+static struct xt_match strict_mt_reg __read_mostly = {
>+	.name		= "strict",
>+	.family		= NFPROTO_IPV4,
>+	.match		= strict_mt,
>+	.matchsize	= 0,
>+	.me		= THIS_MODULE,
>+};

The match seems to make the most sense where an input device
is available, so

	.hooks = (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_IN) |
	         (1 << NF_INET_FORWARD)

should probably be added.
