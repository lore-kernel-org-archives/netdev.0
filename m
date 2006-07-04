From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping actions
Date: Wed, 05 Jul 2006 00:00:03 +0200
Message-ID: <20060704220550.406275000@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch>
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:58309 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932313AbWGDWGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:06:55 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=act_fix_dump_err_handling
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"return -err" and blindly inheriting the error code in the netlink
failure exception handler causes errors codes to be returned as
positive value therefore making them being ignored by the caller.

May lead to sending out incomplete netlink messages.

Signed-off-by: Thomas Graf <tgraf@suug.ch>


Index: net-2.6.git/net/sched/act_api.c
===================================================================
--- net-2.6.git.orig/net/sched/act_api.c
+++ net-2.6.git/net/sched/act_api.c
@@ -250,15 +250,17 @@ tcf_action_dump(struct sk_buff *skb, str
 		RTA_PUT(skb, a->order, 0, NULL);
 		err = tcf_action_dump_1(skb, a, bind, ref);
 		if (err < 0)
-			goto rtattr_failure;
+			goto errout;
 		r->rta_len = skb->tail - (u8*)r;
 	}
 
 	return 0;
 
 rtattr_failure:
+	err = -EINVAL;
+errout:
 	skb_trim(skb, b - skb->data);
-	return -err;
+	return err;
 }
 
 struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,

--

