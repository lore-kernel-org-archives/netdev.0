From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: TCP - RST flag
Date: Wed, 24 Aug 2011 00:32:00 +0300
Message-ID: <CAEnQRZChkX0K_qWf-Gmu8YeAyxoOb7DTPvvbnA5YxSHEMj_J=g@mail.gmail.com>
References: <CAEnQRZAchYf-3-t7RRogfb0WogzY9ZF8rzMdtOeS1Vdvx7N4og@mail.gmail.com>
	<1314132932.4478.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:38566 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab1HWVcB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 17:32:01 -0400
Received: by qyk34 with SMTP id 34so423019qyk.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 14:32:01 -0700 (PDT)
In-Reply-To: <1314132932.4478.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2011 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 23 ao=FBt 2011 =E0 23:31 +0300, Daniel Baluta a =E9crit :
>> Hello,
>>
>> Please help me understanding the behavior of the following
>> TCP conversation.
>>
>> You can find bellow a snippet of the (FTP) conversation captured bot=
h
>> on client (C) and server (S).
>>
>> [client]$ tcpdump =A0-n =A0-r client-6-conv.cap
>> [P1] 49.045690 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
>> 197:220, ack 81, win 757, length 23
>> [P2] 49.046600 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 22=
0,
>> win 738, length 0
>> [P3] 49.047462 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [P.], seq
>> 81:87, ack 220, win 738, length 6
>> [P5] 49.048757 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [F.], seq
>> 242, ack 87, win 757, length 0
>> [P6] 49.048794 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 22=
0,
>> win 738, options [nop,nop,sack 1 {242:243}], length 0
>> [P4] 49.048801 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
>> 220:242, ack 87, win 757, length 22
>> [P7] 49.048833 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 24=
3,
>> win 715, length 0
>> [P8] 49.049566 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [F.], seq 8=
7,
>> ack 243, win 715, length 0
>> [P9] 49.050889 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [R], seq
>> 1672731590, win 0, length 0
>>
>> [server]$ tcpdump =A0-n =A0-r server-6-conv.cap
>> [P1] 49.059740 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
>> 197:220, ack 81, win 757, length 23
>> [P2] 49.061394 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 22=
0,
>> win 738, length 0
>> [P3] 49.061760 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [P.], seq
>> 81:87, ack 220, win 738, length 6
>> [P4] 49.062794 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
>> 220:242, ack 87, win 757, length 22
>> [P5] 49.062843 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [F.], seq
>> 242, ack 87, win 757, length 0
>> [P6] 49.063808 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 22=
0,
>> win 738, options [nop,nop,sack 1 {242:243}], length 0
>> [P7] 49.063823 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 24=
3,
>> win 715, length 0
>> [P8] 49.064271 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [F.], seq 8=
7,
>> ack 243, win 715, length 0
>> [P9] 49.064481 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [R], seq
>> 1672731590, win 0, length 0
>>
>> What happens is that servers sends packets P4 and P5, but client
>> receives P5 before P4.
>> Since SACK is enabled, client will send a SACK (P6) ack-ing P5.
>>
>> Then client sees P4, and will send an ack (P7) for P4, then sends P8
>> with FIN flag set.
>> What I don't understand, is why server responds with RST (P9) instea=
d of ACK?
>>
>> This is was obtained on 2.6.32.43. I have also attached full capture=
 files.
>>
>> I am reading TCP's RFC and kernel code, but so far I haven't reached
>> a conclusion.
>
> TCP in RFC 1122 section 4.2.2.13:
>
> =A0"A host MAY implement a "half-duplex" TCP close sequence, so that =
an
> =A0application that has called CLOSE cannot continue to read data fro=
m the
> =A0connection. If such a host issues a CLOSE call while received data=
 is
> =A0still pending in TCP, or if new data is received after CLOSE is ca=
lled,
> =A0its TCP SHOULD send a RST to show that data was lost."

So, this means that server's CLOSE operation is issued while received
data is still pending? I will analyze ftp's server code, but this is st=
range
since P4 [221 Have a nice day!\r\n] it is generated as a response for
P3 [QUIT\r\n]. So P4 must have been fully received.

Also, looking at the capture no data is received from the client after
server calls CLOSE (P5) (there are only ACKs and FIN - P6, P7, P8).

> This is why some apps first call shutdown(), then drain receive queue=
,
> then close()

This makes sense :).

thanks Eric.

Daniel.
