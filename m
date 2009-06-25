From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: A small fix to davinci_emac driver
Date: Thu, 25 Jun 2009 06:34:38 -0700
Message-ID: <87ocscsahd.fsf@deeprootsystems.com>
References: <028901c9f54b$4579eae0$d06dc0a0$@com>
	<B85A65D85D7EB246BE421B3FB0FBB59301D829C4CE@dbde02.ent.ti.com>
	<7448ec710906250613p5fde8b44s24842a32e42dce37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Nori\, Sekhar" <nsekhar@ti.com>, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Pablo Bitton <pablo.bitton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f190.google.com ([209.85.216.190]:63543 "EHLO
	mail-px0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbZFYNei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 09:34:38 -0400
Received: by pxi28 with SMTP id 28so1035043pxi.33
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 06:34:41 -0700 (PDT)
In-Reply-To: <7448ec710906250613p5fde8b44s24842a32e42dce37@mail.gmail.com> (Pablo Bitton's message of "Thu\, 25 Jun 2009 16\:13\:59 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Bitton <pablo.bitton@gmail.com> writes:

> Hello all,
>
> I have attached a small fix for the following problem:
> When davinci_emac interface is down, changing MAC address results in
> kernel oops, due to NULL pointer dereference.

This should go linux-net after a signoff from Sekhar or Chaithrika.

> I apologize for not inlining the patch into the message (since GMail
> is the only web client I can use, and it does not allow me to inline
> it correctly).

You can send via Gmail using git-send-email directly.  Read this:

  http://git.or.cz/gitwiki/GitTips#Mail

Kevin


> Remarks are welcomed.
>
> Thanks in advance.
>
> On Thu, Jun 25, 2009 at 11:31 AM, Nori, Sekhar<nsekhar@ti.com> wrote:
>>
>> Pablo,
>>
>> Chaithrika's mails to gmail.com are bouncing, so I am replying
>> on her behalf.
>>
>> "
>> You are right there is indeed an issue. We looked at other
>> drivers and found that this is solved by checking for netif_running
>> to be true before going ahead and setting the mac address. Have a
>> look at how this is done in tg3.c driver
>>
>> http://git.kernel.org/?p=linux/kernel/git/khilman/linux-davinci.git;a=blob;f=drivers/net/tg3.c;h=201be425643a6fb7acb8801bbbb718897c9a6431;hb=35265abf67337f57a023ffeae5f4c492e7f8ea24#l6589
>> "
>>
>> Can you please go ahead and submit a fix for this to netdev
>> mailing list and CC linux-davinci ML?
>>
>> Thanks,
>> Sekhar
>>
>>> -----Original Message-----
>>> From: Pablo Bitton [mailto:pablo.bitton@gmail.com]
>>> Sent: Wednesday, June 24, 2009 7:13 PM
>>> To: Subrahmanya, Chaithrika
>>> Subject: A small fix to davinci_emac driver
>>>
>>> Hello,
>>>
>>> In drivers/net/davinci_emac.c file, at emac_dev_setmac_addr() function, rxch
>>> is NULL when DaVinci EMAC is down (using "ifconfig eth0 down").
>>>
>>> So when MAC address is changed using "ifconfig eth0 hw ether
>>> 00:11:22:33:44:55",
>>> emac_dev_setmac_addr() performs an illegal access to rxch->mac_addr, which
>>> causes a kernel oops.
>>>
>>> In order to fix this situation, the attached patch is applied (I've couldn't
>>> inline it correctly into GMail).
>>> Remarks are welcomed.
>>>
>>> Thanks in advance.
>>
>
> From ae9480af26eba3302614ea3d92077a80341cd190 Mon Sep 17 00:00:00 2001
> From: Pablo Bitton <pablo.bitton@gmail.com>
> Date: Tue, 23 Jun 2009 15:45:43 +0300
> Subject: [PATCH] davinci_emac: fix kernel oops when changing MAC address while interface is down
>
> rxch == NULL when DaVinci EMAC is down (using "ifconfig eth0 down").
> So when MAC address is changed using "ifconfig eth0 hw ether 00:11:22:33:44:55",
> emac_dev_setmac_addr() performs an illegal access to rxch->mac_addr, which
> causes a kernel oops.
>
> Signed-off-by: Pablo Bitton <pablo.bitton@gmail.com>
> ---
>  drivers/net/davinci_emac.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index cf689a0..cd114d9 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1823,9 +1823,14 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
>  
>  	/* Store mac addr in priv and rx channel and set it in EMAC hw */
>  	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
> -	memcpy(rxch->mac_addr, sa->sa_data, ndev->addr_len);
>  	memcpy(ndev->dev_addr, sa->sa_data, ndev->addr_len);
> -	emac_setmac(priv, EMAC_DEF_RX_CH, rxch->mac_addr);
> +
> +	/* If the interface is down - rxch is NULL. */
> +	/* MAC address is configured only after the interface is enabled. */
> +	if (netif_running(ndev)) {
> +		memcpy(rxch->mac_addr, sa->sa_data, ndev->addr_len);
> +		emac_setmac(priv, EMAC_DEF_RX_CH, rxch->mac_addr);
> +	}
>  
>  	if (netif_msg_drv(priv))
>  		dev_notice(emac_dev, "DaVinci EMAC: emac_dev_setmac_addr %s\n",
> -- 
> 1.5.4.3
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
