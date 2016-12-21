From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Wed, 21 Dec 2016 10:51:37 -0800
Message-ID: <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
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
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36567 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbcLUSv7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 13:51:59 -0500
Received: by mail-qk0-f193.google.com with SMTP id h201so9280615qke.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 10:51:58 -0800 (PST)
In-Reply-To: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 9:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> What happens is that in tc_ctl_tfilter(), thread A allocates a new
> tp, initializes it, sets tp_created to 1, and calls into tp->ops->change()
> with it. In that classifier callback we had to unlock/lock the rtnl
> mutex and returned with -EAGAIN. One reason why we need to drop there
> is, for example, that we need to request an action module to be loaded.

Excellent catch!

But why do we have to replay the request here? Shouldn't we just return
EAGAIN to user-space and let user-space decide to retry or not?
Replaying is the root of the evil here.

I mean:

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3fbba79..a21f7d66 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -154,7 +154,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb,
struct nlmsghdr *n)
            !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
                return -EPERM;

-replay:
        err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
        if (err < 0)
                return err;
@@ -278,8 +277,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb,
struct nlmsghdr *n)
                                tp_ops = tcf_proto_lookup_ops(kind);
                                /* We dropped the RTNL semaphore in order to
                                 * perform the module load.  So, even if we
-                                * succeeded in loading the module we have to
-                                * replay the request.  We indicate this using
+                                * succeeded in loading the module we return
                                 * -EAGAIN.
                                 */
                                if (tp_ops != NULL) {
@@ -378,9 +376,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb,
struct nlmsghdr *n)
 errout:
        if (cl)
                cops->put(q, cl);
-       if (err == -EAGAIN)
-               /* Replay the request. */
-               goto replay;
        return err;
 }
