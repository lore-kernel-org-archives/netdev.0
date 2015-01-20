From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Tue, 20 Jan 2015 14:31:54 +0000
Message-ID: <20150120143154.GR14883@acer.localdomain>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.01, Thomas Graf wrote:
> Lock out table resizes while dumping Netlink sockets to user space.
> This keeps disruptions to a minimum for readers which don't handle
> the NLM_F_DUMP_INTR flag.

This doesn't lock them out for the duration of the entire dump of
course, so the benefit seems rather small. Still with this patch,
they will need to handle NLM_F_DUMP_INTR or will get unpredictable
behaviour, in which case I'd think it makes more sense to not even
try this, all it does is hide parts of the brokenness.

An alternative would be to set a flag in ht when a dump begins that
indicates to skip resizing operations and on the end of the dump
perform any resizing operations that might be necessary. Herbert
disagrees though and he might be right.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/netlink/diag.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netlink/diag.c b/net/netlink/diag.c
> index 50aa385..be4ea6e 100644
> --- a/net/netlink/diag.c
> +++ b/net/netlink/diag.c
> @@ -114,6 +114,8 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  	req = nlmsg_data(cb->nlh);
>  	cb->seq = atomic_read(&nl_table_seq);
>  
> +	mutex_lock(&ht->mutex);
> +
>  	for (i = 0; i < htbl->size; i++) {
>  		struct rhash_head *pos;
>  
> @@ -161,6 +163,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  		num++;
>  	}
>  done:
> +	mutex_unlock(&ht->mutex);
>  	cb->args[0] = num;
>  	cb->args[1] = protocol;
>  
> -- 
> 1.9.3
> 
