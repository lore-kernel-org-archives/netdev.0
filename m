From: Jesse Gross <jesse@kernel.org>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 17:40:30 -0800
Message-ID: <CAEh+42h1w=8nFi73afh8_B8_x3-kKSCBOkJZjE2v2QNfCAQ4oA@mail.gmail.com>
References: <5697D833.5010506@hpe.com> <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com> <20160120013128.GA6326@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51691 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933554AbcATBks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 20:40:48 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id AEE5F20576
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 01:40:46 +0000 (UTC)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1F2BA20552
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 01:40:45 +0000 (UTC)
Received: by mail-qk0-f182.google.com with SMTP id o6so30984571qkc.2
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 17:40:45 -0800 (PST)
In-Reply-To: <20160120013128.GA6326@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 5:31 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/19/16 at 04:51pm, Jesse Gross wrote:
>> On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > So what is the purpose of having a dst if we need to drop it ?
>> >
>> > Adding code in GRO would be fine if someone explains me the purpose of
>> > doing apparently useless work.
>> >
>> > (refcounting on dst is not exactly free)
>>
>> In the GRO case, the dst is only dropped on the packets which have
>> been merged and therefore need to be freed (the GRO_MERGED_FREE case).
>> It's not being thrown away for the overall frame, just metadata that
>> has been duplicated on each individual frame, similar to the metadata
>> in struct sk_buff itself. And while it is not used by the IP stack
>> there are other consumers (eBPF/OVS/etc.). This entire process is
>> controlled by the COLLECT_METADATA flag on tunnels, so there is no
>> cost in situations where it is not actually used.
>
> Right. There were thoughts around leveraging a per CPU scratch
> buffer without a refcount and turn it into a full reference when
> the packet gets enqueued somewhere but the need hasn't really come
> up yet.
>
> Jesse, is this what you have in mind:

Yes, that's what I was thinking. I also realized that we should
probably have a check in gro_list_prepare() to ensure that the dst of
the packets that we are about to merge are equal. And we should fix IP
early demux as Eric pointed out.
