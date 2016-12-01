From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 1 Dec 2016 17:39:45 +0800
Message-ID: <220b8126-7445-8803-182e-0b04467ebf74@redhat.com>
References: <1480584880-48651-1-git-send-email-andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, syzkaller@googlegroups.com
To: Andrey Konovalov <andreyknvl@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Peter Klausler <pmk@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480584880-48651-1-git-send-email-andreyknvl@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月01日 17:34, Andrey Konovalov wrote:
> This patch changes tun.c to call netif_receive_skb instead of netif_rx
> when a packet is received (if CONFIG_4KSTACKS is not enabled to avoid
> stack exhaustion). The difference between the two is that netif_rx queues
> the packet into the backlog, and netif_receive_skb proccesses the packet
> in the current context.
>
> This patch is required for syzkaller [1] to collect coverage from packet
> receive paths, when a packet being received through tun (syzkaller collects
> coverage per process in the process context).
>
> As mentioned by Eric this change also speeds up tun/tap. As measured by
> Peter it speeds up his closed-loop single-stream tap/OVS benchmark by
> about 23%, from 700k packets/second to 867k packets/second.
>
> A similar patch was introduced back in 2010 [2, 3], but the author found
> out that the patch doesn't help with the task he had in mind (for cgroups
> to shape network traffic based on the original process) and decided not to
> go further with it. The main concern back then was about possible stack
> exhaustion with 4K stacks.
>
> [1] https://github.com/google/syzkaller
>
> [2] https://www.spinics.net/lists/netdev/thrd440.html#130570
>
> [3] https://www.spinics.net/lists/netdev/msg130570.html
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>
> Changes since v1:
> - incorporate Eric's note about speed improvements in commit description
> - use netif_receive_skb CONFIG_4KSTACKS is not enabled
>
>   drivers/net/tun.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8093e39..d310b13 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1304,7 +1304,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>   	skb_probe_transport_header(skb, 0);
>   
>   	rxhash = skb_get_hash(skb);
> +#ifndef CONFIG_4KSTACKS
> +	local_bh_disable();
> +	netif_receive_skb(skb);
> +	local_bh_enable();
> +#else
>   	netif_rx_ni(skb);
> +#endif
>   
>   	stats = get_cpu_ptr(tun->pcpu_stats);
>   	u64_stats_update_begin(&stats->syncp);

I get +20% tx pps from guest with this patch.

Acked-by: Jason Wang <jasowang@redhat.com>
