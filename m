From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] vxlan: fix missing options_len update on RX with collect metadata
Date: Wed,  2 Mar 2016 02:32:08 +0100
Message-ID: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, pshelar@nicira.com, jesse@kernel.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59879 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753433AbcCBBcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 20:32:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When signalling to metadata consumers that the metadata_dst entry
carries additional GBP extension data for vxlan (TUNNEL_VXLAN_OPT),
the dst's vxlan_metadata information is populated, but options_len
is left to zero. F.e. in ovs, ovs_flow_key_extract() checks for
options_len before extracting the data through ip_tunnel_info_opts_get().

Geneve uses ip_tunnel_info_opts_set() helper in receive path, which
sets options_len internally, vxlan however uses ip_tunnel_info_opts(),
so when filling vxlan_metadata, we do need to update options_len.

Fixes: 4c22279848c5 ("ip-tunnel: Use API to access tunnel metadata options.")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/vxlan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b601139..1c32bd1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1308,8 +1308,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		gbp = (struct vxlanhdr_gbp *)vxh;
 		md->gbp = ntohs(gbp->policy_id);
 
-		if (tun_dst)
+		if (tun_dst) {
 			tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
+			tun_dst->u.tun_info.options_len = sizeof(*md);
+		}
 
 		if (gbp->dont_learn)
 			md->gbp |= VXLAN_GBP_DONT_LEARN;
-- 
1.9.3
