From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/5] rxrpc: fix last_call processing
Date: Sat, 27 Aug 2016 08:01:42 +0100
Message-ID: <4145.1472281302@warthog.procyon.org.uk>
References: <20160826152546.604384-4-arnd@arndb.de> <20160826152546.604384-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826152546.604384-4-arnd@arndb.de>
Content-ID: <4144.1472281302.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> A change to the retransmission handling in rxrpc caused a use-before-init
> bug in rxrpc_data_ready(), as indicated by "gcc -Wmaybe-uninitialized":
> 
> net/rxrpc/input.c: In function 'rxrpc_data_ready':
> net/rxrpc/input.c:735:34: error: 'call' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This moves the initialization of the local variable before the first
> user, which presumably is what was intended here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 18bfeba50dfd ("rxrpc: Perform terminal call ACK/ABORT retransmission from conn processor")
> ---
> Cc: David Howells <dhowells@redhat.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> 
>  net/rxrpc/input.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
> index 66cdeb56f44f..3c22e43a58fd 100644
> --- a/net/rxrpc/input.c
> +++ b/net/rxrpc/input.c
> @@ -728,6 +728,10 @@ void rxrpc_data_ready(struct sock *sk)
>  		if (sp->hdr.callNumber < chan->last_call)
>  			goto discard_unlock;
>  
> +		call = rcu_dereference(chan->call);
> +		if (!call || atomic_read(&call->usage) == 0)
> +			goto cant_route_call;
> +
>  		if (sp->hdr.callNumber == chan->last_call) {
>  			/* For the previous service call, if completed
>  			 * successfully, we discard all further packets.
> @@ -744,10 +748,6 @@ void rxrpc_data_ready(struct sock *sk)
>  			goto out_unlock;
>  		}
>  
> -		call = rcu_dereference(chan->call);
> -		if (!call || atomic_read(&call->usage) == 0)
> -			goto cant_route_call;
> -
>  		rxrpc_post_packet_to_call(call, skb);
>  		goto out_unlock;
>  	}

You can't rearrange these like this.  I have a different fix.

David
