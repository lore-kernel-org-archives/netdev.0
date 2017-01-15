From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net  1/1] net sched actions: fix refcnt when GETing of action after bind
Date: Sun, 15 Jan 2017 10:14:06 -0500
Message-ID: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35517 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751084AbdAOPOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 10:14:15 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so9869195ith.2
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 07:14:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Demonstrating the issue:

.. add a drop action
$sudo $TC actions add action drop index 10

.. retrieve it
$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 2 bind 0 installed 29 sec used 29 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

... bug 1 above: reference is two.
    Reference is actually 1 but we forget to subtract 1.

... do a GET again and we see the same issue
    try a few times and nothing changes
~$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 2 bind 0 installed 31 sec used 31 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

... lets try to bind the action to a filter..
$ sudo $TC qdisc add dev lo ingress
$ sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
  u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 10

... and now a few GETs:
$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 3 bind 1 installed 204 sec used 204 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 4 bind 1 installed 206 sec used 206 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 5 bind 1 installed 235 sec used 235 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

.... as can be observed the reference count keeps going up.

After the fix

$ sudo $TC actions add action drop index 10
$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 1 bind 0 installed 4 sec used 4 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 1 bind 0 installed 6 sec used 6 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

$ sudo $TC qdisc add dev lo ingress
$ sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
  u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 10

$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 2 bind 1 installed 32 sec used 32 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

$ sudo $TC -s actions get action gact index 10

	action order 1: gact action drop
	 random type none pass val 0
	 index 10 ref 2 bind 1 installed 33 sec used 33 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

Fixes: aecc5cefc389 ("net sched actions: fix GETing actions")

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2095c83..e10456ef6f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -900,8 +900,6 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 			goto err;
 		}
 		act->order = i;
-		if (event == RTM_GETACTION)
-			act->tcfa_refcnt++;
 		list_add_tail(&act->list, &actions);
 	}
 
@@ -914,7 +912,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 		return ret;
 	}
 err:
-	tcf_action_destroy(&actions, 0);
+	if (event != RTM_GETACTION)
+		tcf_action_destroy(&actions, 0);
 	return ret;
 }
 
-- 
1.9.1
