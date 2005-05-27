From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sat, 28 May 2005 09:37:41 +1000
Message-ID: <20050527233741.GA9157@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is the patch that I reverted due to Jamal's objection to it.
I still think it's the right way to go which is why I'm submitting
it.  As it is, all the xfrm event notifications sent by the kernel
except the ones for SA/policy deletion are symmetric in the sense
that if they were sent straight back to the kernel in that same
form they would be accepted and perform the same action that
triggered the initial events.  As far as I know this is true for
non-xfrm netlink notifications as well, including deletion events.

What is different between xfrm and and other netlink notifications
is that requests such as route/address deletion use the same format
as route/address addition, while the SA/policy deletion format is
certainly not the same as SA/policy addition.

Based on these observations, I think we should change the IPsec
deletion notifications to use the same format as the IPsec deletion
requests that triggered them in the first place.  Of course, we
can do this in a way without losing information such as the SA/policy
that was actually deleted.

The objection to this change is that it creates an inconsistency
between xfrm deletion and non-xfrm deletion event formats.  However,
my view is that this is an inconsistency that is already present
between xfrm deleteion and non-xfrm deletion request formats.  By
doing this we in fact improve the consistency in the sense that all
netlink event notifications, xfrm or non-xfrm are now of the same
format as their corresponding requests.

One thing to note is that whatever we decide here we'll probably be
stuck with it for a long time since this is part of the xfrm netlink
ABI.


Here is the original changelog:

This patch changes the format of the XFRM_MSG_DELSA and
XFRM_MSG_DELPOLICY notification so that the main message
sent is of the same format as that received by the kernel
if the original message was via netlink.  This also means
that we won't lose the byid information carried in km_event.

Since this user interface is introduced by Jamal's patch
we can still afford to change it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -174,6 +174,8 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_COMP,		/* struct xfrm_algo */
 	XFRMA_ENCAP,		/* struct xfrm_algo + struct xfrm_encap_tmpl */
 	XFRMA_TMPL,		/* 1 or more struct xfrm_user_tmpl */
+	XFRMA_SA,
+	XFRMA_POLICY,
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1159,7 +1159,7 @@ nlmsg_failure:
 
 static int inline xfrm_sa_len(struct xfrm_state *x)
 {
-	int l = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
+	int l = 0;
 	if (x->aalg)
 		l += RTA_SPACE(sizeof(*x->aalg) + (x->aalg->alg_key_len+7)/8);
 	if (x->ealg)
@@ -1175,20 +1175,39 @@ static int inline xfrm_sa_len(struct xfr
 static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 {
 	struct xfrm_usersa_info *p;
+	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
 	int len = xfrm_sa_len(x);
+	int headlen;
+
+	headlen = sizeof(*p);
+	if (c->event == XFRM_MSG_DELSA) {
+		len += RTA_SPACE(headlen);
+		headlen = sizeof(*id);
+	}
+	len += NLMSG_SPACE(headlen);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, sizeof(*p));
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, headlen);
 	nlh->nlmsg_flags = 0;
 
 	p = NLMSG_DATA(nlh);
+	if (c->event == XFRM_MSG_DELSA) {
+		id = NLMSG_DATA(nlh);
+		memcpy(&id->daddr, &x->id.daddr, sizeof(id->daddr));
+		id->spi = x->id.spi;
+		id->family = x->props.family;
+		id->proto = x->id.proto;
+
+		p = RTA_DATA(__RTA_PUT(skb, XFRMA_SA, sizeof(*p)));
+	}
+
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
@@ -1389,20 +1408,39 @@ static int xfrm_exp_policy_notify(struct
 static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct xfrm_userpolicy_info *p;
+	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
 	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_info));
+	int headlen;
+
+	headlen = sizeof(*p);
+	if (c->event == XFRM_MSG_DELPOLICY) {
+		len += RTA_SPACE(headlen);
+		headlen = sizeof(*id);
+	}
+	len += NLMSG_SPACE(headlen);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, sizeof(*p));
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, headlen);
 
 	p = NLMSG_DATA(nlh);
+	if (c->event == XFRM_MSG_DELPOLICY) {
+		id = NLMSG_DATA(nlh);
+		memset(id, 0, sizeof(*id));
+		id->dir = dir;
+		if (c->data.byid)
+			id->index = xp->index;
+		else
+			memcpy(&id->sel, &xp->selector, sizeof(id->sel));
+
+		p = RTA_DATA(__RTA_PUT(skb, XFRMA_POLICY, sizeof(*p)));
+	}
 
 	nlh->nlmsg_flags = 0;
 
@@ -1415,6 +1453,7 @@ static int xfrm_notify_policy(struct xfr
 	return netlink_broadcast(xfrm_nl, skb, 0, XFRMGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
+rtattr_failure:
 	kfree_skb(skb);
 	return -1;
 }

--W/nzBZO5zC0uMSeA--
