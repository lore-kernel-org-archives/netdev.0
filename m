From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix panic on non-ARPHRD_ETHER enslave
 failure
Date: Sat, 7 Nov 2015 02:31:14 +0100
Message-ID: <563D5462.1040907@cumulusnetworks.com>
References: <9700.1446859403@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38171 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbbKGBbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 20:31:17 -0500
Received: by wicll6 with SMTP id ll6so38315067wic.1
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 17:31:16 -0800 (PST)
In-Reply-To: <9700.1446859403@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2015 02:23 AM, Jay Vosburgh wrote:
> 	Since commit 7d5cd2ce529b, when bond_enslave fails on devices that
> are not ARPHRD_ETHER, if needed, it resets the bonding device back to
> ARPHRD_ETHER by calling ether_setup.
> 
> 	Unfortunately, ether_setup clobbers dev->flags, clearing IFF_UP
> if the bond device is up, leaving it in a quasi-down state without
> having actually gone through dev_close.  For bonding, if any periodic
> work queue items are active (miimon, arp_interval, etc), those will
> remain running, as they are stopped by bond_close.  At this point, if
> the bonding module is unloaded or the bond is deleted, the system will
> panic when the work function is called.
> 
> 	This panic is resolved by calling dev_close on the bond itself
> prior to calling ether_setup.
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> Fixes: 7d5cd2ce5292 ("bonding: correctly handle bonding type change on enslave failure")
> 
> ---
>  drivers/net/bonding/bond_main.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b4351ca..9e0f8a7 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1749,6 +1749,7 @@ err_undo_flags:
>  					    slave_dev->dev_addr))
>  			eth_hw_addr_random(bond_dev);
>  		if (bond_dev->type != ARPHRD_ETHER) {
> +			dev_close(bond_dev);
>  			ether_setup(bond_dev);
>  			bond_dev->flags |= IFF_MASTER;
>  			bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
> 

Oh, I've missed it. Very good catch!

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks,
 Nik
 
