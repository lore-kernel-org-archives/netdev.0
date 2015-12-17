From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v5 2/8] netfilter: Factor out nf_ct_get_info().
Date: Thu, 17 Dec 2015 16:31:24 +0300
Message-ID: <5672B92C.1000903@cogentembedded.com>
References: <1450312607-44050-1-git-send-email-jarno@ovn.org>
 <1450312607-44050-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:36319 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934325AbbLQNb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 08:31:27 -0500
Received: by mail-lf0-f42.google.com with SMTP id z124so46927495lfa.3
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 05:31:26 -0800 (PST)
In-Reply-To: <1450312607-44050-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/17/2015 3:36 AM, Jarno Rajahalme wrote:

> Define a new inline function to map conntrack status to enum
> ip_conntrack_info.  This removes the need to otherwise duplicate this
> code in a later patch ("openvswitch: Find existing conntrack entry
> after upcall.").
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
[...]
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 3cb3cb8..7546fc7 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1056,25 +1056,15 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
>   	ct = nf_ct_tuplehash_to_ctrack(h);
>
>   	/* It exists; we have (non-exclusive) reference. */
> -	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY) {
> -		*ctinfo = IP_CT_ESTABLISHED_REPLY;
> -		/* Please set reply bit if this packet OK */
> -		*set_reply = 1;
> -	} else {
> -		/* Once we've had two way comms, always ESTABLISHED. */
> -		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
> -			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
> -			*ctinfo = IP_CT_ESTABLISHED;
> -		} else if (test_bit(IPS_EXPECTED_BIT, &ct->status)) {
> -			pr_debug("nf_conntrack_in: related packet for %p\n",
> -				 ct);
> -			*ctinfo = IP_CT_RELATED;
> -		} else {
> -			pr_debug("nf_conntrack_in: new packet for %p\n", ct);
> -			*ctinfo = IP_CT_NEW;
> -		}
> -		*set_reply = 0;
> -	}
> +	*ctinfo = nf_ct_get_info(h);
> +	if (*ctinfo == IP_CT_ESTABLISHED)
> +		pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
> +	else if (*ctinfo == IP_CT_RELATED)
> +		pr_debug("nf_conntrack_in: related packet for %p\n", ct);
> +	else if (*ctinfo == IP_CT_NEW)
> +		pr_debug("nf_conntrack_in: new packet for %p\n", ct);

    This is asking to be a *switch* statement...

[...]

MBR, Sergei
