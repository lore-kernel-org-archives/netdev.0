From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 02:59:30 +0300
Message-ID: <200805280259.30931.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527154710.GA6305@2ka.mipt.ru> <20080527172849.GA14746@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_iBKPIilZ1rD0Yso"
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4324 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753952AbYE1AAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 20:00:41 -0400
In-Reply-To: <20080527172849.GA14746@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_iBKPIilZ1rD0Yso
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 27 May 2008, Evgeniy Polyakov wrote:
>
> Please try attached patch on top of vanilla tree.
> It does not use skb after socket was dropped, but instead search it
> again when socket is locked, so if socket is alive, it will find it and
> clean otherwise it will exit.
>

This fixes the crash, thanks.

One doubt though: suppose that while we drop the lock the skb gets aggregated 
with the one after it. If the original skb is fully consumed in the receive 
actor, then the we will eat the new, aggregated skb, loosing data. 

Here is a patch, based on your idea, which tries to cope with the above 
scenario. The !skb check was added for the case in which the actor does not 
consume anything in the current interration. 

tavi


--Boundary-00=_iBKPIilZ1rD0Yso
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="a.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="a.diff"

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0a9002b..0a0a663 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1358,7 +1358,8 @@ done:
 
 	if (spd.nr_pages) {
 		int ret;
-
+		struct sock *sk= __skb->sk;
+ 
 		/*
 		 * Drop the socket lock, otherwise we have reverse
 		 * locking dependencies between sk_lock and i_mutex
@@ -1368,9 +1369,9 @@ done:
 		 * we call into ->sendpage() with the i_mutex lock held
 		 * and networking will grab the socket lock.
 		 */
-		release_sock(__skb->sk);
+		release_sock(sk);
 		ret = splice_to_pipe(pipe, &spd);
-		lock_sock(__skb->sk);
+		lock_sock(sk);
 		return ret;
 	}
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3e91b28..34049d0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1227,7 +1227,8 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				copied += used;
 				offset += used;
 			}
-			if (offset != skb->len)
+			skb = tcp_recv_skb(sk, seq-1, &offset);
+			if (!skb || (offset+1 != skb->len))
 				break;
 		}
 		if (tcp_hdr(skb)->fin) {

--Boundary-00=_iBKPIilZ1rD0Yso--
