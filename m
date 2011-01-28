From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/2] net/netlabel: Avoid call to genlmsg_cancel
Date: Fri, 28 Jan 2011 10:46:51 -0500
Message-ID: <1296229611.5511.15.camel@sifl>
References: <1296224232-8115-2-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296224232-8115-2-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-28 at 15:17 +0100, Julia Lawall wrote:
> genlmsg_cancel subtracts some constants from its second argument before
> calling nlmsg_cancel.  nlmsg_cancel then calls nlmsg_trim on the same
> arguments.  nlmsg_trim tests for NULL before doing any computation, but a
> NULL second argument to genlmsg_cancel is no longer NULL due to the initial
> subtraction.  Nothing else happens in this execution, so the call to
> genlmsg_cancel is simply unnecessary in this case.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression data;
> @@
> 
> if (data == NULL) { ...
> * genlmsg_cancel(..., data);
>   ...
>   return ...;
> }
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_cipso_v4.c  |    2 +-
>  net/netlabel/netlabel_mgmt.c      |    4 ++--
>  net/netlabel/netlabel_unlabeled.c |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
> index 5f14c84..0a1f77b 100644
> --- a/net/netlabel/netlabel_cipso_v4.c
> +++ b/net/netlabel/netlabel_cipso_v4.c
> @@ -635,7 +635,7 @@ static int netlbl_cipsov4_listall_cb(struct cipso_v4_doi *doi_def, void *arg)
>  			   cb_arg->seq, &netlbl_cipsov4_gnl_family,
>  			   NLM_F_MULTI, NLBL_CIPSOV4_C_LISTALL);
>  	if (data == NULL)
> -		goto listall_cb_failure;
> +		return ret_val;
>  
>  	ret_val = nla_put_u32(cb_arg->skb, NLBL_CIPSOV4_A_DOI, doi_def->doi);
>  	if (ret_val != 0)
> diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
> index 998e85e..daaa01d 100644
> --- a/net/netlabel/netlabel_mgmt.c
> +++ b/net/netlabel/netlabel_mgmt.c
> @@ -452,7 +452,7 @@ static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
>  			   cb_arg->seq, &netlbl_mgmt_gnl_family,
>  			   NLM_F_MULTI, NLBL_MGMT_C_LISTALL);
>  	if (data == NULL)
> -		goto listall_cb_failure;
> +		return ret_val;
>  
>  	ret_val = netlbl_mgmt_listentry(cb_arg->skb, entry);
>  	if (ret_val != 0)
> @@ -617,7 +617,7 @@ static int netlbl_mgmt_protocols_cb(struct sk_buff *skb,
>  			   &netlbl_mgmt_gnl_family, NLM_F_MULTI,
>  			   NLBL_MGMT_C_PROTOCOLS);
>  	if (data == NULL)
> -		goto protocols_cb_failure;
> +		return ret_val;
>  
>  	ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, protocol);
>  	if (ret_val != 0)
> diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
> index e2b0a68..b5d3945 100644
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -1141,7 +1141,7 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
>  			   cb_arg->seq, &netlbl_unlabel_gnl_family,
>  			   NLM_F_MULTI, cmd);
>  	if (data == NULL)
> -		goto list_cb_failure;
> +		return ret_val;
>  
>  	if (iface->ifindex > 0) {
>  		dev = dev_get_by_index(&init_net, iface->ifindex);
> 

-- 
paul moore
linux @ hp
