From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3 nf] netfilter: seqadj: Fix one possible panic in
 seqadj when mem is exhausted
Date: Mon, 5 Sep 2016 20:36:01 +0200
Message-ID: <20160905183601.GA4845@salvia>
References: <1472903510-16652-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, fw@strlen.de,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472903510-16652-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 03, 2016 at 07:51:50PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
> extension. But the function nf_ct_seqadj_init doesn't check if get valid
> seqadj pointer by the nfct_seqadj, while other functions perform the
> sanity check.
> 
> So the system would be panic when nfct_seqadj_ext_add failed.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Remove the warning log when seqadj is null;
>  v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
>  v1: Initial patch
> 
>  net/netfilter/nf_conntrack_seqadj.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index dff0f0c..7f8d814 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -16,9 +16,12 @@ int nf_ct_seqadj_init(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
>  	if (off == 0)
>  		return 0;
>  
> +	seqadj = nfct_seqadj(ct);
> +	if (unlikely(!seqadj))
> +		return 0;

I think we should handle this from init_conntrack() by simply dropping
the packet as we do under similar circunstances (too stress to deal).
