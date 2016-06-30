From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v13 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 30 Jun 2016 08:44:54 -0400 (EDT)
Message-ID: <20160630.084454.396711639535557444.davem@davemloft.net>
References: <CO2PR03MB2182E76562A8236C5ABEA71CBF230@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, joe@perches.com, rolf.neugebauer@docker.com,
 netdev@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 vkuznets@redhat.com, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CO2PR03MB2182E76562A8236C5ABEA71CBF230@CO2PR03MB2182.namprd03.prod.outlook.com>
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

From: Dexuan Cui <decui@microsoft.com>
Date: Wed, 29 Jun 2016 11:30:40 +0000

> @@ -1509,4 +1509,18 @@ static inline void commit_rd_index(struct vmbus_channel *channel)
>  }
>  
>  
> +struct vmpipe_proto_header {
> +	u32 pkt_type;

It is wasteful to have two empty lines before this structure definition, one
is sufficient.

> +/*
> + * This is the address fromat of Hyper-V Sockets.
> + * Note: here we just borrow the kernel's built-in type uuid_le. When
> + * an application calls bind() or connect(), the 2 members of struct
> + * sockaddr_hv must be of GUID.
> + * The GUID format differs from the UUID format only in the byte order of
> + * the first 3 fields. Refer to:
> + * https://en.wikipedia.org/wiki/Globally_unique_identifier
> + */

Comments should be of the form:

	/* Like
	 * this.
	 */

Rather than:

	/*
	 * Like
	 * this.
	 */

> +	__le16		reserved;	     /* Must be Zero		*/

Why does an ignored, reserved, field need an endianness?  Just use
plain "u16" for this.

> +static
> +void hvsock_enqueue_accept(struct sock *listener, struct sock *connected)

Don't split the declaration after "static" with a newline, instead use:

====================
static void hvsock_enqueue_accept(struct sock *listener,
				  struct sock *connected)
====================

> +{
> +	struct hvsock_sock *hvlistener;
> +	struct hvsock_sock *hvconnected;

Please order local variables from logest to shortest line.

> +static struct sock *hvsock_dequeue_accept(struct sock *listener)
> +{
> +	struct hvsock_sock *hvlistener;
> +	struct hvsock_sock *hvconnected;

Likewise.

> +static void hvsock_sk_destruct(struct sock *sk)
> +{
> +	struct hvsock_sock *hvsk = sk_to_hvsock(sk);
> +	struct vmbus_channel *channel = hvsk->channel;

Likewise.

> +/* This function runs in the tasklet context of process_chn_event() */
> +static void hvsock_on_channel_cb(void *ctx)
> +{
> +	struct sock *sk = (struct sock *)ctx;
> +	struct hvsock_sock *hvsk = sk_to_hvsock(sk);
> +	struct vmbus_channel *channel = hvsk->channel;
> +	bool can_read, can_write;

Likewise.

> +static int hvsock_open_connection(struct vmbus_channel *channel)
> +{
> +	struct hvsock_sock *hvsk, *new_hvsk;
> +	struct sockaddr_hv hv_addr;
> +	struct sock *sk, *new_sk;
> +	unsigned char conn_from_host;

Likewise.

> +static int hvsock_connect_wait(struct socket *sock,
> +			       int flags, int current_ret)
> +{
> +	struct sock *sk = sock->sk;
> +	struct hvsock_sock *hvsk = sk_to_hvsock(sk);

Likewise.
