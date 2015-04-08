From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Wed, 8 Apr 2015 11:05:20 +0200
Message-ID: <20150408090520.GA2057@nanopsycho.orion>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
 <1428455025-5945-2-git-send-email-ast@plumgrid.com>
 <20150407.223549.335906307265617841.davem@davemloft.net>
 <55249EFA.5040405@plumgrid.com>
 <5524B339.1070403@plumgrid.com>
 <5524E878.7070803@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35534 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbDHJFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 05:05:24 -0400
Received: by wgyo15 with SMTP id o15so70329322wgy.2
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 02:05:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5524E878.7070803@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 08, 2015 at 10:36:08AM CEST, daniel@iogearbox.net wrote:
>On 04/08/2015 06:48 AM, Alexei Starovoitov wrote:
>>On 4/7/15 8:22 PM, Alexei Starovoitov wrote:
>>>but it seems no one cares about using them with ingress, so I'll go back
>>>to cls_bpf specific skb_share_check and push.
>>
>>that didn't work either :(
>>we cannot replace skb via skb_share_check() inside cls/act. We cannot do
>>it inside ingress_enqueue() either. It can only be done at handle_ing()
>>level. And it's quite ugly to change the signatures of the whole
>>qdisc->enqueue() call chain just for cls_bpf. May be introducing
>>bpf-only ingress qdisc to decouple the logic is not such a bad idea?
>
>So it seems ingress qdisc is quite broken for various classifier
>and actions. :/ I wouldn't go that far to have a bpf-only ingress
>qdisc, but what about introducing l2/l3 ingress qdisc (or, name
>it "early ingress" and "ingress" qdisc), so at an early point in
>netif_receive_skb_internal(), we would have an l2_ingress hook,
>wrapped via static keys to have minimal impact if unused, and could
>do the push/pull similarly as in the PTP classifier w/o worry that
>it is referenced by other entities. There, we could at least still
>benefit from hw flow steering.

How about to just adjust ingress qdisc to do the right thing (of adjust
egress qdisc so they both behave the same). I don't like the idea of
having more ingres queue disk. Would be just confusing.

>
>The current ingress qdisc, we'd rename l3_ingress to make it clear
>what to expect (can also be aliased in iproute2). Maybe classifiers,
>actions could be flagged as l2/l3 capable and checked at config
>time where to apply, at least in the case of {cls,act}_bpf?
>
>The other thing I had in mind is that we could expose skb_iif to
>detect that we're actually coming from ingress qdisc from inside
>the ebpf prog, but that is very limited and you nevertheless miss
>out on l2 context.

As you said, this needs to be resolved for others as well.

>
>Thanks,
>Daniel
