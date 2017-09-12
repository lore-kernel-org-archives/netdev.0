From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Tue, 12 Sep 2017 08:47:42 -0700
Message-ID: <1505231262.15310.149.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
         <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
         <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
         <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34973 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdILPrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 11:47:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id i23so1591618pfi.2
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 08:47:43 -0700 (PDT)
In-Reply-To: <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-11 at 23:27 -0700, Samudrala, Sridhar wrote:
> 
> On 9/11/2017 8:53 PM, Eric Dumazet wrote:
> > On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:
> >
> >> Two ints in sock_common for this purpose is quite expensive and the
> >> use case for this is limited-- even if a RX->TX queue mapping were
> >> introduced to eliminate the queue pair assumption this still won't
> >> help if the receive and transmit interfaces are different for the
> >> connection. I think we really need to see some very compelling results
> >> to be able to justify this.
> Will try to collect and post some perf data with symmetric queue 
> configuration.
> 
> > Yes, this is unreasonable cost.
> >
> > XPS should really cover the case already.
> >   
> Eric,
> 
> Can you clarify how XPS covers the RX-> TX queue mapping case?
> Is it possible to configure XPS to select TX queue based on the RX queue 
> of a flow?
> IIUC, it is based on the CPU of the thread doing the transmit OR based 
> on skb->priority to TC mapping?
> It may be possible to get this effect if the the threads are pinned to a 
> core, but if the app threads are
> freely moving, i am not sure how XPS can be configured to select the TX 
> queue based on the RX queue of a flow.

If application is freely moving, how NIC can properly select the RX
queue so that packets are coming to the appropriate queue ?

This is called aRFS, and it does not scale to millions of flows.
We tried in the past, and this went nowhere really, since the setup cost
is prohibitive and DDOS vulnerable.

XPS will follow the thread, since selection is done on current cpu.

The problem is RX side. If application is free to migrate, then special
support (aRFS) is needed from the hardware.

At least for passive connections, we already have all the support in the
kernel so that you can have one thread per NIC queue, dealing with
sockets that have incoming packets all received on one NIC RX queue.
(And of course all TX packets will use the symmetric TX queue)

SO_REUSEPORT plus appropriate BPF filter can achieve that.

Say you have 32 queues, 32 cpus.

Simply use 32 listeners, 32 threads (or 32 pools of threads)
