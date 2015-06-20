From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Fri, 19 Jun 2015 21:27:06 -0400
Message-ID: <20150619212706.2f13a44e@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
	<20150619122553.43d2d86c@gandalf.local.home>
	<20150619131759.7b38d9de@gandalf.local.home>
	<CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	<20150619155226.7c5d6637@synchrony.poochiereds.net>
	<1434745818.8838.1.camel@primarydata.com>
	<20150619181440.22f54e6a@gandalf.local.home>
	<1434756359.8498.2.camel@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bruce James Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434756359.8498.2.camel-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Jun 2015 19:25:59 -0400
Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:


> 8<--------------------------------------------------------------
> >From 4876cc779ff525b9c2376d8076edf47815e71f2c Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> Date: Fri, 19 Jun 2015 16:17:57 -0400
> Subject: [PATCH v2] SUNRPC: Ensure we release the TCP socket once it has been
>  closed
> 
> This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
> Make xs_tcp_close() do a socket shutdown rather than a sock_release").
> Prior to that commit, the autoclose feature would ensure that an
> idle connection would result in the socket being both disconnected and
> released, whereas now only gets disconnected.
> 
> While the current behaviour is harmless, it does leave the port bound
> until either RPC traffic resumes or the RPC client is shut down.

Is there a way to test RPC traffic resuming? I'd like to try that before
declaring this bug harmless.

> 
> Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>

The problem appears to go away with this patch.

Tested-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>

Thanks a lot!

-- Steve

> Signed-off-by: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> ---
>  net/sunrpc/xprt.c     |  2 +-
>  net/sunrpc/xprtsock.c | 40 ++++++++++++++++++++++------------------
>  2 files changed, 23 insertions(+), 19 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3ca31f20b97c..ab5dd621ae0c 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -611,8 +611,8 @@ static void xprt_autoclose(struct work_struct *work)
>  	struct rpc_xprt *xprt =
>  		container_of(work, struct rpc_xprt, task_cleanup);
>  
> -	xprt->ops->close(xprt);
>  	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> +	xprt->ops->close(xprt);
>  	xprt_release_write(xprt, NULL);
>  }
>  
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index fda8ec8c74c0..ee0715dfc3c7 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -623,24 +623,6 @@ process_status:
>  }
>  
>  /**
> - * xs_tcp_shutdown - gracefully shut down a TCP socket
> - * @xprt: transport
> - *
> - * Initiates a graceful shutdown of the TCP socket by calling the
> - * equivalent of shutdown(SHUT_RDWR);
> - */
> -static void xs_tcp_shutdown(struct rpc_xprt *xprt)
> -{
> -	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> -	struct socket *sock = transport->sock;
> -
> -	if (sock != NULL) {
> -		kernel_sock_shutdown(sock, SHUT_RDWR);
> -		trace_rpc_socket_shutdown(xprt, sock);
> -	}
> -}
> -
> -/**
>   * xs_tcp_send_request - write an RPC request to a TCP socket
>   * @task: address of RPC task that manages the state of an RPC request
>   *
> @@ -786,6 +768,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
>  	xs_sock_reset_connection_flags(xprt);
>  	/* Mark transport as closed and wake up all pending tasks */
>  	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
>  }
>  
>  /**
> @@ -2103,6 +2086,27 @@ out:
>  	xprt_wake_pending_tasks(xprt, status);
>  }
>  
> +/**
> + * xs_tcp_shutdown - gracefully shut down a TCP socket
> + * @xprt: transport
> + *
> + * Initiates a graceful shutdown of the TCP socket by calling the
> + * equivalent of shutdown(SHUT_RDWR);
> + */
> +static void xs_tcp_shutdown(struct rpc_xprt *xprt)
> +{
> +	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> +	struct socket *sock = transport->sock;
> +
> +	if (sock == NULL)
> +		return;
> +	if (xprt_connected(xprt)) {
> +		kernel_sock_shutdown(sock, SHUT_RDWR);
> +		trace_rpc_socket_shutdown(xprt, sock);
> +	} else
> +		xs_reset_transport(transport);
> +}
> +
>  static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>  {
>  	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
