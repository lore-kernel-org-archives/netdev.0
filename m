From: Shahar Klein <shahark@mellanox.com>
Subject: Soft lockup in tc_classify
Date: Mon, 12 Dec 2016 11:43:08 +0200
Message-ID: <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roi Dayan <roid@mellanox.com>, David Miller <davem@davemloft.net>,
        "Cong Wang" <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "Jiri Pirko" <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Or Gerlitz" <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20053.outbound.protection.outlook.com ([40.107.2.53]:64032
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752903AbcLMBOp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 20:14:45 -0500
In-Reply-To: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

sorry for the spam, the first time was sent with html part and was rejected.

We observed an issue where a classifier instance next member is pointing 
back to itself, causing a CPU soft lockup.
We found it by running traffic on many udp connections and then adding a 
new flower rule using tc.

We added a quick workaround to verify it:

In tc_classify:

         for (; tp; tp = rcu_dereference_bh(tp->next)) {
                 int err;
+               if (tp == tp->next)
+                     RCU_INIT_POINTER(tp->next, NULL);


We also had a print here showing tp->next is pointing to tp. With this 
workaround we are not hitting the issue anymore.
We are not sure we fully understand the mechanism here - with the rtnl 
and rcu locks.
We'll appreciate your help solving this issue.

Thanks,
Shahar
