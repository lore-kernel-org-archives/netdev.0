From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/4] [IPSEC] Add xfrm_state_mtu
Date: Tue, 15 Feb 2005 09:12:00 +1100
Message-ID: <20050214221200.GA18465@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050214221006.GA18415@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch introduces the function xfrm_state_mtu which calculates
the MTU under a specific SA.  This function can be simplified once
we get rid all other uses of get_max_size as we can move the calculation
into the invidual SA type.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-2

===== include/net/xfrm.h 1.75 vs edited =====
--- 1.75/include/net/xfrm.h	2005-02-14 14:02:13 +11:00
+++ edited/include/net/xfrm.h	2005-02-14 14:11:38 +11:00
@@ -807,6 +807,7 @@
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
+extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
===== net/xfrm/xfrm_state.c 1.54 vs edited =====
--- 1.54/net/xfrm/xfrm_state.c	2005-02-09 11:17:47 +11:00
+++ edited/net/xfrm/xfrm_state.c	2005-02-14 14:06:17 +11:00
@@ -966,6 +966,36 @@
 }
 EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 
+int xfrm_state_mtu(struct xfrm_state *x, int mtu)
+{
+	int res = mtu;
+
+	res -= x->props.header_len;
+
+	for (;;) {
+		int m = res;
+
+		if (m < 68)
+			return 68;
+
+		spin_lock_bh(&x->lock);
+		if (x->km.state == XFRM_STATE_VALID &&
+		    x->type && x->type->get_max_size)
+			m = x->type->get_max_size(x, m);
+		else
+			m += x->props.header_len;
+		spin_unlock_bh(&x->lock);
+
+		if (m <= mtu)
+			break;
+		res -= (m - mtu);
+	}
+
+	return res;
+}
+
+EXPORT_SYMBOL(xfrm_state_mtu);
+ 
 void __init xfrm_state_init(void)
 {
 	int i;

--x+6KMIRAuhnl3hBn--
