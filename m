From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/1] netfilter: ebtables: make broute table work again
Date: Fri, 24 Dec 2010 08:47:17 +0800
Message-ID: <AANLkTikgoc6xzx-0xn4cXsVuWVETOG1=dpE_1kZKBVnM@mail.gmail.com>
References: <1293150436-12092-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36090 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab0LXArj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 19:47:39 -0500
In-Reply-To: <1293150436-12092-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 24, 2010 at 8:27 AM, Florian Westphal <fw@strlen.de> wrote:
> broute table init hook sets up the "br_should_route_hook" pointer,
> which then gets called from br_input.
>
> commit a386f99025f13b32502fe5dedf223c20d7283826
> (bridge: add proper RCU annotation to should_route_hook)
> introduced a typedef, and then changed this to:
>
> br_should_route_hook_t *rhook;
> [..]
> rhook =3D rcu_dereference(br_should_route_hook);
> if (*rhook(skb))
>
> problem is that "br_should_route_hook" contains the address of the fu=
nction,
> so calling *rhook() results in kernel panic.
>
> Can't simply use "if (rhook(skb)", because br_should_route_hook_t *rh=
ook
> is not a function.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>
> =A0include/linux/if_bridge.h | =A0 =A02 +-
> =A0net/bridge/br_input.c =A0 =A0 | =A0 =A02 +-
> =A02 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index f7e73c3..dd3f201 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -103,7 +103,7 @@ struct __fdb_entry {
>
> =A0extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned i=
nt, void __user *));
>
> -typedef int (*br_should_route_hook_t)(struct sk_buff *skb);
> +typedef int br_should_route_hook_t(struct sk_buff *skb);
> =A0extern br_should_route_hook_t __rcu *br_should_route_hook;
>
> =A0#endif
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 6f6d8e1..1d677bf 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -178,7 +178,7 @@ forward:
> =A0 =A0 =A0 =A0case BR_STATE_FORWARDING:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rhook =3D rcu_dereference(br_should_ro=
ute_hook);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rhook) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((*rhook)(skb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rhook(skb))

I don't think this change is necessary. Would you like to remove this
change and test again?

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 skb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dest =3D eth_hdr(skb)-=
>h_dest;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}




--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
