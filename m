From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next 1/3] RDS-TCP: Make RDS-TCP work correctly
 when it is set up in a netns other than init_net
Date: Thu, 30 Jul 2015 11:03:13 -0600
Message-ID: <55BA58D1.3050108@gmail.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com> <89cdf26d7506a1d2d1a2d6cfda2fab9a5fc84ad6.1438245718.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33389 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbbG3RDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:03:19 -0400
Received: by igbpg9 with SMTP id pg9so15166729igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 10:03:19 -0700 (PDT)
In-Reply-To: <89cdf26d7506a1d2d1a2d6cfda2fab9a5fc84ad6.1438245718.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15 2:55 AM, Sowmini Varadhan wrote:
> diff --git a/net/rds/connection.c b/net/rds/connection.c
> index da6da57..3bea7b9 100644
> --- a/net/rds/connection.c
> +++ b/net/rds/connection.c
> @@ -117,7 +117,8 @@ static void rds_conn_reset(struct rds_connection *conn)
>    * For now they are not garbage collected once they're created.  They
>    * are torn down as the module is removed, if ever.
>    */
> -static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
> +static struct rds_connection *__rds_conn_create(struct net *net,
> +						__be32 laddr, __be32 faddr,
>   				       struct rds_transport *trans, gfp_t gfp,
>   				       int is_outgoing)
>   {
> @@ -157,6 +158,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
>   	conn->c_faddr = faddr;
>   	spin_lock_init(&conn->c_lock);
>   	conn->c_next_tx_seq = 1;
> +	write_pnet(&conn->c_net, net);

these are typically in wrappers like sock_net and sock_net_set


> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index 0da2a45..c38d8a0 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -448,8 +448,8 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>   		 (unsigned long long)be64_to_cpu(lguid),
>   		 (unsigned long long)be64_to_cpu(fguid));
>
> -	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_ib_transport,
> -			       GFP_KERNEL);
> +	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
> +			       &rds_ib_transport, GFP_KERNEL);

I forget what connection this is -- control channel? you should at least 
put a note as to why it is using init_net.

> diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
> index 8f486fa..4ea55a3 100644
> --- a/net/rds/iw_cm.c
> +++ b/net/rds/iw_cm.c
> @@ -398,8 +398,8 @@ int rds_iw_cm_handle_connect(struct rdma_cm_id *cm_id,
>   		 &dp->dp_saddr, &dp->dp_daddr,
>   		 RDS_PROTOCOL_MAJOR(version), RDS_PROTOCOL_MINOR(version));
>
> -	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_iw_transport,
> -			       GFP_KERNEL);
> +	conn = rds_conn_create(&init_net, dp->dp_daddr, dp->dp_saddr,
> +			       &rds_iw_transport, GFP_KERNEL);

Ditto here.

David
