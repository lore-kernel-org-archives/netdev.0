From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss >
 window)
Date: Fri, 13 Jan 2017 09:41:27 -0800
Message-ID: <1484329287.13165.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
         <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
         <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
         <CANn89i+5m2uUBmHRHG32_oPyR53vQoG4SfOY6xWG_RNxPz6dZw@mail.gmail.com>
         <CADVnQykVj0CdHVYkfuogy6nOxfL+ODXue-3siKh_oACCBjVrtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33350 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdAMRlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:41:51 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so9234295pfg.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 09:41:34 -0800 (PST)
In-Reply-To: <CADVnQykVj0CdHVYkfuogy6nOxfL+ODXue-3siKh_oACCBjVrtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 12:32 -0500, Neal Cardwell wrote:
> On Fri, Jan 13, 2017 at 12:14 PM, Eric Dumazet <edumazet@google.com> wrote:
> >
> > On Fri, Jan 13, 2017 at 9:07 AM, Alexey Kodanev
> > <alexey.kodanev@oracle.com> wrote:
> > > Hi Eric,
> > > On 13.01.2017 18:35, Eric Dumazet wrote:
> >
> > >> Care to send a packetdrill test so that we have a clear picture of what
> > >> is going on ?
> > >
> > > Is it capable of making two connections in the single test, one after
> > > another?
> >
> > Absolutely.
> >
> > Neal, Yuchung would you be kind enough to send a Fastopen tpacketdrill
> > template showing a typical fastopen test
> > running on an upstream kernel ?
> >
> > Thanks !
> 
> Sure, here is an example packetdrill script, IIRC written by Yuchung,
> which demonstrates TCP fast open and consecutive active connections:
> 
> `sysctl -q net.ipv4.tcp_timestamps=0`
> 
> // Cache warmup: send a Fast Open cookie request
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>    +0 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
>    +0 sendto(3, ..., 0, MSG_FASTOPEN, ..., ...) = -1 EINPROGRESS
> (Operation is now in progress)
>    +0 > S 0:0(0) <mss 1460,nop,nop,sackOK,nop,wscale 8,FO,nop,nop>
> +.010 < S. 123:123(0) ack 1 win 5840 <mss
> 1040,nop,nop,sackOK,nop,wscale 6,FO abcd1234,nop,nop>
>    +0 > . 1:1(0) ack 1
>    +0 close(3) = 0
>    +0 > F. 1:1(0) ack 1
> +.010 < F. 1:1(0) ack 2 win 92
>    +0 > .  2:2(0) ack 2
> 
> //
> // TEST1: Servers sends SYN-ACK with data and another two data packets
> //
>    +0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 4
>    +0 fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK) = 0
>    +0 sendto(4, ..., 1000, MSG_FASTOPEN, ..., ...) = 1000
>    +0 > S 0:1000(1000) <mss 1460,nop,nop,sackOK,nop,wscale 8,FO
> abcd1234,nop,nop>
> +.010 < S. 1000000:1001400(1400) ack 1001 win 5840 <mss
> 1040,nop,nop,sackOK,nop,wscale 6>
>    +0 < . 1401:2801(1400) ack 1001 win 257
>    +0 < P. 2801:3001(200) ack 1001 win 257
> 
> neal

Thanks Neal

Also worth adding that packetdrill has the following option to tune the
MTU on the tun device :

--mtu=xxxxx
