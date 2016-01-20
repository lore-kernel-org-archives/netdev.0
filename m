From: Jesse Gross <jesse@kernel.org>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 16:51:57 -0800
Message-ID: <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
References: <5697D833.5010506@hpe.com> <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com> <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46743 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933560AbcATAwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 19:52:14 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D0FDD2056D
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 00:52:12 +0000 (UTC)
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0BC6520253
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 00:52:12 +0000 (UTC)
Received: by mail-qg0-f42.google.com with SMTP id e32so506877080qgf.3
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 16:52:12 -0800 (PST)
In-Reply-To: <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-19 at 16:00 -0800, Jesse Gross wrote:
>
>> Oh, I wasn't disagreeing that there is a problem. I was just trying to
>> point out the conceptual root of the problem rather than the
>> individual instances in different tunnels implementations.
>>
>> In any case, I think we can solve this by calling
>> skb_release_head_state() in napi_skb_finish() and switching early
>> demux to use skb_valid_dst().
>
> Yes, but it will also have to call skb_dst_drop() or risk a leak of
> prior one.

skb_dst_drop() is the key part but I mentioned
skb_release_head_state() (which calls skb_dst_drop()) as a slightly
more generic solution. But either one is fine.

> So what is the purpose of having a dst if we need to drop it ?
>
> Adding code in GRO would be fine if someone explains me the purpose of
> doing apparently useless work.
>
> (refcounting on dst is not exactly free)

In the GRO case, the dst is only dropped on the packets which have
been merged and therefore need to be freed (the GRO_MERGED_FREE case).
It's not being thrown away for the overall frame, just metadata that
has been duplicated on each individual frame, similar to the metadata
in struct sk_buff itself. And while it is not used by the IP stack
there are other consumers (eBPF/OVS/etc.). This entire process is
controlled by the COLLECT_METADATA flag on tunnels, so there is no
cost in situations where it is not actually used.
