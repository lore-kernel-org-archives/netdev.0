From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet loss when txqueuelen is zero
Date: Sat, 28 Jun 2014 07:40:18 -0700
Message-ID: <1403966418.15139.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53AEA00F.6060500@lategoodbye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Stefan Wahren <info@lategoodbye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:54217 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbaF1OkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 10:40:22 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so6392967wes.10
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 07:40:21 -0700 (PDT)
In-Reply-To: <53AEA00F.6060500@lategoodbye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-06-28 at 12:59 +0200, Stefan Wahren wrote:
> Hi,
> 
> i'm new to Linux network driver development and currently i want to port 
> the QCA7000 network driver to mainline [1]. I concentrate my tests on tx 
> buffering since my last QCA7000 patch RFC [2]. Now i've found a test 
> scenario which leads to packet loss:
> 
> host A          Powerline       host B
> (QCA7000)       Ethernet        Ethernet
> 192.168.1.3     adaptor         192.168.1.5
> |------------------|---------------|
>       Homeplug         Ethernet
>       10 Mbit          100 Mbit
> 
> 1. Reduce the txqueuelen from 100 (default value) to 0
> 2. Run ping in flood mode on host A to host B
> 
> ping -c 200 -s 10000 -f 192.168.1.5
> 
> 3. ping reports a high packet loss
> 
> Additional information:
> - QCA7000 network driver has a tx ring size of 10 packets
> - the packet loss doesn't appear when txqueuelen is 100
> 
> Here are my questions:
> 
> Is the packet loss a expected result for this scenario?

Sure it is totally expected.

-f is a flood ping, and you remove ability to store packets in the Qdisc
(pifo_fast limit is device txqueuelen).

If you have txqueuelen = 100, then the socket used by ping will more
likely hit its SO_SNDBUF limit and ping will handle this properly (it
detects that a sendmsg() returns -1, errno = ENOBUF

If QCA7000 network driver has a tx ring size of 10 packets, you really
want a qdisc being able to store bursts.

If bufferbloat is your concern, you can switch pfifo_fast to fq_codel or
fq

tc qdisc replace dev eth0 root fq_codel  (or fq to get TCP pacing)
