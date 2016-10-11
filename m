From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 12:01:19 -0600
Message-ID: <20161011180119.GB17319@obsidianresearch.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>, linux-rdma@vger.kernel.org,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:57079 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753480AbcJKSDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 14:03:41 -0400
Content-Disposition: inline
In-Reply-To: <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 01:41:56PM -0400, Doug Ledford wrote:

> declare the header.  The problem then became that the sg setup is such
> that we are limited to 16 4k pages for the sg array, so that header had
> to come out of the 64k maximum mtu.

Oh, that clarifies things..

Hum, so various options become:
 - Use >=17 SGL entries when creating the QP. Is this possible
   on common adapters?
 - Use the FRWR infrastructure when necessary. Is there any chance
   the majority of skbs will have at least two physically
   continuous pages to make this overhead rare? Perhaps as a fall
   back if many adaptors can do >=17 SGLs 
 - Pad the hard header out to 4k and discard the first page
   when building the sgl
 - Memcopy the first ~8k into a contiguous 8k region on send
 - Move the pseudo header to the end so it can cross the page
   barrier without needing a sgl entry. (probably impossible?)
 
>From Paolo

> AFAICS the max mtu is already underlying h/w dependent, how does such
> differences are currently coped by ? (I'm sorry I lack some/a lot of IB
> back-ground)

It isn't h/w dependent. In CM mode the MTU is 65520 because that is
what is hard coded into the ipoib driver. We tell everyone to use that
number. Eg see RH's docs on the subject:

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec-Configuring_IPoIB.html

AFAIK, today everyone just wires that number into their scripts, so we
have to mass change everything to the smaller number. That sounds
really hard, IMHO if there is any way to avoid it we should, even if
it is a little costly.

Jason
