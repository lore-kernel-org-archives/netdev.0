From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec Oops when deleting an ip address
Date: Fri, 21 May 2004 23:19:50 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040521131950.GA20040@gondor.apana.org.au>
References: <20040510134958.13691.qmail@mason.oriente.labs.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Michele Bergonzoni <bergonz@nospam.org>
Content-Disposition: inline
In-Reply-To: <20040510134958.13691.qmail@mason.oriente.labs.it>
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 10, 2004 at 12:51:23PM +0000, Michele Bergonzoni wrote:
> 
> CPU: 0
> EIP: 0060:[<c030415a>] Not tainted
> EFLAGS: 00010202 (2.6.5)
> EIP is at xfrm_state_gc_destroy+0x1a/0xc0

Sorry, that's probably my fault.  I don't know what I was thinking, but
doing a mod_timer on a live state without holding a lock or for that
matter not even checking whether the state is dead is definitely a bad
idea.

This patch should fix it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: net/xfrm/xfrm_state.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/xfrm/xfrm_state.c,v
retrieving revision 1.12
diff -u -r1.12 xfrm_state.c
--- a/net/xfrm/xfrm_state.c	29 Nov 2003 06:48:37 -0000	1.12
+++ b/net/xfrm/xfrm_state.c	21 May 2004 13:13:34 -0000
@@ -489,15 +489,16 @@
 			memcpy(x1->encap, x->encap, sizeof(*x1->encap));
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
+
+		if (!mod_timer(&x1->timer, jiffies + HZ))
+			xfrm_state_hold(x1);
+		if (x1->curlft.use_time)
+			xfrm_state_check_expire(x1);
+
 		err = 0;
 	}
 	spin_unlock_bh(&x1->lock);
 
-	if (!mod_timer(&x1->timer, jiffies + HZ))
-		xfrm_state_hold(x1);
-	if (x1->curlft.use_time)
-		xfrm_state_check_expire(x1);
-
 	xfrm_state_put(x1);
 
 	return err;

--ibTvN161/egqYuK8--
