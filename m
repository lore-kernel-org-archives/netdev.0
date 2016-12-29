From: Wei Zhang <asuka.com@163.com>
Subject: [PATCH v2] net: fix incorrect original ingress device index in PKTINFO
Date: Thu, 29 Dec 2016 16:45:04 +0800
Message-ID: <1483001104-17614-1-git-send-email-asuka.com@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, dsa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we send a packet for our own local address on a non-loopback
interface (e.g. eth0), due to the change had been introduced from
commit 0b922b7a829c ("net: original ingress device index in PKTINFO"), the
original ingress device index would be set as the loopback interface.
However, the packet should be considered as if it is being arrived via the
sending interface (eth0), otherwise it would break the expectation of the
userspace application (e.g. the DHCPRELEASE message from dhcp_release
binary would be ignored by the dnsmasq daemon, since it come from lo which
is not the interface dnsmasq bind to)

Fixes: 0b922b7a829c ("net: original ingress device index in PKTINFO")
Acked-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Wei Zhang <asuka.com@163.com>
---
v2:
 - add the missing Fixes line
 - better comment come from David Ahern

 net/ipv4/ip_sockglue.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 57e1405..53ae0c6 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1225,8 +1225,14 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		 * which has interface index (iif) as the first member of the
 		 * underlying inet{6}_skb_parm struct. This code then overlays
 		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
-		 * element so the iif is picked up from the prior IPCB
+		 * element so the iif is picked up from the prior IPCB. If iif
+		 * is the loopback interface, then return the sending interface
+		 * (e.g., process binds socket to eth0 for Tx which is
+		 * redirected to loopback in the rtable/dst).
 		 */
+		if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX)
+			pktinfo->ipi_ifindex = inet_iif(skb);
+
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
 		pktinfo->ipi_ifindex = 0;
-- 
1.8.3.1
