From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [CFT][PATCH] net: Delay default_device_exit_batch until no devices are unregistering
Date: Mon, 16 Sep 2013 20:49:31 -0700
Message-ID: <87mwncaz04.fsf_-_@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43373 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab3IQFK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 01:10:57 -0400
In-Reply-To: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	(Francesco Ruggeri's message of "Mon, 16 Sep 2013 13:30:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The implementation is a little rough but the logic should be right.

Device registration and unregistration is serialized with the rtnl_lock.
The final pieces of device unregistration do not happen under the
rtnl_lock resulting in the possibility that while we wait for the
refcount of a device to drop to zero the network namespace is
unregistered while no locks are held.

Prevent that by keeping a count of the network devices that are being
unregistered and before we make the final pass through a network
namespace to flush out all of the network devices, wait for the count of
network devices being unregistered to drop to zero.

Reported-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Francesco could you take a look at this.  I am about 99% certain this is
right but I am starting to fade.  So it is entirely possible I missed
something.

 net/core/dev.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5d702fe..c25e6f3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5002,10 +5002,13 @@ static int dev_new_index(struct net *net)
 
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
+static atomic_t netdev_unregistering = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wait);
 
 static void net_set_todo(struct net_device *dev)
 {
 	list_add_tail(&dev->todo_list, &net_todo_list);
+	atomic_inc(&netdev_unregistering);
 }
 
 static void rollback_registered_many(struct list_head *head)
@@ -5673,6 +5676,9 @@ void netdev_run_todo(void)
 		if (dev->destructor)
 			dev->destructor(dev);
 
+		if (atomic_dec_and_test(&netdev_unregistering))
+			wake_up(&netdev_unregistering_wait);
+
 		/* Free network device */
 		kobject_put(&dev->dev.kobj);
 	}
@@ -6369,7 +6375,13 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 	struct net *net;
 	LIST_HEAD(dev_kill_list);
 
+retry:
+	wait_event(netdev_unregistering_wait, (atomic_read(&netdev_unregistering) == 0));
 	rtnl_lock();
+	if (atomic_read(&netdev_unregistering) != 0) {
+		__rtnl_unlock();
+		goto retry;
+	}
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
 			if (dev->rtnl_link_ops)
-- 
1.7.5.4
