From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 4/6] kobj: Send hotplug events in the proper namespace.
Date: Tue,  4 May 2010 17:36:47 -0700
Message-ID: <1273019809-16472-4-git-send-email-ebiederm@xmission.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34764 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934270Ab0EEAhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:37:02 -0400
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Utilize netlink_broacast_filtered to allow sending hotplug events
in the proper namespace.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 lib/kobject_uevent.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 3f5f17b..9057ec1 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -82,6 +82,22 @@ out:
 	return ret;
 }
 
+static int kobj_bcast_filter(struct sock *dsk, struct sk_buff *skb, void *data)
+{
+	struct kobject *kobj = data;
+	const struct kobj_ns_type_operations *ops;
+
+	ops = kobj_ns_ops(kobj);
+	if (ops) {
+		const void *sock_ns, *ns;
+		ns = kobj->ktype->namespace(kobj);
+		sock_ns = ops->netlink_ns(dsk);
+		return sock_ns != ns;
+	}
+
+	return 0;
+}
+
 /**
  * kobject_uevent_env - send an uevent with environmental data
  *
@@ -243,8 +259,10 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 			}
 
 			NETLINK_CB(skb).dst_group = 1;
-			retval = netlink_broadcast(uevent_sock, skb, 0, 1,
-						   GFP_KERNEL);
+			retval = netlink_broadcast_filtered(uevent_sock, skb,
+							    0, 1, GFP_KERNEL,
+							    kobj_bcast_filter,
+							    kobj);
 			/* ENOBUFS should be handled in userspace */
 			if (retval == -ENOBUFS)
 				retval = 0;
-- 
1.6.5.2.143.g8cc62

