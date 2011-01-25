From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP: fix a bug that triggers large number of TCP RST by mistake
Date: Tue, 25 Jan 2011 15:48:10 -0800
Message-ID: <AANLkTinVrXDUUgpq2=CXqkNdTiidUPYcPVrY3Z3dgtEY@mail.gmail.com>
References: <1295723177-23576-1-git-send-email-hkchu@google.com>
	<20110125.134816.48501871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:53678 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1AYXsO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 18:48:14 -0500
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p0PNmCKf003433
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 15:48:12 -0800
Received: from yxd39 (yxd39.prod.google.com [10.190.1.231])
	by wpaz33.hot.corp.google.com with ESMTP id p0PNllIP002936
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 15:48:11 -0800
Received: by yxd39 with SMTP id 39so2104838yxd.12
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 15:48:11 -0800 (PST)
In-Reply-To: <20110125.134816.48501871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 25, 2011 at 1:48 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Sat, 22 Jan 2011 11:06:17 -0800
>
>> From: Jerry Chu <hkchu@google.com>
>>
>> This patch fixes a bug that causes TCP RST packets to be generated
>> on otherwise correctly behaved applications, e.g., no unread data
>> on close,..., etc. To trigger the bug, at least two conditions must
>> be met:
>>
>> 1. The FIN flag is set on the last data packet, i.e., it's not on a
>> separate, FIN only packet.
>> 2. The size of the last data chunk on the receive side matches
>> exactly with the size of buffer posted by the receiver, and the
>> receiver closes the socket without any further read attempt.
>>
>> This bug was first noticed on our netperf based testbed for our IW10
>> proposal to IETF where a large number of RST packets were observed.
>> netperf's read side code meets the condition 2 above 100%.
>>
>> Before the fix, tcp_data_queue() will queue the last skb that meets
>> condition 1 to sk_receive_queue even though it has fully copied out
>> (skb_copy_datagram_iovec()) the data. Then if condition 2 is also me=
t,
>> tcp_recvmsg() often returns all the copied out data successfully
>> without actually consuming the skb, due to a check
>> "if ((chunk =3D len - tp->ucopy.len) !=3D 0) {"
>> and
>> "len -=3D chunk;"
>> after tcp_prequeue_process() that causes "len" to become 0 and an
>> early exit from the big while loop.
>>
>> I don't see any reason not to free the skb whose data have been full=
y
>> consumed in tcp_data_queue(), regardless of the FIN flag. =A0We won'=
t
>> get there if MSG_PEEK is on. Am I missing some arcane cases related
>> to urgent data?
>>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>
> This bug goes as far back as January, 2000 right after the softnet
> mega-merge happened via the netdev CVS tree (netdev-vger-cvs GIT
> commit 214d457e)

Yes I also tried to trace how long the bug has been there and it seems
to go back to the prehistoric era :). Guess only TCP types got alarmed
by spurious RSTs.

Jerry

>
> Good work, applied, thanks!
>
