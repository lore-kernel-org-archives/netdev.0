From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Sat, 13 Aug 2016 15:47:46 +0800
Message-ID: <CADvbK_dXX=Z8yr_yQPpHe2zst9uFYkMeL9-fHx17ZOCb5-x07A@mail.gmail.com>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
 <20160812.211113.1099230839994600349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33636 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcHMHrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 03:47:48 -0400
In-Reply-To: <20160812.211113.1099230839994600349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This style of error handling is dangerous.  The first error can be
> lost.
>
> For example, if sctp_outq_flush_rtx() earlier in this function returns
> an error, it will be lost if any invocation of the function
> sctp_packet_transmit() at the end function signals an error.
>
> I think you should always preserve the first error that is recorded
> into 'error'.
>
> I also wonder about why sctp_outq_flush_rtx() errors are completely
> ignored and don't influence the control flow here in any way.

Yes, the first error can be lost.
Here we just keep the last error. We don't really have to return the
first error or return it on the first failure.

[1]
Both sctp_outq_flush_rtx and sctp_packet_transmit can ONLY
return one error (-ENOMEM), as sctp_outq_flush_rtx also calls
sctp_packet_transmit.

[2]
It's the original codes that it doesn't return immediately when
sctp_outq_flush_rtx returns error. I guess it just doesn't want
to stop flushing out transport_list only because it fail to flush
rtx.
even sctp_packet_transmit_chunk in sctp_outq_flush also just
put the error into sk->sk_err, instread of returning immediately.

So we cannot return the err at the first failure as [2], the error
here is always -ENOMEM as [1].
I think to return the last error here is ok, at least  not dangerous,
can also fix the issue "a success return may hide an error" with
clear codes. :)
