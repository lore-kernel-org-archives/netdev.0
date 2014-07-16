From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: use rtnl_deref in
 bond_change_rx_flags()
Date: Wed, 16 Jul 2014 11:05:48 +0200
Message-ID: <1405501548.10255.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405495467-16187-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:55866 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaGPJF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 05:05:56 -0400
Received: by mail-wg0-f52.google.com with SMTP id a1so571435wgh.23
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 02:05:54 -0700 (PDT)
In-Reply-To: <1405495467-16187-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-16 at 09:24 +0200, Veaceslav Falico wrote:
> As it's always called with RTNL held, via dev_set_allmulti/promiscuity.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index d643807..2998710 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -498,7 +498,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
>  	int err = 0;
>  
>  	if (bond_uses_primary(bond)) {
> -		struct slave *curr_active = bond_deref_active_protected(bond);
> +		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
>  
>  		/* write lock already acquired */

This seems dubious to me. What really protects curr_active_slave being
modified ?

Considering the presence of the previous comment, I assumed the sync
point was the write lock. Not rtnl.

If write lock is never held without rtnl, then maybe the write lock is
useless, I don't know.

But after your patch its not really consistent and we increase
confusion.

>  		if (curr_active)
> @@ -524,7 +524,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
>  	int err = 0;
>  
>  	if (bond_uses_primary(bond)) {
> -		struct slave *curr_active = bond_deref_active_protected(bond);
> +		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
>  
>  		/* write lock already acquired */
>  		if (curr_active)
