From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Mon, 25 Oct 2010 10:02:05 -0700
Message-ID: <AANLkTi=Pzxnf=bJXANwz8Rmd8GOUu9oxpO_YF6udJE01@mail.gmail.com>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
	<20101024.153206.179940220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:61657 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758705Ab0JYRCJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 13:02:09 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o9PH27IR025414
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 10:02:07 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by kpbe17.cbf.corp.google.com with ESMTP id o9PH25we009336
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 10:02:06 -0700
Received: by pvc30 with SMTP id 30so454083pvc.23
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 10:02:05 -0700 (PDT)
In-Reply-To: <20101024.153206.179940220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 3:32 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 21 Oct 2010 13:17:08 -0700 (PDT)
>
>> @@ -822,8 +822,10 @@ static int tcp_transmit_skb(struct sock *sk, st=
ruct sk_buff *skb, int clone_it,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&md5);
>> =A0 =A0 =A0 tcp_header_size =3D tcp_options_size + sizeof(struct tcp=
hdr);
>>
>> - =A0 =A0 if (tcp_packets_in_flight(tp) =3D=3D 0)
>> + =A0 =A0 if (tcp_packets_in_flight(tp) =3D=3D 0) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_ca_event(sk, CA_EVENT_TX_START);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->ooo_okay =3D 1;
>> + =A0 =A0 }
>>
>
> You'll need to clear this flag the moment the first transmit of
> this packet happens, otherwise OOO won't be handled correctly in
> the event that fast retransmit is necessary later.
>

Would this be sufficient:

@@ -825,7 +825,8 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb
        if (tcp_packets_in_flight(tp) =3D=3D 0) {
                tcp_ca_event(sk, CA_EVENT_TX_START);
                skb->ooo_okay =3D 1;
-       }
+       } else
+               skb->ooo_okay =3D 0;
