From: Jan Luebbe <jluebbe@debian.org>
Subject: [PATCH] Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in ip_options_echo()
Date: Thu, 24 Mar 2011 18:44:22 +0100
Message-ID: <1300988662-13204-1-git-send-email-jluebbe@debian.org>
Cc: Jan Luebbe <jluebbe@debian.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:33832 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932109Ab1CXRo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 13:44:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current handling of echoed IP timestamp options with prespecified
addresses is rather broken since the 2.2.x kernels. As far as i understand
it, it should behave like when originating packets.

Currently it will only timestamp the next free slot if:
 - there is space for *two* timestamps
 - some random data from the echoed packet taken as an IP is *not* a local IP

This first is caused by an off-by-one error. 'soffset' points to the next
free slot and so we only need to have 'soffset + 7 <= optlen'.

The second bug is using sptr as the start of the option, when it really is
set to 'skb_network_header(skb)'. I just use dptr instead which points to
the timestamp option.

Finally it would only timestamp for non-local IPs, which we shouldn't do.
So instead we exclude all unicast destinations, similar to what we do in
ip_options_compile().

Signed-off-by: Jan Luebbe <jluebbe@debian.org>
---
 net/ipv4/ip_options.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 1906fa3..28a736f 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -140,11 +140,11 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 				} else {
 					dopt->ts_needtime = 0;
 
-					if (soffset + 8 <= optlen) {
+					if (soffset + 7 <= optlen) {
 						__be32 addr;
 
-						memcpy(&addr, sptr+soffset-1, 4);
-						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_LOCAL) {
+						memcpy(&addr, dptr+soffset-1, 4);
+						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_UNICAST) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
-- 
1.7.4.1

