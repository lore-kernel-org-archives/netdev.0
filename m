From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Sun, 14 Feb 2016 23:01:43 +0100
Message-ID: <CALx6S37K9i0WH-bbfYS3p5EUzGnpHdzOAULVp5qozG3Ph+YFLg@mail.gmail.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
	<20160212.055408.1901988218281607996.davem@davemloft.net>
	<47dcce9fc54b42f591284cd8ea72ddba@AMSPEX02CL03.citrite.net>
	<20160212.114146.557404301623026279.davem@davemloft.net>
	<708813d655494f2785fda3bb4f83e1d9@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36209 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcBNWBo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 17:01:44 -0500
Received: by mail-io0-f177.google.com with SMTP id l127so140713800iof.3
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2016 14:01:43 -0800 (PST)
In-Reply-To: <708813d655494f2785fda3bb4f83e1d9@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 5:59 PM, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: 12 February 2016 16:42
>> To: Paul Durrant
>> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
>> Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
>>
>> From: Paul Durrant <Paul.Durrant@citrix.com>
>> Date: Fri, 12 Feb 2016 11:07:50 +0000
>>
>> > Windows *requires* use of Teoplitz so your position completely rules
>> > out being able to support receive side scaling in Windows PV
>> > frontends on Linux kernel backends, not only for Xen but for any
>> > other hypervisor, which I think is totally unreasonable.
>>
>> We have strong reason to believe that Toeplitz has properties that
>> make it very weak if not exploitable, therefore doing software RSS
>> with Jenkins is superior.
>
> I don't disagree, but there is really no choice of algorithm where a Windows frontend is concerned. My patches only add Toeplitz hashing into xen-netback according to the specification in xen's netif.h; the algorithm is not exposed for use by any other part of the kernel.

You are touching struct sk_buff for this. Changing such a core
networking data structure just to satisfy a requirement of Windows
seems like a long shot to me...

> If it would help I can add a module parameter to xen-netback to control advertising the option of the hash to frontends so that it can be globally disabled if it is deployed on host where there are no Windows guests.

Toeplitz is dog-slow to compute in software. Comparing your
implementation to Jenkins hash (hash) it's about 12x slower (102 nsecs
versus 8 nsecs for IPv4 on my system). Doing this for every packet
seems like a non-starter to me. I suspect the majority use case for
receive is simple uniform load balancing across the virtual queues in
which case jhash will be perfectly fine. The case where it probably
matters is if the Windows OS is trying to configure some non-uniform
distribution (isolating a single flow for instance). To handle this
case, you could implement a simple look up flow table to map a
skb->hash to a Toeplitz hash, so that the Toeplitz hash only needs to
be calculated one time for a flow (recomputed with some periodic
timeout). This would be probabilistic though, so if really Windows
requires the hash to be set correctly 100% of the time it won't work.

Tom

>
>   Paul
