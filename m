From: Cong Wang <amwang@redhat.com>
Subject: [Patch net v2] ipip: fix a regression in ioctl
Date: Tue,  2 Jul 2013 14:49:34 +0800
Message-ID: <1372747774-28570-1-git-send-email-amwang@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab3GBGt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 02:49:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This is a regression introduced by 
commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)

Similar to GRE tunnel, previously we only check the parameters
for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
check is moved for all commands.

So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.

Also, the check for i_key, o_key etc. is suspicious too,
which did not exist before, reset them before passing
to ip_tunnel_ioctl().

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: reset *_key and *_flags before passing them to ip_tunnel_ioctl

 net/ipv4/ipip.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 77bfcce..7cfc456 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -240,11 +240,13 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
 
-	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
-			p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
-		return -EINVAL;
-	if (p.i_key || p.o_key || p.i_flags || p.o_flags)
-		return -EINVAL;
+	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
+		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
+		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
+			return -EINVAL;
+	}
+
+	p.i_key = p.o_key = p.i_flags = p.o_flags = 0;
 	if (p.iph.ttl)
 		p.iph.frag_off |= htons(IP_DF);
 
