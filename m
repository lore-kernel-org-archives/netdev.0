From: jamal <hadi@cyberus.ca>
Subject: PATCH: IPSEC acquire in presence of multiple managers
Date: 25 Mar 2005 19:12:07 -0500
Message-ID: <1111795927.1089.749.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KKtamxd5AOUq9jGcgTIc"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-KKtamxd5AOUq9jGcgTIc
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Herbert/Dave,

Acquire should be supported by both pfkey and netlink.
However, it stops to send acquire message from the kernel on first
success.
It is possible that one or the other manager maybe passively monitoring
and needs to see those messages.

Thanks to Masahide NAKAMURA <nakam@linux-ipv6.org>, Shinta Sugimoto
<shinta.sugimoto@ericsson.com> for both identifying the issue and
validating the fix.

If you want i can put this with other NLMSGALIGN one liner i mentioned
earlier.

cheers,
jamal

--=-KKtamxd5AOUq9jGcgTIc
Content-Disposition: attachment; filename=acq_p
Content-Type: text/plain; name=acq_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_state.c	2005/03/25 17:44:43	1.1
+++ b/net/xfrmxfrm_state.c	2005/03/25 18:55:33
@@ -774,16 +774,20 @@
 		wake_up(&km_waitq);
 }
 
+/*
+ * We send to all registered managers regardless of failure
+ * We are happy with one success
+*/
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 {
-	int err = -EINVAL;
+	int err = -EINVAL, acqret = -EINVAL;
 	struct xfrm_mgr *km;
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		err = km->acquire(x, t, pol, XFRM_POLICY_OUT);
-		if (!err)
-			break;
+		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
+		if (!acqret)
+			err = acqret;
 	}
 	read_unlock(&xfrm_km_lock);
 	return err;

--=-KKtamxd5AOUq9jGcgTIc--
