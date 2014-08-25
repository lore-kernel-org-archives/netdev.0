From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [tipc-discussion] [PATCH net-next 2/2] tipc: add name
	distributor resiliency queue
Date: Mon, 25 Aug 2014 21:40:04 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2BED68@eusaamb103.ericsson.se>
References: <1408978469-10584-1-git-send-email-erik.hugne@ericsson.com>
	<1408978469-10584-2-git-send-email-erik.hugne@ericsson.com>
 <A2BAEFC30C8FD34388F02C9B3121859D1C2BED37@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:48630 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbaHYVky convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 17:40:54 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C2BED37@eusaamb103.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Jon Maloy [mailto:jon.maloy@ericsson.com]
> Sent: August-25-14 5:18 PM
> To: Erik Hugne; ying.xue@windriver.com; Richard Alpe;
> netdev@vger.kernel.org
> Cc: tipc-discussion@lists.sourceforge.net
> Subject: Re: [tipc-discussion] [PATCH net-next 2/2] tipc: add name distributor
> resiliency queue
> 
> 
> 
> > -----Original Message-----
> > From: Erik Hugne
> > Sent: August-25-14 10:54 AM
> > To: Jon Maloy; ying.xue@windriver.com; Richard Alpe;
> > netdev@vger.kernel.org
> > Cc: tipc-discussion@lists.sourceforge.net; Erik Hugne
> > Subject: [PATCH net-next 2/2] tipc: add name distributor resiliency
> > queue
> >
> > From: Erik Hugne <erik.hugne@ericsson.com>
> >
> > TIPC name table updates are distributed asynchronously in a cluster,
> > entailing a risk of certain race conditions. E.g., if two nodes
> > simultaneously issue conflicting (overlapping) publications, this may
> > not be detected until both publications have reached a third node, in
> > which case one of the publications will be silently dropped on that
> > node. Hence, we end up with an inconsistent name table.
> >
> > In most cases this conflict is just a temporary race, e.g., one node
> > is issuing a publication under the assumption that a previous,
> > conflicting, publication has already been withdrawn by the other node.
> > However, because of the (rtt related) distributed update delay, this
> > may not yet hold true on all nodes. The symptom of this failure is a syslog
> message:
> > "tipc: Cannot publish {%u,%u,%u}, overlap error".
> >
> > In this commit we add a resiliency queue at the receiving end of the
> > name table distributor. When insertion of an arriving publication
> > fails, we retain it in this queue for a short amount of time, assuming
> > that another update will arrive very soon and clear the conflict. If
> > so happens, we insert the publication, otherwise we drop it.
> >
> > The (configurable) retention value defaults to 2000 ms. Knowing from
> > experience that the situation described above is extremely rare, there
> > is no risk that the queue will accumulate any large number of items.
> >
> > Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> > Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> > ---
> >  Documentation/sysctl/net.txt | 14 +++++++++
> >  net/tipc/core.h              |  1 +
> >  net/tipc/name_distr.c        | 69
> > ++++++++++++++++++++++++++++++++++++++++++--
> >  net/tipc/name_distr.h        |  1 +
> >  net/tipc/name_table.c        |  8 ++---
> >  net/tipc/sysctl.c            |  7 +++++
> >  6 files changed, 93 insertions(+), 7 deletions(-)
> >
> > diff --git a/Documentation/sysctl/net.txt
> > b/Documentation/sysctl/net.txt index 9a0319a..89ce54e 100644
> > --- a/Documentation/sysctl/net.txt
> > +++ b/Documentation/sysctl/net.txt
> > @@ -241,6 +241,9 @@ address of the router (or Connected) for internal
> > networks.
> >  6. TIPC
> >  -------------------------------------------------------
> >
> > +tipc_rmem
> > +----------
> > +
> >  The TIPC protocol now has a tunable for the receive memory, similar
> > to the tcp_rmem - i.e. a vector of 3 INTEGERs: (min, default, max)
> >
> > @@ -252,3 +255,14 @@ The max value is set to CONN_OVERLOAD_LIMIT,
> and
> > the default and min values  are scaled (shifted) versions of that same
> > value.  Note that the min value  is not at this point in time used in
> > any meaningful way, but the triplet is  preserved in order to be
> > consistent with things like tcp_rmem.
> > +
> > +named_timeout
> > +--------------
> > +
> > +TIPC name table updates are distributed asynchronous
> 
> asynchronously
> 
> >+ in a cluster,
> without any form of transaction handling.
> 
> This means that different race scenarios are possible.  One such is that a
> name withdrawal sent out by one node and received by a another node may
> arrive after a second, overlapping name publication already has been
> accepted from a third node, although the conflicting updates originally may
> have been  issued in the correct sequential order.
> 
> > +If named_timeout is nonzero, failed topology updates will be placed
> > +on a defer queue until another event arrives that clears the error,
> > +or until the timeout expires. Value is in milliseconds.
> > diff --git a/net/tipc/core.h b/net/tipc/core.h index d2607a8..f773b14
> > 100644
> > --- a/net/tipc/core.h
> > +++ b/net/tipc/core.h
> > @@ -81,6 +81,7 @@ extern u32 tipc_own_addr __read_mostly;  extern int
> > tipc_max_ports __read_mostly;  extern int tipc_net_id __read_mostly;
> > extern int sysctl_tipc_rmem[3] __read_mostly;
> > +extern int sysctl_tipc_named_timeout __read_mostly;
> >
> >  /*
> >   * Other global variables
> > diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c index
> > 0591f33..0cbe5e1 100644
> > --- a/net/tipc/name_distr.c
> > +++ b/net/tipc/name_distr.c
> > @@ -1,7 +1,7 @@
> >  /*
> >   * net/tipc/name_distr.c: TIPC name distribution code
> >   *
> > - * Copyright (c) 2000-2006, Ericsson AB
> > + * Copyright (c) 2000-2006, 2014, Ericsson AB
> >   * Copyright (c) 2005, 2010-2011, Wind River Systems
> >   * All rights reserved.
> >   *
> > @@ -71,6 +71,21 @@ static struct publ_list *publ_lists[] = {  };
> >
> >
> > +int sysctl_tipc_named_timeout __read_mostly = 2000;
> > +
> > +/**
> > + * struct tipc_dist_queue - queue holding deferred name table updates
> > +*/ static struct list_head tipc_dist_queue =
> > +LIST_HEAD_INIT(tipc_dist_queue);
> > +
> > +struct distr_queue_item {
> > +	struct distr_item i;
> > +	u32 dtype;
> > +	u32 node;
> > +	u64 expiry;
> > +	struct list_head next;
> > +};
> > +
> >  /**
> >   * publ_to_item - add publication info to a publication message
> >   */
> > @@ -299,6 +314,52 @@ struct publication *tipc_update_nametbl(struct
> > distr_item *i, u32 node,  }
> >
> >  /**
> > + * tipc_named_add_backlog - add a failed name table update to the
> > +backlog
> > + *
> > + */
> > +static void tipc_named_add_backlog(struct distr_item *i, u32 type,
> > +u32
> > +node) {
> > +	struct distr_queue_item *e;
> > +	u64 now = get_jiffies_64();
> > +
> > +	e = kzalloc(sizeof(*e), GFP_ATOMIC);
> > +	if (!e)
> > +		return;
> > +	e->dtype = type;
> > +	e->node = node;
> > +	e->expiry = now + msecs_to_jiffies(sysctl_tipc_named_timeout);
> > +	memcpy(e, i, sizeof(*i));
> > +	list_add_tail(&e->next, &tipc_dist_queue); }
> > +
> > +/**
> > + * tipc_named_process_backlog - try to process any pending name table
> > +updates
> > + * from the network.
> > + */
> > +void tipc_named_process_backlog(void) {
> > +	struct distr_queue_item *e, *tmp;
> > +	char addr[16];
> > +	u64 now = get_jiffies_64();
> > +
> > +	list_for_each_entry_safe(e, tmp, &tipc_dist_queue, next) {
> > +		if (e->expiry > now) {
> > +			if (!tipc_update_nametbl(&e->i, e->node, e-
> > >dtype))
> > +				continue;
> > +		} else {
> > +			tipc_addr_string_fill(addr, e->node);
> > +			pr_warn_ratelimited("Dropping name table update
> > (%d) of {%u, %u, %u} from %s key=%u\n",
> > +					    e->dtype, ntohl(e->i.type),
> > +					    ntohl(e->i.lower),
> > +					    ntohl(e->i.upper),
> 
> 
> +
> + tipc_addr_string_fill(addr),
> 
> Otherwise you'll have a nice little crash here ;)

Ahh, I see it is correct now. Sorry for the noice.

///jon

> 
> Apart from this I am ok with it. You can add "Reviewed-by"  from me.
> 
> ///jon
> 
> 
> > +                                                                            ntohl(e->i.key));
> > +		}
> > +		list_del(&e->next);
> > +		kfree(e);
> > +	}
> > +}
> > +
> > +/**
> >   * tipc_named_rcv - process name table update message sent by another
> > node
> >   */
> >  void tipc_named_rcv(struct sk_buff *buf) @@ -306,13 +367,15 @@ void
> > tipc_named_rcv(struct sk_buff *buf)
> >  	struct tipc_msg *msg = buf_msg(buf);
> >  	struct distr_item *item = (struct distr_item *)msg_data(msg);
> >  	u32 count = msg_data_sz(msg) / ITEM_SIZE;
> > +	u32 node = msg_orignode(msg);
> >
> >  	write_lock_bh(&tipc_nametbl_lock);
> >  	while (count--) {
> > -		tipc_update_nametbl(item, msg_orignode(msg),
> > -				    msg_type(msg));
> > +		if (!tipc_update_nametbl(item, node, msg_type(msg)))
> > +			tipc_named_add_backlog(item, msg_type(msg),
> > node);
> >  		item++;
> >  	}
> > +	tipc_named_process_backlog();
> >  	write_unlock_bh(&tipc_nametbl_lock);
> >  	kfree_skb(buf);
> >  }
> > diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h index
> > 8afe32b..b9e75fe 100644
> > --- a/net/tipc/name_distr.h
> > +++ b/net/tipc/name_distr.h
> > @@ -73,5 +73,6 @@ void named_cluster_distribute(struct sk_buff *buf);
> > void tipc_named_node_up(u32 dnode);  void tipc_named_rcv(struct
> > sk_buff *buf);  void tipc_named_reinit(void);
> > +void tipc_named_process_backlog(void);
> >
> >  #endif
> > diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c index
> > c058e30..3a6a0a7 100644
> > --- a/net/tipc/name_table.c
> > +++ b/net/tipc/name_table.c
> > @@ -261,8 +261,6 @@ static struct publication
> > *tipc_nameseq_insert_publ(struct name_seq *nseq,
> >
> >  		/* Lower end overlaps existing entry => need an exact match
> */
> >  		if ((sseq->lower != lower) || (sseq->upper != upper)) {
> > -			pr_warn("Cannot publish {%u,%u,%u}, overlap
> > error\n",
> > -				type, lower, upper);
> >  			return NULL;
> >  		}
> >
> > @@ -284,8 +282,6 @@ static struct publication
> > *tipc_nameseq_insert_publ(struct name_seq *nseq,
> >  		/* Fail if upper end overlaps into an existing entry */
> >  		if ((inspos < nseq->first_free) &&
> >  		    (upper >= nseq->sseqs[inspos].lower)) {
> > -			pr_warn("Cannot publish {%u,%u,%u}, overlap
> > error\n",
> > -				type, lower, upper);
> >  			return NULL;
> >  		}
> >
> > @@ -677,6 +673,8 @@ struct publication *tipc_nametbl_publish(u32 type,
> > u32 lower, u32 upper,
> >  	if (likely(publ)) {
> >  		table.local_publ_count++;
> >  		buf = tipc_named_publish(publ);
> > +		/* Any pending external events? */
> > +		tipc_named_process_backlog();
> >  	}
> >  	write_unlock_bh(&tipc_nametbl_lock);
> >
> > @@ -698,6 +696,8 @@ int tipc_nametbl_withdraw(u32 type, u32 lower,
> u32
> > ref, u32 key)
> >  	if (likely(publ)) {
> >  		table.local_publ_count--;
> >  		buf = tipc_named_withdraw(publ);
> > +		/* Any pending external events? */
> > +		tipc_named_process_backlog();
> >  		write_unlock_bh(&tipc_nametbl_lock);
> >  		list_del_init(&publ->pport_list);
> >  		kfree(publ);
> > diff --git a/net/tipc/sysctl.c b/net/tipc/sysctl.c index
> > f3fef93..1a779b1 100644
> > --- a/net/tipc/sysctl.c
> > +++ b/net/tipc/sysctl.c
> > @@ -47,6 +47,13 @@ static struct ctl_table tipc_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= proc_dointvec,
> >  	},
> > +	{
> > +		.procname	= "named_timeout",
> > +		.data		= &sysctl_tipc_named_timeout,
> > +		.maxlen		=
> > sizeof(sysctl_tipc_named_timeout),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec,
> > +	},
> >  	{}
> >  };
> >
> > --
> > 1.8.3.2
> 
> 
> ------------------------------------------------------------------------------
> Slashdot TV.
> Video for Nerds.  Stuff that matters.
> http://tv.slashdot.org/
> _______________________________________________
> tipc-discussion mailing list
> tipc-discussion@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/tipc-discussion
