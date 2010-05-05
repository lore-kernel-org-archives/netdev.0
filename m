From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 5/6] hotplug: netns aware uevent_helper
Date: Tue,  4 May 2010 17:36:48 -0700
Message-ID: <1273019809-16472-5-git-send-email-ebiederm@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:46816 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934506Ab0EEAhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:37:05 -0400
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

It only makes sense for uevent_helper to get events
in the intial namespaces.  It's invocation is not
per namespace and it is not clear how we could make
it's invocation namespace aware.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 lib/kobject_uevent.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 9057ec1..1b3dbab 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -18,6 +18,7 @@
 #include <linux/string.h>
 #include <linux/kobject.h>
 #include <linux/module.h>
+#include <linux/user_namespace.h>
 
 #include <linux/socket.h>
 #include <linux/skbuff.h>
@@ -98,6 +99,21 @@ static int kobj_bcast_filter(struct sock *dsk, struct sk_buff *skb, void *data)
 	return 0;
 }
 
+static int kobj_usermode_filter(struct kobject *kobj)
+{
+	const struct kobj_ns_type_operations *ops;
+
+	ops = kobj_ns_ops(kobj);
+	if (ops) {
+		const void *init_ns, *ns;
+		ns = kobj->ktype->namespace(kobj);
+		init_ns = ops->initial_ns();
+		return ns != init_ns;
+	}
+
+	return 0;
+}
+
 /**
  * kobject_uevent_env - send an uevent with environmental data
  *
@@ -273,7 +289,7 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 #endif
 
 	/* call uevent_helper, usually only enabled during early boot */
-	if (uevent_helper[0]) {
+	if (uevent_helper[0] && !kobj_usermode_filter(kobj)) {
 		char *argv [3];
 
 		argv [0] = uevent_helper;
-- 
1.6.5.2.143.g8cc62

