From: <gregkh@suse.de>
Subject: patch hotplug-netns-aware-uevent_helper.patch added to gregkh-2.6 tree
Date: Thu, 20 May 2010 11:10:37 -0700
Message-ID: <12743790373148@kroah.org>
References: <1273019809-16472-5-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: ebiederm@xmission.com, bcrl@lhnet.ca, cornelia.huck@de.ibm.com,
	davem@davemloft.net, eric.dumazet@gmail.com, gregkh@suse.de,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.ibm.
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:43233 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757001Ab0ETSKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 14:10:52 -0400
In-Reply-To: <1273019809-16472-5-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: hotplug: netns aware uevent_helper

to my gregkh-2.6 tree.  Its filename is

    hotplug-netns-aware-uevent_helper.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com  Thu May 20 10:45:13 2010
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue,  4 May 2010 17:36:48 -0700
Subject: hotplug: netns aware uevent_helper
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, Benjamin LaHaise <bcrl@lhnet.ca>, Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>
Message-ID: <1273019809-16472-5-git-send-email-ebiederm@xmission.com>


From: Eric W. Biederman <ebiederm@xmission.com>

It only makes sense for uevent_helper to get events
in the intial namespaces.  It's invocation is not
per namespace and it is not clear how we could make
it's invocation namespace aware.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 lib/kobject_uevent.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -19,7 +19,7 @@
 #include <linux/kobject.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-
+#include <linux/user_namespace.h>
 #include <linux/socket.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
@@ -99,6 +99,21 @@ static int kobj_bcast_filter(struct sock
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
@@ -274,7 +289,7 @@ int kobject_uevent_env(struct kobject *k
 #endif
 
 	/* call uevent_helper, usually only enabled during early boot */
-	if (uevent_helper[0]) {
+	if (uevent_helper[0] && !kobj_usermode_filter(kobj)) {
 		char *argv [3];
 
 		argv [0] = uevent_helper;

