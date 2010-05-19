From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix problem in dequeuing from input_pkt_queue
Date: Thu, 20 May 2010 07:45:42 +0800
Message-ID: <AANLkTinvSgc3MTAJZEmhBqmRpYlHdOZ6HQ_j43_m8XX1@mail.gmail.com>
References: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45488 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab0ESXqE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 19:46:04 -0400
Received: by pwi5 with SMTP id 5so1792664pwi.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 16:46:02 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 5:47 AM, Tom Herbert <therbert@google.com> wrot=
e:
> Fix some issues introduced in batch skb dequeuing for input_pkt_queue=
=2E
> The primary issue it that the queue head must be incremented only
> after a packet has been processed, that is only after
> __netif_receive_skb has been called. =C2=A0This is needed for the mec=
hanism
> to prevent OOO packet in RFS. =C2=A0Also when flushing the input_pkt_=
queue
> and process_queue, the process queue should be done first to prevent
> OOO packets.
>
> Because the input_pkt_queue has been effectively split into two queue=
s,
> the calculation of the tail ptr is no longer correct. =C2=A0The corre=
ct value
> would be head+input_pkt_queue->len+process_queue->len. =C2=A0To avoid
> this calculation we added an explict input_queue_tail in softnet_data=
=2E
> The tail value is simply incremented when queuing to input_pkt_queue.
>
> In process_backlog the processing of the packet queue can be done
> without irq's being disabled.
>
> =C2=A0static int napi_gro_complete(struct sk_buff *skb)
> @@ -3320,26 +3319,24 @@ static int process_backlog(struct napi_struct=
 *napi, int quota)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0napi->weight =3D weight_p;
> - =C2=A0 =C2=A0 =C2=A0 local_irq_disable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (work < quota) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff=
 *skb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int q=
len;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0while ((skb =3D=
 __skb_dequeue(&sd->process_queue))) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 local_irq_enable();

we need to keep local irq disabled. If not, flush_backlog may be
called, and it will access sd->process_queue.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
