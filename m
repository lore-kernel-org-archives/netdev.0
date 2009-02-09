From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Tue, 10 Feb 2009 00:58:47 +0100
Message-ID: <4990C337.3040704@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070907010702050102060903"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4990BADA.7040309@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070907010702050102060903
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> We have at least one case where the caller wants to know of
>>> any successful delivery. Keymanager queries done by xfrm_state
>>> want to know whether an acquire was delivered to any keymanager.
>>> So we need to continue to indicate this, maybe using a different
>>> errno code than -ENOBUFS. I don't have a suggestion which one to
>>> use though.
>>
>> Indeed, I have missed that spot. I'm not very familiar with that code,
>> however, I see that the creation of a state depends on the netlink
>> broadcast return value, but how useful is that? I think that the state
>> should be created even if the broadcast fails, the userspace daemon
>> should request a resync to the kernel as soon as it hits ENOBUFS, then
>> it would be in sync again with that state.
> 
> The idea is that the kernel is performing an active query. I agree
> that there's nothing wrong with installing the SA and indicating the
> error to userspace. Userspace could dump the SADB and look for new
> larval states, however thats unlikely to be very useful since once
> an overflow occurs, you probably have a lot of states.

More situations may trigger overflows: a "slow" reader (for example,
spending time on whatever while not retrieving messages) and a userspace
process with too small receive buffer.

> But unless I'm missing something, there's nothing wrong with this
> as long as the error is ignored. The fact that something was received
> by some listener doesn't have any meaning anyways, it might have
> been "ip monitor". Which somehow raises doubt about your proposed
> interface change though, I think anything that wants a reliable
> answer whether a packet was delivered to a process handling it
> appropriately should use unicast.

Don't get me wrong, I agree with you that all netlink_broadcast callers
in the kernel should ignore the return value...

... unless they have "some way" (like in Netfilter) to make event
delivery reliable: I have attached a patch that I didn't send you yet,
I'm still reviewing and testing it. It adds an entry to /proc to enable
reliable event delivery over netlink by dropping packets whose events
were not delivered, you mentioned that possibility once during one of
our conversations ;).

I'm aware of that this option may be dangerous if used by a buggy
process that trigger frequent overflows but it the cost of having
realible logging for ctnetlink (still, this behaviour is not the one by
default!).

And I need this option to make conntrackd synchronize state-changes
appropriately under very heavy load: I've testing the daemon with these
patches and it reliably synchronizes state-changes (my system were 100%
busy filtering traffic and fully synchronizing all TCP state-changes in
near real-time effort, with a noticeable performance drop of 30% in
terms of filtered connections).

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers

--------------070907010702050102060903
Content-Type: text/x-diff;
 name="ctnetlink-drop-under-stress.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ctnetlink-drop-under-stress.patch"

ctnetlink: optional packet drop to make event delivery reliable

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds /proc entry to enable reliable ctnetlink event
delivery. The entry is located at:

/proc/sys/net/netfilter/nf_conntrack_netlink_broadcast_reliable

When this entry is != 0, ctnetlink drops the packet if the delivery of
an event over netlink fails. This patch is useful to provide reliable
state synchronization for conntrackd.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 include/linux/netfilter/nfnetlink.h         |    4 +
 include/net/netfilter/nf_conntrack_core.h   |    6 +-
 include/net/netfilter/nf_conntrack_ecache.h |    2 -
 include/net/netns/conntrack.h               |    2 +
 net/netfilter/nf_conntrack_ecache.c         |   18 +++--
 net/netfilter/nf_conntrack_netlink.c        |  108 ++++++++++++++++++++++++++-
 net/netfilter/nfnetlink.c                   |   24 +++++-
 7 files changed, 146 insertions(+), 18 deletions(-)


diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 7d8e045..b89d5f3 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -74,8 +74,8 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(unsigned int group);
-extern int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, 
-			  int echo);
+extern int nfnetlink_notify(struct sk_buff *skb, u32 pid, unsigned group,
+			    int echo);
 extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags);
 
 extern void nfnl_lock(void);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index e78afe7..0c6826d 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -62,7 +62,11 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	if (ct) {
 		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
 			ret = __nf_conntrack_confirm(skb);
-		nf_ct_deliver_cached_events(ct);
+		if (ret == NF_ACCEPT && nf_ct_deliver_cached_events(ct) < 0) {
+			struct net *net = nf_ct_net(ct);
+			NF_CT_STAT_INC_ATOMIC(net, drop);
+			return NF_DROP;
+		}
 	}
 	return ret;
 }
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 0ff0dc6..6e9e1f7 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -28,7 +28,7 @@ extern struct atomic_notifier_head nf_conntrack_chain;
 extern int nf_conntrack_register_notifier(struct notifier_block *nb);
 extern int nf_conntrack_unregister_notifier(struct notifier_block *nb);
 
-extern void nf_ct_deliver_cached_events(const struct nf_conn *ct);
+extern int nf_ct_deliver_cached_events(const struct nf_conn *ct);
 extern void __nf_ct_event_cache_init(struct nf_conn *ct);
 extern void nf_ct_event_cache_flush(struct net *net);
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index f4498a6..1ff61dd 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -20,9 +20,11 @@ struct netns_ct {
 	int			sysctl_acct;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	int			sysctl_ctnetlink_event_reliable;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
+	struct ctl_table_header *ctnetlink_sysctl_header;
 #endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index dee4190..9c21269 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -31,9 +31,11 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_chain);
 
 /* deliver cached events and clear cache entry - must be called with locally
  * disabled softirqs */
-static inline void
+static inline int
 __nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
 {
+	int ret = 0;
+
 	if (nf_ct_is_confirmed(ecache->ct) && !nf_ct_is_dying(ecache->ct)
 	    && ecache->events) {
 		struct nf_ct_event item = {
@@ -42,28 +44,32 @@ __nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
 			.report	= 0
 		};
 
-		atomic_notifier_call_chain(&nf_conntrack_chain,
-					   ecache->events,
-					   &item);
+		ret = atomic_notifier_call_chain(&nf_conntrack_chain,
+						 ecache->events,
+						 &item);
+		ret = notifier_to_errno(ret);
 	}
 
 	ecache->events = 0;
 	nf_ct_put(ecache->ct);
 	ecache->ct = NULL;
+	return ret;
 }
 
 /* Deliver all cached events for a particular conntrack. This is called
  * by code prior to async packet handling for freeing the skb */
-void nf_ct_deliver_cached_events(const struct nf_conn *ct)
+int nf_ct_deliver_cached_events(const struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
+	int ret = 0;
 
 	local_bh_disable();
 	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	if (ecache->ct == ct)
-		__nf_ct_deliver_cached_events(ecache);
+		ret = __nf_ct_deliver_cached_events(ecache);
 	local_bh_enable();
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 47c2f54..3e0ffb6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -517,6 +517,8 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	unsigned int type;
 	sk_buff_data_t b;
 	unsigned int flags = 0, group;
+	struct net *net = nf_ct_net(ct);
+	int err;
 
 	/* ignore our fake conntrack entry */
 	if (ct == &nf_conntrack_untracked)
@@ -613,13 +615,20 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
-	nfnetlink_send(skb, item->pid, group, item->report);
+	err = nfnetlink_notify(skb, item->pid, group, item->report);
+	if (net->ct.sysctl_ctnetlink_event_reliable &&
+	    (err == -ENOBUFS || err == -EAGAIN))
+		return notifier_from_errno(err);
+
 	return NOTIFY_DONE;
 
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
 	kfree_skb(skb);
+	if (net->ct.sysctl_ctnetlink_event_reliable)
+		return notifier_from_errno(-ENOSPC);
+
 	return NOTIFY_DONE;
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
@@ -1604,7 +1613,8 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	struct sk_buff *skb;
 	unsigned int type;
 	sk_buff_data_t b;
-	int flags = 0;
+	int flags = 0, err;
+	struct net *net = nf_ct_exp_net(exp);
 
 	if (events & IPEXP_NEW) {
 		type = IPCTNL_MSG_EXP_NEW;
@@ -1637,13 +1647,21 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
-	nfnetlink_send(skb, item->pid, NFNLGRP_CONNTRACK_EXP_NEW, item->report);
+	err = nfnetlink_notify(skb, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
+			       item->report);
+	if (net->ct.sysctl_ctnetlink_event_reliable &&
+	    (err == -ENOBUFS || err == -EAGAIN))
+		return notifier_from_errno(err);
+
 	return NOTIFY_DONE;
 
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
 	kfree_skb(skb);
+	if (net->ct.sysctl_ctnetlink_event_reliable)
+		return notifier_from_errno(-ENOSPC);
+
 	return NOTIFY_DONE;
 }
 #endif
@@ -2003,7 +2021,63 @@ MODULE_ALIAS("ip_conntrack_netlink");
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_CTNETLINK);
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_CTNETLINK_EXP);
 
-static int __init ctnetlink_init(void)
+#ifdef CONFIG_SYSCTL
+static struct ctl_table ctnetlink_sysctl_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_netlink_broadcast_reliable",
+		.data		= &init_net.ct.sysctl_ctnetlink_event_reliable,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{}
+};
+
+static int ctnetlink_init_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = kmemdup(ctnetlink_sysctl_table, sizeof(ctnetlink_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	table[0].data = &net->ct.sysctl_ctnetlink_event_reliable;
+
+	net->ct.ctnetlink_sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, table);
+	if (!net->ct.ctnetlink_sysctl_header)
+		goto out_register;
+
+	return 0;
+
+out_register:
+	kfree(table);
+out:
+	return -ENOMEM;
+}
+
+static void ctnetlink_fini_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ct.ctnetlink_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.ctnetlink_sysctl_header);
+	kfree(table);
+}
+#else
+static int ctnetlink_init_sysctl(struct net *net)
+{
+	return 0;
+}
+
+static void ctnetlink_fini_sysctl(struct net *net)
+{
+}
+#endif /* CONFIG_SYSCTL */
+
+static int ctnetlink_net_init(struct net *net)
 {
 	int ret;
 
@@ -2033,10 +2107,18 @@ static int __init ctnetlink_init(void)
 		goto err_unreg_notifier;
 	}
 #endif
+	ret = ctnetlink_init_sysctl(net);
+	if (ret < 0) {
+		printk("ctnetlink_init: cannot register sysctl.\n");
+		goto err_unreg_exp_notifier;
+	}
+	net->ct.sysctl_ctnetlink_event_reliable = 0;
 
 	return 0;
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
+err_unreg_exp_notifier:
+	nf_ct_expect_unregister_notifier(&ctnl_notifier_exp);
 err_unreg_notifier:
 	nf_conntrack_unregister_notifier(&ctnl_notifier);
 err_unreg_exp_subsys:
@@ -2048,7 +2130,7 @@ err_out:
 	return ret;
 }
 
-static void __exit ctnetlink_exit(void)
+static void ctnetlink_net_exit(struct net *net)
 {
 	printk("ctnetlink: unregistering from nfnetlink.\n");
 
@@ -2059,8 +2141,24 @@ static void __exit ctnetlink_exit(void)
 
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
+	ctnetlink_fini_sysctl(net);
 	return;
 }
 
+static struct pernet_operations ctnetlink_net_ops = {
+	.init = ctnetlink_net_init,
+	.exit = ctnetlink_net_exit,
+};
+
+static int __init ctnetlink_init(void)
+{
+	return register_pernet_subsys(&ctnetlink_net_ops);
+}
+
+static void __exit ctnetlink_exit(void)
+{
+	unregister_pernet_subsys(&ctnetlink_net_ops);
+}
+
 module_init(ctnetlink_init);
 module_exit(ctnetlink_exit);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 9c0ba17..fd7bbf4 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -107,11 +107,29 @@ int nfnetlink_has_listeners(unsigned int group)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
-int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
+/* like nlmsg_notify, but we return the multicast error */
+int nfnetlink_notify(struct sk_buff *skb, u32 pid, unsigned group, int report)
 {
-	return nlmsg_notify(nfnl, skb, pid, group, echo, gfp_any());
+	int err = 0, mcast_err = 0;
+
+	if (group) {
+		int exclude_pid = 0;
+
+		if (report) {
+			atomic_inc(&skb->users);
+			exclude_pid = pid;
+		}
+
+		mcast_err = nlmsg_multicast(nfnl, skb, exclude_pid,
+					    group, gfp_any());
+	}
+
+	if (report)
+		err = nlmsg_unicast(nfnl, skb, pid);
+
+	return mcast_err ? mcast_err : err;
 }
-EXPORT_SYMBOL_GPL(nfnetlink_send);
+EXPORT_SYMBOL_GPL(nfnetlink_notify);
 
 int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags)
 {

--------------070907010702050102060903--
