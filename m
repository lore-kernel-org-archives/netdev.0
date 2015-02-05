From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] rtnetlink: ifla_vf_policy: fix misuses of NLA_BINARY
Date: Thu,  5 Feb 2015 18:44:04 +0100
Message-ID: <ceaf2a9c514600d14c9f6a89a8c38e553a85e9fe.1423158127.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60802 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbBERoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:44:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifla_vf_policy[] is wrong in advertising its individual member types as
NLA_BINARY since .type = NLA_BINARY in combination with .len declares the
len member as *max* attribute length [0, len].

The issue is that when do_setvfinfo() is being called to set up a VF
through ndo handler, we could set corrupted data if the attribute length
is less than the size of the related structure itself.

The intent is exactly the opposite, namely to make sure to pass at least
data of minimum size of len.

Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")
Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/rtnetlink.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 446cbaf..5daabfd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1237,18 +1237,12 @@ static const struct nla_policy ifla_vfinfo_policy[IFLA_VF_INFO_MAX+1] = {
 };
 
 static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
-	[IFLA_VF_MAC]		= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_mac) },
-	[IFLA_VF_VLAN]		= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_vlan) },
-	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_tx_rate) },
-	[IFLA_VF_SPOOFCHK]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_spoofchk) },
-	[IFLA_VF_RATE]		= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_rate) },
-	[IFLA_VF_LINK_STATE]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_link_state) },
+	[IFLA_VF_MAC]		= { .len = sizeof(struct ifla_vf_mac) },
+	[IFLA_VF_VLAN]		= { .len = sizeof(struct ifla_vf_vlan) },
+	[IFLA_VF_TX_RATE]	= { .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_VF_SPOOFCHK]	= { .len = sizeof(struct ifla_vf_spoofchk) },
+	[IFLA_VF_RATE]		= { .len = sizeof(struct ifla_vf_rate) },
+	[IFLA_VF_LINK_STATE]	= { .len = sizeof(struct ifla_vf_link_state) },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
-- 
1.9.3
