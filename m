From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] devinet: show all addresses assigned to interface
Date: Thu, 6 Sep 2007 16:10:00 +0100
Message-ID: <20070906161000.74923fff@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41089 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755693AbXIFPJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 11:09:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bug: http://bugzilla.kernel.org/show_bug.cgi?id=8876

Not all ips are shown by "ip addr show" command when IPs number assigned to an
interface is more than 60-80 (in fact it depends on broadcast/label etc
presence on each address).

Steps to reproduce:
It's terribly simple to reproduce:

# for i in $(seq 1 100); do ip ad add 10.0.$i.1/24 dev eth10 ; done
# ip addr show

this will _not_ show all IPs.
Looks like the problem is in netlink/ipv4 message processing.

This is fix from bug submitter, it looks correct.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/devinet.c	2007-08-15 12:56:38.000000000 +0100
+++ b/net/ipv4/devinet.c	2007-09-06 16:02:59.000000000 +0100
@@ -1193,7 +1193,7 @@ static int inet_dump_ifaddr(struct sk_bu
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
 			if (ip_idx < s_ip_idx)
-				goto cont;
+				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
 					     RTM_NEWADDR, NLM_F_MULTI) <= 0)
