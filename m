From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 /
 master]
Date: Tue, 16 Aug 2016 13:31:31 -0700
Message-ID: <1471379491.4943.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160816104551.GA28052@kroah.com>
	 <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXV-jV0FsAzxt4JYrc6d5LCCLt-5_0uMvM49sV8-+SDDQ@mail.gmail.com>
	 <1471379279.4943.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35561 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbcHPUbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 16:31:33 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so5733398pad.2
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 13:31:33 -0700 (PDT)
In-Reply-To: <1471379279.4943.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-16 at 13:27 -0700, Eric Dumazet wrote:

> 
> Look at skb_entail() : It calls tcp_add_write_queue_tail()
> 
> And tcp_add_write_queue_tail() looks like :
> 
> 
> static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
> {
>         __tcp_add_write_queue_tail(sk, skb);
> 
>         /* Queue it, remembering where we must start sending. */
>         if (sk->sk_send_head == NULL) {
>                 sk->sk_send_head = skb;
> 
>                 if (tcp_sk(sk)->highest_sack == NULL)
>                         tcp_sk(sk)->highest_sack = skb;
>         }
> }
> 
> 
> So we definitely need to undo what tcp_add_write_queue_tail() did.

So the bug was probably added in 2.6.25 

commit 6859d49475d4f32abe640372117e4b687906e6b6
Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Date:   Sun Dec 2 00:48:06 2007 +0200

    [TCP]: Abstract tp->highest_sack accessing & point to next skb
    
    Pointing to the next skb is necessary to avoid referencing
    already SACKed skbs which will soon be on a separate list.
    
    Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
