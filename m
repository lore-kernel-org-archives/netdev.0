From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 5/9] sctp: Make the ctl_sock per network namespace
Date: Tue, 14 Aug 2012 23:19:29 -0400
Message-ID: <502B1541.2070200@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <877gtbq2th.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:48580 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336Ab2HODTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 23:19:32 -0400
In-Reply-To: <877gtbq2th.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2012 02:43 PM, Eric W. Biederman wrote:
>
> - Kill sctp_get_ctl_sock, it is useless now.
> - Pass struct net where needed so net->sctp.ctl_sock is accessible.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   include/net/netns/sctp.h |    8 +++++++
>   include/net/sctp/sctp.h  |    1 -
>   net/sctp/input.c         |    4 +-
>   net/sctp/protocol.c      |   47 ++++++++++++++++++---------------------------
>   net/sctp/sm_statefuns.c  |   45 ++++++++++++++++++++++++++++++-------------
>   5 files changed, 60 insertions(+), 45 deletions(-)
>
> diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
> index cbd684e..29e36b4 100644
> --- a/include/net/netns/sctp.h
> +++ b/include/net/netns/sctp.h
> @@ -1,7 +1,15 @@
>   #ifndef __NETNS_SCTP_H__
>   #define __NETNS_SCTP_H__
>
> +struct sock;
> +
>   struct netns_sctp {
> +	/* This is the global socket data structure used for responding to
> +	 * the Out-of-the-blue (OOTB) packets.  A control sock will be created
> +	 * for this socket at the initialization time.
> +	 */
> +	struct sock *ctl_sock;
> +
>   	/* This is the global local address list.
>   	 * We actively maintain this complete list of addresses on
>   	 * the system by catching address add/delete events.
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 00c9205..550a81b 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -114,7 +114,6 @@
>   /*
>    * sctp/protocol.c
>    */
> -extern struct sock *sctp_get_ctl_sock(void);
>   extern int sctp_copy_local_addr_list(struct net *, struct sctp_bind_addr *,
>   				     sctp_scope_t, gfp_t gfp,
>   				     int flags);
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index a7e9a85..c9a0449 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -204,7 +204,7 @@ int sctp_rcv(struct sk_buff *skb)
>   			sctp_endpoint_put(ep);
>   			ep = NULL;
>   		}
> -		sk = sctp_get_ctl_sock();
> +		sk = net->sctp.ctl_sock;
>   		ep = sctp_sk(sk)->ep;
>   		sctp_endpoint_hold(ep);
>   		rcvr = &ep->base;
> @@ -795,7 +795,7 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
>   			goto hit;
>   	}
>
> -	ep = sctp_sk((sctp_get_ctl_sock()))->ep;
> +	ep = sctp_sk(net->sctp.ctl_sock)->ep;
>
>   hit:
>   	sctp_endpoint_hold(ep);
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 291e682..6193d20 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -78,12 +78,6 @@ struct proc_dir_entry	*proc_net_sctp;
>   struct idr sctp_assocs_id;
>   DEFINE_SPINLOCK(sctp_assocs_id_lock);
>
> -/* This is the global socket data structure used for responding to
> - * the Out-of-the-blue (OOTB) packets.  A control sock will be created
> - * for this socket at the initialization time.
> - */
> -static struct sock *sctp_ctl_sock;
> -
>   static struct sctp_pf *sctp_pf_inet6_specific;
>   static struct sctp_pf *sctp_pf_inet_specific;
>   static struct sctp_af *sctp_af_v4_specific;
> @@ -96,12 +90,6 @@ long sysctl_sctp_mem[3];
>   int sysctl_sctp_rmem[3];
>   int sysctl_sctp_wmem[3];
>
> -/* Return the address of the control sock. */
> -struct sock *sctp_get_ctl_sock(void)
> -{
> -	return sctp_ctl_sock;
> -}
> -
>   /* Set up the proc fs entry for the SCTP protocol. */
>   static __init int sctp_proc_init(void)
>   {
> @@ -822,7 +810,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>    * Initialize the control inode/socket with a control endpoint data
>    * structure.  This endpoint is reserved exclusively for the OOTB processing.
>    */
> -static int sctp_ctl_sock_init(void)
> +static int sctp_ctl_sock_init(struct net *net)
>   {
>   	int err;
>   	sa_family_t family = PF_INET;
> @@ -830,14 +818,14 @@ static int sctp_ctl_sock_init(void)
>   	if (sctp_get_pf_specific(PF_INET6))
>   		family = PF_INET6;
>
> -	err = inet_ctl_sock_create(&sctp_ctl_sock, family,
> -				   SOCK_SEQPACKET, IPPROTO_SCTP, &init_net);
> +	err = inet_ctl_sock_create(&net->sctp.ctl_sock, family,
> +				   SOCK_SEQPACKET, IPPROTO_SCTP, net);
>
>   	/* If IPv6 socket could not be created, try the IPv4 socket */
>   	if (err < 0 && family == PF_INET6)
> -		err = inet_ctl_sock_create(&sctp_ctl_sock, AF_INET,
> +		err = inet_ctl_sock_create(&net->sctp.ctl_sock, AF_INET,
>   					   SOCK_SEQPACKET, IPPROTO_SCTP,
> -					   &init_net);
> +					   net);
>
>   	if (err < 0) {
>   		pr_err("Failed to create the SCTP control socket\n");
> @@ -1196,6 +1184,14 @@ static void sctp_v4_del_protocol(void)
>
>   static int sctp_net_init(struct net *net)
>   {
> +	int status;
> +
> +	/* Initialize the control inode/socket for handling OOTB packets.  */
> +	if ((status = sctp_ctl_sock_init(net))) {
> +		pr_err("Failed to initialize the SCTP control sock\n");
> +		goto err_ctl_sock_init;
> +	}
> +
>   	/* Initialize the local address list. */
>   	INIT_LIST_HEAD(&net->sctp.local_addr_list);
>   	spin_lock_init(&net->sctp.local_addr_lock);
> @@ -1210,6 +1206,9 @@ static int sctp_net_init(struct net *net)
>   		    (unsigned long)net);
>
>   	return 0;
> +
> +err_ctl_sock_init:
> +	return status;
>   }
>
>   static void sctp_net_exit(struct net *net)
> @@ -1217,6 +1216,9 @@ static void sctp_net_exit(struct net *net)
>   	/* Free the local address list */
>   	sctp_free_addr_wq(net);
>   	sctp_free_local_addr_list(net);
> +
> +	/* Free the control endpoint.  */
> +	inet_ctl_sock_destroy(net->sctp.ctl_sock);
>   }
>
>   static struct pernet_operations sctp_net_ops = {
> @@ -1438,12 +1440,6 @@ SCTP_STATIC __init int sctp_init(void)
>   	if (status)
>   		goto err_v6_protosw_init;
>
> -	/* Initialize the control inode/socket for handling OOTB packets.  */
> -	if ((status = sctp_ctl_sock_init())) {
> -		pr_err("Failed to initialize the SCTP control sock\n");
> -		goto err_ctl_sock_init;
> -	}
> -
>   	status = register_pernet_subsys(&sctp_net_ops);
>   	if (status)
>   		goto err_register_pernet_subsys;
> @@ -1465,8 +1461,6 @@ err_v6_add_protocol:
>   err_add_protocol:
>   	unregister_pernet_subsys(&sctp_net_ops);
>   err_register_pernet_subsys:
> -	inet_ctl_sock_destroy(sctp_ctl_sock);
> -err_ctl_sock_init:
>   	sctp_v6_protosw_exit();
>   err_v6_protosw_init:
>   	sctp_v4_protosw_exit();
> @@ -1506,9 +1500,6 @@ SCTP_STATIC __exit void sctp_exit(void)
>   	sctp_v6_del_protocol();
>   	sctp_v4_del_protocol();
>
> -	/* Free the control endpoint.  */
> -	inet_ctl_sock_destroy(sctp_ctl_sock);
> -
>   	unregister_pernet_subsys(&sctp_net_ops);
>
>   	/* Free protosw registrations */
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 9fca103..f2daf61 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -74,7 +74,8 @@ static struct sctp_packet *sctp_abort_pkt_new(const struct sctp_endpoint *ep,
>   static int sctp_eat_data(const struct sctp_association *asoc,
>   			 struct sctp_chunk *chunk,
>   			 sctp_cmd_seq_t *commands);
> -static struct sctp_packet *sctp_ootb_pkt_new(const struct sctp_association *asoc,
> +static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
> +					     const struct sctp_association *asoc,
>   					     const struct sctp_chunk *chunk);
>   static void sctp_send_stale_cookie_err(const struct sctp_endpoint *ep,
>   				       const struct sctp_association *asoc,
> @@ -301,6 +302,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(const struct sctp_endpoint *ep,
>   	struct sctp_chunk *err_chunk;
>   	struct sctp_packet *packet;
>   	sctp_unrecognized_param_t *unk_param;
> +	struct net *net;
>   	int len;
>
>   	/* 6.10 Bundling
> @@ -318,7 +320,8 @@ sctp_disposition_t sctp_sf_do_5_1B_init(const struct sctp_endpoint *ep,
>   	/* If the packet is an OOTB packet which is temporarily on the
>   	 * control endpoint, respond with an ABORT.
>   	 */
> -	if (ep == sctp_sk((sctp_get_ctl_sock()))->ep) {
> +	net = sock_net(ep->base.sk);
> +	if (ep == sctp_sk(net->sctp.ctl_sock)->ep) {
>   		SCTP_INC_STATS(SCTP_MIB_OUTOFBLUES);
>   		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
>   	}
> @@ -646,11 +649,13 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
>   	int error = 0;
>   	struct sctp_chunk *err_chk_p;
>   	struct sock *sk;
> +	struct net *net;
>
>   	/* If the packet is an OOTB packet which is temporarily on the
>   	 * control endpoint, respond with an ABORT.
>   	 */
> -	if (ep == sctp_sk((sctp_get_ctl_sock()))->ep) {
> +	net = sock_net(ep->base.sk);
> +	if (ep == sctp_sk(net->sctp.ctl_sock)->ep) {
>   		SCTP_INC_STATS(SCTP_MIB_OUTOFBLUES);
>   		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
>   	}
> @@ -1171,7 +1176,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
>   /* Helper function to send out an abort for the restart
>    * condition.
>    */
> -static int sctp_sf_send_restart_abort(union sctp_addr *ssa,
> +static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
>   				      struct sctp_chunk *init,
>   				      sctp_cmd_seq_t *commands)
>   {
> @@ -1197,7 +1202,7 @@ static int sctp_sf_send_restart_abort(union sctp_addr *ssa,
>   	errhdr->length = htons(len);
>
>   	/* Assign to the control socket. */
> -	ep = sctp_sk((sctp_get_ctl_sock()))->ep;
> +	ep = sctp_sk(net->sctp.ctl_sock)->ep;
>
>   	/* Association is NULL since this may be a restart attack and we
>   	 * want to send back the attacker's vtag.
> @@ -1240,6 +1245,7 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>   				       struct sctp_chunk *init,
>   				       sctp_cmd_seq_t *commands)
>   {
> +	struct net *net = sock_net(new_asoc->base.sk);
>   	struct sctp_transport *new_addr;
>   	int ret = 1;
>
> @@ -1258,7 +1264,7 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>   			    transports) {
>   		if (!list_has_sctp_addr(&asoc->peer.transport_addr_list,
>   					&new_addr->ipaddr)) {
> -			sctp_sf_send_restart_abort(&new_addr->ipaddr, init,
> +			sctp_sf_send_restart_abort(net, &new_addr->ipaddr, init,
>   						   commands);
>   			ret = 0;
>   			break;
> @@ -1650,10 +1656,11 @@ sctp_disposition_t sctp_sf_do_5_2_3_initack(const struct sctp_endpoint *ep,
>   					    const sctp_subtype_t type,
>   					    void *arg, sctp_cmd_seq_t *commands)
>   {
> +	struct net *net = sock_net(ep->base.sk);
>   	/* Per the above section, we'll discard the chunk if we have an
>   	 * endpoint.  If this is an OOTB INIT-ACK, treat it as such.
>   	 */
> -	if (ep == sctp_sk((sctp_get_ctl_sock()))->ep)
> +	if (ep == sctp_sk(net->sctp.ctl_sock)->ep)
>   		return sctp_sf_ootb(ep, asoc, type, arg, commands);
>   	else
>   		return sctp_sf_discard_chunk(ep, asoc, type, arg, commands);
> @@ -3163,8 +3170,10 @@ static sctp_disposition_t sctp_sf_tabort_8_4_8(const struct sctp_endpoint *ep,
>   	struct sctp_packet *packet = NULL;
>   	struct sctp_chunk *chunk = arg;
>   	struct sctp_chunk *abort;
> +	struct net *net;
>
> -	packet = sctp_ootb_pkt_new(asoc, chunk);
> +	net = sock_net(ep->base.sk);
> +	packet = sctp_ootb_pkt_new(net, asoc, chunk);
>
>   	if (packet) {
>   		/* Make an ABORT. The T bit will be set if the asoc
> @@ -3425,8 +3434,10 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(const struct sctp_endpoint *ep,
>   	struct sctp_packet *packet = NULL;
>   	struct sctp_chunk *chunk = arg;
>   	struct sctp_chunk *shut;
> +	struct net *net;
>
> -	packet = sctp_ootb_pkt_new(asoc, chunk);
> +	net = sock_net(ep->base.sk);
> +	packet = sctp_ootb_pkt_new(net, asoc, chunk);
>
>   	if (packet) {
>   		/* Make an SHUTDOWN_COMPLETE.
> @@ -4262,6 +4273,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
>   	struct sctp_packet *packet = NULL;
>   	struct sctp_chunk *chunk =  arg;
>   	struct sctp_chunk *abort = NULL;
> +	struct net *net;
>
>   	/* SCTP-AUTH, Section 6.3:
>   	 *    It should be noted that if the receiver wants to tear
> @@ -4282,6 +4294,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
>   	if (!abort)
>   		goto nomem;
>
> +	net = sock_net(ep->base.sk);
>   	if (asoc) {
>   		/* Treat INIT-ACK as a special case during COOKIE-WAIT. */
>   		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK &&
> @@ -4319,7 +4332,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
>   			SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
>   		}
>   	} else {
> -		packet = sctp_ootb_pkt_new(asoc, chunk);
> +		packet = sctp_ootb_pkt_new(net, asoc, chunk);
>
>   		if (!packet)
>   			goto nomem_pkt;
> @@ -5825,8 +5838,10 @@ static struct sctp_packet *sctp_abort_pkt_new(const struct sctp_endpoint *ep,
>   {
>   	struct sctp_packet *packet;
>   	struct sctp_chunk *abort;
> +	struct net *net;
>
> -	packet = sctp_ootb_pkt_new(asoc, chunk);
> +	net = sock_net(ep->base.sk);
> +	packet = sctp_ootb_pkt_new(net, asoc, chunk);
>
>   	if (packet) {
>   		/* Make an ABORT.
> @@ -5858,7 +5873,8 @@ static struct sctp_packet *sctp_abort_pkt_new(const struct sctp_endpoint *ep,
>   }
>
>   /* Allocate a packet for responding in the OOTB conditions.  */
> -static struct sctp_packet *sctp_ootb_pkt_new(const struct sctp_association *asoc,
> +static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
> +					     const struct sctp_association *asoc,
>   					     const struct sctp_chunk *chunk)
>   {
>   	struct sctp_packet *packet;
> @@ -5919,7 +5935,7 @@ static struct sctp_packet *sctp_ootb_pkt_new(const struct sctp_association *asoc
>   	 * the source address.
>   	 */
>   	sctp_transport_route(transport, (union sctp_addr *)&chunk->dest,
> -			     sctp_sk(sctp_get_ctl_sock()));
> +			     sctp_sk(net->sctp.ctl_sock));
>
>   	packet = sctp_packet_init(&transport->packet, transport, sport, dport);
>   	packet = sctp_packet_config(packet, vtag, 0);
> @@ -5946,7 +5962,8 @@ static void sctp_send_stale_cookie_err(const struct sctp_endpoint *ep,
>   	struct sctp_packet *packet;
>
>   	if (err_chunk) {
> -		packet = sctp_ootb_pkt_new(asoc, chunk);
> +		struct net *net = sock_net(ep->base.sk);
> +		packet = sctp_ootb_pkt_new(net, asoc, chunk);
>   		if (packet) {
>   			struct sctp_signed_cookie *cookie;
>
>
