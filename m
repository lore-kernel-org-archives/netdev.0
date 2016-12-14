From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Wed, 14 Dec 2016 21:37:23 +0100
Message-ID: <c122d91d-9506-ac35-29e5-3d80791259ef@stressinduktion.org>
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com>
 <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com>
 <20161212181344.3ddfa9c3@redhat.com>
 <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com>
 <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org>
 <alpine.DEB.2.20.1612141059020.20959@east.gentwo.org>
 <063D6719AE5E284EB5DD2968C1650D6DB023FA6E@AcuExch.aculab.com>
 <alpine.DEB.2.20.1612141342080.23516@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>,
        Vladislav Yasevich <vyasevich@gmail.com>
To: Christoph Lameter <cl@linux.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56023 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753959AbcLNUhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 15:37:33 -0500
In-Reply-To: <alpine.DEB.2.20.1612141342080.23516@east.gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.12.2016 20:43, Christoph Lameter wrote:
> On Wed, 14 Dec 2016, David Laight wrote:
> 
>> If the kernel is doing ANY validation on the frames it must copy the
>> data to memory the application cannot modify before doing the validation.
>> Otherwise the application could change the data afterwards.
> 
> The application is not allowed to change the data after a work request has
> been submitted to send the frame. Changes are possible after the
> completion request has been received.
> 
> The kernel can enforce that by making the frame(s) readonly and thus
> getting a page fault if the app would do such a thing.

As far as I remember right now, if you gift with vmsplice the memory
over a pipe to a tcp socket, you can in fact change the user data while
the data is in transmit. So you should not touch the memory region until
you received a SOF_TIMESTAMPING_TX_ACK error message in your sockets
error queue or stuff might break horribly. I don't think we have a
proper event for UDP that fires after we know the data left the hardware.

In my opinion this is still fine within the kernel protection limits.
E.g. due to scatter gather I/O you don't get access to the TCP header
nor UDP header and thus can't e.g. spoof or modify the header or
administration policies, albeit TOCTTOU races with netfilter which
matches inside the TCP/UDP packets are very well possible on transmit.

Wouldn't changing of the pages cause expensive TLB flushes?

Bye,
Hannes
