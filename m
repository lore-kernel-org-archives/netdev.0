From: Jesse Gross <jesse@kernel.org>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Wed, 20 Jan 2016 16:19:15 -0800
Message-ID: <CAEh+42g4Zk6WVRwQDLi_fT3wWmQDEdPRA-aRidov1YD5MpYx6A@mail.gmail.com>
References: <5697D833.5010506@hpe.com> <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
 <20160120013128.GA6326@pox.localdomain> <56A01BBF.1010301@hpe.com> <1453334825.1223.332.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John <john.phillips5@hpe.com>, Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44313 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbcAUATd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 19:19:33 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id B2133205E8
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 00:19:32 +0000 (UTC)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8AB3C205EC
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 00:19:31 +0000 (UTC)
Received: by mail-qg0-f52.google.com with SMTP id 6so20133702qgy.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 16:19:31 -0800 (PST)
In-Reply-To: <1453334825.1223.332.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 4:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-01-20 at 16:43 -0700, John wrote:
>>
>> On 01/19/2016 06:31 PM, Thomas Graf wrote:
>> > On 01/19/16 at 04:51pm, Jesse Gross wrote:
>> >> On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >>> So what is the purpose of having a dst if we need to drop it ?
>> >>>
>> >>> Adding code in GRO would be fine if someone explains me the purpose of
>> >>> doing apparently useless work.
>> >>>
>> >>> (refcounting on dst is not exactly free)
>> >> In the GRO case, the dst is only dropped on the packets which have
>> >> been merged and therefore need to be freed (the GRO_MERGED_FREE case).
>> >> It's not being thrown away for the overall frame, just metadata that
>> >> has been duplicated on each individual frame, similar to the metadata
>> >> in struct sk_buff itself. And while it is not used by the IP stack
>> >> there are other consumers (eBPF/OVS/etc.). This entire process is
>> >> controlled by the COLLECT_METADATA flag on tunnels, so there is no
>> >> cost in situations where it is not actually used.
>> > Right. There were thoughts around leveraging a per CPU scratch
>> > buffer without a refcount and turn it into a full reference when
>> > the packet gets enqueued somewhere but the need hasn't really come
>> > up yet.
>> >
>> > Jesse, is this what you have in mind:
>> >
>> > diff --git a/net/core/dev.c b/net/core/dev.c
>> > index cc9e365..3a5e96d 100644
>> > --- a/net/core/dev.c
>> > +++ b/net/core/dev.c
>> > @@ -4548,9 +4548,10 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
>> >                  break;
>> >
>> >          case GRO_MERGED_FREE:
>> > -               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
>> > +               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
>> > +                       skb_release_head_state(skb);
>> >                          kmem_cache_free(skbuff_head_cache, skb);
>> > -               else
>> > +               } else
>> >                          __kfree_skb(skb);
>> >                  break;
>> So I've tested the below patch (same as one above with minor
>> modifications made to make it compile) and it worked - no memory leak.
>> Should I submit this or...?
>
> Unfortunately fix is not complete.
>
> As someone mentioned, GRO should not aggregate packets having different
> dst.
>
> This part is hard to achieve, as a pointer comparison wont be enough :
> Each skb has its own meta dst allocation.
>
> Quite frankly, I would rather disable GRO for packets with a dst,
> instead of making GRO dog slow.

I have a patch that implements the comparison between dsts. For
packets without a dst, there isn't really a cost and if we do have a
dst then GRO is still a benefit. So it seems like it is worth doing,
even if it is more expensive than is ideal.
