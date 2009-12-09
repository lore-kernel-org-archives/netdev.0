From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery)
Date: Wed, 9 Dec 2009 23:49:26 +0200
Message-ID: <200912092349.26264.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <4B20064C.7070301@gmail.com> <200912092236.06298.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:7686 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756156AbZLIVwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 16:52:35 -0500
In-Reply-To: <200912092236.06298.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 December 2009 22:36:06 you wrote:
 
> I think I have everything  (in my head :) ) that I need now to come back
>  with a v2 llc patch set now. 

Hmm, not really :) I still can't see how we can do multicast delivery only with RCU when we need to restart the lookup.

I think you mentioned that it is actually possible to do this for UDP, but I didn't found out how :-?

Also, I think we need to restart the lookup even when only one list is used, when we found out that the object is either free or not the one we were looking for, since the current object might have been added to the end of the 
list, thus short circuiting our search. E.g.:

@@ -323,14 +323,16 @@ static struct sock *llc_lookup_dgram(struct llc_sap *sap,
        struct hlist_nulls_node *node;
 
        rcu_read_lock_bh();
+again:
        sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
+               if (llc_sk(rc)->sap != sap)
+                       goto again;
                if (llc_dgram_match(sap, laddr, rc)) {
                        /* Extra checks required by SLAB_DESTROY_BY_RCU */
                        if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
-                               continue;
+                               goto again;
                        if (unlikely(!llc_dgram_match(sap, laddr, rc))) {
                                sock_put(rc);
-                               continue;
+                               goto again;
                        }
                        goto found;
                }
