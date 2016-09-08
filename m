From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: XPS configuration question (on tg3)
Date: Wed, 07 Sep 2016 17:13:54 -0700
Message-ID: <1473293634.15733.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5b9c6d9d-6905-e3ee-515f-cc68c63078f7@ziu.info>
         <CAKgT0Ud3bRbi0muyB-0nRTS-NbimrgxzhG0cop1bs6MhrV2V-A@mail.gmail.com>
         <6d222016-5ec5-7805-08f3-82844b49c872@ziu.info>
         <1473207563.10725.22.camel@edumazet-glaptop3.roam.corp.google.com>
         <606e134e-ef0b-1b01-e8ec-8c0922172e53@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36840 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcIHAN7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:13:59 -0400
Received: by mail-pf0-f181.google.com with SMTP id 128so11544457pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 17:13:58 -0700 (PDT)
In-Reply-To: <606e134e-ef0b-1b01-e8ec-8c0922172e53@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 01:45 +0200, Michal Soltys wrote:
> > Keep in mind that TCP stack can send packets, responding to incoming
> > ACK.
> > 
> > So you might check that incoming ACK are handled by the 'right' cpu.
> > 
> > Without RFS, there is no such guarantee.

> Did some more testing today, indeed RFS helped with TCP flows, but ....
> it got me wondering:
> 
> In scenario such as: XPS off, RFS/RPS off, irqs pinned, process
> transfering data pinned - one tx queue was chosen (through hash) and
> consistently persisted throughout the whole transfer. No exceptions, at
> least none in the tests I did.

It depends if at least one packet for each flow sits in a qdisc/NIC
queue. TCP has this Out Of Order transmit logic preventing a TX queue
change, even if the process doing the sendmsg() is migrated.

git grep -n ooo_okay

> 
> When XPS is getting enabled, the only thing that changes is that instead
> of using hash to select one of available queues, the cpu running process
> is specifically told which queue it can use (and eventually selects one
> through hash if more than one is available). Shouldn't the choice
> persist throughout the transfer as well then ?

Sure, if the process doing the sendmsg() sticks to one cpu, and this cpu
is the one handling incoming ACK packets as well.
