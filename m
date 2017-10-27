From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net/sched: fix NULL pointer dereference in qdisc_alloc()
Date: Fri, 27 Oct 2017 16:19:55 -0700
Message-ID: <CAM_iQpVsQ1X4PzNAXjUn-e8gHJo4+R0enZo0PzBVZ7TD1Hzsvw@mail.gmail.com>
References: <acc2f5949d2ab4562be3c28a6131fecefbaf8db1.1509040243.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:44392 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751482AbdJ0XUQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 19:20:16 -0400
Received: by mail-pf0-f193.google.com with SMTP id x7so5957260pfa.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 16:20:16 -0700 (PDT)
In-Reply-To: <acc2f5949d2ab4562be3c28a6131fecefbaf8db1.1509040243.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 11:26 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> the following script generates a NULL pointer dereference error:
>
> ip l a name eth0 type dummy
> tc q a dev eth0 parent :1 handle 1: htb
>
> upon creation of classful qdiscs, qdisc_alloc() dereferences dev_queue->dev
> assuming it is not NULL. This is not true when eth0 has been added, but not
> yet set administratively up; a bisect test proved that Linux started making
> NULL exception with the above two commands after commit 59cc1f61f09c ("net:
> sched:convert qdisc linked list to hashtable"). Let qdisc_alloc() return -1
> (-ENOENT) when a NULL value of dev_queue->dev is seen, so that non-crashing
> behaviour observable in Linux 4.8 is restored.

This analysis is wrong, you just hit noop_qdisc in this case.

Parent :1 doesn't exist in this case, so the second command
should be rejected since parent can't be found.

The the following patch works and better than your patch, but
still I think it should fail even earlier in this path, so there is probably
a even better fix.

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c6deb74e3d2f..6a3033c528a8 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1413,7 +1413,7 @@ static int tc_modify_qdisc(struct sk_buff *skb,
struct nlmsghdr *n,

                if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
                        dev_queue = p->ops->cl_ops->select_queue(p, tcm);
-               else if (p)
+               else if (p && p != &noop_qdisc)
                        dev_queue = p->dev_queue;
                else
                        dev_queue = netdev_get_tx_queue(dev, 0);
