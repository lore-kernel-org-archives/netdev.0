From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 09 Jul 2014 09:10:37 +0200
Message-ID: <1404889837.3515.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:36189 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaGIHKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 03:10:43 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so6984212wes.17
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 00:10:41 -0700 (PDT)
In-Reply-To: <1404868198-24839-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-08 at 18:09 -0700, Mahesh Bandewar wrote:
> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
> group are selected based on the hash distribution. This does not
> exclude dead links which are part of the bond. Also if there is a
> temporary link event which brings down the interface, packets
> hashed on that interface would be dropped too.
> 
> This patch fixes these issues and distributes flows across the
> UP links only. Also the array construction of links which are
> capable of sending packets happen in the control path leaving
> only link-selection duing the data-path.

s/duing/during/

Seems a speed improvement as well for bonding of 8 slaves ;)

> 
> One possible side effect of this is - at a link event; all
> flows will be shuffled to get good distribution. But impact of
> this should be minimum with the assumption that a member or
> members of the bond group are not available is a very temporary
> situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_alb.c | 52 +++++++++++++++++++++++++++++++++++++-----
>  drivers/net/bonding/bond_alb.h | 11 +++++++++
>  drivers/net/bonding/bonding.h  |  6 +++++
>  3 files changed, 63 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 76c0dade233f..1f39d41fde4b 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -195,6 +195,9 @@ static int tlb_initialize(struct bonding *bond)
>  
>  	_unlock_tx_hashtbl_bh(bond);
>  
> +	/* Initialize the TLB array spin-lock */
> +	spin_lock_init(&bond_info->slave_arr_lock);
> +
>  	return 0;
>  }
>  
> @@ -209,6 +212,9 @@ static void tlb_deinitialize(struct bonding *bond)
>  	bond_info->tx_hashtbl = NULL;
>  
>  	_unlock_tx_hashtbl_bh(bond);
> +
> +	if (bond_is_nondyn_tlb(bond) && bond_info->slave_arr)
> +		kfree_rcu(bond_info->slave_arr, rcu);

You could remove the first condition, as slave_arr being NULL or not is
enough to take the decision to call kfree_rcu()

I do not know if a the "bond_is_nondyn_tlb(bond)" can change over the
time for a given bonding device, so feel uncomfortable with a possible
memleak here.
