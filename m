From: Neil Horman <nhorman@redhat.com>
Subject: Re: [Patch] ipvs: close race conditions on ip_vs_conn_tab list modification
Date: Fri, 24 Jun 2005 13:40:54 -0400
Message-ID: <20050624174054.GE21499@hmsendeavour.rdu.redhat.com>
References: <20050624144822.GD21499@hmsendeavour.rdu.redhat.com> <Pine.LNX.4.44.0506241808150.2776-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Wensong Zhang <wensong@linux-vs.org>, akpm@osdl.org,
        netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0506241808150.2776-100000@l>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2005 at 06:09:40PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 24 Jun 2005, Neil Horman wrote:
> 
> >  			if (ct) {
> >  				IP_VS_DBG(4, "del conn template\n");
> >  				ip_vs_conn_expire_now(ct);
> >  			}
> 
> 	Don't forget to use cp->control instead of ct, ct is not needed
> anymore.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 


Good catch.  Sorry, should have seen that earlier.  New patch attached with
corrections.  When you're comfortable with this, I'll post the 2.4 version of
the patch.

Regards 
Neil

Signed-off-by: Neil Horman <nhorman@redhat.com>

 ip_vs_conn.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)


--- linux-2.6.git/net/ipv4/ipvs/ip_vs_conn.c.orig	2005-06-23 13:11:00.000000000 -0400
+++ linux-2.6.git/net/ipv4/ipvs/ip_vs_conn.c	2005-06-24 13:33:03.000000000 -0400
@@ -548,7 +548,6 @@
 {
 	if (del_timer(&cp->timer))
 		mod_timer(&cp->timer, jiffies);
-	__ip_vs_conn_put(cp);
 }
 
 
@@ -801,21 +800,12 @@
 					continue;
 			}
 
-			/*
-			 * Drop the entry, and drop its ct if not referenced
-			 */
-			atomic_inc(&cp->refcnt);
-			ct_write_unlock(hash);
-
-			if ((ct = cp->control))
-				atomic_inc(&ct->refcnt);
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
-			if (ct) {
+			if (cp->control) {
 				IP_VS_DBG(4, "del conn template\n");
-				ip_vs_conn_expire_now(ct);
+				ip_vs_conn_expire_now(cp->control);
 			}
-			ct_write_lock(hash);
 		}
 		ct_write_unlock(hash);
 	}
@@ -829,7 +819,6 @@
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct ip_vs_conn *ct;
 
   flush_again:
 	for (idx=0; idx<IP_VS_CONN_TAB_SIZE; idx++) {
@@ -839,18 +828,13 @@
 		ct_write_lock_bh(idx);
 
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
-			atomic_inc(&cp->refcnt);
-			ct_write_unlock(idx);
 
-			if ((ct = cp->control))
-				atomic_inc(&ct->refcnt);
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
-			if (ct) {
+			if (cp->control) {
 				IP_VS_DBG(4, "del conn template\n");
-				ip_vs_conn_expire_now(ct);
+				ip_vs_conn_expire_now(cp->control);
 			}
-			ct_write_lock(idx);
 		}
 		ct_write_unlock_bh(idx);
 	}
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
