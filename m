From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: A second case of XPS considerably reducing single-stream performance
Date: Thu, 25 Aug 2016 12:19:17 -0700
Message-ID: <CAKgT0UeQ_cL4aaSSc47EgzbYp7WZF7C-4+JG6T7gw78J3rv+ZA@mail.gmail.com>
References: <549357ea-dfda-284b-cdd6-4408060f9ca8@hpe.com> <a661ff61-9cf8-fe86-ca20-2181394e1dbb@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:35331 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756419AbcHYT0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 15:26:02 -0400
Received: by mail-it0-f53.google.com with SMTP id x131so290983734ite.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 12:26:02 -0700 (PDT)
In-Reply-To: <a661ff61-9cf8-fe86-ca20-2181394e1dbb@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 4:46 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> Also, while it doesn't seem to have the same massive effect on throughput, I
> can also see out of order behaviour happening when the sending VM is on a
> node with a ConnectX-3 Pro NIC.  Its driver is also enabling XPS it would
> seem.  I'm not *certain* but looking at the traces it appears that with the
> ConnectX-3 Pro there is more interleaving of the out-of-order traffic than
> there is with the Skyhawk.  The ConnectX-3 Pro happens to be in a newer
> generation server with a newer processor than the other systems where I've
> seen this.
>
> I do not see the out-of-order behaviour when the NIC at the sending end is a
> BCM57840.  It does not appear that the bnx2x driver in the 4.4 kernel is
> enabling XPS.
>
> So, it would seem that there are three cases of enabling XPS resulting in
> out-of-order traffic, two of which result in a non-trivial loss of
> performance.
>
> happy benchmarking,
>
> rick jones

The problem is that there is no socket associated with the guest from
the host's perspective.  This is resulting in the traffic bouncing
between queues because there is no saved socket  to lock the interface
onto.

I was looking into this recently as well and had considered a couple
of options.  The first is to fall back to just using skb_tx_hash()
when skb->sk is null for a given buffer.  I have a patch I have been
toying around with but I haven't submitted it yet.  If you would like
I can submit it as an RFC to get your thoughts.  The second option is
to enforce the use of RPS for any interfaces that do not perform Rx in
NAPI context.  The correct solution for this is probably some
combination of the two as you have to have all queueing done in order
at every stage of the packet processing.

- Alex
