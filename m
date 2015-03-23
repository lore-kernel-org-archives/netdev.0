From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: prevent fetching dst twice in early demux code
Date: Mon, 23 Mar 2015 06:49:02 -0700
Message-ID: <1427118542.25985.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150323082718.265EDA0BE9@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323082718.265EDA0BE9@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-23 at 09:27 +0100, Michal Kubecek wrote:
> On s390x, gcc 4.8 compiles this part of tcp_v6_early_demux()
> 
>         struct dst_entry *dst = sk->sk_rx_dst;
> 
>         if (dst)
>                 dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
> 
> to code reading sk->sk_rx_dst twice, once for the test and once for
> the argument of ip6_dst_check() (dst_check() is inline). This allows
> ip6_dst_check() to be called with null first argument, causing a crash.
> 
> Protect sk->sk_rx_dst access by ACCESS_ONCE() both in IPv4 and IPv6
> TCP early demux code.
> 
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
> Fixes: c7109986db3c ("ipv6: Early TCP socket demux")
> 

Please remove this empty line. "Fixes" tags should be in the final group
of tags.

> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  net/ipv4/tcp_ipv4.c | 2 +-
>  net/ipv6/tcp_ipv6.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 5a2dfed..3d42b45 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1518,7 +1518,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
>  		skb->sk = sk;
>  		skb->destructor = sock_edemux;
>  		if (sk->sk_state != TCP_TIME_WAIT) {
> -			struct dst_entry *dst = sk->sk_rx_dst;
> +			struct dst_entry *dst = ACCESS_ONCE(sk->sk_rx_dst);
>  
>  			if (dst)
>  				dst = dst_check(dst, 0);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 5d46832..50eb5ff 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1585,7 +1585,7 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
>  		skb->sk = sk;
>  		skb->destructor = sock_edemux;
>  		if (sk->sk_state != TCP_TIME_WAIT) {
> -			struct dst_entry *dst = sk->sk_rx_dst;
> +			struct dst_entry *dst = ACCESS_ONCE(sk->sk_rx_dst);
>  
>  			if (dst)
>  				dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);


Good catch, (or would I say, strange compiler ? ;) )

Please use READ_ONCE().  Only stable ports will need ACCESS_ONCE()

Also, this probably points a problem on this arch, because its looks
different cpu are handling TCP traffic for the same TCP flow.
