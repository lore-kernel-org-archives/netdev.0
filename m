From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in pppoe_flush_dev()
Date: Mon, 5 Oct 2015 14:08:44 +0200
Message-ID: <20151005120844.GF2911@alphalink.fr>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
 <20151002175426.GE2911@alphalink.fr>
 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Oleksii Berezhniak <core@irc.lg.ua>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:43337 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751403AbbJEMIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 08:08:50 -0400
Content-Disposition: inline
In-Reply-To: <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am doing just "dirty" patch like this, i cannot certainly remember if i
> was doing git reversal, because
> it was a while when i spotted this bug. After that pppoe server is not
> rebooting.
> 
> diff -Naur linux-4.2.2-vanilla/drivers/net/ppp/pppoe.c
> linux-4.2.2-changed/drivers/net/ppp/pppoe.c
> --- linux-4.2.2-vanilla/drivers/net/ppp/pppoe.c 2015-09-29
> 20:38:27.000000000 +0300
> +++ linux-4.2.2-changed/drivers/net/ppp/pppoe.c 2015-10-04
> 19:05:55.697732991 +0300
> @@ -519,7 +519,7 @@
>                 }
> 
>                 bh_unlock_sock(sk);
> -               if (!schedule_work(&po->proto.pppoe.padt_work))
> +//             if (!schedule_work(&po->proto.pppoe.padt_work))
>                         sock_put(sk);
>         }
> 
> @@ -633,7 +633,7 @@
> 
>         lock_sock(sk);
> 
> -       INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
> +//     INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
> 
>         error = -EINVAL;
>         if (sp->sa_protocol != PX_PROTO_OE)
> 
Ok, so this is clearly related with PADT message handling. Setting
sk->sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv() looks wrong to me.
Furthurmore, at a first glance, it doesn't look necessary. If you're
feeling lucky, you can try the following diff (WARNING: not even
compile-tested!):

 	if (po) {
 		struct sock *sk = sk_pppox(po);
 
-		bh_lock_sock(sk);
-
-		/* If the user has locked the socket, just ignore
-		 * the packet.  With the way two rcv protocols hook into
-		 * one socket family type, we cannot (easily) distinguish
-		 * what kind of SKB it is during backlog rcv.
-		 */
-		if (sock_owned_by_user(sk) == 0) {
-			/* We're no longer connect at the PPPOE layer,
-			 * and must wait for ppp channel to disconnect us.
-			 */
-			sk->sk_state = PPPOX_ZOMBIE;
-		}
-
-		bh_unlock_sock(sk);
 		if (!schedule_work(&po->proto.pppoe.padt_work))
 			sock_put(sk);
 	}

I'll take a closer look and do proper testing during the week.
