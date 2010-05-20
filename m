From: <gregkh@suse.de>
Subject: patch kobj-send-hotplug-events-in-the-proper-namespace.patch added to gregkh-2.6 tree
Date: Thu, 20 May 2010 11:10:37 -0700
Message-ID: <1274379037308@kroah.org>
References: <1273019809-16472-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: ebiederm@xmission.com, bcrl@lhnet.ca, cornelia.huck@de.ibm.com,
	davem@davemloft.net, eric.dumazet@gmail.com, gregkh@suse.de,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.ibm.
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:43220 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756997Ab0ETSKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 14:10:52 -0400
In-Reply-To: <1273019809-16472-4-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: kobj: Send hotplug events in the proper namespace.

to my gregkh-2.6 tree.  Its filename is

    kobj-send-hotplug-events-in-the-proper-namespace.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com  Thu May 20 10:44:38 2010
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue,  4 May 2010 17:36:47 -0700
Subject: kobj: Send hotplug events in the proper namespace.
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, Benjamin LaHaise <bcrl@lhnet.ca>, Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>
Message-ID: <1273019809-16472-4-git-send-email-ebiederm@xmission.com>


From: Eric W. Biederman <ebiederm@xmission.com>

Utilize netlink_broacast_filtered to allow sending hotplug events
in the proper namespace.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 lib/kobject_uevent.c |   22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -83,6 +83,22 @@ out:
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
@@ -244,8 +260,10 @@ int kobject_uevent_env(struct kobject *k
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

