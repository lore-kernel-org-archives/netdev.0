From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 10:36:08 +0200
Message-ID: <5524E878.7070803@iogearbox.net>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>	<1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org, tgraf@suug.ch
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38131 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332AbbDHIgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 04:36:16 -0400
In-Reply-To: <5524B339.1070403@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 06:48 AM, Alexei Starovoitov wrote:
> On 4/7/15 8:22 PM, Alexei Starovoitov wrote:
>> but it seems no one cares about using them with ingress, so I'll go back
>> to cls_bpf specific skb_share_check and push.
>
> that didn't work either :(
> we cannot replace skb via skb_share_check() inside cls/act. We cannot do
> it inside ingress_enqueue() either. It can only be done at handle_ing()
> level. And it's quite ugly to change the signatures of the whole
> qdisc->enqueue() call chain just for cls_bpf. May be introducing
> bpf-only ingress qdisc to decouple the logic is not such a bad idea?

So it seems ingress qdisc is quite broken for various classifier
and actions. :/ I wouldn't go that far to have a bpf-only ingress
qdisc, but what about introducing l2/l3 ingress qdisc (or, name
it "early ingress" and "ingress" qdisc), so at an early point in
netif_receive_skb_internal(), we would have an l2_ingress hook,
wrapped via static keys to have minimal impact if unused, and could
do the push/pull similarly as in the PTP classifier w/o worry that
it is referenced by other entities. There, we could at least still
benefit from hw flow steering.

The current ingress qdisc, we'd rename l3_ingress to make it clear
what to expect (can also be aliased in iproute2). Maybe classifiers,
actions could be flagged as l2/l3 capable and checked at config
time where to apply, at least in the case of {cls,act}_bpf?

The other thing I had in mind is that we could expose skb_iif to
detect that we're actually coming from ingress qdisc from inside
the ebpf prog, but that is very limited and you nevertheless miss
out on l2 context.

Thanks,
Daniel
