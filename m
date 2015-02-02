From: shengyong <shengyong1@huawei.com>
Subject: Question: should local address be expired when updating PMTU?
Date: Mon, 2 Feb 2015 16:20:24 +0800
Message-ID: <54CF3348.40207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yangyingling@huawei.com>,
	<steffen.klassert@secunet.com>, <hannes@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:55871 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932814AbbBBIVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 03:21:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David Miller
Since commit 81aded246 (ipv6: Handle PMTU in ICMP error handlers), the entries
in neigh table may get expired. But in the situation:

          Host only
    PC <------------> Virtual Machine

a packet is sent from PC to VM, and the packet looks like:
-----------------------------------
| IPv6 (src=PC-addr, dst=VM-addr) |
|---------------------------------|
|     ICMPv6 (Packet Too Big)     |
|---------------------------------|
| IPv6 (src=VM-addr, dst=VM-addr) |
|---------------------------------|
| ICMPv6 (Neighbor Advertisement) |
-----------------------------------

Then the local addr on VM will be updated with an expire value. After the
lifetime of the local addr is expired, the VM is unreachable from PC.

	# ip -6 route list table local
	local fe80::1 dev lo  metric 0 *expire 596*

I find that the current code seems not check whether the entry is a local one
when doing PMTU update. And if the following code is added, the situation could
be avoided.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b2614b2..b80317a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1136,6 +1136,9 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 {
        struct rt6_info *rt6 = (struct rt6_info*)dst;

+       if (rt6->rt6i_flags & RTF_LOCAL)
+               return;
+
        dst_confirm(dst);
        if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
                struct net *net = dev_net(dst->dev);

So is this modification correct? Or how can we avoid such expiring?

thx & BR,
Sheng
