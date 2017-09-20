From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Tue, 19 Sep 2017 22:13:47 -0700
Message-ID: <1505884427.29839.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
         <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
         <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
         <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com>
         <1505231262.15310.149.camel@edumazet-glaptop3.roam.corp.google.com>
         <ef594f90-0f76-bdf5-63ce-e8750ee0d60f@intel.com>
         <CALx6S372oQ4OsyMd66zwQ08pMvPvLj7Ejf=Cv24xDkdtVXaYjA@mail.gmail.com>
         <9b247caf-fde0-1e39-aa94-f7b3bc4fc88a@intel.com>
         <CALx6S35wbwhz7COqGuUgJZcd8TwYcaVOHpxZxTOd4TuQX76Crg@mail.gmail.com>
         <fe565f14-156e-d703-c91d-d67136a0a0c0@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38577 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdITFNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 01:13:50 -0400
Received: by mail-io0-f193.google.com with SMTP id e9so1408887iod.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 22:13:50 -0700 (PDT)
In-Reply-To: <fe565f14-156e-d703-c91d-d67136a0a0c0@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 21:59 -0700, Samudrala, Sridhar wrote:
> On 9/19/2017 5:48 PM, Tom Herbert wrote:
> > On Tue, Sep 19, 2017 at 5:34 PM, Samudrala, Sridhar
> > <sridhar.samudrala@intel.com> wrote:
> > > On 9/12/2017 3:53 PM, Tom Herbert wrote:
> > > > On Tue, Sep 12, 2017 at 3:31 PM, Samudrala, Sridhar
> > > > <sridhar.samudrala@intel.com> wrote:
> > > > > 
> > > > > On 9/12/2017 8:47 AM, Eric Dumazet wrote:
> > > > > > On Mon, 2017-09-11 at 23:27 -0700, Samudrala, Sridhar wrote:
> > > > > > > On 9/11/2017 8:53 PM, Eric Dumazet wrote:
> > > > > > > > On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:
> > > > > > > > 
> > > > > > > > > Two ints in sock_common for this purpose is quite expensive and the
> > > > > > > > > use case for this is limited-- even if a RX->TX queue mapping were
> > > > > > > > > introduced to eliminate the queue pair assumption this still won't
> > > > > > > > > help if the receive and transmit interfaces are different for the
> > > > > > > > > connection. I think we really need to see some very compelling
> > > > > > > > > results
> > > > > > > > > to be able to justify this.
> > > > > > > Will try to collect and post some perf data with symmetric queue
> > > > > > > configuration.
> > > 
> > > Here is some performance data i collected with memcached workload over
> > > ixgbe 10Gb NIC with mcblaster benchmark.
> > > ixgbe is configured with 16 queues and rx-usecs is set to 1000 for a very
> > > low
> > > interrupt rate.
> > >       ethtool -L p1p1 combined 16
> > >       ethtool -C p1p1 rx-usecs 1000
> > > and busy poll is set to 1000usecs
> > >       sysctl net.core.busy_poll = 1000
> > > 
> > > 16 threads  800K requests/sec
> > > =============================
> > >                   rtt(min/avg/max)usecs     intr/sec contextswitch/sec
> > > -----------------------------------------------------------------------
> > > Default                2/182/10641            23391 61163
> > > Symmetric Queues       2/50/6311              20457 32843
> > > 
> > > 32 threads  800K requests/sec
> > > =============================
> > >                  rtt(min/avg/max)usecs     intr/sec contextswitch/sec
> > > ------------------------------------------------------------------------
> > > Default                2/162/6390            32168 69450
> > > Symmetric Queues        2/50/3853            35044 35847
> > > 
> > No idea what "Default" configuration is. Please report how xps_cpus is
> > being set, how many RSS queues there are, and what the mapping is
> > between RSS queues and CPUs and shared caches. Also, whether and
> > threads are pinned.
> Default is linux 4.13 with the settings i listed above.    
>         ethtool -L p1p1 combined 16
>         ethtool -C p1p1 rx-usecs 1000
>         sysctl net.core.busy_poll = 1000
> 
> # ethtool -x p1p1
> RX flow hash indirection table for p1p1 with 16 RX ring(s):
>     0:      0     1     2     3     4     5     6     7
>     8:      8     9    10    11    12    13    14    15
>    16:      0     1     2     3     4     5     6     7
>    24:      8     9    10    11    12    13    14    15
>    32:      0     1     2     3     4     5     6     7
>    40:      8     9    10    11    12    13    14    15
>    48:      0     1     2     3     4     5     6     7
>    56:      8     9    10    11    12    13    14    15
>    64:      0     1     2     3     4     5     6     7
>    72:      8     9    10    11    12    13    14    15
>    80:      0     1     2     3     4     5     6     7
>    88:      8     9    10    11    12    13    14    15
>    96:      0     1     2     3     4     5     6     7
>   104:      8     9    10    11    12    13    14    15
>   112:      0     1     2     3     4     5     6     7
>   120:      8     9    10    11    12    13    14    15
> 
> smp_affinity for the 16 queuepairs
>         141 p1p1-TxRx-0 0000,00000001
>         142 p1p1-TxRx-1 0000,00000002
>         143 p1p1-TxRx-2 0000,00000004
>         144 p1p1-TxRx-3 0000,00000008
>         145 p1p1-TxRx-4 0000,00000010
>         146 p1p1-TxRx-5 0000,00000020
>         147 p1p1-TxRx-6 0000,00000040
>         148 p1p1-TxRx-7 0000,00000080
>         149 p1p1-TxRx-8 0000,00000100
>         150 p1p1-TxRx-9 0000,00000200
>         151 p1p1-TxRx-10 0000,00000400
>         152 p1p1-TxRx-11 0000,00000800
>         153 p1p1-TxRx-12 0000,00001000
>         154 p1p1-TxRx-13 0000,00002000
>         155 p1p1-TxRx-14 0000,00004000
>         156 p1p1-TxRx-15 0000,00008000
> xps_cpus for the 16 Tx queues
>         0000,00000001
>         0000,00000002
>         0000,00000004
>         0000,00000008
>         0000,00000010
>         0000,00000020
>         0000,00000040
>         0000,00000080
>         0000,00000100
>         0000,00000200
>         0000,00000400
>         0000,00000800
>         0000,00001000
>         0000,00002000
>         0000,00004000
>         0000,00008000
> memcached threads are not pinned.
> 

...

I urge you to take the time to properly tune this host.

linux kernel does not do automagic configuration. This is user policy.

Documentation/networking/scaling.txt has everything you need.
