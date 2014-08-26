From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH v2 net-next 2/2] tipc: add name distributor resiliency
 queue
Date: Tue, 26 Aug 2014 16:32:45 +0200
Message-ID: <20140826143245.GC24538@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1409043477-22761-1-git-send-email-erik.hugne@ericsson.com>
 <1409043477-22761-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:53112 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbaHZOcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:32:48 -0400
Content-Disposition: inline
In-Reply-To: <1409043477-22761-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if (e->expiry > now) should in fact be
if (time_after(e->expiry, now) to handle timer wraps correctly.

Thanks Niklas S=F6derlund for pointing this out.

v2 removed from patchwork

//E

On Tue, Aug 26, 2014 at 10:57:57AM +0200, erik.hugne@ericsson.com wrote=
:
> +void tipc_named_process_backlog(void)
> +{
> +	struct distr_queue_item *e, *tmp;
> +	char addr[16];
> +	u64 now =3D get_jiffies_64();
> +
> +	list_for_each_entry_safe(e, tmp, &tipc_dist_queue, next) {
> +		if (e->expiry > now) {
> +			if (!tipc_update_nametbl(&e->i, e->node, e->dtype))
> +				continue;
> +		} else {
> +			tipc_addr_string_fill(addr, e->node);
> +			pr_warn_ratelimited("Dropping name table update (%d) of {%u, %u, =
%u} from %s key=3D%u\n",
> +					    e->dtype, ntohl(e->i.type),
> +					    ntohl(e->i.lower),
> +					    ntohl(e->i.upper),
> +					    addr, ntohl(e->i.key));
> +		}
> +		list_del(&e->next);
> +		kfree(e);
> +	}
> +}
> +
