From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 3/9] bonding: make BOND_NO_USES_ARP an inline function
Date: Thu, 15 May 2014 08:35:47 -0700
Message-ID: <CAADnVQKMKZ4dMvUXpCQiKc839+UTa7hjBh71WzADXD6vH1B48Q@mail.gmail.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
	<1400156967-8231-4-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:54618 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbaEOPfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 11:35:48 -0400
Received: by mail-qc0-f180.google.com with SMTP id i17so2035422qcy.25
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 08:35:47 -0700 (PDT)
In-Reply-To: <1400156967-8231-4-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 5:29 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> Also, change its name to better reflect its scope, and skip the "no"
> part.
>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c    |  2 +-
>  drivers/net/bonding/bond_options.c |  2 +-
>  drivers/net/bonding/bonding.h      | 11 ++++++-----
>  3 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5c88c11..2448e28 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4113,7 +4113,7 @@ static int bond_check_params(struct bond_params *params)
>         }
>
>         /* reset values for 802.3ad/TLB/ALB */
> -       if (BOND_NO_USES_ARP(bond_mode)) {
> +       if (!bond_mode_uses_arp(bond_mode)) {

looks like condition becomes inverted.
Did you mean to add '!' inside bond_mode_uses_arp() as well?

>                 if (!miimon) {
>                         pr_warn("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
>                         pr_warn("Forcing miimon to 100msec\n");
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index 6dc49da..98c8801 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -672,7 +672,7 @@ const struct bond_option *bond_opt_get(unsigned int option)
>
>  int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
>  {
> -       if (BOND_NO_USES_ARP(newval->value) && bond->params.arp_interval) {
> +       if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
>                 pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
>                         bond->dev->name, newval->string);
>                 /* disable arp monitoring */
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index dca3dfd..8f9f0df 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -60,11 +60,6 @@
>                  ((mode) == BOND_MODE_TLB)          ||  \
>                  ((mode) == BOND_MODE_ALB))
>
> -#define BOND_NO_USES_ARP(mode)                         \
> -               (((mode) == BOND_MODE_8023AD)   ||      \
> -                ((mode) == BOND_MODE_TLB)      ||      \
> -                ((mode) == BOND_MODE_ALB))
> -
>  #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)       \
>         ((htonl(INADDR_BROADCAST) == a) ||      \
>          ipv4_is_zeronet(a))
> @@ -292,6 +287,12 @@ static inline bool bond_is_lb(const struct bonding *bond)
>                bond->params.mode == BOND_MODE_ALB;
>  }
>
> +static inline bool bond_mode_uses_arp(int mode)
> +{
> +       return mode == BOND_MODE_8023AD || mode == BOND_MODE_TLB ||
> +              mode == BOND_MODE_ALB;
> +}
> +
>  static inline void bond_set_active_slave(struct slave *slave)
>  {
>         if (slave->backup) {
> --
> 1.8.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
