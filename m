From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH/RFC net-next 8/9] nfp: add a stats handler for flower
 offloads
Date: Tue, 27 Jun 2017 23:17:52 -0700
Message-ID: <20170627231752.3de880c4@cakuba.netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
        <1498605709-22574-9-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35229 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751312AbdF1GRz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 02:17:55 -0400
Received: by mail-pf0-f180.google.com with SMTP id c73so28135601pfk.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:17:55 -0700 (PDT)
In-Reply-To: <1498605709-22574-9-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 01:21:48 +0200, Simon Horman wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Previously there was no way of updating flow rule stats after they
> have been offloaded to hardware. This is solved by keeping track of
> stats received from hardware and providing this to the TC handler
> on request.
> 
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/netronome/nfp/flower/main.h   |  26 ++++
>  .../net/ethernet/netronome/nfp/flower/metadata.c   | 143 ++++++++++++++++++++-
>  .../net/ethernet/netronome/nfp/flower/offload.c    |  14 +-
>  drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
>  4 files changed, 181 insertions(+), 3 deletions(-)

> +void nfp_flower_populate_stats(struct nfp_fl_payload *nfp_flow)
> +{
> +	spin_lock(&nfp_flow->lock_nfp_flow_stats);
> +	nfp_flow->stats.pkts = 0;
> +	nfp_flow->stats.bytes = 0;
> +	nfp_flow->stats.used = jiffies;
> +	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
> +}

This could be static AFAICT.

> +void nfp_flower_stats_clear(struct nfp_fl_payload *nfp_flow)
> +{
> +	spin_lock(&nfp_flow->lock_nfp_flow_stats);
> +	nfp_flow->stats.pkts = 0;
> +	nfp_flow->stats.bytes = 0;
> +	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
> +}
> +
> +static void
> +nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
> +{
> +	struct nfp_fl_payload *nfp_flow;
> +	unsigned long flower_cookie;
> +
> +	flower_cookie = be64_to_cpu(stats->stats_cookie);
> +
> +	nfp_flow = nfp_flower_find_in_fl_table(app, flower_cookie);

Since you're looking up in the hash table from softirq context and
with RTNL held, I think you need RCU protection.

My understanding is that the mask table is ever only modified with RTNL
held so it needs no protection.  The only thing that may come in
without RTNL is a ctrl message carrying stat updates.  It will try to
lookup the flow and increment its statistics.  So the use-after-free on
statistics is the only danger we may run into here? (or accessing
inconsistent hashtable)

> +	if (!nfp_flow)
> +		return;
> +
> +	if (nfp_flow->meta.host_ctx_id != stats->stats_con_id)
> +		return;
> +
> +	spin_lock(&nfp_flow->lock_nfp_flow_stats);
> +	nfp_flow->stats.pkts += be32_to_cpu(stats->pkt_count);
> +	nfp_flow->stats.bytes += be64_to_cpu(stats->byte_count);
> +	nfp_flow->stats.used = jiffies;
> +	spin_unlock(&nfp_flow->lock_nfp_flow_stats);
> +}
> +
> +void nfp_flower_rx_flow_stats(struct nfp_app *app, struct sk_buff *skb)
> +{
> +	unsigned int msg_len = skb->len - NFP_FLOWER_CMSG_HLEN;
> +	struct nfp_fl_stats_frame *stats_frame;
> +	unsigned char *msg;
> +	int msg_offset = 0;
> +
> +	msg = (unsigned char *)skb->data + NFP_FLOWER_CMSG_HLEN;

nfp_flower_cmsg_get_data()?

Or simply skb_pull() the header off before you invoke specific
handlers in nfp_flower_cmsg_rx()?

> +
> +	while (msg_len >= sizeof(struct nfp_fl_stats_frame)) {
> +		stats_frame = (struct nfp_fl_stats_frame *)msg + msg_offset;

Looks suspicious.  msg_offset counts bytes and you add it to a typed
pointer...

> +		if (!stats_frame)
> +			break;

This looks strange too, can stats_frame ever be NULL?

I think this loop may be better written as:

stats_frame = msg;

for (i = 0; i < msg_len / sizeof(*stats_frame); i++)
	nfp_flower_update_stats(&stats_frame[i] or stats_frame + i);

> +		nfp_flower_update_stats(app, stats_frame);
> +
> +		msg_offset += sizeof(struct nfp_fl_stats_frame);
> +		msg_len -= sizeof(struct nfp_fl_stats_frame);
> +	}
> +}
> +
>  static struct nfp_flower_table *
>  nfp_flower_search_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
>  {

> diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> index a7f688bbc761..b39c96623657 100644
> --- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> @@ -171,6 +171,7 @@ nfp_flower_allocate_new(struct nfp_fl_key_ls *key_layer)
>  		goto err_free_mask;
>  
>  	flow_pay->meta.flags = 0;
> +	spin_lock_init(&flow_pay->lock_nfp_flow_stats);
>  
>  	return flow_pay;
>  
> @@ -294,7 +295,18 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
>  static int
>  nfp_flower_get_stats(struct nfp_app *app, struct tc_cls_flower_offload *flow)
>  {
> -	return -EOPNOTSUPP;
> +	struct nfp_fl_payload *nfp_flow;
> +
> +	nfp_flow = nfp_flower_find_in_fl_table(app, flow->cookie);
> +	if (!nfp_flow)
> +		return -EINVAL;
> +
> +	tcf_exts_stats_update(flow->exts, nfp_flow->stats.bytes,
> +			      nfp_flow->stats.pkts, nfp_flow->stats.used);

So the spin_locks are only taken for writes but not for reads?

> +
> +	nfp_flower_stats_clear(nfp_flow);
> +
> +	return 0;
>  }
>  
>  static int
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> index b1fa77bd708b..cfd74ce36797 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
> @@ -466,6 +466,7 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
>  struct nfp_stat_pair {
>  	u64 pkts;
>  	u64 bytes;
> +	u64 used;
>  };

This is called *_pair, please don't add a third member to this
structure, just define your own :)
