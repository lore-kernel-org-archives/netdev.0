From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net] net: bonding: fix tlb_dynamic_lb default value
Date: Tue, 12 Sep 2017 10:40:44 -0700
Message-ID: <CAF2d9jgwYYBYGGEyGnUmhR8rf4x0K6iJiUY5SkCC-hrgTbQgsA@mail.gmail.com>
References: <1505218205-2637-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:33006 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751435AbdILRlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 13:41:05 -0400
Received: by mail-yw0-f178.google.com with SMTP id s62so29835646ywg.0
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 10:41:05 -0700 (PDT)
In-Reply-To: <1505218205-2637-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 5:10 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> Commit 8b426dc54cf4 ("bonding: remove hardcoded value") changed the
> default value for tlb_dynamic_lb which lead to either broken ALB mode
> (since tlb_dynamic_lb can be changed only in TLB) or setting TLB mode
> with tlb_dynamic_lb equal to 0.
> The first issue was recently fixed by setting tlb_dynamic_lb to 1 always
> when switching to ALB mode, but the default value is still wrong and
> we'll enter TLB mode with tlb_dynamic_lb equal to 0 if the mode is
> changed via netlink or sysfs. In order to restore the previous behaviour
> and default value simply remove the mode check around the default param
> initialization for tlb_dynamic_lb which will always set it to 1 as
> before.
>
> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index fc63992ab0e0..c99dc59d729b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4289,7 +4289,7 @@ static int bond_check_params(struct bond_params *params)
>         int bond_mode   = BOND_MODE_ROUNDROBIN;
>         int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
>         int lacp_fast = 0;
> -       int tlb_dynamic_lb = 0;
> +       int tlb_dynamic_lb;
>
>         /* Convert string parameters. */
>         if (mode) {
> @@ -4601,16 +4601,13 @@ static int bond_check_params(struct bond_params *params)
>         }
>         ad_user_port_key = valptr->value;
>
> -       if ((bond_mode == BOND_MODE_TLB) || (bond_mode == BOND_MODE_ALB)) {
> -               bond_opt_initstr(&newval, "default");
> -               valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB),
> -                                       &newval);
> -               if (!valptr) {
> -                       pr_err("Error: No tlb_dynamic_lb default value");
> -                       return -EINVAL;
> -               }
> -               tlb_dynamic_lb = valptr->value;
> +       bond_opt_initstr(&newval, "default");
> +       valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB), &newval);
> +       if (!valptr) {
> +               pr_err("Error: No tlb_dynamic_lb default value");
> +               return -EINVAL;
>         }
> +       tlb_dynamic_lb = valptr->value;
>
>         if (lp_interval == 0) {
>                 pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
> --
> 2.1.4
>
