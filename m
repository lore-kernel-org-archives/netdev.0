From: jamal <hadi@cyberus.ca>
Subject: 2.4.29 version: Re: patch: annoying u32 double listing
Date: 06 Feb 2005 15:44:15 -0500
Message-ID: <1107722655.1054.24.camel@jzny.localdomain>
References: <1107719343.1055.22.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-i+I4Hm8GUCMTgdvgQnby"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1107719343.1055.22.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-i+I4Hm8GUCMTgdvgQnby
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2005-02-06 at 14:49, jamal wrote:
> bug is around since 2.1.x; never cared about chasing it until now
> because it is affecting someone i know.
> Dave, please apply. I will prepare a 2.4.x version.
> 

Attached.

cheers,
jamal

--=-i+I4Hm8GUCMTgdvgQnby
Content-Disposition: attachment; filename=p2429
Content-Type: text/plain; name=p2429; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- cls_api.c.orig	2004-02-18 08:36:32.000000000 -0500
+++ cls_api.c	2005-02-06 12:21:32.976531360 -0500
@@ -289,6 +289,7 @@
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
+	int ret;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*tcm));
@@ -300,14 +301,19 @@
 	tcm->tcm_handle = 0;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, tp->ops->kind);
-	if (tp->ops->dump && tp->ops->dump(tp, fh, skb, tcm) < 0)
-		goto rtattr_failure;
+	if (tp->ops->dump) {
+		ret = tp->ops->dump(tp, fh, skb, tcm);
+		if (ret < 0)
+			goto rtattr_failure;
+	}
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
 nlmsg_failure:
 rtattr_failure:
 	skb_trim(skb, b - skb->data);
+	if (ret == -ENOENT)
+		return skb->len;
 	return -1;
 }
 
--- cls_u32.c.orig	2004-11-17 06:54:22.000000000 -0500
+++ cls_u32.c	2005-02-06 12:25:31.000346240 -0500
@@ -61,6 +61,7 @@
 #ifdef CONFIG_NET_CLS_POLICE
 	struct tcf_police	*police;
 #endif
+	u32			prio;
 	struct tcf_result	res;
 	struct tc_u_hnode	*ht_down;
 	struct tc_u32_sel	sel;
@@ -577,6 +578,7 @@
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
 	n->handle = handle;
+	n->prio = tp->prio;
 	err = u32_set_parms(tp->q, base, ht, n, tb, tca[TCA_RATE-1]);
 	if (err == 0) {
 		struct tc_u_knode **ins;
@@ -639,6 +641,9 @@
 	if (n == NULL)
 		return skb->len;
 
+	if (n->prio != tp->prio)
+		return -ENOENT;
+
 	t->tcm_handle = n->handle;
 
 	rta = (struct rtattr*)b;

--=-i+I4Hm8GUCMTgdvgQnby--
