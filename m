From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net 1/1] tipc: fix bug in multicast/broadcast message
 reassembly
Date: Mon, 7 Jul 2014 11:22:14 +0800
Message-ID: <53BA1266.7090101@windriver.com>
References: <1404582253-21815-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <maloy@donjonn.com>,
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61524 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbaGGDWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 23:22:40 -0400
In-Reply-To: <1404582253-21815-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/2014 01:44 AM, Jon Maloy wrote:
> Since commit 37e22164a8a3c39bdad45aa463b1e69a1fdf4110 ("tipc: rename and
> move message reassembly function") reassembly of long broadcast messages
> has been broken. This is because we test for a non-NULL return value
> of the *buf parameter as criteria for succesful reassembly. However, this
> parameter is left defined even after reception of the first fragment,
> when reassebly is still incomplete. This leads to a kernel crash as soon
> as a the first fragment of a long broadcast message is received.
> 
> We fix this with this commit, by implementing a stricter behavior of the
> function and its return values.
> 
> This commit should be applied to both net and net-next.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/msg.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index 8be6e94..0a37a47 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -101,9 +101,11 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
>  }
>  
>  /* tipc_buf_append(): Append a buffer to the fragment list of another buffer
> - * Let first buffer become head buffer
> - * Returns 1 and sets *buf to headbuf if chain is complete, otherwise 0
> - * Leaves headbuf pointer at NULL if failure
> + * @*headbuf: in:  NULL for first frag, otherwise value returned from prev call
> + *            out: set when successful non-complete reassembly, otherwise NULL
> + * @*buf:     in:  the buffer to append. Always defined
> + *            out: head buf after sucessful complete reassembly, otherwise NULL
> + * Returns 1 when reassembly complete, otherwise 0
>   */
>  int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  {
> @@ -122,6 +124,7 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  			goto out_free;
>  		head = *headbuf = frag;
>  		skb_frag_list_init(head);
> +		*buf = NULL;
>  		return 0;
>  	}
>  	if (!head)
> @@ -150,5 +153,7 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  out_free:
>  	pr_warn_ratelimited("Unable to build fragment list\n");
>  	kfree_skb(*buf);
> +	kfree_skb(*headbuf);
> +	*buf = *headbuf = NULL;
>  	return 0;
>  }
> 
