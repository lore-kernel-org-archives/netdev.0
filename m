From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Wed, 17 Aug 2016 19:42:37 +0800
Message-ID: <CADvbK_dfc7kmnCP0XgThF9oHX-2tVFNjN1Q-kobqT8WMRv7PqQ@mail.gmail.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net> <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
 <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00E036B@AcuExch.aculab.com>
 <20160816172447.GC3110@localhost.localdomain> <CADvbK_eSD9taybqO0VzfQaUE0jtmKMWiSzkHjO2fNpZrU2Fg3Q@mail.gmail.com>
 <20160816183330.GD3110@localhost.localdomain> <20160816184531.GE3110@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34816 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbcHQLnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 07:43:18 -0400
In-Reply-To: <20160816184531.GE3110@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > If  letting the application see ENOMEM errors, and sctp has to drop this
>> > chunk, instead of retransmiting the ENOMEM chunk, but the ENOMEM
>> > chunk may not be the chunk from current msg, as it flush all the queue.
>> > even if users get an ENOMEM error, they may re-send a chunk that is same
>> > with the one that is still in retransmit queue.
>>
>> Yep, one more reason to handle those internally when safe.
I just checked tcp_sendmsg, it doesn't return any transmit error to user,
*NOT ONLY* ENOMEM.  you can check __tcp_push_pending_frames
and tcp_push, their return type is even void. although it may get
err from sk->sk_err:
    err = sk_stream_error(sk, flags, err);
But I didn't see it put any err into sk->sk_err in the main transmit
path.

yes, tcp_write_xmit has return value, as well as tcp_transmit_skb and
err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl). but
all of them are just used for internal, never return to userspace

In tcp_write_xmit, it even uses "unlikely':
if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
       break;


>
> Xin, maybe you can squash this patch and this ENOMEM handling? I'm
> thinking that handling ENOMEM may result in similar situations in other
> places, so we have a common reasoning on them.
>
So this reason does really matter, and not only for ENOMEM in transmit
path.
