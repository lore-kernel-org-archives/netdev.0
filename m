From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 nf] netfilter: seqadj: Drop the packet directly when
 fail to add seqadj extension to avoid dereference NULL pointer later
Date: Tue, 6 Sep 2016 12:17:55 +0200
Message-ID: <20160906101755.GA2122@salvia>
References: <1473127043-20078-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, fw@strlen.de,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36308 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933088AbcIFKSD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 06:18:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id DC7772791A3
        for <netdev@vger.kernel.org>; Tue,  6 Sep 2016 12:18:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CE13B115101
        for <netdev@vger.kernel.org>; Tue,  6 Sep 2016 12:18:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E9A28FF134
        for <netdev@vger.kernel.org>; Tue,  6 Sep 2016 12:17:56 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1473127043-20078-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 09:57:23AM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
> extension. But the function nf_ct_seqadj_init doesn't check if get valid
> seqadj pointer by the nfct_seqadj.
> 
> Now drop the packet directly when fail to add seqadj extension to avoid
> dereference NULL pointer in nf_ct_seqadj_init.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v4: Drop the packet directly when fail to add seqadj extension;
>  v3: Remove the warning log when seqadj is null;
>  v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
>  v1: Initial patch
> 
>  net/netfilter/nf_conntrack_core.c | 6 +++++-
>  net/netfilter/nf_nat_core.c       | 3 ++-
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index dd2c43a..dfa76ce 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1036,7 +1036,11 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
>  		return (struct nf_conntrack_tuple_hash *)ct;
>  
>  	if (tmpl && nfct_synproxy(tmpl)) {
> -		nfct_seqadj_ext_add(ct);
> +		if (!nfct_seqadj_ext_add(ct)) {
> +			nf_conntrack_free(ct);
> +			pr_debug("Can't add seqadj extension\n");
> +			return NULL;
> +		}
>  		nfct_synproxy_ext_add(ct);

I think this is part of the same logical change, ie. nf_ct_ext_add()
returns NULL, then I would also fix nfct_synproxy_ext_add() in this
go.

>  	}
>  
> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> index de31818..b82282a 100644
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -441,7 +441,8 @@ nf_nat_setup_info(struct nf_conn *ct,
>  			ct->status |= IPS_DST_NAT;
>  
>  		if (nfct_help(ct))
> -			nfct_seqadj_ext_add(ct);
> +			if (!nfct_seqadj_ext_add(ct))
> +				return NF_DROP;

ctnetlink may have created a conntrack with seqadj in place by when we
call nf_nat_setup_info() so NF_ACCEPT would be more conservative, eg.
via conntrackd state synchronization.

Actually, after a quick look at ctnetlink, I don't see any any call to
nfct_seqadj_ext_add() from there, so I suspect this is broken since
SYNPROXY was introduced. It would be great if you can review this and
send us patches to fix this, if indeed needed.

Thanks!
