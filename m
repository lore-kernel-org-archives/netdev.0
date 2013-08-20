From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Tue, 20 Aug 2013 10:28:58 +0200
Message-ID: <1376987338.13829.7.camel@jlt4.sipsolutions.net>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils>
	 <1376899214.14734.6.camel@jlt4.sipsolutions.net>
	 <5211FAB3.7080400@huawei.com>
	 <1376911362.14734.11.camel@jlt4.sipsolutions.net>
	 <alpine.LNX.2.00.1308191147350.1505@eggly.anvils>
	 (sfid-20130819_205317_938941_E76DFECF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Hugh Dickins <hughd@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1308191147350.1505@eggly.anvils> (sfid-20130819_205317_938941_E76DFECF)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-19 at 11:52 -0700, Hugh Dickins wrote:

> > > > We could use the semaphore instead, I believe, but I don't really
> > > > understand the mutex vs. semaphore well enough to be sure that's
> > > > correct.

> > I don't believe so, the semaphore and cb_mutex don't have a dependency
> > yet, afaict.
> 
> The down_read(&cb_lock) patch you suggested gives the lockdep trace below.

Clearly I was wrong then, not sure what I missed in the code though.
>From the lockdep trace it looks like the dependency comes via the
genl_lock, I didn't consider that.

David, can you please just revert it for now and tag the revert for
stable as well, in case Greg already took it somewhere? I think that
some stable trees may need a different fix anyway since they don't have
parallel_ops.

We never saw a problem due to this, and though it's probably fairly easy
to trigger by hand-rolling the dump loop in userspace, one does need to
be able to rmmod to crash the kernel with it.

The only way to fix this that I see right now (that doesn't rewrite the
locking completely) would be to make genetlink use parallel_ops itself,
thereby removing the genl_lock() in genl_rcv_msg() and breaking all
those lock chains that lockdep reported. After that, it should be safe
to use genl_lock() inside all the operations. Something like the patch
below, perhaps? Completely untested so far.

johannes


diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..dea9586 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -665,6 +665,7 @@ static struct genl_family genl_ctrl = {
 	.version = 0x2,
 	.maxattr = CTRL_ATTR_MAX,
 	.netnsok = true,
+	.parallel_ops = true,
 };
 
 static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
@@ -789,10 +790,8 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
-	bool need_locking = chains_to_skip || fams_to_skip;
 
-	if (need_locking)
-		genl_lock();
+	genl_lock();
 
 	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
@@ -814,8 +813,7 @@ errout:
 	cb->args[0] = i;
 	cb->args[1] = n;
 
-	if (need_locking)
-		genl_unlock();
+	genl_unlock();
 
 	return skb->len;
 }
@@ -870,6 +868,8 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 	struct genl_family *res = NULL;
 	int err = -EINVAL;
 
+	genl_lock();
+
 	if (info->attrs[CTRL_ATTR_FAMILY_ID]) {
 		u16 id = nla_get_u16(info->attrs[CTRL_ATTR_FAMILY_ID]);
 		res = genl_family_find_byid(id);
@@ -896,19 +896,25 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (res == NULL)
-		return err;
+		goto out_unlock;
 
 	if (!res->netnsok && !net_eq(genl_info_net(info), &init_net)) {
 		/* family doesn't exist here */
-		return -ENOENT;
+		err = -ENOENT;
+		goto out_unlock;
 	}
 
 	msg = ctrl_build_family_msg(res, info->snd_portid, info->snd_seq,
 				    CTRL_CMD_NEWFAMILY);
-	if (IS_ERR(msg))
-		return PTR_ERR(msg);
+	if (IS_ERR(msg)) {
+		err = PTR_ERR(msg);
+		goto out_unlock;
+	}
 
-	return genlmsg_reply(msg, info);
+	err = genlmsg_reply(msg, info);
+out_unlock:
+	genl_unlock();
+	return err;
 }
 
 static int genl_ctrl_event(int event, void *data)
