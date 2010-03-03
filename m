From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 8/8] x25: use limited socket backlog
Date: Wed, 03 Mar 2010 08:08:29 +0100
Message-ID: <1267600109.2839.101.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Hendry <andrew.hendry@gmail.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:55628 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988Ab0CCHIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 02:08:34 -0500
Received: by mail-bw0-f212.google.com with SMTP id 4so771623bwz.28
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 23:08:33 -0800 (PST)
In-Reply-To: <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 14:35 +0800, Zhu Yi a =C3=A9crit :
> Make x25 adapt to the limited socket backlog change.
>=20
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  net/x25/x25_dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
> index 3e1efe5..5688123 100644
> --- a/net/x25/x25_dev.c
> +++ b/net/x25/x25_dev.c
> @@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, st=
ruct x25_neigh *nb)
>  		if (!sock_owned_by_user(sk)) {
>  			queued =3D x25_process_rx_frame(sk, skb);
>  		} else {
> -			sk_add_backlog(sk, skb);
> +			__sk_add_backlog(sk, skb);
>  		}
>  		bh_unlock_sock(sk);
>  		sock_put(sk);

Please respin your patch the other way=20

Ie: let sk_add_backlog(sk, skb) do its previous job (not leaking skbs,
and returning a void status)

Add a new function able to no limit backlog, and returns an error code,
so that caller can free skb and increment SNMP counters accordingly.

Callers MUST test return value, or use another helper that can free the
skb for them.

Name it sk_move_backlog() for example

This will permit you to split the work as you tried.

sk_add_backlog() could be redefined as the helper :

void sk_add_backlog(sk, skb)
{
	if (sk_move_backlog(sk, skb)) {
		kfree_skb(skb);
		atomic_inc(&sk->sk_drops);
	}
=09
}

Thanks


