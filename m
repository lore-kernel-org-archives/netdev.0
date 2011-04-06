From: dann frazier <dannf@dannf.org>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 6 Apr 2011 12:45:03 -0600
Message-ID: <20110406184503.GA2718@dannf.org>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
 <1301957293.3021.191.camel@edumazet-laptop>
 <1301984679.3021.655.camel@edumazet-laptop>
 <1301987879.3021.714.camel@edumazet-laptop>
 <20110406162547.GA3064@dannf.org>
 <1302108258.3209.117.camel@edumazet-laptop>
 <1302108567.3209.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1302108567.3209.121.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2011 at 06:49:27PM +0200, Eric Dumazet wrote:
> Le mercredi 06 avril 2011 =E0 18:44 +0200, Eric Dumazet a =E9crit :
> > Le mercredi 06 avril 2011 =E0 10:25 -0600, dann frazier a =E9crit :
> >=20
> > > Thanks Eric. Unfortunately that didn't solve the problem I am see=
ing.
> > > I rebaselined (same kernel build as before), and found that I'm a=
ble
> > > to reproduce this 100% of the time by running only:
> > >=20
> > >   sudo ebtables -t filter --init-table
> > >=20
> > > The backtrace I received was this:
> >=20
> >=20
> > Oh yeah, I forgot to remove the WARN_ON_ONCE(1) at the end of
> > xt_compat_calc_jump()
> >=20
> > I focused on restoring ebtables (for example ebtables -A INPUT ...)
> >=20
> > Just ignore the warning for the time being ;)
> >=20
> >=20
> > # ebtables -A INPUT -p arp -s 00:01:02:03:04:05 -j ACCEPT
> > # ebtables -A INPUT -p arp -s 00:01:02:03:04:06 -j ACCEPT
> > # ebtables -L
> > Bridge table: filter
> >=20
> > Bridge chain: INPUT, entries: 2, policy: ACCEPT
> > -p ARP -s 0:1:2:3:4:5 -j ACCEPT=20
> > -p ARP -s 0:1:2:3:4:6 -j ACCEPT=20
> >=20
> > Bridge chain: FORWARD, entries: 0, policy: ACCEPT
> >=20
> > Bridge chain: OUTPUT, entries: 0, policy: ACCEPT
> >=20

Tested-by: dann frazier <dannf@dannf.org>

Thanks!

> [PATCH] netfilter: fix ebtables
>=20
> commit 255d0dc34068a976 (netfilter: x_table: speedup compat operation=
s)
> made ebtables not working anymore.
>=20
> 1) xt_compat_calc_jump() is not an exact match lookup
> 2) compat_table_info() has a typo in xt_compat_init_offsets() call
> 3) compat_do_replace() misses a xt_compat_init_offsets() call
>=20
> Reported-by: dann frazier <dannf@dannf.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> V2: 	remove a comment from V1 (as Patrick suggested)
> 	remove the WARN_ON_ONCE() in xt_compat_calc_jump()
>=20
>=20
>  net/bridge/netfilter/ebtables.c |    3 ++-
>  net/netfilter/x_tables.c        |    4 ++--
>  2 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/e=
btables.c
> index 893669c..c66aa80 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1766,7 +1766,7 @@ static int compat_table_info(const struct ebt_t=
able_info *info,
> =20
>  	newinfo->entries_size =3D size;
> =20
> -	xt_compat_init_offsets(AF_INET, info->nentries);
> +	xt_compat_init_offsets(NFPROTO_BRIDGE, info->nentries);
>  	return EBT_ENTRY_ITERATE(entries, size, compat_calc_entry, info,
>  							entries, newinfo);
>  }
> @@ -2240,6 +2240,7 @@ static int compat_do_replace(struct net *net, v=
oid __user *user,
> =20
>  	xt_compat_lock(NFPROTO_BRIDGE);
> =20
> +	xt_compat_init_offsets(NFPROTO_BRIDGE, tmp.nentries);
>  	ret =3D compat_copy_entries(entries_tmp, tmp.entries_size, &state);
>  	if (ret < 0)
>  		goto out_unlock;
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index a9adf4c..8a025a5 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -455,6 +455,7 @@ void xt_compat_flush_offsets(u_int8_t af)
>  		vfree(xt[af].compat_tab);
>  		xt[af].compat_tab =3D NULL;
>  		xt[af].number =3D 0;
> +		xt[af].cur =3D 0;
>  	}
>  }
>  EXPORT_SYMBOL_GPL(xt_compat_flush_offsets);
> @@ -473,8 +474,7 @@ int xt_compat_calc_jump(u_int8_t af, unsigned int=
 offset)
>  		else
>  			return mid ? tmp[mid - 1].delta : 0;
>  	}
> -	WARN_ON_ONCE(1);
> -	return 0;
> +	return left ? tmp[left - 1].delta : 0;
>  }
>  EXPORT_SYMBOL_GPL(xt_compat_calc_jump);
> =20
>=20
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
