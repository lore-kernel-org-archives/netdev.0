From: Wei Zhang <asuka.com@163.com>
Subject: [PATCH] net: fix incorrect original ingress device index in PKTINFO
Date: Tue, 27 Dec 2016 15:52:18 +0800
Message-ID: <1482825138-2125-1-git-send-email-asuka.com@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we send a packet for our own local address on a non-loopback interface
(e.g. eth0), due to the change had been introduced from commit 0b922b7a829c
("net: original ingress device index in PKTINFO"), the original ingress
device index would be set as the loopback interface. However, the packet
should be considered as if it is being arrived via the sending interface
(eth0), otherwise it would break the expectation of the userspace
application (e.g. the DHCPRELEASE message from dhcp_release binary would
be ignored by the dnsmasq daemon)

Signed-off-by: Wei Zhang <asuka.com@163.com>
---
 net/ipv4/ip_sockglue.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b8a2d63..b6a6d35 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1202,8 +1202,13 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		 * which has interface index (iif) as the first member of the
 		 * underlying inet{6}_skb_parm struct. This code then overlays
 		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
-		 * element so the iif is picked up from the prior IPCB
+		 * element so the iif is picked up from the prior IPCB except
+		 * iif is loopback interface which the packet should be 
+		 * considered as if it is being arrived via the sending interface
 		 */
+		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX) {
+			pktinfo->ipi_ifindex = inet_iif(skb);
+		}
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
 		pktinfo->ipi_ifindex = 0;
-- 
1.8.3.1
