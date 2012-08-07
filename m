From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-tcp: TCP/IP stack bypass for loopback connections
Date: Tue, 07 Aug 2012 23:58:42 +0200
Message-ID: <1344376722.28967.195.camel@edumazet-glaptop>
References: <1344373683-22945-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41280 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870Ab2HGV6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 17:58:47 -0400
Received: by weyx8 with SMTP id x8so67374wey.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 14:58:45 -0700 (PDT)
In-Reply-To: <1344373683-22945-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 14:08 -0700, Bruce "Brutus" Curtis wrote:
> From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
> 
> TCP/IP loopback socket pair stack bypass, based on an idea by, and
> rough upstream patch from, David Miller <davem@davemloft.net> called
> "friends", the data structure modifcations and connection scheme are
> reused with extensive data-path changes.
> 
> A new sysctl, net.ipv4.tcp_friends, is added:
>   0: disable friends and use the stock data path.
>   1: enable friends and bypass the stack data path, the default.
> 
> Note, when friends is enabled any loopback interpose, e.g. tcpdump,
> will only see the TCP/IP packets during connection establishment and
> finish, all data bypasses the stack and instead is delivered to the
> destination socket directly.
> 
> Testing done on a 4 socket 2.2GHz "Quad-Core AMD Opteron(tm) Processor
> 8354 CPU" based system, netperf results for a single connection show
> increased TCP_STREAM throughput, increased TCP_RR and TCP_CRR transaction
> rate for most message sizes vs baseline and comparable to AF_UNIX.
> 
> Significant increase (up to 5x) in aggregate throughput for multiple
> netperf runs (STREAM 32KB I/O x N) is seen.
> 
> Some results:
> 
> Default netperf: netperf
>                  netperf -t STREAM_STREAM
>                  netperf -t STREAM_STREAM -- -s 51882 -m 16384 -M 87380
>                  netperf
> 
>          Baseline  AF_UNIX      AF_UNIX           Friends
>          Mbits/S   Mbits/S      Mbits/S           Mbits/S
>            6860       714   8%    9444 138% 1323%  10576 154% 1481% 112%
> 
> Note, for the AF_UNIX (STREAM_STREAM) test 2 results are listed, 1st
> with no options but as the defaults for AF_UNIX sockets are much lower
> performaning a 2nd set of runs with a socket buffer size and send/recv
> buffer sizes equivalent to AF_INET (TCP_STREAM) are done.
> 
> Note, all subsequent AF_UNIX (STREAM_STREAM, STREAM_RR) tests are done
> with "-s 51882" such that the same total effective socket buffering is
> used as for the AF_INET runs defaults (16384+NNNNN/2).
> 
> STREAM 32KB I/O x N: netperf -l 100 -t TCP_STREAM -- -m 32K -M 32K
>                      netperf -l 100 -t STREAM_STREAM -- -s 51882 -m 32K -M 32K
>                      netperf -l 100 -t TCP_STREAM -- -m 32K -M 32K
> 
>           Baseline  AF_UNIX      Friends
>    N  COC Mbits/S   Mbits/S      Mbits/S
>    1   -    8616      9416 109%   11116 129% 118%
>    2   -   15419     17076 111%   20267 131% 119%
>   16   2   59497    303029 509%  347349 584% 115%
>   32   4   54223    273637 505%  272891 503% 100%
>  256  32   58244     85476 147%  273696 470% 320%
>  512  64   58745     87402 149%  260837 444% 298%
> 1600 200   83161    158915 191%  383947 462% 242%
> 
> COC = Cpu Over Commit ratio (16 core platform)
> 
> STREAM: netperf -l 100 -t TCP_STREAM
>         netperf -l 100 -t STREAM_STREAM -- -s 51882
>         netperf -l 100 -t TCP_STREAM
> 
> netperf  Baseline  AF_UNIX      Friends
> -m/-M N  Mbits/S   Mbits/S      Mbits/S
>   64       1020       445  44%     515  50% 116%
>   1K       4881      4340  89%    5070 104% 117%
>   8K       5933      8387 141%    9770 165% 116%
>  32K       8168      9538 117%   11067 135% 116%
>  64K       9116      9774 107%   11515 126% 118%
> 128K       9053     10044 111%   13082 145% 130%
> 256K       9642     10351 107%   13470 140% 130%
> 512K      10050     10142 101%   13327 133% 131%
>   1M       8640      9843 114%   12201 141% 124%
>  16M       7179      9619 134%   11316 158% 118%
> 
> RR: netperf -l 100 -t TCP_RR
>     netperf -l 100 -t STREAM_RR -- -s 51882 -m 16384 -M 87380
>     netperf -l 100 -t TCP_RR
> 
> netperf  Baseline  AF_UNIX      Friends
> -r N,N   Trans./S  Trans./S     Trans./S
>   64      47913     99681 208%   98225 205%  99%
>   1K      44045     92327 210%   91608 208%  99%
>   8K      26732     33201 124%   33025 124%  99%
>  32K      10903     11972 110%   13574 124% 113%
>  64K       7113      6718  94%    7176 101% 107%
> 128K       4191      3431  82%    3695  88% 108%
> 256K       2324      1937  83%    2147  92% 111%
> 512K        958      1056 110%    1202 125% 114%
>   1M        404       508 126%     497 123%  98%
>  16M       26.1      34.1 131%    32.9 126%  96%
> 
> CRR: netperf -l 100 -t TCP_CRR
>      netperf -l 100 -t TCP_CRR
> 
> netperf  Baseline  AF_UNIX      Friends
>   -r N   Trans./S  Trans./S     Trans./S
>   64      14690         -        18191 124%   -
>   1K      14258         -        17492 123%   -
>   8K      11535         -        14012 121%   -
>  32K       7035         -         8974 128%   -
>  64K       4312         -         5654 131%   -
> 128K       2252         -         3179 141%   -
> 256K       1237         -         2008 162%   -
> 512K       17.5*        -         1079   ?    -
>   1M       4.93*        -          458   ?    -
>  16M       8.29*        -         32.5   ?    -
> 
> Note, "-" denotes test not supported for transport.
>       "*" denotes test results reported without statistical confidence.
>       "?" denotes results not comparable.
> 
> SPLICE 32KB I/O:
> 
> Source
>  Sink   Baseline  Friends
>  FSFS   Mbits/S   Mbits/S
>  ----     8042     10810 134%
>  Z---     7071      9773 138%
>  --N-     8039     10820 135%
>  Z-N-     7902      9796 124%
>  -S--    17326     37496 216%
>  ZS--     9008      9573 106%
>  -SN-    16154     36269 225%
>  ZSN-     9531      9640 101%
>  ---S     8466      9933 117%
>  Z--S     8000      9453 118%
>  --NS    12783     11379  89%
>  Z-NS    11055      9489  86%
>  -S-S    12741     24380 191%
>  ZS-S     8097     10242 126%
>  -SNS    16657     30954 186%
>  ZSNS    12108     12763 105%
> 
> Note, "Z" source File /dev/zero, "-" source user memory
>       "N" sink File /dev/null, "-" sink user memory
>       "S" Splice on, "-" Splice off
> 
> Signed-off-by: Bruce \"Brutus\" Curtis <brutus@google.com>
> ---
>  include/linux/skbuff.h          |    2 +
>  include/net/request_sock.h      |    1 +
>  include/net/sock.h              |   32 +++-
>  include/net/tcp.h               |    3 +-
>  net/core/skbuff.c               |    1 +
>  net/core/sock.c                 |    1 +
>  net/core/stream.c               |   36 +++
>  net/ipv4/inet_connection_sock.c |   20 ++
>  net/ipv4/sysctl_net_ipv4.c      |    7 +
>  net/ipv4/tcp.c                  |  500 ++++++++++++++++++++++++++++++++++-----
>  net/ipv4/tcp_input.c            |   22 ++-
>  net/ipv4/tcp_ipv4.c             |    2 +
>  net/ipv4/tcp_minisocks.c        |    5 +
>  net/ipv4/tcp_output.c           |   18 ++-
>  net/ipv6/tcp_ipv6.c             |    1 +
>  15 files changed, 576 insertions(+), 75 deletions(-)
> 

A change in Documentation is welcome (for the sysctl)

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 642cb73..2fbca93 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -332,6 +332,7 @@ typedef unsigned char *sk_buff_data_t;
>   *	@cb: Control buffer. Free for use by every layer. Put private vars here
>   *	@_skb_refdst: destination entry (with norefcount bit)
>   *	@sp: the security path, used for xfrm
> + *	@friend: loopback friend socket
>   *	@len: Length of actual data
>   *	@data_len: Data length
>   *	@mac_len: Length of link layer header
> @@ -407,6 +408,7 @@ struct sk_buff {
>  #ifdef CONFIG_XFRM
>  	struct	sec_path	*sp;
>  #endif
> +	struct sock		*friend;

Is it really needed ? 

Since skb wont pass other layers (qdisc, IP, ...) we probably can use
cb[] ?

>  	unsigned int		len,
>  				data_len;
>  	__u16			mac_len,
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 4c0766e..2c74420 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -63,6 +63,7 @@ struct request_sock {
>  	unsigned long			expires;
>  	const struct request_sock_ops	*rsk_ops;
>  	struct sock			*sk;
> +	struct sock			*friend;
>  	u32				secid;
>  	u32				peer_secid;
>  };
> diff --git a/include/net/sock.h b/include/net/sock.h
> index dcb54a0..3b371f5 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -197,6 +197,7 @@ struct cg_proto;
>    *	@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
>    *	@sk_lock:	synchronizer
>    *	@sk_rcvbuf: size of receive buffer in bytes
> +  *	@sk_friend: loopback friend socket
>    *	@sk_wq: sock wait queue and async head
>    *	@sk_rx_dst: receive input route used by early tcp demux
>    *	@sk_dst_cache: destination cache
> @@ -286,6 +287,14 @@ struct sock {
>  	socket_lock_t		sk_lock;
>  	struct sk_buff_head	sk_receive_queue;
>  	/*
> +	 * If socket has a friend (sk_friend != NULL) then a send skb is
> +	 * enqueued directly to the friend's sk_receive_queue such that:
> +	 *
> +	 *        sk_sndbuf -> sk_sndbuf + sk_friend->sk_rcvbuf
> +	 *   sk_wmem_queued -> sk_friend->sk_rmem_alloc
> +	 */
> +	struct sock		*sk_friend;
> +	/*
>  	 * The backlog queue is special, it is always used with
>  	 * the per-socket spinlock held and requires low latency
>  	 * access. Therefore we special case it's implementation.
> @@ -673,24 +682,40 @@ static inline bool sk_acceptq_is_full(const struct sock *sk)
>  	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
>  }
>  
> +static inline int sk_wmem_queued_get(const struct sock *sk)
> +{
> +	if (sk->sk_friend)

I try to convince myself sk->sk_friend cannot be changed to NULL after
this test, (by another cpu)


> +		return atomic_read(&sk->sk_friend->sk_rmem_alloc);
> +	else
> +		return sk->sk_wmem_queued;
> +}
> +
> +static inline int sk_sndbuf_get(const struct sock *sk)
> +{
> +	if (sk->sk_friend)
> +		return sk->sk_sndbuf + sk->sk_friend->sk_rcvbuf;
> +	else
> +		return sk->sk_sndbuf;
> +}
> +
>  /

Patch doesnt apply on net-next, so its a bit hard to review it
properly ;)

Thanks
