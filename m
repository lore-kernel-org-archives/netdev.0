From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 1/8] openvswitch: Immediately exit on error in ovs_vport_cmd_set().
Date: Fri, 14 Jun 2013 15:28:50 -0700
Message-ID: <1371248937-35614-2-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:34007 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753522Ab3FNW3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:29:05 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa12so980557pbc.11
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:29:04 -0700 (PDT)
In-Reply-To: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is an error to try to change the type of a vport using the set
command. However, while we check that this is an error, we still
proceed to allocate memory which then gets freed immediately.
This stops processing after noticing the error, which does not
actually fix a bug but is more correct.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..748aa97 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1812,10 +1812,11 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(vport))
 		goto exit_unlock;
 
-	err = 0;
 	if (a[OVS_VPORT_ATTR_TYPE] &&
-	    nla_get_u32(a[OVS_VPORT_ATTR_TYPE]) != vport->ops->type)
+	    nla_get_u32(a[OVS_VPORT_ATTR_TYPE]) != vport->ops->type) {
 		err = -EINVAL;
+		goto exit_unlock;
+	}
 
 	reply = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!reply) {
@@ -1823,10 +1824,11 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	if (!err && a[OVS_VPORT_ATTR_OPTIONS])
+	if (a[OVS_VPORT_ATTR_OPTIONS]) {
 		err = ovs_vport_set_options(vport, a[OVS_VPORT_ATTR_OPTIONS]);
-	if (err)
-		goto exit_free;
+		if (err)
+			goto exit_free;
+	}
 
 	if (a[OVS_VPORT_ATTR_UPCALL_PID])
 		vport->upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
-- 
1.8.1.2
