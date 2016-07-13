From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v16 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 13 Jul 2016 11:20:46 +0000
Message-ID: <CO2PR03MB2182D592E1671E9B3061F06DBF310@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182CAE94F5741648A2FD270BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160713072013.GC27436@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>,
	"Haiyang Zhang" <haiyangz@microsoft.com>,
	Dave Scott <dave.scott@docker.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0114.outbound.protection.outlook.com ([104.47.40.114]:3348
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750978AbcGMLU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 07:20:59 -0400
In-Reply-To: <20160713072013.GC27436@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Michal Kubecek [mailto:mkubecek@suse.cz]
> > ......
> > +static struct sock *hvsock_find_connected_socket_by_channel(
> > +	const struct vmbus_channel *channel)
> > +{
> > +	struct hvsock_sock *hvsk;
> > +
> > +	list_for_each_entry(hvsk, &hvsock_connected_list, connected_list) {
> > +		if (hvsk->channel == channel)
> > +			return hvsock_to_sk(hvsk);
> > +	}
> > +	return NULL;
> > +}
> 
> How does this work from performance point of view if there are many
> connected sockets and/or high frequency of new connections? AFAICS most
> other families use a hash table for socket lookup.

Hi Michal,
Per the current design of the feature in the host, there is actually an implicit
inherent limit of the number of the per-guest connections: a guest can't
have more than 2048 connections.  This is because 1 connection takes a
VMBus channel ID and at most 2048 channel IDs per guest are supported.

And I don't think the lookup function is a bottleneck because the
whole process of creating or closing a connection is actually doing lots of
things, which need several extra rounds of interactions between the host and
the guest, taking much more cycles than the lookup here.

> > +static void get_ringbuffer_rw_status(struct vmbus_channel *channel,
> > +				     bool *can_read, bool *can_write)
> > ......
> > +	if (can_write) {
> > +		hv_get_ringbuffer_availbytes(&channel->outbound,
> > +					     &dummy,
> > +					     &avl_write_bytes);
> > +
> > +		/* We only write if there is enough space */
> > +		*can_write = avl_write_bytes > HVSOCK_PKT_LEN(PAGE_SIZE);
> 
> I'm not sure where does this come from but is this really supposed to be
> PAGE_SIZE (not the fixed 4KB PAGE_SIZE_4K)?

Thanks for pointing this out!
I'll replace it with PAGE_SIZE_4K.

> > +	/* see get_ringbuffer_rw_status() */
> > +	set_channel_pending_send_size(channel, HVSOCK_PKT_LEN(PAGE_SIZE)
> + 1);
> 
> Same question.
I'll replace it with PAGE_SIZE_4K too.

> > +static int hvsock_create_sock(struct net *net, struct socket *sock,
> > +			      int protocol, int kern)
> > +{
> > +	struct sock *sk;
> > +
> > +	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
> > +		return -EPERM;
> 
> Looks like any application wanting to use hyper-v sockets will need
> rather high privileges. It would make sense if these sockets were
> reserved for privileged tasks like VM management. But according to the
> commit message, hv_sock is supposed to be used for regular application
> to application communication. Requiring CAP_{SYS,NET}_ADMIN looks like
> an overkill to me.

I agree with you. Let me remove this check.

BTW, the check was supposed to prevent regular app from using the socket,
because the current design by the host has a drawback: a connection consumes
at least 40KB unswapable memory as the host<->guest shared ring and we
don't want malicious regular apps to be able to consume all the memory.

Later I realized the per-guest number of connections couldn't exceed 2048,
so at most the host<->guest rings consume 2K * 40KB = 80MB memory and
this isn't a big concern to me.

Thanks,
-- Dexuan
