From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Fix mc_list operations
Date: Thu, 11 Nov 2004 15:21:36 +1100
Message-ID: <20041111042136.GA17076@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ReaqsoxgOBHFXBhH"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

While doing the 2.4 version of the netlink patch, I noticed a bug
in my mc_list code.  First of all it wasn't holding the table lock
when adding nodes to the list.  It also didn't take the node off
the list when multicast is switched off.

The following patch fixes it for 2.6.  I will simply fix it in the
2.4 version.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.61 vs edited =====
--- 1.61/net/netlink/af_netlink.c	2004-11-06 18:49:54 +11:00
+++ edited/net/netlink/af_netlink.c	2004-11-11 15:09:40 +11:00
@@ -471,9 +471,16 @@
 			return err;
 	}
 
-	nlk->groups = nladdr->nl_groups;
-	if (nladdr->nl_groups)
+	if (!nladdr->nl_groups && !nlk->groups)
+		return 0;
+
+	netlink_table_grab();
+	if (nlk->groups && !nladdr->nl_groups)
+		__sk_del_bind_node(sk);
+	else if (!nlk->groups && nladdr->nl_groups)
 		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
+	nlk->groups = nladdr->nl_groups;
+	netlink_table_ungrab();
 
 	return 0;
 }

--ReaqsoxgOBHFXBhH--
