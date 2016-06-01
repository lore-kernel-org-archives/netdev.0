From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Wed, 1 Jun 2016 15:00:08 -0700
Message-ID: <CALgkqUq5nedx+wjEur9WVjvYr0pzvL7CMQmHiVtuuB_1PtOZ2Q@mail.gmail.com>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
	<1464811430-19415-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34571 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbcFAWAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 18:00:09 -0400
Received: by mail-io0-f193.google.com with SMTP id l9so4260577ioe.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 15:00:09 -0700 (PDT)
In-Reply-To: <1464811430-19415-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 1:03 PM, Phil Sutter <phil@nwl.cc> wrote:
> Not sure whether I misinterpret commit 7b8179c780a1a, but it looks
> overly complicated. Instead rely upon parse_rtattr_nested() to assign
> the relevant pointer if requested rtattr fields are present.

I'm not sure if newer iproute2 utilities are supposed to work on older
kernels but if it is you may want to check this against a 2.6.32
kernel.

- Greg Rose

>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipaddress.c | 44 ++++++++++----------------------------------
>  1 file changed, 10 insertions(+), 34 deletions(-)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index df363b070d5de..9ac077459f136 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -305,10 +305,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>         struct ifla_vf_mac *vf_mac;
>         struct ifla_vf_vlan *vf_vlan;
>         struct ifla_vf_tx_rate *vf_tx_rate;
> -       struct ifla_vf_spoofchk *vf_spoofchk;
> -       struct ifla_vf_link_state *vf_linkstate;
>         struct rtattr *vf[IFLA_VF_MAX + 1] = {};
> -       struct rtattr *tmp;
>
>         SPRINT_BUF(b1);
>
> @@ -323,31 +320,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>         vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
>         vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
>
> -       /* Check if the spoof checking vf info type is supported by
> -        * this kernel.
> -        */
> -       tmp = (struct rtattr *)((char *)vf[IFLA_VF_TX_RATE] +
> -                               vf[IFLA_VF_TX_RATE]->rta_len);
> -
> -       if (tmp->rta_type != IFLA_VF_SPOOFCHK)
> -               vf_spoofchk = NULL;
> -       else
> -               vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
> -
> -       if (vf_spoofchk) {
> -               /* Check if the link state vf info type is supported by
> -                * this kernel.
> -                */
> -               tmp = (struct rtattr *)((char *)vf[IFLA_VF_SPOOFCHK] +
> -                                       vf[IFLA_VF_SPOOFCHK]->rta_len);
> -
> -               if (tmp->rta_type != IFLA_VF_LINK_STATE)
> -                       vf_linkstate = NULL;
> -               else
> -                       vf_linkstate = RTA_DATA(vf[IFLA_VF_LINK_STATE]);
> -       } else
> -               vf_linkstate = NULL;
> -
>         fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
>                 ll_addr_n2a((unsigned char *)&vf_mac->mac,
>                             ETH_ALEN, 0, b1, sizeof(b1)));
> @@ -366,14 +338,18 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>                 if (vf_rate->min_tx_rate)
>                         fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
>         }
> +       if (vf[IFLA_VF_SPOOFCHK]) {
> +               struct ifla_vf_spoofchk *vf_spoofchk =
> +                       RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
>
> -       if (vf_spoofchk && vf_spoofchk->setting != -1) {
> -               if (vf_spoofchk->setting)
> -                       fprintf(fp, ", spoof checking on");
> -               else
> -                       fprintf(fp, ", spoof checking off");
> +               if (vf_spoofchk->setting != -1)
> +                       fprintf(fp, ", spoof checking %s",
> +                               vf_spoofchk->setting ? "on" : "off");
>         }
> -       if (vf_linkstate) {
> +       if (vf[IFLA_VF_LINK_STATE]) {
> +               struct ifla_vf_link_state *vf_linkstate =
> +                       RTA_DATA(vf[IFLA_VF_LINK_STATE]);
> +
>                 if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_AUTO)
>                         fprintf(fp, ", link-state auto");
>                 else if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_ENABLE)
> --
> 2.8.2
>
