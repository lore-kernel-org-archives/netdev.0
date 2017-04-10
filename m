From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Non-standard TCP stack processing of packets with unacceptable
 ACK numbers
Date: Mon, 10 Apr 2017 08:34:53 -0700
Message-ID: <1491838493.10587.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frits Vaandrager <F.Vaandrager@cs.ru.nl>
To: Paul Fiterau Brostean <p.fiterau-brostean@science.ru.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34781 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754762AbdDJPe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:34:57 -0400
Received: by mail-pg0-f45.google.com with SMTP id 21so107790866pgg.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:34:56 -0700 (PDT)
In-Reply-To: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 22:29 +0200, Paul Fiterau Brostean wrote:
> Hello,
> 
> My name is Paul Fiterau, I am a PhD student at Radboud University whose 
> focus for the past few years has been among others to develop and apply 
> inference techniques on TCP stacks in order to obtain nice models, and 
> to verify them if possible using formal methods.  We contacted you on 
> something similar 2 years back.
> 
> The older (3.19 kernel release) Linux TCP stack we analyze exhibits 
> behavior that seems odd to me. The scenario is as follows (all packets 
> have empty payloads, no window scaling, rcv/snd window size should not 
> be a factor):
> 
>        TEST HARNESS (CLIENT)                        LINUX SERVER
> 
>    1.  -                                          LISTEN (server listen, then accepts)
> 
>    2.  - --> <SEQ=100><CTL=SYN>               --> SYN-RECEIVED
> 
>    3.  - <-- <SEQ=300><ACK=101><CTL=SYN,ACK>  <-- SYN-RECEIVED
> 
>    4.  - --> <SEQ=101><ACK=301><CTL=ACK>      --> ESTABLISHED
>   
>    5.  - <-- <SEQ=301><ACK=101><CTL=FIN,ACK>  <-- FIN WAIT-1 (server opts to close the data connection calling "close" on the connection socket)
> 
>    6.  - --> <SEQ=101><ACK=99999><CTL=FIN,ACK> --> CLOSING (client sends FIN,ACK with not yet sent acknowledgement number)
> 
>    7.  - <-- <SEQ=302><ACK=102><CTL=ACK>      <-- CLOSING (ACK is 102 instead of 101, why?)
>   
> ... (silence from CLIENT)
> 
>    8.  - <-- <SEQ=301><ACK=102><CTL=FIN,ACK>  <-- CLOSING (retransmission, again ACK is 102)
> 
> 
> Now, note that packet 6 while having the expected sequence number, 
> acknowledges something that wasn't sent by the server. So I would expect 
> the packet to maybe prompt an ACK response from the server, and then be 
> ignored. Yet it is not ignored and actually leads to an increase of the 
> acknowledgement number in the server's retransmission of the FIN,ACK 
> packet. The explanation I found is that the FIN  in packet 6 was 
> processed, despite the acknowledgement number being unacceptable. 
> Further experiments indeed show that the server processes this FIN, 
> transitioning to CLOSING, then on receiving an ACK for the FIN it had 
> send in packet 5, the server (or better said connection) transitions 
> from CLOSING to TIME_WAIT (as signaled by netstat).
> 
> 
> I attached a capture showing the scenario, as well as an equivalent 
> capture for a Windows 10 TCP server, which behaves exactly as I would 
> expect by  not increasing the expected sequence number after packet 6, 
> and thus not processing the FIN flag received.
> 
> I hope someone more knowledgeable can clear this up for me. Is it ok for 
> the server to process the FIN bit in a packet with an unacceptable 
> acknowledgement number? Could this be an inconsistency in the tested stack?

Hi Paul.

Thanks for your report, we will take a look at this today.
