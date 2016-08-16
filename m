From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Wed, 17 Aug 2016 02:24:19 +0800
Message-ID: <CADvbK_eSD9taybqO0VzfQaUE0jtmKMWiSzkHjO2fNpZrU2Fg3Q@mail.gmail.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net> <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00DFD69@AcuExch.aculab.com>
 <CADvbK_fsH9RAc_r6SaTKYTUJusGcZzPuCXX3zntH7UhFFWq-Cg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00E036B@AcuExch.aculab.com> <20160816172447.GC3110@localhost.localdomain>
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
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35105 "EHLO
	mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcHPSYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 14:24:34 -0400
In-Reply-To: <20160816172447.GC3110@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > This err returns back to sctp_sendmsg, there sctp will abort asoc.
>
> That's not right I think. sctp_sendmsg will only free the asoc if it was
> created to send that specific chunk. And in this case, this change
> should have no effect as it can't have sctp_outq_flush() touching
> several transports in a row.
>
> I'm basing on:
> out_free:
>         if (new_asoc)
>                 sctp_association_free(asoc);
>
> and sctp_recvmsg will just fetch, return and clear the error via
> sctp_skb_recv_datagram, but not free it.
>
> Do you see any other place freeing it?
Sorry, you are right, it free assoc just for new_asoc.

>
>>
>> That doesn't seem a good idea.
>> You don't want to abort the association if there is a transient
>> memory allocation failure.
>> You also can't drop data chunks.
>
> From a system-wise POV, this behavior - to free the new asoc in case of
> transient memory allocation failure - doesn't seem bad to me.
> That's what will have to happen if any allocation before it failed and
> also it helps the system to reduce the stress a little bit. I don't see
> any inconsistency/problems here because we are not dropping a single
> random chunk but instead we are actually refusing to initialize a new
> asoc in such conditions.
>
> Nevertheless, I agree that letting the application see ENOMEM errors when
> the data actually got queued and is being fully handled, as in, it will
> be retransmitted later, is not be wise, as the application probably
> won't be able to distinguish from ENOMEMs that it should retry or not.
> Here I see a problem, yet it's not due to this specific change, perhaps
> it just got attention because of it. In this situation, we should handle
> ENOMEMs internally if possible so the application can know that if it
> hits an ENOMEM, it's real and it has to retry.
If  letting the application see ENOMEM errors, and sctp has to drop this
chunk, instead of retransmiting the ENOMEM chunk, but the ENOMEM
chunk may not be the chunk from current msg, as it flush all the queue.
even if users get an ENOMEM error, they may re-send a chunk that is same
with the one that is still in retransmit queue.

>
> Fixing this inconsistency may very well cause us to let that new asoc to
> live longer, works for me too.
>
>>
>> > in this function, sctp tries to do 3 things:
>> > 1. flush rtx queue
>> > 2. transmit the packet of current transport
>> > 3. flush all the transports.
>> > Now sctp would do them one by one, even if one of them returns err.
>>
>> You probably need to explain what 'flush' means here.
>> I think it means 'process and send', but it might mean 'discard the
>> contents of'.
>
> Yes, the first. He probably use the work 'flush' because the function is
> called .._flush_..
Yes, :D

>
>> Last time I looked at the sctp code my head exploded.
>> ISTR it is a mess of timing errors waiting to happen
>> (and I write comms protocol stack code for a living).
>
> Well, it may be, but we are trying to improve it.  Please continue
> discussing the fixes so we can keep improving it. :)
>
>   Marcelo
>
