From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v4 2/8] netfilter: Factor out nf_ct_get_info().
Date: Thu, 10 Dec 2015 20:14:41 +0100
Message-ID: <20151210191441.GA20536@salvia>
References: <1449622870-48944-1-git-send-email-jarno@ovn.org>
 <1449622870-48944-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56781 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbbLJTOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 14:14:45 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8ECF612925D
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 20:14:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7FF5CDA795
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 20:14:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id ACBC1DA795
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 20:14:42 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1449622870-48944-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 05:01:04PM -0800, Jarno Rajahalme wrote:
> Define a new inline function to map conntrack status to enum
> ip_conntrack_info.  This removes the need to otherwise duplicate this
> code in a later patch ("openvswitch: Find existing conntrack entry
> after upcall.").
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
>  net/netfilter/nf_conntrack_core.c    | 22 +++-------------------
>  2 files changed, 18 insertions(+), 19 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
> index fde4068..b3de10e 100644
> --- a/include/net/netfilter/nf_conntrack.h
> +++ b/include/net/netfilter/nf_conntrack.h
> @@ -125,6 +125,21 @@ nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
>  			    tuplehash[hash->tuple.dst.dir]);
>  }
>  
> +static inline enum ip_conntrack_info
> +nf_ct_get_info(const struct nf_conntrack_tuple_hash *h)
> +{
> +	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
> +
> +	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
> +		return IP_CT_ESTABLISHED_REPLY;
> +	/* Once we've had two way comms, always ESTABLISHED. */
> +	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
> +		return IP_CT_ESTABLISHED;
> +	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
> +		return IP_CT_RELATED;
> +	return IP_CT_NEW;
> +}
> +
>  static inline u_int16_t nf_ct_l3num(const struct nf_conn *ct)
>  {
>  	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 3cb3cb8..70ddbd8 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1056,25 +1056,9 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
>  	ct = nf_ct_tuplehash_to_ctrack(h);
>  
>  	/* It exists; we have (non-exclusive) reference. */
> -	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY) {
> -		*ctinfo = IP_CT_ESTABLISHED_REPLY;
> -		/* Please set reply bit if this packet OK */
> -		*set_reply = 1;
> -	} else {
> -		/* Once we've had two way comms, always ESTABLISHED. */
> -		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
> -			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);

This implicitly assumes we don't want pr_debug for nf_conntrack
anymore. Not telling this is wrong, but we have more pr_debug() calls
in nf_conntrack that will remain there.
