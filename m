From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 18:37:19 +1100
Message-ID: <20050220073719.GA13008@gondor.apana.org.au>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au> <42182082.9060301@trash.net> <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: kaber@trash.net, davem@davemloft.net, netdev@oss.sgi.com
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Feb 20, 2005 at 03:55:27PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> I didn't this because there are several places which depend on u8.
> If we go this way, we need to fix other places as well. e.g.

Good point.  However, I think it's better to fix things up once when
we cross from user-space to the kernel rather than converting it for
every single packet.

So here we can do something like this.  Please note that this patch
needs to be used with Patrick's earlier work.  Patrick, if you're
OK with it please merge it in with your patch.

By all means give xfrm_selector_fixup a better name :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/key/af_key.c 1.69 vs edited =====
--- 1.69/net/key/af_key.c	2005-01-26 16:53:19 +11:00
+++ edited/net/key/af_key.c	2005-02-20 18:26:57 +11:00
@@ -1914,6 +1914,8 @@
 	if (xp->selector.dport)
 		xp->selector.dport_mask = ~0;
 
+	xfrm_selector_fixup(&xp->selector);
+
 	xp->lft.soft_byte_limit = XFRM_INF;
 	xp->lft.hard_byte_limit = XFRM_INF;
 	xp->lft.soft_packet_limit = XFRM_INF;
@@ -2004,6 +2006,7 @@
 	if (sel.dport)
 		sel.dport_mask = ~0;
 
+	xfrm_selector_fixup(&sel);
 	xp = xfrm_policy_bysel(pol->sadb_x_policy_dir-1, &sel, 1);
 	if (xp == NULL)
 		return -ENOENT;
===== net/xfrm/xfrm_user.c 1.52 vs edited =====
--- 1.52/net/xfrm/xfrm_user.c	2005-01-26 16:53:19 +11:00
+++ edited/net/xfrm/xfrm_user.c	2005-02-20 18:23:41 +11:00
@@ -204,6 +204,7 @@
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
 	memcpy(&x->sel, &p->sel, sizeof(x->sel));
+	xfrm_selector_fixup(&x->sel);
 	memcpy(&x->lft, &p->lft, sizeof(x->lft));
 	x->props.mode = p->mode;
 	x->props.replay_window = p->replay_window;
@@ -626,6 +627,7 @@
 	xp->priority = p->priority;
 	xp->index = p->index;
 	memcpy(&xp->selector, &p->sel, sizeof(xp->selector));
+	xfrm_selector_fixup(&xp->selector);
 	memcpy(&xp->lft, &p->lft, sizeof(xp->lft));
 	xp->action = p->action;
 	xp->flags = p->flags;
@@ -808,6 +810,7 @@
 	struct xfrm_userpolicy_id *p;
 	int err;
 	int delete;
+	struct xfrm_selector sel;
 
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
@@ -818,8 +821,11 @@
 
 	if (p->index)
 		xp = xfrm_policy_byid(p->dir, p->index, delete);
-	else
+	else {
+		memcpy(&sel, &p->sel, sizeof(sel));
+		xfrm_selector_fixup(&sel);
 		xp = xfrm_policy_bysel(p->dir, &p->sel, delete);
+	}
 	if (xp == NULL)
 		return -ENOENT;
 
===== include/net/flow.h 1.11 vs edited =====
--- 1.11/include/net/flow.h	2004-03-19 15:20:28 +11:00
+++ edited/include/net/flow.h	2005-02-20 18:07:39 +11:00
@@ -58,7 +58,9 @@
 		} ports;
 
 		struct {
+			__u8	pad1;
 			__u8	type;
+			__u8	pad2;
 			__u8	code;
 		} icmpt;
 
===== include/net/xfrm.h 1.74 vs edited =====
--- 1.74/include/net/xfrm.h	2005-01-26 16:53:19 +11:00
+++ edited/include/net/xfrm.h	2005-02-20 18:29:01 +11:00
@@ -492,6 +492,17 @@
 	return 0;
 }
 
+static inline void xfrm_selector_fixup(struct xfrm_selector *sel)
+{
+	switch (sel->proto) {
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		sel->sport_mask &= htons(0xff);
+		sel->dport_mask &= htons(0xff);
+		break;
+	}
+}
+
 /* A struct encoding bundle of transformations to apply to some set of flow.
  *
  * dst->child points to the next element of bundle.

--VbJkn9YxBvnuCH5J--
