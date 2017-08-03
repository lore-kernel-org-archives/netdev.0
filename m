From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/3] skbuff: Function to send an skbuf on a socket
Date: Thu, 03 Aug 2017 12:51:14 -0700
Message-ID: <59837EB2.9010009@gmail.com>
References: <20170728232243.3040-1-tom@quantonium.net> <20170728232243.3040-3-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32784 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdHCTvY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 15:51:24 -0400
Received: by mail-pf0-f195.google.com with SMTP id c65so2391422pfl.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 12:51:24 -0700 (PDT)
In-Reply-To: <20170728232243.3040-3-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 04:22 PM, Tom Herbert wrote:
> Add skb_send_sock to send an skbuff on a socket within the kernel.
> Arguments include an offset so that an skbuf might be sent in mulitple
> calls (e.g. send buffer limit is hit).
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---

[...]

> +/* Send skb data on a socket. Socket must be locked. */
> +int skb_send_sock_locked(struct sock *sk, struct sk_buff *skb, int offset,
> +			 int len)
> +{
> +	unsigned int orig_len = len;
> +	struct sk_buff *head = skb;
> +	unsigned short fragidx;
> +	int slen, ret;
> +
> +do_frag_list:
> +
> +	/* Deal with head data */
> +	while (offset < skb_headlen(skb) && len) {
> +		struct kvec kv;
> +		struct msghdr msg;
> +
> +		slen = min_t(int, len, skb_headlen(skb) - offset);
> +		kv.iov_base = skb->data + offset;
> +		kv.iov_len = len;
                            ^^^^^^

This should be slen right?

> +		memset(&msg, 0, sizeof(msg));
> +
> +		ret = kernel_sendmsg_locked(sk, &msg, &kv, 1, slen);
> +		if (ret <= 0)
> +			goto error;
> +
> +		offset += ret;
> +		len -= ret;
> +	}
> +

Thanks,
John
