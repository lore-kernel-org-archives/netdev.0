From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Tue, 16 Aug 2016 19:34:18 +0800
Message-ID: <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net> <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33222 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbcHPLeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 07:34:20 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> [1]
>> Both sctp_outq_flush_rtx and sctp_packet_transmit can ONLY
>> return one error (-ENOMEM), as sctp_outq_flush_rtx also calls
>> sctp_packet_transmit.
>
> What is the effect of the error?
> If it is 'just' equivalent to a lost ethernet packet (and the skb (etc)
> is freed) then the protocol will recover.
> If it is anything else then the error path is probably wrong.
This err returns back to sctp_sendmsg, there sctp will abort asoc.
in this function, sctp tries to do 3 things:
1. flush rtx queue
2. transmit the packet of current transport
3. flush all the transports.
Now sctp would do them one by one, even if one of them returns err.

>
> Also after one error is it actually worth trying to send anything else
> at all? ISTM that the code should either:
yeah, that's the problem.
the "sctp_flush_out:" code tries to force clear all the transport before
returning even if there're errors already.

> 1) wait for resources and retry.
> 2) discard the entire queue (freeing resource) and hope the protocol
>    timers will recover.
It's a different process, will think about it.

>
>> [2]
>> It's the original codes that it doesn't return immediately when
>> sctp_outq_flush_rtx returns error. I guess it just doesn't want
>> to stop flushing out transport_list only because it fail to flush
>> rtx.
>> even sctp_packet_transmit_chunk in sctp_outq_flush also just
>> put the error into sk->sk_err, instread of returning immediately.
>>
>> So we cannot return the err at the first failure as [2], the error
>> here is always -ENOMEM as [1].
>> I think to return the last error here is ok, at least  not dangerous,
>> can also fix the issue "a success return may hide an error" with
>> clear codes. :)
>
> Which code looks at sk->sk_err?
> It doesn't look right to be setting an error code on the socket due
> a transmit packet discard.
I guess sctp_packet_transmit_chunk's return value is used for
'status' (like PMTU_FULL,RWND_FUL... ), that's why err was
put into sk->sk_err.   This err is supposed to be checked in
sctp_sendmsg, but there sctp_error check sk->sk_err only when
err == -EPIPE.
yes, we need to fix this, thanks.
