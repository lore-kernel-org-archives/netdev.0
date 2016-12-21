From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Wed, 21 Dec 2016 11:10:59 -0800
Message-ID: <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
 <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:32771 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754086AbcLUTLV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 14:11:21 -0500
Received: by mail-qt0-f196.google.com with SMTP id n6so27949683qtd.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 11:11:20 -0800 (PST)
In-Reply-To: <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 10:51 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Dec 21, 2016 at 9:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> What happens is that in tc_ctl_tfilter(), thread A allocates a new
>> tp, initializes it, sets tp_created to 1, and calls into tp->ops->change()
>> with it. In that classifier callback we had to unlock/lock the rtnl
>> mutex and returned with -EAGAIN. One reason why we need to drop there
>> is, for example, that we need to request an action module to be loaded.
>
> Excellent catch!
>
> But why do we have to replay the request here? Shouldn't we just return
> EAGAIN to user-space and let user-space decide to retry or not?
> Replaying is the root of the evil here.

Answer myself: probably due to historical reasons, but still replaying
inside such a big function is just error-prone, we should promote it
out:

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3fbba79..7d5b42b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -129,7 +129,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)

 /* Add/change/delete/get a filter node */

-static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
+static int __tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 {
        struct net *net = sock_net(skb->sk);
        struct nlattr *tca[TCA_MAX + 1];
@@ -154,7 +154,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb,
struct nlmsghdr *n)
            !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
                return -EPERM;

-replay:
        err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
        if (err < 0)
                return err;
@@ -378,12 +377,19 @@ static int tc_ctl_tfilter(struct sk_buff *skb,
struct nlmsghdr *n)
 errout:
        if (cl)
                cops->put(q, cl);
-       if (err == -EAGAIN)
-               /* Replay the request. */
-               goto replay;
        return err;
 }

+static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
+{
+       int ret;
+replay:
+       ret = __tc_ctl_tfilter(skb, n);
+       if (ret == -EAGAIN)
+               goto replay;
+       return ret;
+}
+
 static int tcf_fill_node(struct net *net, struct sk_buff *skb,
                         struct tcf_proto *tp, unsigned long fh, u32 portid,
                         u32 seq, u16 flags, int event)
