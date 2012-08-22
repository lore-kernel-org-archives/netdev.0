From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Wed, 22 Aug 2012 14:17:46 +0200
Message-ID: <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	<1345634026.5158.1084.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:52525 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab2HVMRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 08:17:47 -0400
Received: by vbbff1 with SMTP id ff1so944246vbb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 05:17:46 -0700 (PDT)
In-Reply-To: <1345634026.5158.1084.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Could be the infamous slave_dev_queue_mapping striking again.
>
> Could you please try :
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 346b1eb..df731a0 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -335,8 +335,11 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
>         /* don't get messages out of order, and no recursion */
>         if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
>                 struct netdev_queue *txq;
> +               int queue_index = skb_get_queue_mapping(skb);
>
> -               txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> +               if (queue_index >= dev->real_num_tx_queues)
> +                       queue_index = 0;
> +               txq = netdev_get_tx_queue(dev, queue_index);
>
>                 /* try until next clock tick */
>                 for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;


Well, it doesn't solve the problem :(

It does have an effect though. Now even on the machine with the
broadcom card, it just freeze the machine ...
On the machine with intel card, it actually does get a couple of
netconsole packet out and then freeze as well.


FYI this is the disass of bnx2 module around the issue :

   0x00000000000065f9 <+433>:	mov    %rax,%rsi
   0x00000000000065fc <+436>:	mov    %rax,0x8(%rsp)
   0x0000000000006601 <+441>:	add    $0x98,%rdi
   0x0000000000006608 <+448>:	callq  0xac9 <dma_mapping_error>
   0x000000000000660d <+453>:	test   %eax,%eax
   0x000000000000660f <+455>:	mov    0x8(%rsp),%rdx
   0x0000000000006614 <+460>:	mov    0x10(%rsp),%r8d
   0x0000000000006619 <+465>:	mov    0x18(%rsp),%r9d
   0x000000000000661e <+470>:	jne    0x6966 <bnx2_start_xmit+1310>
   0x0000000000006624 <+476>:	movzbl %r15b,%eax
   0x0000000000006628 <+480>:	shl    $0x10,%r9d
   0x000000000000662c <+484>:	mov    %rdx,%rsi
   0x000000000000662f <+487>:	imul   $0x18,%rax,%rcx
   0x0000000000006633 <+491>:	shl    $0x4,%rax
   0x0000000000006637 <+495>:	shr    $0x20,%rsi
   0x000000000000663b <+499>:	add    0x350(%r12),%rcx
   0x0000000000006643 <+507>:	or     %r9d,%r8d
   0x0000000000006646 <+510>:	mov    %r9d,0x38(%rsp)
   0x000000000000664b <+515>:	movl   $0x0,0x24(%rsp)
   0x0000000000006653 <+523>:	mov    %rdx,0x8(%rcx)
   0x0000000000006657 <+527>:	mov    %rbx,(%rcx)
   0x000000000000665a <+530>:	add    0x348(%r12),%rax
   0x0000000000006662 <+538>:	mov    %edx,0x4(%rax)
   0x0000000000006665 <+541>:	mov    %r14d,%edx
   0x0000000000006668 <+544>:	mov    %esi,(%rax)
   0x000000000000666a <+546>:	or     $0x80,%dl
   0x000000000000666d <+549>:	mov    %r8d,0x8(%rax)
   0x0000000000006671 <+553>:	mov    %edx,0xc(%rax)


The issue it at this line :

 0x0000000000006653 <+523>:	mov    %rdx,0x8(%rcx)

RCX is NULL it seems.


Cheers,

    Sylvain Munaut
