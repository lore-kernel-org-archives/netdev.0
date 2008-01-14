From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Mon, 14 Jan 2008 23:15:47 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801142314340.26034@bizon.gios.gov.pl>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
 <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death>
 <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death>
 <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death>
 <20080109201709.GF8728@gospo.usersys.redhat.com>
 <Pine.LNX.4.64.0801121150001.16465@bizon.gios.gov.pl> <18609.1200160598@death>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1383237924-1200348947=:26034"
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:47689 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756829AbYANWWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:22:17 -0500
In-Reply-To: <18609.1200160598@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1383237924-1200348947=:26034
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 12 Jan 2008, Jay Vosburgh wrote:

> Krzysztof Oledzki <olel@ans.pl> wrote:
> [...]
>> Exactly. All I need to do is to reboot my server, I have 100% probabilit=
y
>> to get the warning.
>
> =09I wish it were that easy for me; I'm not sure what magic thing
> you've got on your server or network that I don't, but I haven't been
> able to make this lockdep warning happen at all.
>
>> Right. So, what is the final patch? I would like to test it if that's
>> possible. ;)
>
> =09Can you test the following and let me know if it triggers the
> warning?  I believe this is the minimum locking needed, and based on
> input from Herbert, we shouldn't need to hold the lock at _bh.  If this
> one works, and nobody sees any other issues with it, then it's the final
> patch for this lockdep problem.  I'll add some deep, meaningful comments
> to explain the locking a bit (i.e., we're called with rtnl for the
> allmulti and promisc cases, so we're ok there without additional locks,
> but the later code could be called from anywhere, so it needs locks to
> prevent the slave list from changing, but the mc_lists themselves are
> covered by the netif_tx_lock that all callers will hold), but this would
> be the actual code change.
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_m=
ain.c
> index 77d004d..6906dbc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3937,8 +3937,6 @@ static void bond_set_multicast_list(struct net_devi=
ce *bond_dev)
> =09struct bonding *bond =3D bond_dev->priv;
> =09struct dev_mc_list *dmi;
>
> -=09write_lock_bh(&bond->lock);
> -
> =09/*
> =09 * Do promisc before checking multicast_mode
> =09 */
> @@ -3959,6 +3957,8 @@ static void bond_set_multicast_list(struct net_devi=
ce *bond_dev)
> =09=09bond_set_allmulti(bond, -1);
> =09}
>
> +=09read_lock(&bond->lock);
> +
> =09bond->flags =3D bond_dev->flags;
>
> =09/* looking for addresses to add to slaves' mc list */
> @@ -3979,7 +3979,7 @@ static void bond_set_multicast_list(struct net_devi=
ce *bond_dev)
> =09bond_mc_list_destroy(bond);
> =09bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
>
> -=09write_unlock_bh(&bond->lock);
> +=09read_unlock(&bond->lock);
> }
>
> /*
>
>

I can confirm that the warning went away.

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1383237924-1200348947=:26034--
