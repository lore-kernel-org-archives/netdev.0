From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Sat, 22 Apr 2017 07:30:46 -0400
Message-ID: <1bc569c7-3248-48d6-e3ab-10e27c3c66b1@mojatatu.com>
References: <20170421.113800.1367091481085913667.davem@davemloft.net>
 <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
 <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
 <20170421.121217.1268145592512455181.davem@davemloft.net>
 <c6333422-ae6d-149c-09ec-c5dfb43d68b3@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------4094BD37AEE815EAC87C7D45"
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33799 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1043859AbdDVLbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 07:31:04 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so37054413ioi.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 04:31:03 -0700 (PDT)
In-Reply-To: <c6333422-ae6d-149c-09ec-c5dfb43d68b3@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------4094BD37AEE815EAC87C7D45
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 17-04-21 02:11 PM, Jamal Hadi Salim wrote:

> Please bear with me. I want to make sure to get this right.
>
> Lets say I updated the kernel today to reject transactions with
> bits it didnt understand. Lets call this "old kernel". A tc that
> understands/sets these bits and nothing else. Call it "old tc".
> 3 months later:
> I add one more bit setting to introduce a new feature in a new
> kernel version. Lets call this new "kernel". I update to
> understand new bits. Call it "new tc".
>
> The possibilities:
> a) old tc + old kernel combo. No problem
> b) new tc + new kernel combo. No problem.
> c) old tc + new kernel combo. No problem.
> d) new tc + old kernel. Rejection.
>
> For #d if i have a smart tc it would retry with a new combination
> which restores its behavior to old tc level. Of course this means
> apps would have to be rewritten going forward to understand these
> mechanics.
> Alternative is to request for capabilities first then doing a
> lowest common denominator request.
> But even that is a lot more code and crossing user/kernel twice.
>
> There is a simpler approach that would work going forward.
> How about letting the user choose their fate? Set something maybe
> in the netlink header to tell the kernel "if you dont understand
> something I am asking for - please ignore it and do what you can".
> This would maintain current behavior but would force the user to
> explicitly state so.
>


Tested patch that demonstrates this idea is attached.

cheers,
jamal


--------------4094BD37AEE815EAC87C7D45
Content-Type: text/plain; charset=UTF-8;
 name="patch-act-check-flags"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-act-check-flags"

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index cce0613..48d3acb 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -674,10 +674,28 @@ struct tcamsg {
 	unsigned char	tca__pad1;
 	unsigned short	tca__pad2;
 };
+
+enum {
+	TCA_ROOT_UNSPEC,
+	TCA_ROOT_TAB,
+#define TCA_ACT_TAB TCA_ROOT_TAB
+	TCA_ROOT_FLAGS,
+	TCA_ROOT_COUNT,
+	__TCA_ROOT_MAX,
+#define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
+};
+
 #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
 #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
-#define TCAA_MAX 1
+/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
+ *
+ * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
+ * actions in a dump. All dump responses will contain the number of actions
+ * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
+ *
+ */
+#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
+#define TCA_FLAG_LIBERAL_CHECK_ON	(1 << 1)
 
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 9ce22b7..fbe96ae 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -83,6 +83,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
+	u32 act_flags = cb->args[2];
 	struct nlattr *nest;
 
 	spin_lock_bh(&hinfo->lock);
@@ -111,14 +112,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			}
 			nla_nest_end(skb, nest);
 			n_i++;
-			if (n_i >= TCA_ACT_MAX_PRIO)
+			if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
+			    n_i >= TCA_ACT_MAX_PRIO)
 				goto done;
 		}
 	}
 done:
 	spin_unlock_bh(&hinfo->lock);
-	if (n_i)
+	if (n_i) {
 		cb->args[0] += n_i;
+		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
+			cb->args[1] = n_i;
+	}
 	return n_i;
 
 nla_put_failure:
@@ -993,11 +998,15 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 	return tcf_add_notify(net, n, &actions, portid);
 }
 
+static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
+	[TCA_ROOT_FLAGS]      = { .type = NLA_U32 },
+};
+
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCAA_MAX + 1];
+	struct nlattr *tca[TCA_ROOT_MAX + 1];
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
@@ -1005,7 +1014,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ROOT_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;
@@ -1046,16 +1055,12 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	return ret;
 }
 
-static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
+static struct nlattr *find_dump_kind(struct nlattr **nla)
 {
 	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
-	struct nlattr *nla[TCAA_MAX + 1];
 	struct nlattr *kind;
 
-	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX,
-			NULL, NULL) < 0)
-		return NULL;
 	tb1 = nla[TCA_ACT_TAB];
 	if (tb1 == NULL)
 		return NULL;
@@ -1073,6 +1078,24 @@ static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
 	return kind;
 }
 
+#define valid_tca_flags (TCA_FLAG_LARGE_DUMP_ON | TCA_FLAG_LIBERAL_CHECK_ON)
+/* If user has set TCA_FLAG_LIBERAL_CHECK_ON we let the kernel continue
+ * its checking for valid bits only, otherwise we check for any unknown
+ * bits set and reject them
+ */
+static inline bool tca_flags_valid(u32 act_flags)
+{
+	u32 invalid_flags_mask  = ~valid_tca_flags;
+	printk("act flags 0x%x\n", act_flags);
+	if (act_flags & TCA_FLAG_LIBERAL_CHECK_ON)
+		return true;
+
+	if (act_flags & invalid_flags_mask)
+		return false;
+
+	return true;
+}
+
 static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1082,8 +1105,18 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tc_action_ops *a_o;
 	int ret = 0;
 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
-	struct nlattr *kind = find_dump_kind(cb->nlh);
+	struct nlattr *count_attr = NULL;
+	struct nlattr *tb[TCA_ROOT_MAX + 1];
+	struct nlattr *kind = NULL;
+	u32 act_flags = 0;
+	u32 act_count = 0;
+
+	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tb, TCA_ROOT_MAX,
+			  tcaa_policy, NULL);
+	if (ret < 0)
+		return ret;
 
+	kind = find_dump_kind(tb);
 	if (kind == NULL) {
 		pr_info("tc_dump_action: action bad kind\n");
 		return 0;
@@ -1093,14 +1126,28 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (a_o == NULL)
 		return 0;
 
+	if (tb[TCA_ROOT_FLAGS])
+		act_flags = nla_get_u32(tb[TCA_ROOT_FLAGS]);
+
+	if (act_flags && !tca_flags_valid(act_flags)) {
+		printk("invalid flags 0x%x. Ask for liberal behavior\n",
+		       act_flags);
+		return -EINVAL;
+	}
+
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
+
+	cb->args[2] = act_flags;
 	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
+	count_attr = nla_reserve(skb, TCA_ROOT_COUNT, sizeof(u32));
+	if (!count_attr)
+		goto out_module_put;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
@@ -1113,6 +1160,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (ret > 0) {
 		nla_nest_end(skb, nest);
 		ret = skb->len;
+		act_count = cb->args[1];
+		memcpy(nla_data(count_attr), &act_count, sizeof(u32));
+		cb->args[1] = 0;
 	} else
 		nlmsg_trim(skb, b);
 

--------------4094BD37AEE815EAC87C7D45--
