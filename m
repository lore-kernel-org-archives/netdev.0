From: Ying Xue <ying.xue0@gmail.com>
Subject: Re: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Thu, 20 Oct 2016 17:30:51 +0800
Message-ID: <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
References: <20161019021654.GD2773@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Ben Hutchings <ben@decadent.org.uk>,
        Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34684 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757253AbcJTJa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 05:30:59 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so5076049pfz.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 02:30:59 -0700 (PDT)
In-Reply-To: <20161019021654.GD2773@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2016 10:16 AM, Ben Hutchings wrote:
> Qian Zhang (张谦) reported a potential socket buffer overflow in
> tipc_msg_build().  The minimum fragment length needs to be checked
> against the maximum packet size, which is based on the link MTU.
> 
> Reported-by: Qian Zhang (张谦) <zhangqian-c@360.cn>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is untested, but I think it fixes the issue reported.  Ideally
> tipc_l2_device_event() would also disable use of TIPC on devices with
> too small an MTU, like several other protocols do.
> 

Yes, I think so. I will create a patch to disable TIPC sending process
when MTU size is too small.

> Ben.
> 
>  net/tipc/msg.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index 17201aa8423d..b9124ac82c29 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -274,6 +274,10 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
>  		goto error;
>  	}
>  
> +	/* Check that fragment and message header will fit */
> +	if (INT_H_SIZE + mhsz > pktmax)
> +		return -EMSGSIZE;

The "mhsz" represents the size of tipc packet header for current socket,
INT_H_SIZE indicates the size of tipc internal message header. So it
seems unreasonable to identify whether the sum of both header sizes is
bigger than MTU size. In my opinion, it's better to use MAX_H_SIZE to
compare it with pktmax. If MAX_H_SIZE is bigger than pktmax, we should
return EMSGSIZE error code.

> +
>  	/* Prepare reusable fragment header */
>  	tipc_msg_init(msg_prevnode(mhdr), &pkthdr, MSG_FRAGMENTER,
>  		      FIRST_FRAGMENT, INT_H_SIZE, msg_destnode(mhdr));
> 
