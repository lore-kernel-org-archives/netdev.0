From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 3/5] bnx2x: Add support for segmentation of tunnels
 with outer checksums
Date: Wed, 31 Aug 2016 09:13:39 -0700
Message-ID: <CAKgT0UdHpEd4qRkJa1EWCUPt72FGsnvE5SRusFqzJ2JdC2pD8Q@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
 <20160419190609.11723.8710.stgit@ahduyck-xeon-server> <CO2PR11MB0088207088FA6F6A502AB3B097EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc3CMzvChw2ifaw4Gz+i=udaZsS8m4Qn8adL6ZoXor5wQ@mail.gmail.com>
 <CO2PR11MB008820D7EEE1788F55A3BE4997ED0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uf194vxfsMU8-OC2jFQhv7aNbr+gbUzD9uH_o=oyC1=2Q@mail.gmail.com> <DM5PR11MB1723AFE410DF1591E46921AB97E30@DM5PR11MB1723.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35575 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935148AbcHaQPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:15:04 -0400
Received: by mail-it0-f54.google.com with SMTP id e124so52830881ith.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 09:13:40 -0700 (PDT)
In-Reply-To: <DM5PR11MB1723AFE410DF1591E46921AB97E30@DM5PR11MB1723.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 4:31 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
> One question I have regarding the feature, regarding the
> partial offload compatible with ndo_features_check().
>
> Consider the following example -
> Let's assume my adapter is capable of doing outer-csum validation
> for vxlan packets, but only if inner network protocol is IPv4,
> while at the same time it's capable of doing gso offloading for any
> vxlan-encapsulated packet.

When you say validation do you mean generating an outer checksum?  If
I recall ndo_features_check applies to Tx features not Rx features.
I'll assume you mean Tx checksum offload and not validation.

> In that case, I'll publish NETIF_F_GSO_UDP_TUNNEL_CSUM as
> part of my offload capability [& encap capabilities], and in my driver's
> implementation of ndo_features_check() I'd remove the feature in case
> I'd find out SKB is vxlan whose inner network protocol is ipv6.

Right.  That sounds correct so far.

> Is there a way I could have benefited from the partial offload in that
> case? If I understand the feature correctly, if I were to publish
> UDP_TUNNEL_CSUM  under partial-gso, it would mean that stack would
> peel the feature off until it would decide there's actual need for SW GSO,
> thereby denying me the ability of utilizing the HW offload capability for CSUM.
>
> Am I reading it wrong? Or does this trade-off exist?

I think you may have that correct.  Basically any feature you
advertise as partially supporting via GSO_PARTIAL ends up being tied
to the partial offload after that.  Although from what I have seen the
difference isn't really all that great between GSO_PARTIAL versus TSO.
In many cases the stack generates MSS aligned frames anyway so all
GSO_PARTIAL is really doing is unsharing the header and updating the
header fields.
