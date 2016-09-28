From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 10/12] openvswitch: make get_dp_rcu() available outside datapath.c
Date: Wed, 28 Sep 2016 14:43:00 +0200
Message-ID: <1475066582-1971-11-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37699 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932371AbcI1MnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:23 -0400
Received: by mail-wm0-f43.google.com with SMTP id b130so69648061wmc.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:22 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make get_dp_rcu() available outside datapath.c and as a precaution add a
check to ensure that rcu_read_lock is held.

This is in preparation for calling get_dp_rcu() from other source files
which is in turn in preparation for prototyping allowing Open vSwitch to
program flows into hardware.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/datapath.c | 4 +++-
 net/openvswitch/datapath.h | 2 ++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4d67ea856067..365d480031d3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -145,10 +145,12 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
 				  uint32_t cutlen);
 
 /* Must be called with rcu_read_lock. */
-static struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
+struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
 {
 	struct net_device *dev = dev_get_by_index_rcu(net, dp_ifindex);
 
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
 	if (dev) {
 		struct vport *vport = ovs_internal_dev_get_vport(dev);
 		if (vport)
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index ab85c1cae255..6094d912eaec 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -154,6 +154,8 @@ int lockdep_ovsl_is_held(void);
 #define lockdep_ovsl_is_held()	1
 #endif
 
+struct datapath *get_dp_rcu(struct net *net, int dp_ifindex);
+
 #define ASSERT_OVSL()		WARN_ON(!lockdep_ovsl_is_held())
 #define ovsl_dereference(p)					\
 	rcu_dereference_protected(p, lockdep_ovsl_is_held())
-- 
2.7.0.rc3.207.g0ac5344
