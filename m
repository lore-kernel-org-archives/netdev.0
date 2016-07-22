From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Fri, 22 Jul 2016 10:20:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg>
References: <1469123890-2715-1-git-send-email-hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	David Barroso <dbarroso@fastly.com>,
	Martin Zhang <martinbj2008@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51058 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752180AbcGVHWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:22:47 -0400
In-Reply-To: <1469123890-2715-1-git-send-email-hchunhui@mail.ustc.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 21 Jul 2016, Chunhui He wrote:

> If neigh entry was CONNECTED and address is not changed, and if new state is
> STALE, entry state will not change. Because DELAY is not in CONNECTED, it's
> possible to change state from DELAY to STALE.
> 
> That is bad. Consider a host in IPv4 nerwork, a neigh entry in STALE state
> is referenced to send packets, so goes to DELAY state. If the entry is not
> confirmed by upper layer, it goes to PROBE state, and sends ARP request.
> The neigh host sends ARP reply, then the entry goes to REACHABLE state.
> But the entry state may be reseted to STALE by broadcast ARP packets, before
> the entry goes to PROBE state. So it's possible that the entry will never go
> to REACHABLE state, without external confirmation.
> 
> In my case, the gateway refuses to send unicast packets to me, before it sees
> my ARP request. So it's critical to enter REACHABLE state by sending ARP
> request, but not by external confirmation.
> 
> This fixes neigh_update() not to change to STALE if old state is CONNECTED or
> DELAY.
> 
> Signed-off-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
> ---
>  net/core/neighbour.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 510cd62..29429eb 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1152,7 +1152,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  		} else {
>  			if (lladdr == neigh->ha && new == NUD_STALE &&
>  			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
> -			     (old & NUD_CONNECTED))
> +			     (old & (NUD_CONNECTED | NUD_DELAY)))
>  			    )
>  				new = old;
>  		}

	You change looks correct to me. But this place
has more problems. There is no good reason to set NUD_STALE
for any state that is NUD_VALID if address is not changed.
This matches perfectly the comment above this code:
NUD_STALE should change a NUD_VALID state only when
address changes. It also means that IPv6 does not need
to provide NEIGH_UPDATE_F_WEAK_OVERRIDE anymore when
NEIGH_UPDATE_F_OVERRIDE is also present.

	By this way the state machine can continue with
the resolving: NUD_STALE -> NUD_DELAY (traffic) ->
NUD_PROBE (retries) -> NUD_REACHABLE (unicast reply)
while the address is not changed. Your change covers only
NUD_DELAY, not NUD_PROBE, so it is better to allow more
retries to send. We should not give up until success (NUD_REACHABLE).

	Second problem: NEIGH_UPDATE_F_WEAK_OVERRIDE has no
priority over NEIGH_UPDATE_F_ADMIN. For example, now I can not
change from NUD_PERMANENT to NUD_STALE:

# ip neigh add 192.168.168.111 lladdr 00:11:22:33:44:55 nud perm dev wlan0
# ip neigh show to 192.168.168.111
192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT
# ip neigh change 192.168.168.111 lladdr 00:11:22:33:44:55 nud stale dev wlan0
# ip neigh show to 192.168.168.111
192.168.168.111 dev wlan0 lladdr 00:11:22:33:44:55 PERMANENT

	IMHO, here is how this place should look:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5cdc62a..2b1cb91 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1151,10 +1151,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 				goto out;
 		} else {
 			if (lladdr == neigh->ha && new == NUD_STALE &&
-			    ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
-			     (old & NUD_CONNECTED))
-			    )
-				new = old;
+			    !(flags & NEIGH_UPDATE_F_ADMIN))
+				goto out;
 		}
 	}

	Any thoughts?
 
Regards
