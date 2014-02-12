From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: use netif_receive_skb instead of netif_rx_ni
Date: Wed, 12 Feb 2014 13:28:14 +0800
Message-ID: <52FB066E.1020006@redhat.com>
References: <52FA32C5.9040601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Qin Chuanyu <qinchuanyu@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbaBLF2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 00:28:30 -0500
In-Reply-To: <52FA32C5.9040601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2014 10:25 PM, Qin Chuanyu wrote:
> we could xmit directly instead of going through softirq to gain
> throughput and lantency improved.
> test model: VM-Host-Host just do transmit. with vhost thread and nic
> interrupt bind cpu1. netperf do throuhput test and qperf do lantency
> test.
> Host OS: suse11sp3, Guest OS: suse11sp3
>
> latency result(us):
> packet_len 64 256 512 1460
> old(UDP)   44  47  48   66
> new(UDP)   38  41  42   66
>
> old(TCP)   52  55  70  117
> new(TCP)   45  48  61  114
>
> throughput result(Gbit/s):
> packet_len   64   512   1024   1460
> old(UDP)   0.42  2.02   3.75   4.68
> new(UDP)   0.45  2.14   3.77   5.06
>
> TCP due to the latency, client couldn't send packet big enough
> to get benefit from TSO of nic, so the result show it will send
> more packet per sencond but get lower throughput.
>
> Eric mentioned that it would has problem with cgroup, but the patch
> had been sent by Herbert Xu.
> patch_id f845172531fb7410c7fb7780b1a6e51ee6df7d52
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> ---

A question: without NAPI weight, could this starve other net devices?
>  drivers/net/tun.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 44c4db8..90b4e58 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1184,7 +1184,9 @@ static ssize_t tun_get_user(struct tun_struct
> *tun, struct tun_file *tfile,
>      skb_probe_transport_header(skb, 0);
>
>      rxhash = skb_get_hash(skb);
> -    netif_rx_ni(skb);
> +    rcu_read_lock_bh();
> +    netif_receive_skb(skb);
> +    rcu_read_unlock_bh();
>
>      tun->dev->stats.rx_packets++;
>      tun->dev->stats.rx_bytes += len;
