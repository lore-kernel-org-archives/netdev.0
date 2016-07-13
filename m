From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v16 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 13 Jul 2016 09:20:13 +0200
Message-ID: <20160713072013.GC27436@unicorn.suse.cz>
References: <CO2PR03MB2182CAE94F5741648A2FD270BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 Dave Scott <dave.scott@docker.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CO2PR03MB2182CAE94F5741648A2FD270BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Jul 11, 2016 at 02:56:52PM +0000, Dexuan Cui wrote:
> Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> mechanism between the host and the guest. It's somewhat like TCP over
> VMBus, but the transportation layer (VMBus) is much simpler than IP.
> 
> With Hyper-V Sockets, applications between the host and the guest can talk
> to each other directly by the traditional BSD-style socket APIs.
> 
> Hyper-V Sockets is only available on new Windows hosts, like Windows Server
> 2016. More info is in this article "Make your own integration services":
> https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/develop/make_mgmt_service
> 
> The patch implements the necessary support in the guest side by introducing
> a new socket address family AF_HYPERV.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
> Cc: Cathy Avery <cavery@redhat.com>
> Cc: Olaf Hering <olaf@aepfle.de>
> ---
> 
> You can also get the patch by (commit 5dde7975):
> https://github.com/dcui/linux/tree/decui/hv_sock/net-next/20160711_v16
> 
> 
> For the change log before v12, please see https://lkml.org/lkml/2016/5/15/31
> 
> In v12, the changes are mainly the following:
> 
> 1) remove the module params as David suggested.
> 
> 2) use 5 exact pages for VMBus send/recv rings, respectively.
> The host side's design of the feature requires 5 exact pages for recv/send
> rings respectively -- this is suboptimal considering memory consumption,
> however unluckily we have to live with it, before the host comes up with
> a new design in the future. :-(
> 
> 3) remove the per-connection static send/recv buffers
> Instead, we allocate and free the buffers dynamically only when we recv/send
> data. This means: when a connection is idle, no memory is consumed as
> recv/send buffers at all.
> 
> In v13:
> I return ENOMEM on buffer alllocation failure
> 
>    Actually "man read/write" says "Other errors may occur, depending on the
> object connected to fd". "man send/recv" indeed lists ENOMEM.
>    Considering AF_HYPERV is a new socket type, ENOMEM seems OK here.
>    In the long run, I think we should add a new API in the VMBus driver,
> allowing data copy from VMBus ringbuffer into user mode buffer directly.
> This way, we can even eliminate this temporary buffer.
> 
> In v14:
> fix some coding style issues pointed out by David.
> 
> In v15:
> Just some stylistic changes addressing comments from Joe Perches and
> Olaf Hering -- thank you!
> - add a GPL blurb.
> - define a new macro PAGE_SIZE_4K and use it to replace PAGE_SIZE
> - change sk_to_hvsock/hvsock_to_sk() from macros to inline functions
> - remove a not-very-useful pr_err()
> - fix some typos in comment and coding style issues.
> 
> In v16:
> Made stylistic changes addressing comments from Vitaly Kuznetsov.
> Thank you very much for the detailed comments, Vitaly!
> 
> Looking forward to your comments!
> 
>  MAINTAINERS                 |    2 +
>  include/linux/hyperv.h      |   13 +
>  include/linux/socket.h      |    4 +-
>  include/net/af_hvsock.h     |   78 +++
>  include/uapi/linux/hyperv.h |   23 +
>  net/Kconfig                 |    1 +
>  net/Makefile                |    1 +
>  net/hv_sock/Kconfig         |   10 +
>  net/hv_sock/Makefile        |    3 +
>  net/hv_sock/af_hvsock.c     | 1509 +++++++++++++++++++++++++++++++++++++++++++
>  10 files changed, 1643 insertions(+), 1 deletion(-)

...

> +static LIST_HEAD(hvsock_bound_list);
> +static LIST_HEAD(hvsock_connected_list);
> +static DEFINE_MUTEX(hvsock_mutex);
> +
> +static struct sock *hvsock_find_bound_socket(const struct sockaddr_hv *addr)
> +{
> +	struct hvsock_sock *hvsk;
> +
> +	list_for_each_entry(hvsk, &hvsock_bound_list, bound_list) {
> +		if (!uuid_le_cmp(addr->shv_service_guid,
> +				 hvsk->local_addr.shv_service_guid))
> +			return hvsock_to_sk(hvsk);
> +	}
> +	return NULL;
> +}
> +
> +static struct sock *hvsock_find_connected_socket_by_channel(
> +	const struct vmbus_channel *channel)
> +{
> +	struct hvsock_sock *hvsk;
> +
> +	list_for_each_entry(hvsk, &hvsock_connected_list, connected_list) {
> +		if (hvsk->channel == channel)
> +			return hvsock_to_sk(hvsk);
> +	}
> +	return NULL;
> +}

How does this work from performance point of view if there are many
connected sockets and/or high frequency of new connections? AFAICS most
other families use a hash table for socket lookup.

> +static void get_ringbuffer_rw_status(struct vmbus_channel *channel,
> +				     bool *can_read, bool *can_write)
> +{
> +	u32 avl_read_bytes, avl_write_bytes, dummy;
> +
> +	if (can_read) {
> +		hv_get_ringbuffer_availbytes(&channel->inbound,
> +					     &avl_read_bytes,
> +					     &dummy);
> +		/* 0-size payload means FIN */
> +		*can_read = avl_read_bytes >= HVSOCK_PKT_LEN(0);
> +	}
> +
> +	if (can_write) {
> +		hv_get_ringbuffer_availbytes(&channel->outbound,
> +					     &dummy,
> +					     &avl_write_bytes);
> +
> +		/* We only write if there is enough space */
> +		*can_write = avl_write_bytes > HVSOCK_PKT_LEN(PAGE_SIZE);

I'm not sure where does this come from but is this really supposed to be
PAGE_SIZE (not the fixed 4KB PAGE_SIZE_4K)?

> +static int hvsock_open_connection(struct vmbus_channel *channel)
> +{
> +	struct hvsock_sock *hvsk, *new_hvsk;
> +	uuid_le *instance, *service_id;
> +	unsigned char conn_from_host;
> +	struct sockaddr_hv hv_addr;
> +	struct sock *sk, *new_sk;
> +	int ret;
> +
> +	instance = &channel->offermsg.offer.if_instance;
> +	service_id = &channel->offermsg.offer.if_type;
> +
> +	/* The first byte != 0 means the host initiated the connection. */
> +	conn_from_host = channel->offermsg.offer.u.pipe.user_def[0];
> +
> +	mutex_lock(&hvsock_mutex);
> +
> +	hvsock_addr_init(&hv_addr, conn_from_host ? *service_id : *instance);
> +	sk = hvsock_find_bound_socket(&hv_addr);
> +
> +	if (!sk || (conn_from_host && sk->sk_state != SS_LISTEN) ||
> +	    (!conn_from_host && sk->sk_state != SS_CONNECTING)) {
> +		ret = -ENXIO;
> +		goto out;
> +	}
> +
> +	if (conn_from_host) {
> +		if (sk->sk_ack_backlog >= sk->sk_max_ack_backlog) {
> +			ret = -ECONNREFUSED;
> +			goto out;
> +		}
> +
> +		new_sk = hvsock_create(sock_net(sk), NULL, GFP_KERNEL,
> +				       sk->sk_type);
> +		if (!new_sk) {
> +			ret = -ENOMEM;
> +			goto out;
> +		}
> +
> +		new_sk->sk_state = SS_CONNECTING;
> +		new_hvsk = sk_to_hvsock(new_sk);
> +		new_hvsk->channel = channel;
> +		hvsock_addr_init(&new_hvsk->local_addr, *service_id);
> +		hvsock_addr_init(&new_hvsk->remote_addr, *instance);
> +	} else {
> +		hvsk = sk_to_hvsock(sk);
> +		hvsk->channel = channel;
> +	}
> +
> +	set_channel_read_state(channel, false);
> +	ret = vmbus_open(channel, RINGBUFFER_HVSOCK_SND_SIZE,
> +			 RINGBUFFER_HVSOCK_RCV_SIZE, NULL, 0,
> +			 hvsock_on_channel_cb, conn_from_host ? new_sk : sk);
> +	if (ret != 0) {
> +		if (conn_from_host) {
> +			new_hvsk->channel = NULL;
> +			sock_put(new_sk);
> +		} else {
> +			hvsk->channel = NULL;
> +		}
> +		goto out;
> +	}
> +
> +	vmbus_set_chn_rescind_callback(channel, hvsock_close_connection);
> +
> +	/* see get_ringbuffer_rw_status() */
> +	set_channel_pending_send_size(channel, HVSOCK_PKT_LEN(PAGE_SIZE) + 1);

Same question.

> +
> +	if (conn_from_host) {
> +		new_sk->sk_state = SS_CONNECTED;
> +
> +		sock_hold(&new_hvsk->sk);
> +		list_add(&new_hvsk->connected_list, &hvsock_connected_list);
> +
> +		hvsock_enqueue_accept(sk, new_sk);
> +	} else {
> +		sk->sk_state = SS_CONNECTED;
> +		sk->sk_socket->state = SS_CONNECTED;
> +
> +		sock_hold(&hvsk->sk);
> +		list_add(&hvsk->connected_list, &hvsock_connected_list);
> +	}
> +
> +	sk->sk_state_change(sk);
> +out:
> +	mutex_unlock(&hvsock_mutex);
> +	return ret;
> +}

...

> +static int hvsock_create_sock(struct net *net, struct socket *sock,
> +			      int protocol, int kern)
> +{
> +	struct sock *sk;
> +
> +	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
> +		return -EPERM;

Looks like any application wanting to use hyper-v sockets will need
rather high privileges. It would make sense if these sockets were
reserved for privileged tasks like VM management. But according to the
commit message, hv_sock is supposed to be used for regular application
to application communication. Requiring CAP_{SYS,NET}_ADMIN looks like
an overkill to me.

> +
> +	if (protocol != 0 && protocol != SHV_PROTO_RAW)
> +		return -EPROTONOSUPPORT;
> +
> +	switch (sock->type) {
> +	case SOCK_STREAM:
> +		sock->ops = &hvsock_ops;
> +		break;
> +	default:
> +		return -ESOCKTNOSUPPORT;
> +	}
> +
> +	sock->state = SS_UNCONNECTED;
> +
> +	sk = hvsock_create(net, sock, GFP_KERNEL, 0);
> +	return sk ? 0 : -ENOMEM;
> +}

Michal Kubecek
