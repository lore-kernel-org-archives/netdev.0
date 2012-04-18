From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 10:23:54 +0200
Message-ID: <1334737434.2472.95.camel@edumazet-glaptop>
References: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
	 <20120417085248.3e642294@nehalam.linuxnetplumber.net>
	 <1334681323.2472.43.camel@edumazet-glaptop>  <4F8E73E3.6080900@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ctrix+debianbugs@navynet.it,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F8E73E3.6080900@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-18 at 15:57 +0800, Peter Huang(Peng) wrote:
> On 2012/4/18 0:48, Eric Dumazet wrote:
> > On Tue, 2012-04-17 at 08:52 -0700, Stephen Hemminger wrote:
> >
> >> This check seems like a disaster waiting to happen when the next
> >> change to DST table happens.
> >
> > Please Peter Document this, adding a new DST_FAKE_RTABLE flag
> >
> > #define DST_FAKE_RTABLE DST_NOPEER
> >
> > or just use a bit, we have plenty of them available.
> >
> 
> 
> Add DST_FAKE_RTABLE to dst_entry, this is the new patch.
> Is this ok?
> 

A full new patch is needed, with nice changelog, and proper formatting
(your mail was mangled)


>   };
> 
> +static inline void br_drop_fake_rtable(struct sk_buff *skb) {
> +       struct dst_entry *dst = skb_dst(skb);
> +       /* abuse fact that only fake_rtable has DST_FAKE_RTABLE set */

Remove the comment, since we dont abuse NOPEER anymore, we use a
dedicated flag. (keep an empty line)

> +       if (dst && (dst->flags & DST_FAKE_RTABLE))
> +               skb_dst_drop(skb);
> +}
> +
>   #else
>   #define nf_bridge_maybe_copy_header(skb)       (0)
>   #define nf_bridge_pad(skb)                     (0)
> +#define br_drop_fake_rtable(skb)               (0)
>   #endif /* CONFIG_BRIDGE_NETFILTER */
> 
>   #endif /* __KERNEL__ */
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 59c5d18..b094030 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -55,6 +55,7 @@ struct dst_entry {
>   #define DST_NOCACHE            0x0010
>   #define DST_NOCOUNT            0x0020
>   #define DST_NOPEER             0x0040
> +#define DST_FAKE_RTABLE                0x0080
