From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 1/6] tipc: add link_kfree_skbuff helper function
Date: Fri, 6 Dec 2013 14:34:27 +0800
Message-ID: <52A16FF3.7040107@windriver.com>
References: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com> <1386311022-11176-2-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Wang Weidong <wangweidong1@huawei.com>, <jon.maloy@ericsson.com>,
	<allan.stephens@windriver.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45550 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab3LFGeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:34:46 -0500
In-Reply-To: <1386311022-11176-2-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 02:23 PM, Wang Weidong wrote:
> replaces some chunks of code that kfree the sk_buff.
> This is just code simplification, no functional changes.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/tipc/link.c | 58 +++++++++++++++++++--------------------------------------
>  1 file changed, 19 insertions(+), 39 deletions(-)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 69cd9bf..1c27d7b 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -100,6 +100,17 @@ static unsigned int align(unsigned int i)
>  	return (i + 3) & ~3u;
>  }
>  
> +static void link_kfree_skbuff(struct sk_buff *buf)
> +{
> +	struct sk_buff *next;
> +
> +	while (buf) {
> +		next = buf->next;
> +		kfree_skb(buf);
> +		buf = next;
> +	}
> +}
> +

Your new defined function is unnecessary, instead we already have
another patch doing the same thing with kfree_skb_list(), and the patch
will be to be sent out soon.

Please see below link:

http://article.gmane.org/gmane.network.tipc.general/5140/

And the patch cleans up more things than your patch.

Regards,
Ying

>  static void link_init_max_pkt(struct tipc_link *l_ptr)
>  {
>  	u32 max_pkt;
> @@ -387,13 +398,8 @@ exit:
>  static void link_release_outqueue(struct tipc_link *l_ptr)
>  {
>  	struct sk_buff *buf = l_ptr->first_out;
> -	struct sk_buff *next;
>  
> -	while (buf) {
> -		next = buf->next;
> -		kfree_skb(buf);
> -		buf = next;
> -	}
> +	link_kfree_skbuff(buf);
>  	l_ptr->first_out = NULL;
>  	l_ptr->out_queue_size = 0;
>  }
> @@ -416,21 +422,12 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
>  void tipc_link_stop(struct tipc_link *l_ptr)
>  {
>  	struct sk_buff *buf;
> -	struct sk_buff *next;
>  
>  	buf = l_ptr->oldest_deferred_in;
> -	while (buf) {
> -		next = buf->next;
> -		kfree_skb(buf);
> -		buf = next;
> -	}
> +	link_kfree_skbuff(buf);
>  
>  	buf = l_ptr->first_out;
> -	while (buf) {
> -		next = buf->next;
> -		kfree_skb(buf);
> -		buf = next;
> -	}
> +	link_kfree_skbuff(buf);
>  
>  	tipc_link_reset_fragments(l_ptr);
>  
> @@ -472,11 +469,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
>  	kfree_skb(l_ptr->proto_msg_queue);
>  	l_ptr->proto_msg_queue = NULL;
>  	buf = l_ptr->oldest_deferred_in;
> -	while (buf) {
> -		struct sk_buff *next = buf->next;
> -		kfree_skb(buf);
> -		buf = next;
> -	}
> +	link_kfree_skbuff(buf);
>  	if (!list_empty(&l_ptr->waiting_ports))
>  		tipc_link_wakeup_ports(l_ptr, 1);
>  
> @@ -1127,10 +1120,7 @@ again:
>  		if (copy_from_user(buf->data + fragm_crs, sect_crs, sz)) {
>  			res = -EFAULT;
>  error:
> -			for (; buf_chain; buf_chain = buf) {
> -				buf = buf_chain->next;
> -				kfree_skb(buf_chain);
> -			}
> +			link_kfree_skbuff(buf_chain);
>  			return res;
>  		}
>  		sect_crs += sz;
> @@ -1180,18 +1170,12 @@ error:
>  		if (l_ptr->max_pkt < max_pkt) {
>  			sender->max_pkt = l_ptr->max_pkt;
>  			tipc_node_unlock(node);
> -			for (; buf_chain; buf_chain = buf) {
> -				buf = buf_chain->next;
> -				kfree_skb(buf_chain);
> -			}
> +			link_kfree_skbuff(buf_chain);
>  			goto again;
>  		}
>  	} else {
>  reject:
> -		for (; buf_chain; buf_chain = buf) {
> -			buf = buf_chain->next;
> -			kfree_skb(buf_chain);
> -		}
> +		link_kfree_skbuff(buf_chain);
>  		return tipc_port_reject_sections(sender, hdr, msg_sect,
>  						 len, TIPC_ERR_NO_NODE);
>  	}
> @@ -2306,11 +2290,7 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
>  		fragm = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
>  		if (fragm == NULL) {
>  			kfree_skb(buf);
> -			while (buf_chain) {
> -				buf = buf_chain;
> -				buf_chain = buf_chain->next;
> -				kfree_skb(buf);
> -			}
> +			link_kfree_skbuff(buf_chain);
>  			return -ENOMEM;
>  		}
>  		msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
> 
