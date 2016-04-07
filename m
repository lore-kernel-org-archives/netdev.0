From: "Franklin S Cooper Jr." <fcooper@ti.com>
Subject: Re: Boot failure when using NFS on OMAP based evms
Date: Thu, 7 Apr 2016 09:36:57 -0500
Message-ID: <57067089.4080406@ti.com>
References: <570597EA.3040902@ti.com>
 <CAF=yD-L=HZtD+LaKt1y4OcY0CQKOk_jmXZcQcyXjdfrPLpAhEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sam Kumar <samanthakumar@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>, <tony@atomide.com>,
	<mugunthanvnm@ti.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<nsekhar@ti.com>, <linux-omap@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-L=HZtD+LaKt1y4OcY0CQKOk_jmXZcQcyXjdfrPLpAhEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/06/2016 09:22 PM, Willem de Bruijn wrote:
> On Wed, Apr 6, 2016 at 7:12 PM, Franklin S Cooper Jr. <fcooper@ti.com> wrote:
>> Hi All,
>>
>> Currently linux-next is failing to boot via NFS on my AM335x GP evm,
>> AM437x GP evm and Beagle X15. I bisected the problem down to the commit
>> "udp: remove headers from UDP packets before queueing".
>>
>> I had to revert the following three commits to get things working again:
>>
>> e6afc8ace6dd5cef5e812f26c72579da8806f5ac
>> udp: remove headers from UDP packets before queueing
>>
>> 627d2d6b550094d88f9e518e15967e7bf906ebbf
>> udp: enable MSG_PEEK at non-zero offset
>>
>> b9bb53f3836f4eb2bdeb3447be11042bd29c2408
>> sock: convert sk_peek_offset functions to WRITE_ONCE
>>
> 
> Thanks for the report, and apologies for breaking your configuration.
> I had missed that sunrpc can dequeue skbs from a udp receive
> queue and makes assumptions about the layout of those packets. rxrpc
> does the same. From what I can tell so far, those are the only two
> protocols that do this. I have verified that the following fixes rxrpc for me
> 
> --- a/net/rxrpc/ar-input.c
> +++ b/net/rxrpc/ar-input.c
> @@ -612,9 +612,9 @@ int rxrpc_extract_header(struct rxrpc_skb_priv
> *sp, struct sk_buff *skb)
>         struct rxrpc_wire_header whdr;
> 
>         /* dig out the RxRPC connection details */
> -       if (skb_copy_bits(skb, sizeof(struct udphdr), &whdr, sizeof(whdr)) < 0)
> +       if (skb_copy_bits(skb, 0, &whdr, sizeof(whdr)) < 0)
>                 return -EBADMSG;
> -       if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(whdr)))
> +       if (!pskb_pull(skb, sizeof(whdr)))
>                 BUG();
> 
> I have not yet been able to reproduce the sunrpc/nfs issue, but I
> suspect that the following might fix it. I will try to create an NFS
> setup.
> 
> diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
> index 2df87f7..8ab40ba 100644
> --- a/net/sunrpc/socklib.c
> +++ b/net/sunrpc/socklib.c
> @@ -155,7 +155,7 @@ int csum_partial_copy_to_xdr(struct xdr_buf *xdr,
> struct sk_buff *skb)
>         struct xdr_skb_reader   desc;
> 
>         desc.skb = skb;
> -       desc.offset = sizeof(struct udphdr);
> +       desc.offset = 0;
>         desc.count = skb->len - desc.offset;
> 
>         if (skb_csum_unnecessary(skb))
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 1413cdc..71d6072 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -617,7 +617,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>         svsk->sk_sk->sk_stamp = skb->tstamp;
>         set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be
> more data... */
> 
> -       len  = skb->len - sizeof(struct udphdr);
> +       len  = skb->len;
>         rqstp->rq_arg.len = len;
> 
>         rqstp->rq_prot = IPPROTO_UDP;
> @@ -641,8 +641,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>                 skb_free_datagram_locked(svsk->sk_sk, skb);
>         } else {
>                 /* we can use it in-place */
> -               rqstp->rq_arg.head[0].iov_base = skb->data +
> -                       sizeof(struct udphdr);
> +               rqstp->rq_arg.head[0].iov_base = skb->data;
>                 rqstp->rq_arg.head[0].iov_len = len;
>                 if (skb_checksum_complete(skb))
>                         goto out_free;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 65e7595..c1fc7b2 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -995,15 +995,14 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
>         u32 _xid;
>         __be32 *xp;
> 
> -       repsize = skb->len - sizeof(struct udphdr);
> +       repsize = skb->len;
>         if (repsize < 4) {
>                 dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
>                 return;
>         }
> 
> 
> 
>         /* Copy the XID from the skb... */
> -       xp = skb_header_pointer(skb, sizeof(struct udphdr),
> -                               sizeof(_xid), &_xid);
> +       xp = skb_header_pointer(skb, 0, sizeof(_xid), &_xid);
>         if (xp == NULL)
>                 return;
> 


Thank you for your quick response. I verified with all of the above
suggested changes that NFS works again on my 3 evms.
