From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Wed, 20 Jan 2016 02:31:28 +0100
Message-ID: <20160120013128.GA6326@pox.localdomain>
References: <5697D833.5010506@hpe.com>
 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33445 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933441AbcATBbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 20:31:32 -0500
Received: by mail-wm0-f48.google.com with SMTP id 123so114104401wmz.0
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 17:31:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/16 at 04:51pm, Jesse Gross wrote:
> On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > So what is the purpose of having a dst if we need to drop it ?
> >
> > Adding code in GRO would be fine if someone explains me the purpose of
> > doing apparently useless work.
> >
> > (refcounting on dst is not exactly free)
> 
> In the GRO case, the dst is only dropped on the packets which have
> been merged and therefore need to be freed (the GRO_MERGED_FREE case).
> It's not being thrown away for the overall frame, just metadata that
> has been duplicated on each individual frame, similar to the metadata
> in struct sk_buff itself. And while it is not used by the IP stack
> there are other consumers (eBPF/OVS/etc.). This entire process is
> controlled by the COLLECT_METADATA flag on tunnels, so there is no
> cost in situations where it is not actually used.

Right. There were thoughts around leveraging a per CPU scratch
buffer without a refcount and turn it into a full reference when
the packet gets enqueued somewhere but the need hasn't really come
up yet.

Jesse, is this what you have in mind:

diff --git a/net/core/dev.c b/net/core/dev.c
index cc9e365..3a5e96d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4548,9 +4548,10 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
                break;
 
        case GRO_MERGED_FREE:
-               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
+               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
+                       skb_release_head_state(skb);
                        kmem_cache_free(skbuff_head_cache, skb);
-               else
+               } else
                        __kfree_skb(skb);
                break;
