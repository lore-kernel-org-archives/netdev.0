From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 2/2] sctp: Add RCU protection to assoc->transport_addr_list
Date: Thu, 06 Dec 2012 15:07:51 -0500
Message-ID: <50C0FB17.9000602@gmail.com>
References: <cover.1354821623.git.tgraf@suug.ch> <93b74d9f3e36e0009e8ca77192f417bc9f3e8dea.1354821623.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:50915 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667Ab2LFUHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:07:54 -0500
In-Reply-To: <93b74d9f3e36e0009e8ca77192f417bc9f3e8dea.1354821623.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2012 02:25 PM, Thomas Graf wrote:
> peer.transport_addr_list is currently only protected by sk_sock
> which is inpractical to acquire for procfs dumping purposes.
>
> This patch adds RCU protection allowing for the procfs readers to
> enter RCU read-side critical sections.
>
> Modification of the list continues to be serialized via sk_lock.
>
> V2: Use list_del_rcu() in sctp_association_free() to be safe
>      Skip transports marked dead when dumping for procfs
>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   include/net/sctp/structs.h |  2 ++
>   net/sctp/associola.c       |  6 +++---
>   net/sctp/proc.c            | 14 ++++++++++++--
>   net/sctp/transport.c       | 18 +++++++++++++-----
>   4 files changed, 30 insertions(+), 10 deletions(-)
>
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 64158aa..5d6987b 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -948,6 +948,8 @@ struct sctp_transport {
>
>   	/* 64-bit random number sent with heartbeat. */
>   	__u64 hb_nonce;
> +
> +	struct rcu_head rcu;
>   };
>
>   struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index b1ef3bc..81b1236 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -445,7 +445,7 @@ void sctp_association_free(struct sctp_association *asoc)
>   	/* Release the transport structures. */
>   	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
>   		transport = list_entry(pos, struct sctp_transport, transports);
> -		list_del(pos);
> +		list_del_rcu(pos);
>   		sctp_transport_free(transport);
>   	}
>
> @@ -565,7 +565,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
>   		sctp_assoc_update_retran_path(asoc);
>
>   	/* Remove this peer from the list. */
> -	list_del(&peer->transports);
> +	list_del_rcu(&peer->transports);
>
>   	/* Get the first transport of asoc. */
>   	pos = asoc->peer.transport_addr_list.next;
> @@ -765,7 +765,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
>   	peer->state = peer_state;
>
>   	/* Attach the remote transport to our asoc.  */
> -	list_add_tail(&peer->transports, &asoc->peer.transport_addr_list);
> +	list_add_tail_rcu(&peer->transports, &asoc->peer.transport_addr_list);
>   	asoc->peer.transport_count++;
>
>   	/* If we do not yet have a primary path, set one.  */
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 06b05ee..8c19e97 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -162,15 +162,20 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
>   	struct sctp_af *af;
>
>   	primary = &assoc->peer.primary_addr;
> -	list_for_each_entry(transport, &assoc->peer.transport_addr_list,
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(transport, &assoc->peer.transport_addr_list,
>   			transports) {
>   		addr = &transport->ipaddr;
> +		if (transport->dead)
> +			continue;
> +
>   		af = sctp_get_af_specific(addr->sa.sa_family);
>   		if (af->cmp_addr(addr, primary)) {
>   			seq_printf(seq, "*");
>   		}
>   		af->seq_dump_addr(seq, addr);
>   	}
> +	rcu_read_unlock();
>   }
>
>   static void * sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
> @@ -441,12 +446,16 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>   	head = &sctp_assoc_hashtable[hash];
>   	sctp_local_bh_disable();
>   	read_lock(&head->lock);
> +	rcu_read_lock();
>   	sctp_for_each_hentry(epb, node, &head->chain) {
>   		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
>   			continue;
>   		assoc = sctp_assoc(epb);
> -		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
> +		list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
>   					transports) {
> +			if (tsp->dead)
> +				continue;
> +
>   			/*
>   			 * The remote address (ADDR)
>   			 */
> @@ -492,6 +501,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>   		}
>   	}
>
> +	rcu_read_unlock();
>   	read_unlock(&head->lock);
>   	sctp_local_bh_enable();
>
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 206cf52..1295aec 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -163,13 +163,11 @@ void sctp_transport_free(struct sctp_transport *transport)
>   	sctp_transport_put(transport);
>   }
>
> -/* Destroy the transport data structure.
> - * Assumes there are no more users of this structure.
> - */
> -static void sctp_transport_destroy(struct sctp_transport *transport)
> +static void sctp_transport_destroy_rcu(struct rcu_head *head)
>   {
> -	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
> +	struct sctp_transport *transport;
>
> +	transport = container_of(head, struct sctp_transport, rcu);
>   	if (transport->asoc)
>   		sctp_association_put(transport->asoc);
>
> @@ -180,6 +178,16 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
>   	SCTP_DBG_OBJCNT_DEC(transport);
>   }
>
> +/* Destroy the transport data structure.
> + * Assumes there are no more users of this structure.
> + */
> +static void sctp_transport_destroy(struct sctp_transport *transport)
> +{
> +	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
> +
> +	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
> +}
> +
>   /* Start T3_rtx timer if it is not already running and update the heartbeat
>    * timer.  This routine is called every time a DATA chunk is sent.
>    */
>
