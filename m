From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 3/5]: Use double-linked list for dev->qdisc_list
Date: Wed, 04 Aug 2004 21:55:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41113F36.8050204@trash.net>
References: <410FAE42.2050909@trash.net> <20040804094308.606f79bd.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030100070902050203020709"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040804094308.606f79bd.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030100070902050203020709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>On Tue, 03 Aug 2004 17:24:50 +0200
>Patrick McHardy <kaber@trash.net> wrote:
>
>  
>
>>This patch changes dev->qdisc_list to a double-linked list. This solves
>>the performance problems when destroying qdiscs with large number of inner
>>qdiscs.
>>    
>>
>
>I don't see how this bit is correct:
>  
>
You're right. This patch on top fixes the problem.


--------------030100070902050203020709
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/04 21:51:04+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix q_idx calculation in tc_dump_qdisc
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2004/08/04 21:50:44+02:00 kaber@coreworks.de +5 -2
#   [PKT_SCHED]: Fix q_idx calculation in tc_dump_qdisc
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-04 21:55:13 +02:00
+++ b/net/sched/sch_api.c	2004-08-04 21:55:13 +02:00
@@ -817,13 +817,16 @@
 		read_lock_bh(&qdisc_tree_lock);
 		q_idx = 0;
 		list_for_each_entry(q, &dev->qdisc_list, list) {
-			if (q_idx++ < s_q_idx)
+			if (q_idx < s_q_idx) {
+				q_idx++;
 				continue;
+			}
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
 				read_unlock_bh(&qdisc_tree_lock);
 				goto done;
 			}
+			q_idx++;
 		}
 		read_unlock_bh(&qdisc_tree_lock);
 	}
@@ -832,7 +835,7 @@
 	read_unlock(&dev_base_lock);
 
 	cb->args[0] = idx;
-	cb->args[1] = q_idx - 1;
+	cb->args[1] = q_idx;
 
 	return skb->len;
 }

--------------030100070902050203020709--
