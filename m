From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v4 net-next 02/12] bonding: permit using arp_validate
 with non-ab modes
Date: Mon, 17 Feb 2014 16:22:21 +0100
Message-ID: <5302292D.4050206@redhat.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com> <1392648088-21336-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567AbaBQP0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 10:26:54 -0500
In-Reply-To: <1392648088-21336-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2014 03:41 PM, Veaceslav Falico wrote:
> Currently it's disabled because it's sometimes hard, in typical configs, to
> make it work - because of the nature how the loadbalance modes work - as
> it's hard to deliver valid arp replies to correct slaves by the switch.
> 
> However we still can use arp_validation in loadbalance with several other
> configs, per example with arp_validate == 2 for backup with one broadcast
> domain, without the switch(es) doing any balancing - this way we'd be (a
> bit more) sure that the slave is up.
> 
> So, enable it to let users decide which one works/suits them best. Also
> remove the mode limitation from BOND_OPT_ARP_VALIDATE.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  Documentation/networking/bonding.txt | 6 +++---
>  drivers/net/bonding/bond_main.c      | 4 ----
>  drivers/net/bonding/bond_options.c   | 1 -
>  3 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
> index 5cdb229..96b4ad8 100644
> --- a/Documentation/networking/bonding.txt
> +++ b/Documentation/networking/bonding.txt
> @@ -270,9 +270,9 @@ arp_ip_target
>  arp_validate
>  
>  	Specifies whether or not ARP probes and replies should be
> -	validated in the active-backup mode.  This causes the ARP
> -	monitor to examine the incoming ARP requests and replies, and
> -	only consider a slave to be up if it is receiving the
> +	validated in any mode that supports arp monitoring.  This causes
> +	the ARP monitor to examine the incoming ARP requests and replies,
> +	and only consider a slave to be up if it is receiving the
>  	appropriate ARP traffic.
>  
>  	Possible values are:
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3c50bec..91c0248 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4183,10 +4183,6 @@ static int bond_check_params(struct bond_params *params)
>  	}
>  
>  	if (arp_validate) {
> -		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
> -			pr_err("arp_validate only supported in active-backup mode\n");
> -			return -EINVAL;
> -		}
>  		if (!arp_interval) {
>  			pr_err("arp_validate requires arp_interval\n");
>  			return -EINVAL;
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index f3eb44d..d566cab 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -151,7 +151,6 @@ static struct bond_option bond_opts[] = {
>  		.id = BOND_OPT_ARP_VALIDATE,
>  		.name = "arp_validate",
>  		.desc = "validate src/dst of ARP probes",
> -		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP)),
>  		.values = bond_arp_validate_tbl,
>  		.set = bond_option_arp_validate_set
>  	},
> 
Sorry for not noticing before, but I just remembered the reason why all the
checks are there when changing the recv_probe, especially from the options.
The problem was that lacp mode also uses the recv_probe, so after this patch we
can overwrite the recv_probe while it's running in lacp mode, because
bond_option_arp_validate_set changes the recv_probe. We can actually only set it
to NULL because arp_interval can't be set in those modes, but still we can break
the mode and there'll be need for at least down/up cycle to fix it.
I think rlb also uses the recv_probe so this applies to it as well.

Nik
