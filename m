From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH 1/2] Resend: LSM-IPSec Networking Hooks
Date: Sun, 29 May 2005 02:07:42 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505290153510.19554-100000@thoron.boston.redhat.com>
References: <1116361510.5560.121.camel@dyn9002018177.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <chrisw@osdl.org>, <serue@us.ibm.com>,
        <latten@austin.ibm.com>, <sds@tycho.nsa.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: jaegert <jaegert@us.ibm.com>
In-Reply-To: <1116361510.5560.121.camel@dyn9002018177.watson.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A few issues:

1) The following patch is needed to ensure that the error value is 
propagated back, that the err is initialized and that you don't try and 
xfrm_pol_put() an uninitialized xp.


diff -purN -X dontdiff linux-2.6.12-rc4.w/net/key/af_key.c linux-2.6.12-rc4.x/net/key/af_key.c
--- linux-2.6.12-rc4.w/net/key/af_key.c	2005-05-29 01:30:08.000000000 -0400
+++ linux-2.6.12-rc4.x/net/key/af_key.c	2005-05-29 01:54:17.751327592 -0400
@@ -2098,8 +2098,9 @@ static int pfkey_spddelete(struct sock *
 	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
 	memcpy(&tmp.selector, &sel, sizeof(struct xfrm_selector));
 	if (sec_ctx != NULL) {
-		if (security_xfrm_policy_alloc(&tmp, sec_ctx))
-			goto out;
+		err = security_xfrm_policy_alloc(&tmp, sec_ctx);
+		if (err)
+			return err;
 	}
 
 	xp = xfrm_policy_bysel(pol->sadb_x_policy_dir-1, &tmp.selector, 1);



2) Compiler warnings:

You pass a 
struct xfrm_user_sec_ctx to security_xfrm_policy_alloc() instead of the 
struct sadb_x_sec_ctx defined for that function:

net/xfrm/xfrm_user.c:223
net/xfrm/xfrm_user.c:651
net/xfrm/xfrm_user.c:939

This may seem to work on some systems because the structs are the same, 
but one is packed and it's bad form in any case.

Not sure what the best way is to fix this.  xfrm is native, so any penalty 
should likely go to pfkey.


Also,

net/xfrm/xfrm_user.c:1241: warning: unused variable `ctx'


3)  security/selinux/nethooks.c

The name of this file is potentially misleading, it does not contain all 
of the SELinux networking hooks, just the xfrm related code.  I'd suggest 
calling it security/selinux/xfrm.c.  It also has no author/copyright info, 
or a GPL notice (look at the other files there).


(More to come).


- James
-- 
James Morris
<jmorris@redhat.com>
