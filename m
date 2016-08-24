From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 3/5] bnx2x: Add support for segmentation of tunnels
 with outer checksums
Date: Wed, 24 Aug 2016 08:39:38 -0700
Message-ID: <CAKgT0Uc3CMzvChw2ifaw4Gz+i=udaZsS8m4Qn8adL6ZoXor5wQ@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
 <20160419190609.11723.8710.stgit@ahduyck-xeon-server> <CO2PR11MB0088207088FA6F6A502AB3B097EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36348 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753083AbcHXPjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:39:39 -0400
Received: by mail-it0-f52.google.com with SMTP id e63so217016183ith.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:39:39 -0700 (PDT)
In-Reply-To: <CO2PR11MB0088207088FA6F6A502AB3B097EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 5:33 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> This patch assumes that the bnx2x hardware will ignore existing IPv4/v6 header
>> fields for length and checksum as well as the length and checksum fields for
>> outer UDP and GRE headers.
>>
>> I have no means of testing this as I do not have any bnx2x hardware but thought
>> I would submit it as an RFC to see if anyone out there wants to test this and see
>> if this does in fact enable this functionality allowing us to to segment tunneled
>> frames that have an outer checksum.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> So it took me some [well, a lot] time to reach this, but I've finally  gave it a try.
> I saw a performance boost with the partial support -
> Throughput for vxlan tunnels with and without udpcsum were almost identical
> after this, whereas without this patch the udpcsum prevented GSO and
> a TCP/IPv4 connection on top of it got roughly half the throughput.
>
> However, I did encounter one oddity I couldn't explain -
> After I've disabled tx-udp_tnl-segmentation via ethtool on the base interface,
> got left with:
>    tx-gso-partial: on
>    tx-udp_tnl-segmentation: off
>    tx-udp_tnl-csum-segmentation: on
>
> When I ran traffic over both vxlan tunnels the one with the udpcsum was still
> Passing gso aggregations to base device to transmit [and the throughput was
> same as before], where's the tunnel without the udpcsum showed only
> MTU-sized packets reaching the base interface for transmission [which is what
> I've expected]
>
> Any idea why that happened?

So the way they are implemented tx-udp_tnl-segmentation and
tx-udp_tnl-csum-segmentation are treated as two separate features.
The kernel currently gives them the same treatment as NETIF_F_TSO and
NETIF_F_TSO6.  You can disable one and the other still functions.

Now if you disable tx-gso-partial you should expect to see
tx-udp_tnl-csum-segmentation be disabled because it is dependent on
the partial GSO offload.

- Alex
