From: jamal <hadi@cyberus.ca>
Subject: patch: annoying u32 double listing
Date: 06 Feb 2005 14:49:04 -0500
Message-ID: <1107719343.1055.22.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hXDhNYmEsldW+1l6It/N"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-hXDhNYmEsldW+1l6It/N
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


bug is around since 2.1.x; never cared about chasing it until now
because it is affecting someone i know.
Dave, please apply. I will prepare a 2.4.x version.

To see the problem:

tc qdisc add dev eth0 ingress
#add two filters at different prio levels
tc filter add dev eth0 parent ffff: protocol ip prio 6 \
u32 match ip src 10.0.0.210/32 flowid 1:16
#
tc filter add dev eth0 parent ffff: protocol ip prio 7 \
u32 match ip src 10.0.0.144/32 flowid 1:15 
#now list them..
root@jdev:/# tc -s filter show parent ffff: dev eth0 

filter protocol ip pref 6 u32 
filter protocol ip pref 6 u32 fh 801: ht divisor 1 
filter protocol ip pref 6 u32 fh 801::800 order 2048 key ht 801 bkt 0
flowid 1:15 
  match 0a000090/ffffffff at 12
filter protocol ip pref 6 u32 fh 800: ht divisor 1 
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16 
  match 0a0000d2/ffffffff at 12
filter protocol ip pref 7 u32 
filter protocol ip pref 7 u32 fh 801: ht divisor 1 
filter protocol ip pref 7 u32 fh 801::800 order 2048 key ht 801 bkt 0
flowid 1:15 
  match 0a000090/ffffffff at 12
filter protocol ip pref 7 u32 fh 800: ht divisor 1 
filter protocol ip pref 7 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16 
  match 0a0000d2/ffffffff at 12

each filter is listed in each priority. So if you had 5 rules in 5 prios
(which is where sherlock started) you see 25 outputs.

AFTER FIX: 
---------

root@jdev:/usr/src# tc -s filter show parent ffff: dev eth0
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16  
  match 0a0000d2/ffffffff at 12 
  filter protocol ip pref 7 u32
  filter protocol ip pref 7 u32 fh 801::800 order 2048 key ht 801 bkt 0
flowid 1:15  
    match 0a000090/ffffffff at 12 


cheers,
jamal

--=-hXDhNYmEsldW+1l6It/N
Content-Disposition: attachment; filename=u32multi_p
Content-Type: text/plain; name=u32multi_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2611-rc3+bk3/net/sched/cls_api.c	2005/02/06 16:28:26	1.1
+++ 2611-rc3+bk3/net/sched/cls_api.c	2005/02/06 16:41:47
@@ -326,6 +326,7 @@
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
+	int ret;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
@@ -339,8 +340,11 @@
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
-		if (tp->ops->dump && tp->ops->dump(tp, fh, skb, tcm) < 0)
-			goto rtattr_failure;
+		if (tp->ops->dump) {
+			ret = tp->ops->dump(tp, fh, skb, tcm);
+			if (ret < 0)
+				goto rtattr_failure;
+		}
 	}
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
@@ -348,6 +352,8 @@
 nlmsg_failure:
 rtattr_failure:
 	skb_trim(skb, b - skb->data);
+	if (ret == -ENOENT)
+		return skb->len;
 	return -1;
 }
 
--- 2611-rc3+bk3/net/sched/cls_u32.c	2005/02/06 16:30:44	1.1
+++ 2611-rc3+bk3/net/sched/cls_u32.c	2005/02/06 16:33:13
@@ -76,6 +76,7 @@
 	char                     indev[IFNAMSIZ];
 #endif
 	u8			fshift;
+	u32			prio;
 	struct tcf_result	res;
 	struct tc_u_hnode	*ht_down;
 #ifdef CONFIG_CLS_U32_PERF
@@ -641,6 +642,7 @@
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
 	n->handle = handle;
+	n->prio = tp->prio;
 {
 	u8 i = 0;
 	u32 mask = s->hmask;
@@ -736,6 +738,9 @@
 	if (n == NULL)
 		return skb->len;
 
+	if (n->prio != tp->prio)
+		return -ENOENT;
+
 	t->tcm_handle = n->handle;
 
 	rta = (struct rtattr*)b;

--=-hXDhNYmEsldW+1l6It/N--
