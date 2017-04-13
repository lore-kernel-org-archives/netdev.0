From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ney/key: slab-out-of-bounds in parse_ipsecrequests
Date: Thu, 13 Apr 2017 18:35:59 +0800
Message-ID: <20170413103559.GA23263@gondor.apana.org.au>
References: <CAAeHK+yuQZ1v-BBLoeGxfuXg-5uFe6sS5qC-gagaVkq4YroS8g@mail.gmail.com>
 <CAM_iQpXC03OpCxMQd3VoaVuDHma0Z6h=BuDUf63qc5x1aZvdww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpXC03OpCxMQd3VoaVuDHma0Z6h=BuDUf63qc5x1aZvdww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 05:39:22PM -0700, Cong Wang wrote:
> On Wed, Apr 12, 2017 at 8:02 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > Hi,
> >
> > I've got the following error report while fuzzing the kernel with syzkaller.
> >
> > On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
> >
> > A reproducer and .config are attached.
> >
> > When subtracting rq->sadb_x_ipsecrequest_len from len it can become
> > negative and the while loop condition remains true.
> 
> Good catch! Seems the fix is pretty straight forward:
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index c6252ed..cbce595 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1945,7 +1945,7 @@ parse_ipsecrequests(struct xfrm_policy *xp,
> struct sadb_x_policy *pol)
>         if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
>                 return -EINVAL;
> 
> -       while (len >= sizeof(struct sadb_x_ipsecrequest)) {
> +       while (len >= (int)sizeof(struct sadb_x_ipsecrequest)) {
>                 if ((err = parse_ipsecrequest(xp, rq)) < 0)
>                         return err;
>                 len -= rq->sadb_x_ipsecrequest_len;
> 
> But pol->sadb_x_policy_len and rq->sadb_x_ipsecrequest_len
> are controllable by user (fortunately root), I am feeling there might
> be other problem I miss too.

Well the fact that it is negative means that you've already parsed
crap in the previous loop.  This interface really needs to die.

---8<---
Subject: af_key: Fix sadb_x_ipsecrequest parsing

The parsing of sadb_x_ipsecrequest is broken in a number of ways.
First of all we're not verifying sadb_x_ipsecrequest_len.  This
is needed when the structure carries addresses at the end.  Worse
we don't even look at the length when we parse those optional
addresses.

The migration code had similar parsing code that's better but
it also has some deficiencies.  The length is overcounted first
of all as it includes the header itself.  It also fails to check
the length before dereferencing the sa_family field.

This patch fixes those problems in parse_sockaddr_pair and then
uses it in parse_ipsecrequest.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed..6ea5751 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -65,6 +65,10 @@ struct pfkey_sock {
 	} dump;
 };
 
+static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
+			       xfrm_address_t *saddr, xfrm_address_t *daddr,
+			       u16 *family);
+
 static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
 {
 	return (struct pfkey_sock *)sk;
@@ -1913,19 +1917,14 @@ static u32 gen_reqid(struct net *net)
 
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
-		u8 *sa = (u8 *) (rq + 1);
-		int family, socklen;
+		int err;
 
-		family = pfkey_sockaddr_extract((struct sockaddr *)sa,
-						&t->saddr);
-		if (!family)
-			return -EINVAL;
-
-		socklen = pfkey_sockaddr_len(family);
-		if (pfkey_sockaddr_extract((struct sockaddr *)(sa + socklen),
-					   &t->id.daddr) != family)
-			return -EINVAL;
-		t->encap_family = family;
+		err = parse_sockaddr_pair(
+			(struct sockaddr *)(rq + 1),
+			rq->sadb_x_ipsecrequest_len - sizeof(*rq),
+			&t->saddr, &t->id.daddr, &t->encap_family);
+		if (err)
+			return err;
 	} else
 		t->encap_family = xp->family;
 
@@ -1945,7 +1944,11 @@ static u32 gen_reqid(struct net *net)
 	if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
 		return -EINVAL;
 
-	while (len >= sizeof(struct sadb_x_ipsecrequest)) {
+	while (len >= sizeof(*rq)) {
+		if (len < rq->sadb_x_ipsecrequest_len ||
+		    rq->sadb_x_ipsecrequest_len < sizeof(*rq))
+			return -EINVAL;
+
 		if ((err = parse_ipsecrequest(xp, rq)) < 0)
 			return err;
 		len -= rq->sadb_x_ipsecrequest_len;
@@ -2408,7 +2411,6 @@ static int key_pol_get_resp(struct sock *sk, struct xfrm_policy *xp, const struc
 	return err;
 }
 
-#ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_sockaddr_pair_size(sa_family_t family)
 {
 	return PFKEY_ALIGN8(pfkey_sockaddr_len(family) * 2);
@@ -2420,7 +2422,7 @@ static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
 {
 	int af, socklen;
 
-	if (ext_len < pfkey_sockaddr_pair_size(sa->sa_family))
+	if (ext_len < 2 || ext_len < pfkey_sockaddr_pair_size(sa->sa_family))
 		return -EINVAL;
 
 	af = pfkey_sockaddr_extract(sa, saddr);
@@ -2436,6 +2438,7 @@ static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
 	return 0;
 }
 
+#ifdef CONFIG_NET_KEY_MIGRATE
 static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 				    struct xfrm_migrate *m)
 {
@@ -2443,13 +2446,14 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 	struct sadb_x_ipsecrequest *rq2;
 	int mode;
 
-	if (len <= sizeof(struct sadb_x_ipsecrequest) ||
-	    len < rq1->sadb_x_ipsecrequest_len)
+	if (len < sizeof(*rq1) ||
+	    len < rq1->sadb_x_ipsecrequest_len ||
+	    rq1->sadb_x_ipsecrequest_len < sizeof(*rq1))
 		return -EINVAL;
 
 	/* old endoints */
 	err = parse_sockaddr_pair((struct sockaddr *)(rq1 + 1),
-				  rq1->sadb_x_ipsecrequest_len,
+				  rq1->sadb_x_ipsecrequest_len - sizeof(*rq1),
 				  &m->old_saddr, &m->old_daddr,
 				  &m->old_family);
 	if (err)
@@ -2458,13 +2462,14 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 	rq2 = (struct sadb_x_ipsecrequest *)((u8 *)rq1 + rq1->sadb_x_ipsecrequest_len);
 	len -= rq1->sadb_x_ipsecrequest_len;
 
-	if (len <= sizeof(struct sadb_x_ipsecrequest) ||
-	    len < rq2->sadb_x_ipsecrequest_len)
+	if (len <= sizeof(*rq2) ||
+	    len < rq2->sadb_x_ipsecrequest_len ||
+	    rq2->sadb_x_ipsecrequest_len < sizeof(*rq2))
 		return -EINVAL;
 
 	/* new endpoints */
 	err = parse_sockaddr_pair((struct sockaddr *)(rq2 + 1),
-				  rq2->sadb_x_ipsecrequest_len,
+				  rq2->sadb_x_ipsecrequest_len - sizeof(*rq2),
 				  &m->new_saddr, &m->new_daddr,
 				  &m->new_family);
 	if (err)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
