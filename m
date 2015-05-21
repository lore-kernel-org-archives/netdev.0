From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Thu, 21 May 2015 11:49:21 +0800
Message-ID: <20150521034921.GA20427@gondor.apana.org.au>
References: <1432177162-9573-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37463 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbbEUDtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 23:49:33 -0400
Content-Disposition: inline
In-Reply-To: <1432177162-9573-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 04:59:22AM +0200, Linus L=FCssing wrote:
>=20
> * For i=3Dbr_multicast_init(), e=3Dbr_multicast_enable() and
>   s=3Dbr_multicast_stop() is the order i->e->s->e->s->e->... always
>   ensured by the netdev API? Will this work even if I have

br_multicast_init always happens first obviously.  But there is
no ordering requirement between e and s.

>   many fast and wild calls to "ip link set up dev br0" and
>   "ip link set down dev br0" and some changes to hash_max and
>   multicast_router in between?

The timer operations are all supposed to be idempotent.  So enabling
a port twice or stopping it twice should be OK.

> * Might calls to br_multicast_add_router() via br_multicast_enable_po=
rt()
>   cause unintended side-effects?

What do you mean? How does add_router get called from enable_port?

> * (maybe independent of this patch: )
>   Can fast changes to the multicast_router attribute of a bridge (por=
t)
>   cause race conditions because a del_timer() instead of a
>   del_timer_sync() is used in br_multicast_set_{port,}router()?
>   (or: why does br_multicast_stop() use del_timer_sync() while
>    br_multicast_disable_port() doesn't?)

I don't think so.  Firstly everything should happen under the
multicast lock except for stop/del_port.  The latter rely on
those adding timers to check netif_running and port !=3D disabled
to avoid races.

Apart from that you can always mod_timer twice or del_timer
twice so that's not really an issue.

> * @Herbert: Do you remember whether there was a reason for
>   checking netif_running() or the bridge port state which
>   I might have overlooked?

See above.  It's there so that you don't readd a timer when we're
calling del_timer_sync.  del_timer_sync has to be called without
the multicast lock so that's why we need another mechanism to
prevent the timers from being readded.

AFAICS the spots you patched aren't adding timers so they *should*
be OK.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
