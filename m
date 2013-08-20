From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Linux 3.0.92
Date: Tue, 20 Aug 2013 21:36:26 +0200
Message-ID: <1377027386.13829.29.camel@jlt4.sipsolutions.net>
References: <20130820155735.GA2805@kroah.com>
	 <CA+55aFxrPP8=xPWuRVy0HPyiFkT8Mc03zWGKosg+WrEQfqNDfQ@mail.gmail.com>
	 <20130820164343.GA3958@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>,
	Borislav Petkov <bp@alien8.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	stable <stable@vger.kernel.org>, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>,
	Ding Tianhong <dingtianhong@huawei.com>,
	netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, sergey.senozhatsky@gmail.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130820164343.GA3958@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[too many email threads, so + a few folks]

> > This one turns out to be buggy, see thread called "3.11-rc6 genetlink
> > locking fix offends lockdep".
> 
> Yeah, I messed up in keeping it here, I'll go revert it and push out a
> new 3.0 release.

Sorry everyone, I thought I tested that code but clearly I didn't test
it well enough. I can easily reproduce the issues now so not sure why I
didn't see it before.

> I thought that there was a fix already for this...  Ah, no, that was for
> another reported regression in an older 3.10-stable release, my bad.
> 
> Johannes, what do you want to do here?  Just revert it in Linus's tree
> for now, given the late -rc cycle?

I think that'd be the best course of action for now. I just tried a few
other approaches but I can't come up with a dead-lock free way to
actually add locking here, short of providing some way for dump to
actually always have locking from "outside" (netlink code).

I think the better way would be to convert it to just use RCU. This
isn't very efficient, but then again we don't unregister generic netlink
families all the time. Below patch works without lockdep complaining,
but that's obvious since it can't check RCU ... I'm not sure I want to
do this so close to a release?

johannes

>From 5b4790a1188c40422e99b4fc8840e4860d57f0d0 Mon Sep 17 00:00:00 2001
From: Johannes Berg <johannes.berg@intel.com>
Date: Tue, 20 Aug 2013 21:31:48 +0200
Subject: [PATCH] genetlink: convert family dump code to use RCU

In my previous commit 58ad436fcf49810aa006016107f494c9ac9013db
("genetlink: fix family dump race") I attempted to solve an
issue in generic netlink that could lead to crashes, but it
turns out that this introduced a possibility for deadlock. As
I haven't found a way to actually add locking without causing
that, convert the family, family ops/mcast group lists all to
use RCU, so the family dump code can simply use RCU protection
instead of locking.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..ceeaee4 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -246,7 +246,7 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 	netlink_table_ungrab();
 
 	clear_bit(grp->id, mc_groups);
-	list_del(&grp->list);
+	list_del_rcu(&grp->list);
 	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
 	grp->id = 0;
 	grp->family = NULL;
@@ -272,6 +272,7 @@ void genl_unregister_mc_group(struct genl_family *family,
 	genl_lock_all();
 	__genl_unregister_mc_group(family, grp);
 	genl_unlock_all();
+	synchronize_rcu();
 }
 EXPORT_SYMBOL(genl_unregister_mc_group);
 
@@ -281,6 +282,7 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 
 	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
 		__genl_unregister_mc_group(family, grp);
+	synchronize_rcu();
 }
 
 /**
@@ -351,9 +353,10 @@ int genl_unregister_ops(struct genl_family *family, struct genl_ops *ops)
 	genl_lock_all();
 	list_for_each_entry(rc, &family->ops_list, ops_list) {
 		if (rc == ops) {
-			list_del(&ops->ops_list);
+			list_del_rcu(&ops->ops_list);
 			genl_unlock_all();
 			genl_ctrl_event(CTRL_CMD_DELOPS, ops);
+			synchronize_rcu();
 			return 0;
 		}
 	}
@@ -418,7 +421,7 @@ int genl_register_family(struct genl_family *family)
 	} else
 		family->attrbuf = NULL;
 
-	list_add_tail(&family->family_list, genl_family_chain(family->id));
+	list_add_tail_rcu(&family->family_list, genl_family_chain(family->id));
 	genl_unlock_all();
 
 	genl_ctrl_event(CTRL_CMD_NEWFAMILY, family);
@@ -498,7 +501,8 @@ int genl_unregister_family(struct genl_family *family)
 		if (family->id != rc->id || strcmp(rc->name, family->name))
 			continue;
 
-		list_del(&rc->family_list);
+		list_del_rcu(&rc->family_list);
+		synchronize_rcu();
 		INIT_LIST_HEAD(&family->ops_list);
 		genl_unlock_all();
 
@@ -692,7 +696,7 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 		if (nla_ops == NULL)
 			goto nla_put_failure;
 
-		list_for_each_entry(ops, &family->ops_list, ops_list) {
+		list_for_each_entry_rcu(ops, &family->ops_list, ops_list) {
 			struct nlattr *nest;
 
 			nest = nla_nest_start(skb, idx++);
@@ -718,7 +722,7 @@ static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 		if (nla_grps == NULL)
 			goto nla_put_failure;
 
-		list_for_each_entry(grp, &family->mcast_groups, list) {
+		list_for_each_entry_rcu(grp, &family->mcast_groups, list) {
 			struct nlattr *nest;
 
 			nest = nla_nest_start(skb, idx++);
@@ -789,14 +793,11 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
-	bool need_locking = chains_to_skip || fams_to_skip;
-
-	if (need_locking)
-		genl_lock();
 
+	rcu_read_lock();
 	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
-		list_for_each_entry(rt, genl_family_chain(i), family_list) {
+		list_for_each_entry_rcu(rt, genl_family_chain(i), family_list) {
 			if (!rt->netnsok && !net_eq(net, &init_net))
 				continue;
 			if (++n < fams_to_skip)
@@ -811,12 +812,11 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 errout:
+	rcu_read_unlock();
+
 	cb->args[0] = i;
 	cb->args[1] = n;
 
-	if (need_locking)
-		genl_unlock();
-
 	return skb->len;
 }
 
-- 
1.8.4.rc2
