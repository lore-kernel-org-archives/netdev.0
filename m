From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 11:15:32 -0700
Message-ID: <CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>, Jesse Gross <jesse@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:61048 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbaJGSPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:15:33 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so6357574qcy.13
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 11:15:32 -0700 (PDT)
In-Reply-To: <1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 10:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-10-07 at 09:50 -0700, Alexei Starovoitov wrote:
>
>> it's definitely more difficult to properly implement
>> CHECKSUM_UNNECESSARY in HW, but it's worth it.
>> CHECKSUM_COMPLETE is a burden on software. Old NICs
>> used to do that, but overhead of recomputing csum for every
>> step of packet parsing and header modifications is too high.
>> sw routers, bridges and < L4 networking devices are
>> simpler and faster with CHECKSUM_UNNECESSARY.
>
> Really this is wrong. Once you validated/pulled a header,
> adjusting the complete checksum is in the order of 10 cycles or so,
> ie less than 1% of the other costs.

correct, but there is also postpull() cost for every pull.
and there are many of them for encapsulated traffic.
It's small, but it's not zero.

> UNNECESSARY usually requests complex NIC firmware, and usually the NIC
> has fewer cores than the host.
>
> It mostly worked for basic IP+TCP kind of traffic, but once you want
> complex cloud models, it is a major pain.
>
> If we need to optimize csum_partial() for short lengths, lets do it,
> instead of pushing hardware vendors adding more and more schemes.

csum_partial() is in asm already. probably not much more can be squeezed.
I'm not suggesting that NICs must always do UNNECESSARY.
COMPLETE is a low bar which is magnitude better than NONE,
but if HW has programmable parser it should be able to take advantage
of it and UNNECESSARY is an established model.
