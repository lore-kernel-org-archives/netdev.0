From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md
 mode
Date: Tue, 5 Sep 2017 20:14:30 -0700
Message-ID: <ece190cd-b8a1-225a-84c6-80ca2b46a44d@fb.com>
References: <1504514174-14958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1504514174-14958-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504514174-14958-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/4/17 1:36 AM, Haishuang Yan wrote:
> In collect_md mode, if the tun dev is down, it still can call
> __ip6_tnl_rcv to receive on packets, and the rx statistics increase
> improperly.
>
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Cc: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>
> ---
> Change since v3:
>   * Increment rx_dropped if tunnel device is not up, suggested by
>   Pravin B Shelar
>   * Fix wrong recipient address
> ---
>  net/ipv6/ip6_tunnel.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 10a693a..e91d3b6 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -171,8 +171,11 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
>  	}
>
>  	t = rcu_dereference(ip6n->collect_md_tun);
> -	if (t)
> -		return t;
> +	if (t) {
> +		if (t->dev->flags & IFF_UP)
> +			return t;
> +		t->dev->stats.rx_dropped++;
> +	}

Why increment the stats only for this drop case?
There are plenty of other conditions where packet
will be dropped in ip6 tunnel. I think it's important
to present consistent behavior to the users,
so I'd increment drop stats either for all drop cases
or for none. And today it's none.
The ! IFF_UP case should probably be return NULL too.
