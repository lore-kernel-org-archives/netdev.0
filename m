From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH V6] netfilter: h323: avoid potential attack
Date: Mon, 15 Feb 2016 20:59:30 +0100
Message-ID: <20160215195930.GA9001@salvia>
References: <1454420404-347-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454420404-347-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 02, 2016 at 09:40:04PM +0800, Zhouyi Zhou wrote:
> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> index 9511af0..8d24c4b 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -110,6 +110,21 @@ int (*nat_q931_hook) (struct sk_buff *skb,
>  
>  static DEFINE_SPINLOCK(nf_h323_lock);
>  static char *h323_buffer;
> +static int h323_buffer_valid_bytes;
> +
> +static bool h323_buffer_ref_valid(void *p, int len)

I'd rather see you pass a parameter to this function with the
remaining size in the buffer, so we don't need this global variable
h323_buffer_valid_bytes.

You can probably add an initial patch to add a structure to store the
state information so we reduce the function parameter footprint.

        struct h323_ct_state {
                ...
                int buflen;
        };

So you pass up the h323_ct_state structure to function calls,
something like that.

Thanks.

> +{
> +	if ((unsigned long)len > h323_buffer_valid_bytes)
> +		return false;
> +
> +	if (p + len > (void *)h323_buffer + h323_buffer_valid_bytes)
> +		return false;
> +
> +	if (p < (void *)h323_buffer)
> +		return false;
> +
> +	return true;
> +}
>  
>  static struct nf_conntrack_helper nf_conntrack_helper_h245;
>  static struct nf_conntrack_helper nf_conntrack_helper_q931[];
