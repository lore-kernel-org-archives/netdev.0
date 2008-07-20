From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG?] dst reference leak possible in ndisc_send
Date: Sat, 19 Jul 2008 23:31:40 -0700
Message-ID: <20080719233140.601a15a4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56235 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbYGTGbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2008 02:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code path looks like it leaks the dst_entry  if xfrm_lookup fails:

static void __ndisc_send(struct net_device *dev,
			 struct neighbour *neigh,
			 const struct in6_addr *daddr,
			 const struct in6_addr *saddr,
			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
			 int llinfo)
{
	struct flowi fl;
	struct dst_entry *dst;
	struct net *net = dev_net(dev);
	struct sock *sk = net->ipv6.ndisc_sk;
	struct sk_buff *skb;
	struct icmp6hdr *hdr;
	struct inet6_dev *idev;
	int len;
	int err;
	u8 *opt, type;

	type = icmp6h->icmp6_type;

	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);

	dst = icmp6_dst_alloc(dev, neigh, daddr);
	if (!dst)
		return;

	err = xfrm_lookup(&dst, &fl, NULL, 0);
	if (err < 0)
		return;
