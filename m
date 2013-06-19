From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 4/6] bonding: don't validate arp if we don't
 have to
Date: Thu, 20 Jun 2013 00:19:04 +0200
Message-ID: <51C22E58.5080209@redhat.com>
References: <1371663286-12518-5-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964822Ab3FSWTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 18:19:48 -0400
In-Reply-To: <1371663286-12518-5-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/13 19:34, Veaceslav Falico wrote:
> Currently, we validate all the incoming arps if arp_validate not 0.
> However, we don't have to validate backup slaves if arp_validate == active
> and vice versa, so return early in bond_arp_rcv() in these cases.
> 
> It works correctly now because we verify arp_validate in slave_last_rx(),
> however we're just doing useless work in bond_arp_rcv().
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b69c7f0..2cfbb2e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2624,6 +2624,10 @@ static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>  		return RX_HANDLER_ANOTHER;
>  
>  	read_lock(&bond->lock);
> +
> +	if (!slave_do_arp_validate(bond, slave))
> +		goto out_unlock;
> +
>  	alen = arp_hdr_len(bond->dev);
>  
>  	pr_debug("bond_arp_rcv: bond %s skb->dev %s\n",
Hm, I think this issue runs deeper because recv_probe can be wrong and
also if arp_validate is enabled while the bond is running then
recv_probe is not set (or unset for that matter if disabled). I have a
patch which needs little more work for some time now in my queue that
fixes this, but if you'd like to fix it I'd suggest addressing that
issue (recv_probe), because then you can just drop these checks and
improve performance when disabled (after it's been enabled).
This got a bit confusing when I read it :-)

Cheers,
 Nik
