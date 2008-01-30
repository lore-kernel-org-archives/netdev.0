From: Andi Kleen <ak@suse.de>
Subject: [PATCH] [2/2] Remove some unnecessary gotos in established_get_first()
Date: Wed, 30 Jan 2008 09:01:10 +0100 (CET)
Message-ID: <20080130080110.35B691B416F@basil.firstfloor.org>
References: <20080130901.138686634@suse.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:51104 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYA3IRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:17:32 -0500
In-Reply-To: <20080130901.138686634@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


gcc does not generate different code for return foo vs bar = foo; goto x;
x: return bar; So convert it all to direct returns for better readability.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/net/ipv4/tcp_ipv4.c
===================================================================
--- linux.orig/net/ipv4/tcp_ipv4.c
+++ linux/net/ipv4/tcp_ipv4.c
@@ -2065,8 +2065,7 @@ static void *established_get_first(struc
 			if (sk->sk_family != st->family) {
 				continue;
 			}
-			rc = sk;
-			goto out;
+			return sk;
 		}
 		st->state = TCP_SEQ_STATE_TIME_WAIT;
 		inet_twsk_for_each(tw, node,
@@ -2074,13 +2073,11 @@ static void *established_get_first(struc
 			if (tw->tw_family != st->family) {
 				continue;
 			}
-			rc = tw;
-			goto out;
+			return tw;
 		}
 		read_unlock_bh(lock);
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 	}
-out:
 	return rc;
 }
 
@@ -2100,10 +2097,8 @@ get_tw:
 		while (tw && tw->tw_family != st->family) {
 			tw = tw_next(tw);
 		}
-		if (tw) {
-			cur = tw;
-			goto out;
-		}
+		if (tw)
+			return tw;
 		read_unlock_bh(inet_ehash_lockp(&tcp_hashinfo, st->bucket));
 		st->state = TCP_SEQ_STATE_ESTABLISHED;
 
@@ -2121,16 +2116,12 @@ get_tw:
 
 	sk_for_each_from(sk, node) {
 		if (sk->sk_family == st->family)
-			goto found;
+			return sk;
 	}
 
 	st->state = TCP_SEQ_STATE_TIME_WAIT;
 	tw = tw_head(&tcp_hashinfo.ehash[st->bucket].twchain);
 	goto get_tw;
-found:
-	cur = sk;
-out:
-	return cur;
 }
 
 static void *established_get_idx(struct seq_file *seq, loff_t pos)
