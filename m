From: Greg <gvrose8192@gmail.com>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Tue, 08 Nov 2016 15:05:31 -0800
Message-ID: <1478646331.8250.1.camel@gmail.com>
References: <20161108212912.27258-1-phil@nwl.cc>
         <20161108212912.27258-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36480 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcKHXFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 18:05:34 -0500
Received: by mail-pf0-f193.google.com with SMTP id n85so21099797pfi.3
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 15:05:34 -0800 (PST)
In-Reply-To: <20161108212912.27258-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-08 at 22:29 +0100, Phil Sutter wrote:
> Commit 7b8179c780a1a ("iproute2: Add new command to ip link to
> enable/disable VF spoof check") tried to add support for
> IFLA_VF_SPOOFCHK in a backwards-compatible manner, but aparently overdid
> it: parse_rtattr_nested() handles missing attributes perfectly fine in
> that it will leave the relevant field unassigned so calling code can
> just compare against NULL. There is no need to layback from the previous
> (IFLA_VF_TX_RATE) attribute to the next to check if IFLA_VF_SPOOFCHK is
> present or not. To the contrary, it establishes a potentially incorrect
> assumption of these two attributes directly following each other which
> may not be the case (although up to now, kernel aligns them this way).
> 
> This patch cleans up the code to adhere to the common way of checking
> for attribute existence. It has been tested to return correct results
> regardless of whether the kernel exports IFLA_VF_SPOOFCHK or not.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipaddress.c | 44 ++++++++++----------------------------------
>  1 file changed, 10 insertions(+), 34 deletions(-)
> 
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 7f05258f43453..df0f1b9c94c58 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -322,10 +322,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>  {
>  	struct ifla_vf_mac *vf_mac;
>  	struct ifla_vf_tx_rate *vf_tx_rate;
> -	struct ifla_vf_spoofchk *vf_spoofchk;
> -	struct ifla_vf_link_state *vf_linkstate;
>  	struct rtattr *vf[IFLA_VF_MAX + 1] = {};
> -	struct rtattr *tmp;
>  
>  	SPRINT_BUF(b1);
>  
> @@ -339,31 +336,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>  	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
>  	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
>  
> -	/* Check if the spoof checking vf info type is supported by
> -	 * this kernel.
> -	 */
> -	tmp = (struct rtattr *)((char *)vf[IFLA_VF_TX_RATE] +
> -				vf[IFLA_VF_TX_RATE]->rta_len);
> -
> -	if (tmp->rta_type != IFLA_VF_SPOOFCHK)
> -		vf_spoofchk = NULL;
> -	else
> -		vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
> -
> -	if (vf_spoofchk) {
> -		/* Check if the link state vf info type is supported by
> -		 * this kernel.
> -		 */
> -		tmp = (struct rtattr *)((char *)vf[IFLA_VF_SPOOFCHK] +
> -					vf[IFLA_VF_SPOOFCHK]->rta_len);
> -
> -		if (tmp->rta_type != IFLA_VF_LINK_STATE)
> -			vf_linkstate = NULL;
> -		else
> -			vf_linkstate = RTA_DATA(vf[IFLA_VF_LINK_STATE]);
> -	} else
> -		vf_linkstate = NULL;
> -
>  	fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
>  		ll_addr_n2a((unsigned char *)&vf_mac->mac,
>  			    ETH_ALEN, 0, b1, sizeof(b1)));
> @@ -407,14 +379,18 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
>  		if (vf_rate->min_tx_rate)
>  			fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
>  	}
> +	if (vf[IFLA_VF_SPOOFCHK]) {
> +		struct ifla_vf_spoofchk *vf_spoofchk =
> +			RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
>  
> -	if (vf_spoofchk && vf_spoofchk->setting != -1) {
> -		if (vf_spoofchk->setting)
> -			fprintf(fp, ", spoof checking on");
> -		else
> -			fprintf(fp, ", spoof checking off");
> +		if (vf_spoofchk->setting != -1)
> +			fprintf(fp, ", spoof checking %s",
> +			        vf_spoofchk->setting ? "on" : "off");

I wrote some of this code at a time when I was pretty new to Linux
kernel net programming and I really just didn't understand it.  It
appears you're doing it more correctly than I.

Thanks for cleaning it up.

Reviewed-by: Greg Rose <grose@lightfleet.com>

- Greg

>  	}
> -	if (vf_linkstate) {
> +	if (vf[IFLA_VF_LINK_STATE]) {
> +		struct ifla_vf_link_state *vf_linkstate =
> +			RTA_DATA(vf[IFLA_VF_LINK_STATE]);
> +
>  		if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_AUTO)
>  			fprintf(fp, ", link-state auto");
>  		else if (vf_linkstate->link_state == IFLA_VF_LINK_STATE_ENABLE)
