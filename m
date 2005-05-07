From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/7] [IPSEC] Add complete xfrm event notification
Date: Sat, 07 May 2005 16:51:33 +0200
Message-ID: <427CD5F5.9010605@trash.net>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080705010204000004010703"
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050507071824.GA5753@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080705010204000004010703
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> @@ -1254,6 +1326,7 @@ static int pfkey_add(struct sock *sk, st
>  	if (IS_ERR(x))
>  		return PTR_ERR(x);
>  
> +	xfrm_state_hold(x);

This introduces a leak when xfrm_state_add()/xfrm_state_update()
fail. We hold two references (one from xfrm_state_alloc(), one
from xfrm_state_hold()), but only drop one. We need to take the
reference because the reference from xfrm_state_alloc() can
be dropped by __xfrm_state_delete(), so the fix is to drop both
references on error. Same problem in xfrm_user.c.


--------------080705010204000004010703
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix xfrm_state leaks in error path

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a4222e4b4f4fe6a28204e7960972ef833ac0c4ce
tree c24f26cfe03081d10a3a3f66d5d3e503395090b4
parent 16efae13731912e8cd028a85257fb33726318770
author Patrick McHardy <kaber@trash.net> 1115477180 +0200
committer Patrick McHardy <kaber@trash.net> 1115477180 +0200

Index: net/key/af_key.c
===================================================================
--- 6c0df7e8f613031668cf54aec5735e8b9f76aaa9/net/key/af_key.c  (mode:100644 sha1:577f0bb5bb31816bb1ecf94848ae2758d9c2cbcf)
+++ c24f26cfe03081d10a3a3f66d5d3e503395090b4/net/key/af_key.c  (mode:100644 sha1:98b72f2024ffd84564530e5973861b908fd8f541)
@@ -1333,7 +1333,7 @@
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
-		return err;
+		goto out;
 	}
 
 	if (hdr->sadb_msg_type == SADB_ADD)
@@ -1343,8 +1343,8 @@
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	km_state_notify(x, &c);
+out:
 	xfrm_state_put(x);
-
 	return err;
 }
 
Index: net/xfrm/xfrm_user.c
===================================================================
--- 6c0df7e8f613031668cf54aec5735e8b9f76aaa9/net/xfrm/xfrm_user.c  (mode:100644 sha1:6c8c6d6924939fe30264caab9f6fca943cf70e3b)
+++ c24f26cfe03081d10a3a3f66d5d3e503395090b4/net/xfrm/xfrm_user.c  (mode:100644 sha1:4f37b4f2ea8a238b8ae5f97496b727df7489d5fb)
@@ -287,7 +287,7 @@
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
-		return err;
+		goto out;
 	}
 
 	c.seq = nlh->nlmsg_seq;
@@ -295,8 +295,8 @@
 	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
+out:
 	xfrm_state_put(x);
-
 	return err;
 }
 

--------------080705010204000004010703--
