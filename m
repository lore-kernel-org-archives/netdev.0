From: Houcheng Lin <houcheng@gmail.com>
Subject: Re: [PATCH v2] netfilter: release skbuf when nlmsg put fail
Date: Tue, 14 Oct 2014 22:51:32 +0800
Message-ID: <CAL8JtxARGy6V1=m_4RJmeS5O0D0PD75cv+q2NrbmBr7ZGKeE4w@mail.gmail.com>
References: <CAL8JtxD=Vopo7fvKEnfKgOa3T=WyVH=mb_YqX9mES+n-6dJbrQ@mail.gmail.com>
	<20141014104923.GA30916@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pablo@netfilter.org, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141014104923.GA30916@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-10-14 18:49 GMT+08:00 Florian Westphal <fw@strlen.de>:
> Houcheng Lin <houcheng@gmail.com> wrote:
>> When system is under heavy loading, the __nfulnl_send() may may failed
>> to put nlmsg into skbuf of nfulnl_instance. If not clear the skbuff on failed,
>> the __nfulnl_send() will still try to put next nlmsg onto this half-full skbuf
>> and cause the user program can never receive packet.
>>
>> This patch fix this issue by releasing skbuf immediately after nlmst put
>> failed.
>
> Could you please try this patch on top of this one and see if the
> WARN_ON goes away?
>
> Thanks
>
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -649,7 +649,8 @@ nfulnl_log_packet(struct net *net,
>                 + nla_total_size(sizeof(u_int32_t))     /* gid */
>                 + nla_total_size(plen)                  /* prefix */
>                 + nla_total_size(sizeof(struct nfulnl_msg_packet_hw))
> -               + nla_total_size(sizeof(struct nfulnl_msg_packet_timestamp));
> +               + nla_total_size(sizeof(struct nfulnl_msg_packet_timestamp))
> +               + nla_total_size(sizeof(struct nfgenmsg));      /* NLMSG_DONE */
>
>         if (in && skb_mac_header_was_set(skb)) {
>                 size +=   nla_total_size(skb->dev->hard_header_len)
> @@ -692,8 +693,7 @@ nfulnl_log_packet(struct net *net,
>                 goto unlock_and_release;
>         }
>
> -       if (inst->skb &&
> -           size > skb_tailroom(inst->skb) - sizeof(struct nfgenmsg)) {
> +       if (inst->skb && size > skb_tailroom(inst->skb)) {
>                 /* either the queue len is too high or we don't have
>                  * enough room in the skb left. flush to userspace. */
>                 __nfulnl_flush(inst);
Hi Florian,
The modified code seems won't affect the program flow: Size is add a
extra value,
sizeof(struct nfgenmsg), during initialization. comparison size with tailroom
space, the right-side value also add the same value. Is there anything
I miss or
not understand ?

-- 
Best regards,
Houcheng Lin
