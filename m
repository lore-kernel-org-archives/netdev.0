From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: [PATCH] net: l2tp: fix reversed udp6 checksum flags
Date: Fri, 29 Apr 2016 01:32:30 +0800
Message-ID: <BC51AA6B-A62C-446D-8B70-6717FC222674@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34415 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcD1Rce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 13:32:34 -0400
Received: by mail-pf0-f173.google.com with SMTP id y69so36292017pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 10:32:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug which causes the behavior of whether to ignore
udp6 checksum of udp6 encapsulated l2tp tunnel contrary to what
userspace program requests.

When the flag `L2TP_ATTR_UDP_ZERO_CSUM6_RX` is set by userspace, it is
expected that udp6 checksums of received packets of the l2tp tunnel
to create should be ignored. In `l2tp_netlink.c`:
`l2tp_nl_cmd_tunnel_create()`, `cfg.udp6_zero_rx_checksums` is set
according to the flag, and then passed to `l2tp_core.c`:
`l2tp_tunnel_create()` and then `l2tp_tunnel_sock_create()`. In
`l2tp_tunnel_sock_create()`, `udp_conf.use_udp6_rx_checksums` is set
the same to `cfg.udp6_zero_rx_checksums`. However, if we want the
checksum to be ignored, `udp_conf.use_udp6_rx_checksums` should be set
to `false`, i.e. be set to the contrary. Similarly, the same should be
done to `udp_conf.use_udp6_tx_checksums`.

Signed-off-by: Miao Wang <shankerwangmiao@gmail.com>
---
net/l2tp/l2tp_core.c | 4 ++--
1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index afca2eb..6edfa99 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net *net,
			memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
			       sizeof(udp_conf.peer_ip6));
			udp_conf.use_udp6_tx_checksums =
-			    cfg->udp6_zero_tx_checksums;
+			  ! cfg->udp6_zero_tx_checksums;
			udp_conf.use_udp6_rx_checksums =
-			    cfg->udp6_zero_rx_checksums;
+			  ! cfg->udp6_zero_rx_checksums;
		} else
#endif
		{
-- 
2.5.2
