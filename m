From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [6/*] [IPSEC] Add xfrm_userpolicy_delete for xfrm_user notification
Date: Sun, 10 Apr 2005 19:38:37 +1000
Message-ID: <20050410093837.GA26769@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <20050409111551.GA7378@gondor.apana.org.au> <20050410074849.GA13259@gondor.apana.org.au> <20050410090250.GA26022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050410090250.GA26022@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch changes the format of the XFRM_MSG_DELPOLICY notification
so that we don't lose the byid information carried in km_event.

Since this user interface is introduced by Jamal's patch we can still
afford to change it.

I know that this is a bit trivial but as it is the information carried
in xfrm_user's notifications is a strict superset of that of af_key
and I'd like to keep it that way :)
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-6

===== include/linux/xfrm.h 1.24 vs edited =====
--- 1.24/include/linux/xfrm.h	2005-04-08 23:08:26 +10:00
+++ edited/include/linux/xfrm.h	2005-04-10 19:25:22 +10:00
@@ -227,6 +227,11 @@
 	__u8				dir;
 };
 
+struct xfrm_userpolicy_delete {
+	struct xfrm_userpolicy_info	pol;
+	__u8				byid;
+};
+
 struct xfrm_user_acquire {
 	struct xfrm_id			id;
 	xfrm_address_t			saddr;
===== net/xfrm/xfrm_user.c 1.56 vs edited =====
--- 1.56/net/xfrm/xfrm_user.c	2005-04-10 19:03:30 +10:00
+++ edited/net/xfrm/xfrm_user.c	2005-04-10 19:30:30 +10:00
@@ -1386,20 +1386,30 @@
 static int xfrm_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct xfrm_userpolicy_info *p;
+	struct xfrm_userpolicy_delete *pdel;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	unsigned char *b;
 	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_info));
+	int payload;
+
+	payload = (c->event == XFRM_MSG_DELPOLICY) ?
+		  sizeof(*pdel) : sizeof(*p);
+	len += NLMSG_SPACE(payload);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 	b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, sizeof(*p));
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, payload);
 
 	p = NLMSG_DATA(nlh);
+	if (c->event == XFRM_MSG_DELPOLICY) {
+		pdel = NLMSG_DATA(nlh);
+		pdel->byid = !!c->data.byid;
+		p = &pdel->pol;
+	}
 
 	nlh->nlmsg_flags = 0;
 

--CE+1k2dSO48ffgeK--
