From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Fix xfrm_tunnel leak
Date: Tue, 1 Jun 2004 22:25:59 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040601122559.GA19761@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I recently managed to create a mode=tunnel state that I couldn't get rid
of:

192.168.0.6 192.168.0.178 
	unspec mode=tunnel spi=3232235526(0xc0a80006) reqid=0(0x00000000)
	seq=0x00000000 replay=0 flags=0x00000000 state=mature 
	created: May 29 13:20:10 2004	current: Jun  1 22:23:15 2004
	diff: 291785(s)	hard: 0(s)	soft: 0(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=0 pid=19776 refcnt=0

Turns out that the IPIP tunnel used by IPCOMP states are only freed
if the IPCOMP state is deleted by xfrm_state_delete.

This is not the case for all states.  For example, an immature IPCOMP
state that dies in add_sa will not go through xfrm_state_delete.

The following patch moves the delete_tunnel call into IPCOMP's
destructor.  I think it makes more sense there as IPCOMP is the
only user of the tunnel anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ipcomp.c 1.19 vs edited =====
--- 1.19/net/ipv4/ipcomp.c	2004-04-17 06:54:43 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-06-01 22:21:02 +10:00
@@ -339,6 +339,7 @@
 	struct ipcomp_data *ipcd = x->data;
 	if (!ipcd)
 		return;
+	xfrm_state_delete_tunnel(x);
 	ipcomp_free_data(ipcd);
 	kfree(ipcd);
 }
===== net/xfrm/xfrm_state.c 1.44 vs edited =====
--- 1.44/net/xfrm/xfrm_state.c	2004-05-30 18:20:34 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-06-01 22:18:09 +10:00
@@ -231,7 +231,6 @@
 
 void xfrm_state_delete(struct xfrm_state *x)
 {
-	xfrm_state_delete_tunnel(x);
 	spin_lock_bh(&x->lock);
 	__xfrm_state_delete(x);
 	spin_unlock_bh(&x->lock);

--UugvWAfsgieZRqgk--
