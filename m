From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Wed, 25 Feb 2015 16:10:29 +0200
Message-ID: <CAHsH6GthPu2w8F+jqbeMt9kano6uHdicrmMhsLugLt-0exLVUw@mail.gmail.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
	<20150223.164801.842537100812023841.davem@davemloft.net>
	<CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	<CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	<1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:35673 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbBYOKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 09:10:30 -0500
Received: by ykbq200 with SMTP id q200so953155ykb.2
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 06:10:29 -0800 (PST)
In-Reply-To: <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> bluetooth : Whole struct rxrpc_skb_priv is not used when packet is
>> stored in receive queue.
>>
>> We only need bt_cb(skb)->psm & bt_cb(skb)->bdaddr according to
>> l2cap_skb_msg_name()
>>
>> An union will be possible.
>>
>
> I can look into that.

Another approach is to get rid struct_req_ctrl defintion -
It is never used as a separate object outside of struct bt_skb_cb and inlining
it saves 8 bytes on a 64 bit machine, i.e.:

 typedef void (*hci_req_complete_t)(struct hci_dev *hdev, u8 status,
u16 opcode);

-struct hci_req_ctrl {
-       bool                    start;
-       u8                      event;
-       hci_req_complete_t      complete;
-};
-
 struct bt_skb_cb {
        __u8 pkt_type;
        __u8 incoming;
        __u16 opcode;
        __u16 expect;
        __u8 force_active;
+       bool req_start;
+       u8 req_event;
+       hci_req_complete_t req_complete;
        struct l2cap_chan *chan;
        struct l2cap_ctrl control;
-       struct hci_req_ctrl req;
        bdaddr_t bdaddr;
        __le16 psm;
 };

Would you prefer this approach?
