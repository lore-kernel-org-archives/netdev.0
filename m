From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: rxrpc: change call to
 sock_recv_ts_and_drops() on rxrpc recvmsg to sock_recv_timestamp()
Date: Thu, 26 Feb 2015 09:30:30 +0200
Message-ID: <CAHsH6Gup09dtVZEi-vmp5ep_rs1ELueDudMJy1084e5vDbqJ0Q@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-4-git-send-email-eyal.birger@gmail.com>
	<1424925652.5565.145.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:37640 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbBZHab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:30:31 -0500
Received: by ykq19 with SMTP id 19so3299189ykq.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:30:30 -0800 (PST)
In-Reply-To: <1424925652.5565.145.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> However, protocol families wishing to receive dropcount should call
>> sock_queue_rcv_skb() or set the dropcount specifically (as done
>> in packet_rcv()). This was not done for rxrpc and thus this feature
>> never worked on these sockets.
>>
>> Formalizing this by not calling sock_recv_ts_and_drops() in rxrpc as
>> part of an effort to move skb->dropcount into skb->cb[]
>>
>> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
>> ---
>>  net/rxrpc/ar-recvmsg.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
>> index 4575485..d58ba70 100644
>> --- a/net/rxrpc/ar-recvmsg.c
>> +++ b/net/rxrpc/ar-recvmsg.c
>> @@ -150,7 +150,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
>>                                      &call->conn->trans->peer->srx, len);
>>                               msg->msg_namelen = len;
>>                       }
>> -                     sock_recv_ts_and_drops(msg, &rx->sk, skb);
>> +                     sock_recv_timestamp(msg, &rx->sk, skb);
>>               }
>
> I guess this should be the last patch of the serie, as this will
> overwrite skb->mark, and rxrpc seems to care about skb->mark
>

Maybe I didn't understand your comment. Note this patch does not fix
SO_RXQ_OVFL on rxrpc sockets.

I essentially reverted 3b885787ea4112 for these sockets.

It may be possible to compact rxrpc skb->cb[] usage by tricking the size
of the resend_at variable as you suggested.

However, since SO_RXQ_OVFL never really worked on these sockets,
I limited the patch series scope to moving skb->dropcount; This patch only
signals that rxrpc can't support this feature unless some space is freed in its
skb->cb[] use.
