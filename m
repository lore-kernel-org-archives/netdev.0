From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Wed, 21 Apr 2010 16:23:05 -0700
Message-ID: <k2n65634d661004211623k3ce51c95o2c329529ce402eda@mail.gmail.com>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	 <1271891149.7895.3751.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:2841 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab0DUXXK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:23:10 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o3LNN7Zx016101
	for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 01:23:08 +0200
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe17.cbf.corp.google.com with ESMTP id o3LNN6Tu020333
	for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 16:23:06 -0700
Received: by pwi8 with SMTP id 8so4971864pwi.1
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 16:23:06 -0700 (PDT)
In-Reply-To: <1271891149.7895.3751.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =A0 =A0 =A0 =A0do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lim =3D quota - work;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lim > ARRAY_SIZE(sd->batch))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lim =3D ARRAY_SIZE(sd->=
batch);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* batch at most 16 buffers */
>

How about just using two input_pkt_queue's (define
input_pkt_queue[2])?  One that is used to enqueue from RPS, and one
that is being processed by process_backlog.  Then the only thing that
needs to be done under lock in process_backlog is to switch the
queues;  something like sd->current_input_pkt_queue ^=3D 1

Tom

> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rps_lock(sd);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D __skb_dequeue(&sd->input_pkt_qu=
eue);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (n =3D 0; n < lim; n++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sd->batch[n] =3D __skb_=
dequeue(&sd->input_pkt_queue);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sd->batch[n])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sd->input_pkt_queue.qlen) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__napi_complete(napi);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_unlock(sd);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 quota =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 input_queue_head_incr(sd);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rps_unlock(sd);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __netif_receive_skb(skb);
> - =A0 =A0 =A0 } while (++work < quota);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Now process our batch */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < n; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D sd->batch[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* flush_backlog() migh=
t have stolen this skb */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 input_queue_head_incr(s=
d);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sd->bat=
ch[i] =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_i=
rq_enable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __netif=
_receive_skb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_i=
rq_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 work +=3D n;
> + =A0 =A0 =A0 } while (work < quota);
>
> + =A0 =A0 =A0 local_irq_enable();
> =A0 =A0 =A0 =A0return work;
> =A0}
>
>
>
>
