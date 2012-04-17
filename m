From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Tue, 17 Apr 2012 08:52:48 -0700
Message-ID: <20120417085248.3e642294@nehalam.linuxnetplumber.net>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	ctrix+debianbugs@navynet.it, peter.huangpeng@gmail.com,
	harry.majun@huawei.com
To: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Apr 2012 14:22:26 +0800
"Peter Huang (Peng)" <peter.huangpeng@huawei.com> wrote:

> When bridge is deleted before tap/vif device's delete, kernel may encounter an oops because of NULL reference to fake_rtable's dst.
> Set fake_rtable's dst to NULL before sending packets out can solve this problem.
> 
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
> ---
> include/linux/netfilter_bridge.h |    8 ++++++++
>  net/bridge/br_forward.c          |    1 +
>  net/bridge/br_netfilter.c        |    6 +-----
>  3 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
> index 0ddd161..70744fe 100644
> --- a/include/linux/netfilter_bridge.h
> +++ b/include/linux/netfilter_bridge.h
> @@ -104,9 +104,17 @@ struct bridge_skb_cb {
>  	} daddr;
>  };
>  
> +static inline void br_drop_fake_rtable(struct sk_buff *skb) {
> +	struct dst_entry *dst = skb_dst(skb);
> +	/* abuse fact that only fake_rtable has DST_NOPEER set */
> +	if (dst && (dst->flags & DST_NOPEER))
> +		skb_dst_drop(skb);
> +}

This check seems like a disaster waiting to happen when the next
change to DST table happens.
