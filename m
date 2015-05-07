From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Thu, 07 May 2015 11:14:13 -0500
Message-ID: <87wq0kcqlm.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <cwang@twopensource.com>,
	<herbert@gondor.apana.org.au>, <xemul@openvz.org>,
	<davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51133 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbbEGQSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:18:47 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com> (Ying
	Xue's message of "Thu, 7 May 2015 16:52:39 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ying Xue <ying.xue@windriver.com> writes:

> When commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
> netlink_kernel_create().") attempted to fix the race between put_net()
> and kernel socket's creation, it adopted a complex solution: create
> netlink socket inside init_net namespace and then re-attach it to the
> desired one right after the socket is created; similarly, when close
> the socket, move back its namespace to init_net so that the socket can
> be destroyed in the context which is same as the socket creation.
>
> But the solution artificially makes the whole thing complex as its
> design is not only weird, but also it causes a bad consequence that
> when all kernel modules create kernel sockets, they have to follow
> the model of namespace switch. More importantly, with the way kernel
> sockets are created in init_net namespace, but they are released in
> another new ones. This inconsistent namespace brings some modules many
> inconvenience. For example, what tipc socket is inserted to rhashtable
> happens in socket's creation, and different namespace has different
> rhashtable for tipc socket. With the approach, a tipc kernel socket
> will be inserted into the rhashtable of init_net. But as releasing
> the socket happens in another one, it causes what the socket cannot
> be found from the rhashtable of the new namespace.
>
> Therefore, we propose a simpler solution to avoid the race: if we
> find there is still pending a cleanup work in __put_net(), we don't
> queue a new cleanup work to stop the cleanup process. The new proposal
> not only successfully solves the race, but also it can help us to
> avoid unnecessary namespace switches when creating kernel sockets.
> Moreover, it can guarantee that both creation and release of kernel
> sockets happen in the same namespace at all time.
>
> In the series, we first resolve the race with patch #1, and then
> prevent namespace switches from happening in all relevant kernel
> modules one by one from patch #2 to patch #9. Until now, as all
> dependencies on sk_change_net() are killed, we can delete the
> interface completely in patch #10. Lastly, we simplify the code of
> creating kernel sockets through changing the original behaviours
> of sock_create_kern() and sk_release_kernel(). If a kernel socket
> is created within a namespace which is different with init_net,
> we must put the reference counter of the namespace once the socket
> is successfully allocated in sk_alloc(), otherwise, the namespace
> is probably unable to be shut down finally. Therefore, we decrease
> namespace's reference counter once a kernel socket is created
> successfully by sock_create_kern() within a namespace which is
> different with init_net. Similarly, namespace's reference counter
> must be increased back before the socket is destroyed in
> sk_release_kernel().
>
> Welcome to any comments.

I agree that commit 23fe18669e7f ("[NETNS]: Fix race between put_net()
and netlink_kernel_create()."  was a hack.

However it is not appropriate to call get_net on a network namespace
whose count might be zero.  I believe all of your patches rely on that
currently.  Instead we need to build something like sk_release_kernel
that does not increase the network namespace reference count if you are
going to avoid changing the network namespace on a socket (a worthy
goal).

The following change shows how it is possible to always know that your
network namespace has a non-zero reference count in the network
namespace initialization methods.  My implementation of
lock_network_namespaces is problematic in that it does not sleep
while network namespaces are unregistering.  But it is enough to show
how the locking and reference counting can be fixed.

Eric


diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index a3abb719221f..81c53ccc5764 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -822,6 +822,49 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
 		ida_remove(&net_generic_ids, *ops->id);
 }
 
+static void unlock_network_namespaces(void)
+{
+	/* Drop the reference count to every network namespace
+	 * and then release the net_mutex.
+	 */
+	struct net *net;
+
+	for_each_net(net)
+		put_net(net);
+
+	mutex_unlock(&net_mutex);
+}
+
+static void lock_network_namespaces(void)
+{
+	/* Take the mutex lock ensuring no new network namespaces
+	 * and take a reference on all existing network namespaces
+	 * allowing network namespace initialization code to take
+	 * further references
+	 */
+	for (;;) {
+		struct net *net, *stop;
+
+		mutex_lock(&net_mutex);
+		for_each_net(net) {
+			if (!maybe_get_net(net))
+				goto undo;
+		}
+		return;
+undo:
+		/* Remember the network namespace whose reference
+		 * count was not acquired. */
+		stop = net;
+		for_each_net(net) {
+			if (net_eq(net, stop))
+				goto undone;
+			put_net(net);
+		}
+undone:
+		mutex_unlock(&net_mutex);
+	}
+}
+
 /**
  *      register_pernet_subsys - register a network namespace subsystem
  *	@ops:  pernet operations structure for the subsystem
@@ -844,9 +887,9 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
 int register_pernet_subsys(struct pernet_operations *ops)
 {
 	int error;
-	mutex_lock(&net_mutex);
+	lock_network_namespaces();
 	error =  register_pernet_operations(first_device, ops);
-	mutex_unlock(&net_mutex);
+	unlock_network_namespaces();
 	return error;
 }
 EXPORT_SYMBOL_GPL(register_pernet_subsys);
@@ -890,11 +933,11 @@ EXPORT_SYMBOL_GPL(unregister_pernet_subsys);
 int register_pernet_device(struct pernet_operations *ops)
 {
 	int error;
-	mutex_lock(&net_mutex);
+	lock_network_namespaces();
 	error = register_pernet_operations(&pernet_list, ops);
 	if (!error && (first_device == &pernet_list))
 		first_device = &ops->list;
-	mutex_unlock(&net_mutex);
+	unlock_network_namespaces();
 	return error;
 }
 EXPORT_SYMBOL_GPL(register_pernet_device);
