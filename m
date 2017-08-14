From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 12:15:27 -0700
Message-ID: <4013878.dizogNlyrN@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1756525.aGoekHffaC@tjmaciei-mobl1> <CAF=yD-K4HgOhMMT0tWycZgcqhU5OACQk_roPQEeRems1_Azhgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41107 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdHNTPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:15:36 -0400
In-Reply-To: <CAF=yD-K4HgOhMMT0tWycZgcqhU5OACQk_roPQEeRems1_Azhgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 August 2017 12:03:16 PDT Willem de Bruijn wrote:
> On Mon, Aug 14, 2017 at 2:58 PM, Thiago Macieira
> 
> <thiago.macieira@intel.com> wrote:
> > On Monday, 14 August 2017 11:46:42 PDT Willem de Bruijn wrote:
> >> > By the way, what were the usecases for the peek offset feature?
> >> 
> >> The idea was to be able to peek at application headers of upper
> >> layer protocols and multiplex messages among threads. It proved
> >> so complex even for UDP that we did not attempt the same feature
> >> for TCP. Also, KCM implements demultiplexing using eBPF today.
> > 
> > Interesting, but how would userspace coordinate like that? Suppose
> > multiple
> > threads are woken up by a datagram being received
> 
> This assumes a separate listener thread and worker threadpool.

The listener thread still needs to synchronise with the worker that got 
activated and wait for it to recv from the socket before the listener thread 
can go back to poll().

If we are really talking about threads in the same process, it might be easier 
for the listener to just read the datagram anyway and pass it on to the 
worker. That way, it can proceed immediately to the next datagram and not have 
to wait for the possibly slow worker.

If it is a separate process, then I don't see another way and this might be 
necessary.

By the way, what does recv with MSG_PEEK | MSG_TRUNC return? Is it the full 
datagram's size or is it the size minus the peek offset?

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
