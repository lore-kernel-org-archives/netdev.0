From: John <john.phillips5@hpe.com>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Wed, 20 Jan 2016 16:43:59 -0700
Message-ID: <56A01BBF.1010301@hpe.com>
References: <5697D833.5010506@hpe.com>
 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
 <20160120013128.GA6326@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t6225.austin.hp.com ([15.73.96.126]:40408 "EHLO
	g1t6225.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbcATXtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 18:49:18 -0500
Received: from g2t4618.austin.hp.com (g2t4618.austin.hp.com [15.73.212.83])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g1t6225.austin.hp.com (Postfix) with ESMTPS id D3CFD3677
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 23:49:17 +0000 (UTC)
In-Reply-To: <20160120013128.GA6326@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/19/2016 06:31 PM, Thomas Graf wrote:
> On 01/19/16 at 04:51pm, Jesse Gross wrote:
>> On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> So what is the purpose of having a dst if we need to drop it ?
>>>
>>> Adding code in GRO would be fine if someone explains me the purpose of
>>> doing apparently useless work.
>>>
>>> (refcounting on dst is not exactly free)
>> In the GRO case, the dst is only dropped on the packets which have
>> been merged and therefore need to be freed (the GRO_MERGED_FREE case).
>> It's not being thrown away for the overall frame, just metadata that
>> has been duplicated on each individual frame, similar to the metadata
>> in struct sk_buff itself. And while it is not used by the IP stack
>> there are other consumers (eBPF/OVS/etc.). This entire process is
>> controlled by the COLLECT_METADATA flag on tunnels, so there is no
>> cost in situations where it is not actually used.
> Right. There were thoughts around leveraging a per CPU scratch
> buffer without a refcount and turn it into a full reference when
> the packet gets enqueued somewhere but the need hasn't really come
> up yet.
>
> Jesse, is this what you have in mind:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cc9e365..3a5e96d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4548,9 +4548,10 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
>                  break;
>   
>          case GRO_MERGED_FREE:
> -               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
> +               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
> +                       skb_release_head_state(skb);
>                          kmem_cache_free(skbuff_head_cache, skb);
> -               else
> +               } else
>                          __kfree_skb(skb);
>                  break;
So I've tested the below patch (same as one above with minor 
modifications made to make it compile) and it worked - no memory leak. 
Should I submit this or...?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129..a8fac63 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2829,6 +2829,7 @@ int skb_zerocopy(struct sk_buff *to, struct 
sk_buff *from,
  void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
  int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
  void skb_scrub_packet(struct sk_buff *skb, bool xnet);
+void skb_release_head_state(struct sk_buff *skb);
  unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t 
features);
  struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b89..76e3623 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4337,9 +4337,10 @@ static gro_result_t napi_skb_finish(gro_result_t 
ret, struct sk_buff *skb)
          break;

      case GRO_MERGED_FREE:
-        if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
+        if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
+                        skb_release_head_state(skb);
              kmem_cache_free(skbuff_head_cache, skb);
-        else
+                } else
              __kfree_skb(skb);
          break;

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b2df375..45f6f50 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -633,7 +633,7 @@ fastpath:
      kmem_cache_free(skbuff_fclone_cache, fclones);
  }

-static void skb_release_head_state(struct sk_buff *skb)
+void skb_release_head_state(struct sk_buff *skb)
  {
      skb_dst_drop(skb);
  #ifdef CONFIG_XFRM
