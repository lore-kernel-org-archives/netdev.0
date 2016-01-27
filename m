From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netfilter: h323: avoid potential attack
Date: Wed, 27 Jan 2016 07:57:43 -0800
Message-ID: <1453910263.20722.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453905646-6446-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1453905646-6446-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-27 at 22:40 +0800, Zhouyi Zhou wrote:
> From: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> 
> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> 
> For example, he may fabricate a very large taddr->ipAddress.ip; 
> 
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
> ---
>  net/netfilter/nf_conntrack_h323_main.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> index 9511af0..3b3dd8c 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -110,6 +110,10 @@ int (*nat_q931_hook) (struct sk_buff *skb,
>  
>  static DEFINE_SPINLOCK(nf_h323_lock);
>  static char *h323_buffer;
> +#define CHECK_BOUND(p, n) do {					\
> +		if (((p - h323_buffer) + n) > 65536)		\
> +			return 0;				\
> +} while (0)
>  


Do not add 'return X;' or 'goto something;' in macros please.

Even referring to 'h323_buffer' is not nice, and of course 65536 is
another 'magic' value.

Even if h323_buffer was allocated to hold 65536 bytes, the various
skb_header_pointer() calls only populated a part of it.

I understand there is a bad precedent in
net/netfilter/nf_conntrack_h323_asn1.c, but it is not a good reason.

Anyway, if the issue is real, you do not take into account the 2 extra
bytes for the port.

memcpy(port, p + len, sizeof(__be16));




