From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: fix error handling if slave is busy
Date: Sat, 31 Dec 2011 17:11:05 +0100
Message-ID: <4EFF3419.4050504@gmail.com>
References: <20111230144023.371be015@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44770 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab1LaQKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 11:10:50 -0500
Received: by werm1 with SMTP id m1so6933679wer.19
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2011 08:10:49 -0800 (PST)
In-Reply-To: <20111230144023.371be015@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/12/2011 23:40, Stephen Hemminger a =E9crit :
> The bonding device can cause kernel panic in the enslave error handli=
ng.
>
> If slave device already has a receive handler registered, then the
> error unwind does not clear the new entry out of the slave list.
> This ends up leaving a reference to freed memory in the bond
> device slave linked list.
>
> The following is a simple example:
> # modprobe dummy
> # ip li add dummy0-1 link dummy0 type macvlan
> # modprobe bonding
> # echo +dummy0>/sys/class/net/bond0/bonding/slaves
> # ip -s li show dev bond0
>
> This returns with -EBUSY, but the bonding device has bogus entry in
> the slave list, and will panic on next operation that gets statistics
> from bond0.
>
> The fix is to detach the slave (which removes it from the list)
> in the unwind path.
>
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>
> ---
> Patch is against net-next but should be applied to net (3.2), and
> stable (3.1 and 3.0).
>
> --- a/drivers/net/bonding/bond_main.c	2011-12-30 14:20:03.171823181 -=
0800
> +++ b/drivers/net/bonding/bond_main.c	2011-12-30 14:20:20.232020474 -=
0800
> @@ -1853,6 +1853,9 @@ err_dest_symlinks:
>   	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>
>   err_close:
> +	write_lock_bh(&bond->lock);
> +	bond_detach_slave(bond, new_slave);
> +	write_unlock_bh(&bond->lock);
>   	dev_close(slave_dev);
>
>   err_unset_master:

NAK.

There are three 'goto err_close' before the call to bond_attach_slave. =
=46or those three goto, your=20
path will call bond_detach_slave without a previous call to bond_attach=
_slave.

This would at least decrement bond->slave_cnt, without having increment=
ed it before.

Do I miss something ?

	Nicolas.
