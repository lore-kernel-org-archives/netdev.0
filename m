From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 16:43:32 -0700
Message-ID: <CA+mtBx_PAF-H5az1SrZoXmDjKXCtV468O=7FFzMpoh=ctNGuAg@mail.gmail.com>
References: <CAADnVQ+wRjo3ORK5_Ra4c9W5bgyFBgotbeGB1fAuPkz1a=oy7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35748 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbaJGXnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 19:43:33 -0400
Received: by mail-ig0-f180.google.com with SMTP id uq10so6302772igb.13
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 16:43:32 -0700 (PDT)
In-Reply-To: <CAADnVQ+wRjo3ORK5_Ra4c9W5bgyFBgotbeGB1fAuPkz1a=oy7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 3:05 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Oct 7, 2014 at 1:48 PM, David Miller <davem@davemloft.net> wrote:
>>> They're exposing packet parsers to users, so we will be able to
>>> program any protocol into the device without reflashing it.
>>> Some of the guys are even allowing reprogramming the parser
>>> while packets are flowing.
>>
>> So we have to write new software in _EVERY_ driver to accomodate this.
>>
>> That makes zero sense either, and it is unneeded complexity in the
>> hardware.
>
> I have to agree that for single purpose of csum verify
> adding all the complexity around programmable
> parsers doesn't make sense.
> To me packet parsing is the first step of HW offload,
> regardless whether it's flow based or what else this hw can do.
>
> I'd rather see HW vendors provide programmable parser
> for any and all protocols instead of them saying:
> here is my device X that supports protocols defined
> by standards Y and Z.
> (which is the case today and it's not pretty)
>
>> COMPLETE works everywhere, on everything, with no driver changes, and
>> is so much harder to get wrong.
>
> agree. I'm not against COMPLETE in any way.
>
>> Every protocol specific feature has major downsides whether you choose
>> to see them or not.
>
> I surely don't have a preference to a protocol.
> I want to see programmable HW that supports any crazy
> packet format.
>
> Let's get back to COMPLETE and VMs example,
> because I want to see it fixed.
> In such case kernel stack in hypervisor will be pulling
> encap headers then populating new field in virtio
> ring with updated csum and let guest VMs to continue
> adjusting that csum, right?

That seems like the correct approach. It's not even guaranteed that
the kernel or device could parse the inner packet to verify inner
checksums (consider if checksum was added to a protocol like QUIC).

> Alternative would be to do inner processing and
> csum verification in hypervisor so that packet
> can be marked as DATA_VALID, but is it better?

One important clarification in RX checksum overhaul is that
CHECKSUM_UNNECESSARY does not mean that all possible checksums in the
packet have been verified. It means that one or more (per csum_level)
consecutive checksums have been verified. Seems like the DATA_VALID
interface might need a similar clarification.
