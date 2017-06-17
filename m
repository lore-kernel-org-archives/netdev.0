From: Christoph Paasch <christoph.paasch@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Fri, 16 Jun 2017 17:14:55 -0700
Message-ID: <20170617001455.GB82626@Chimay.local>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Tom Herbert <tom@herbertland.com>, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        nmav@gnutls.org, fridolin.pokorny@gmail.com
To: Dave Watson <davejwatson@fb.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 14/06/17 - 11:37:14, Dave Watson wrote:
> Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
> sockets. Based on a similar infrastructure in tcp_cong.  The idea is that any
> ULP can add its own logic by changing the TCP proto_ops structure to its own
> methods.
> 
> Example usage:
> 
> setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
> 
> modules will call:
> tcp_register_ulp(&tcp_tls_ulp_ops);
> 
> to register/unregister their ulp, with an init function and name.
> 
> A list of registered ulps will be returned by tcp_get_available_ulp, which is
> hooked up to /proc.  Example:
> 
> $ cat /proc/sys/net/ipv4/tcp_available_ulp
> tls
> 
> There is currently no functionality to remove or chain ULPs, but
> it should be possible to add these in the future if needed.
> 
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> Signed-off-by: Dave Watson <davejwatson@fb.com>
> ---
>  include/net/inet_connection_sock.h |   4 ++
>  include/net/tcp.h                  |  25 +++++++
>  include/uapi/linux/tcp.h           |   1 +
>  net/ipv4/Makefile                  |   2 +-
>  net/ipv4/sysctl_net_ipv4.c         |  25 +++++++
>  net/ipv4/tcp.c                     |  28 ++++++++
>  net/ipv4/tcp_ipv4.c                |   2 +
>  net/ipv4/tcp_ulp.c                 | 134 +++++++++++++++++++++++++++++++++++++
>  8 files changed, 220 insertions(+), 1 deletion(-)
>  create mode 100644 net/ipv4/tcp_ulp.c

I know I'm pretty late to the game (and maybe this has already been
discussed but I couldn't find anything in the archives), but I am wondering
what the take is on potential races of the setsockopt() vs other system-calls.

For example one might race the setsockopt() with a sendmsg() and the sendmsg
might end up blocking on the lock_sock in tcp_sendmsg, waiting for
tcp_set_ulp() to finish changing sk_prot. When the setsockopt() finishes, we
are then inside tcp_sendmsg() coming directly from sendmsg(), while we
should have been in the ULP's sendmsg.

It seems like TLS-ULP is resilient to this (or at least, won't cause a panic),
but there might be more exotic users of ULP in the future, that change other
callbacks and then things might go wrong.


Thoughts?


Thanks,
Christoph
