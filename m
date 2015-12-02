From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Kernel 4.1.12 crash
Date: Wed, 2 Dec 2015 18:23:35 +0100
Message-ID: <20151202172335.GB16101@alphalink.fr>
References: <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua>
 <56514FF5.7060906@gmail.com>
 <5654EBE8.9030705@seti.kr.ua>
 <20151125141048.GA3868@alphalink.fr>
 <5655CCAE.6000300@seti.kr.ua>
 <20151126164452.GA2988@alphalink.fr>
 <565B7699.8030105@seti.kr.ua>
 <20151130150337.GC3059@alphalink.fr>
 <20151130204208.GA6046@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, Simon Farnsworth <simon@farnz.org.uk>
To: Andrew <nitr0@seti.kr.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51997 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964871AbbLBRXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 12:23:38 -0500
Content-Disposition: inline
In-Reply-To: <20151130204208.GA6046@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 09:42:08PM +0100, Guillaume Nault wrote:
> On Mon, Nov 30, 2015 at 04:03:37PM +0100, Guillaume Nault wrote:
> > Yes, it most likely was introduced by 287f3a943fef ("pppoe: Use
> > workqueue to die properly when a PADT is received"). I still have to
> > figure out why.
> 
> I confirm the bug comes from this commit.
> 
> It happens if pppoe_connect() reinitialises po->proto.pppoe.padt_work
> after pppoe_disc_rcv() has added it to the system's work queue, and
> before that work got scheduled. Then when scheduling occurs, the worker
> thread tries to run a corrupted structure and crashes.
> 
> I'm going to work on a patch.

You can try the following. It's not yet a proper fix as there are still
a few things that bug me in pppoe_connect().

---
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 5e0b432..865b74d 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -568,6 +568,9 @@ static int pppoe_create(struct net *net, struct socket *sock, int kern)
 	sk->sk_family		= PF_PPPOX;
 	sk->sk_protocol		= PX_PROTO_OE;
 
+	INIT_WORK(&pppox_sk(sk)->proto.pppoe.padt_work,
+		  pppoe_unbind_sock_work);
+
 	return 0;
 }
 
@@ -632,8 +635,6 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	lock_sock(sk);
 
-	INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
-
 	error = -EINVAL;
 	if (sp->sa_protocol != PX_PROTO_OE)
 		goto end;
@@ -663,8 +664,6 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 			po->pppoe_dev = NULL;
 		}
 
-		memset(sk_pppox(po) + 1, 0,
-		       sizeof(struct pppox_sock) - sizeof(struct sock));
 		sk->sk_state = PPPOX_NONE;
 	}
 
