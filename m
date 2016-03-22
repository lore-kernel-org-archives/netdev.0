From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Tue, 22 Mar 2016 13:11:21 -0700
Message-ID: <CAEh+42jq1byHx0yuZgUCLqfk3G3eGfhoA1oq4Wwn5SmefCbNnQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain> <56F17A13.8090701@solarflare.com>
 <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com> <56F19FAA.3090005@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56611 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbcCVULj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 16:11:39 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 294FC2039D
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 20:11:38 +0000 (UTC)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 66FDF2038A
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 20:11:36 +0000 (UTC)
Received: by mail-qg0-f45.google.com with SMTP id y89so188857812qge.2
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 13:11:36 -0700 (PDT)
In-Reply-To: <56F19FAA.3090005@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 12:40 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 22/03/16 17:47, Alexander Duyck wrote:
>> On Tue, Mar 22, 2016 at 10:00 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> On 18/03/16 23:25, Alexander Duyck wrote:
>>>> This patch adds support for something I am referring to as GSO partial.
>>>> The basic idea is that we can support a broader range of devices for
>>>> segmentation if we use fixed outer headers and have the hardware only
>>>> really deal with segmenting the inner header.  The idea behind the naming
>>>> is due to the fact that everything before csum_start will be fixed headers,
>>>> and everything after will be the region that is handled by hardware.
>>>>
>>>> With the current implementation it allows us to add support for the
>>>> following GSO types with an inner TSO or TSO6 offload:
>>>> NETIF_F_GSO_GRE
>>>> NETIF_F_GSO_GRE_CSUM
>>>> NETIF_F_UDP_TUNNEL
>>>> NETIF_F_UDP_TUNNEL_CSUM
>>>>
>>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>>> ---
>>> If I'm correctly understanding what you're doing, you're building a large
>>> TCP segment, feeding it through the encapsulation drivers as normal, then
>>> at GSO time you're fixing up length fields, checksums etc. in the headers.
>>> I think we can do this more simply, by making it so that at the time when
>>> we _generate_ the TCP segment, we give it headers saying it's one MSS big,
>>> but have several MSS of data.  Similarly when adding the encap headers,
>>> they all need to get their lengths from what the layer below tells them,
>>> rather than the current length of data in the SKB.  Then at GSO time all
>>> the headers already have the right things in, and you don't need to call
>>> any per-protocol GSO callbacks for them.
>> One issue I have to deal with here is that we have no way of knowing
>> what the underlying hardware can support at the time of segment being
>> created.  You have to keep in mind that what we have access to is the
>> tunnel dev in many cases, not the underlying dev so we don't know if
>> things can be offloaded to hardware or not.  By pushing this logic
>> into the GSO code we can actually implement it without much overhead
>> since we either segment it into an MSS multiple, or into single MSS
>> sized chunks.  This way we defer the decision until the very last
>> moment when we actually know if we can offload some portion of this in
>> hardware or not.
> But won't the tunnel dev have the feature flag for GSO_PARTIAL depending
> on what the underlying dev advertises?  (Or, at least, could we make it
> bethatway?)

Features that have been designed this way in the past are usually
pretty fragile. Not only would you have to track changes in the
routing table but you could have bridges, tc, vlan devices, etc. all
of which might change the path of the packet and would have to somehow
propagate this information. It's much more robust to resolve the
device capabilities just before you hand the packet to that device.
Plus, anything along the path of the packet (iptables, for example)
that looks at the headers might potentially need to be aware of this
optimization.

You're also assuming that the generating TCP stack is resident on the
same machine as the device that does the offloads. That's not
necessarily true in the case of VMs or remote senders whose packets
have been GRO'ed.

Keeping the core stack consistent and just handling this at the
GRO/driver layer as Alex has here seems preferable to me.
