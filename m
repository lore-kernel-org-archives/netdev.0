From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Tue, 24 Feb 2015 16:07:07 +0200
Message-ID: <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
	<CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	<CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	<1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45626 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbBXOHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 09:07:08 -0500
Received: by pdjz10 with SMTP id z10so33499771pdj.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 06:07:08 -0800 (PST)
In-Reply-To: <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Feb 24, 2015 at 3:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-02-24 at 12:10 +0200, Eyal Birger wrote:
>
>>
>> Well, gave it a shot... it looks like several protocol families
>> (packet, rxrpc, bluetooth) do not
>> have room in skb->cb[] for the dropcount - at least on my 64 bit machine.
>
> No idea how you took a look ?
>
> sizeof(struct packet_skb_cb) == 24  : We have plenty of room ?
>

Well, I took a look, then I tried :)

It breaks in packet_rcv() in a BUILD_BUG_ON() assertion. The asserted size is:

sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8

This was introduced in ffbc61117d32dc4e768 ("[PACKET]: Fix skb->cb
clobbering between aux and sockaddr")
It requires the ability to store the maximal possible address length (32).

>
> bluetooth : Whole struct rxrpc_skb_priv is not used when packet is
> stored in receive queue.
>
> We only need bt_cb(skb)->psm & bt_cb(skb)->bdaddr according to
> l2cap_skb_msg_name()
>
> An union will be possible.
>

I can look into that.

> rxpc is buggy right now anyway, as it reads skb->mark _and_ uses
> sock_recv_ts_and_drops(), so skb->mark value is pretty much void.
>

Yes, but it does not seem to use sock_queue_rcv_skb() which sets skb->dropcount.
BTW, aliasing priority instead of mark would allow someone to refactor rxrpc to
use sock_queue_rcv_skb() if desired.

> Note that resend_at field could probably converted into u32. tcp stack
> uses same (u32)jiffies trick (tcp_time_stamp)
>
>
> I never said it was going to be easy ;)
>

I don't mind :) though I wonder whether the added complexity in
partitioning skb->cb[]
between the protocol families and the socket layer is worth it.
