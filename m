From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH V3] netfilter: h323: avoid potential attack
Date: Mon, 1 Feb 2016 18:58:58 +0100
Message-ID: <20160201175858.GA2453@salvia>
References: <1454037935-14842-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454037935-14842-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 11:25:35AM +0800, Zhouyi Zhou wrote:
> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> For example, he may fabricate a very large taddr->ipAddress.ip;
> As suggested by Eric, this module is protected by a lock (nf_h323_lock)
> so adding a variable h323_buffer_valid_bytes that would contain
> the number of valid bytes would not require to change prototypes of
> get_h2x5_addr.
> 
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> 
> 
> ---
>  net/netfilter/nf_conntrack_h323_main.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> index 9511af0..65d84bc 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -110,6 +110,11 @@ int (*nat_q931_hook) (struct sk_buff *skb,
>  
>  static DEFINE_SPINLOCK(nf_h323_lock);
>  static char *h323_buffer;
> +static unsigned int h323_buffer_valid_bytes;
> +/* check offset overflow and out of range data reference */
> +#define CHECK_BOUND(p, n) ((n) > h323_buffer_valid_bytes ||		\
> +			   ((void *)(p) + (n) - (void *)h323_buffer	\
> +			    > h323_buffer_valid_bytes))

We don't want obscure macros. You add a function for this, the
compiler will likely inline it.
