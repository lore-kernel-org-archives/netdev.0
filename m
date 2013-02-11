From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Mon, 11 Feb 2013 15:22:33 +0100
Message-ID: <5118FEA9.2080201@redhat.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1360196636-9357-2-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/07/13 01:23, Andy King wrote:
> +struct vsock_transport_recv_notify_data {
> +	u64 data1; /* Transport-defined. */
> +	u64 data2; /* Transport-defined. */
> +	bool notify_on_block;
> +};
> +
> +struct vsock_transport_send_notify_data {
> +	u64 data1; /* Transport-defined. */
> +	u64 data2; /* Transport-defined. */
> +};
> +
> +struct vsock_transport {
> +	/* Initialize/tear-down socket. */
> +	int (*init)(struct vsock_sock *, struct vsock_sock *);
> +	void (*destruct)(struct vsock_sock *);
> +	void (*release)(struct vsock_sock *);
> +
> +	/* Connections. */
> +	int (*connect)(struct vsock_sock *);
> +
> +	/* DGRAM. */
> +	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
> +	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
> +			     struct msghdr *msg, size_t len, int flags);
> +	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
> +			     struct iovec *, size_t len);
> +	bool (*dgram_allow)(u32 cid, u32 port);
> +
> +	/* STREAM. */
> +	/* TODO: stream_bind() */
> +	ssize_t (*stream_dequeue)(struct vsock_sock *, struct iovec *,
> +				  size_t len, int flags);
> +	ssize_t (*stream_enqueue)(struct vsock_sock *, struct iovec *,
> +				  size_t len);
> +	s64 (*stream_has_data)(struct vsock_sock *);
> +	s64 (*stream_has_space)(struct vsock_sock *);
> +	u64 (*stream_rcvhiwat)(struct vsock_sock *);
> +	bool (*stream_is_active)(struct vsock_sock *);
> +	bool (*stream_allow)(u32 cid, u32 port);
> +
> +	/* Notification. */
> +	int (*notify_poll_in)(struct vsock_sock *, size_t, bool *);
> +	int (*notify_poll_out)(struct vsock_sock *, size_t, bool *);
> +	int (*notify_recv_init)(struct vsock_sock *, size_t,
> +		struct vsock_transport_recv_notify_data *);
> +	int (*notify_recv_pre_block)(struct vsock_sock *, size_t,
> +		struct vsock_transport_recv_notify_data *);
> +	int (*notify_recv_pre_dequeue)(struct vsock_sock *, size_t,
> +		struct vsock_transport_recv_notify_data *);
> +	int (*notify_recv_post_dequeue)(struct vsock_sock *, size_t,
> +		ssize_t, bool, struct vsock_transport_recv_notify_data *);
> +	int (*notify_send_init)(struct vsock_sock *,
> +		struct vsock_transport_send_notify_data *);
> +	int (*notify_send_pre_block)(struct vsock_sock *,
> +		struct vsock_transport_send_notify_data *);
> +	int (*notify_send_pre_enqueue)(struct vsock_sock *,
> +		struct vsock_transport_send_notify_data *);
> +	int (*notify_send_post_enqueue)(struct vsock_sock *, ssize_t,
> +		struct vsock_transport_send_notify_data *);
> +
> +	/* Shutdown. */
> +	int (*shutdown)(struct vsock_sock *, int);
> +
> +	/* Buffer sizes. */
> +	void (*set_buffer_size)(struct vsock_sock *, u64);
> +	void (*set_min_buffer_size)(struct vsock_sock *, u64);
> +	void (*set_max_buffer_size)(struct vsock_sock *, u64);
> +	u64 (*get_buffer_size)(struct vsock_sock *);
> +	u64 (*get_min_buffer_size)(struct vsock_sock *);
> +	u64 (*get_max_buffer_size)(struct vsock_sock *);
> +
> +	/* Addressing. */
> +	u32 (*get_local_cid)(void);
> +};
> +

Whoa.  This has grown *alot*.  Care to explain this please?  Patch
creating a Documentation/virtual/vsock.txt would be cool.

*_enqueue + *_dequeue is sending/receiving data, ok.

stream_has_data + stream_has_space + stream_rcvhiwat look like they are
needed for buffer management.  Details please (especially for
stream_rcvhiwat).

What is stream_is_active?
What is *_allow?

What are all those notify_* calls?

Why do you need vsock_transport_{send,recv}_notify_data structs?
Can't this live in vsock_sock->trans?

thanks,
  Gerd
