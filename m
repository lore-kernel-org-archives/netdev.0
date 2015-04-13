From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 10:16:01 -0400
Message-ID: <552BCFA1.7020502@mojatatu.com>
References: <1428708792-5872-1-git-send-email-ast@plumgrid.com> <1428708792-5872-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38172 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262AbbDMOQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:16:10 -0400
Received: by igbqf9 with SMTP id qf9so44854230igb.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:16:09 -0700 (PDT)
In-Reply-To: <1428708792-5872-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/15 19:33, Alexei Starovoitov wrote:
> TC classifers and actions attached to ingress and egress qdiscs see
> inconsistent skb->data. For ingress L2 header is already pulled, whereas
> for egress it's present. Introduce an optional flag for ingress qdisc
> which if set will cause ingress to push L2 header before calling
> into classifiers/actions and pull L2 back afterwards.
>
> The cls_bpf/act_bpf are now marked as 'needs_l2'. The users can use them
> on ingress qdisc created with 'needs_l2' flag and on any egress qdisc.
> The use of them with vanilla ingress is disallowed.
>
> The ingress_l2 qdisc can only be attached to devices that provide headers_ops.
>
> When ingress is not enabled static_key avoids *(skb->dev->ingress_queue)
>
> When ingress is enabled the difference old vs new to reach qdisc spinlock:
> old:
> *(skb->dev->ingress_queue), if, *(rxq->qdisc), if, *(rxq->qdisc), if
> new:
> *(skb->dev->ingress_queue), if, *(rxq->qdisc), if, if
>
> This patch provides a foundation to use ingress_l2+cls_bpf to filter
> interesting traffic and mirror small part of it to a different netdev for
> capturing. This approach is significantly faster than traditional af_packet,
> since skb_clone is called after filtering. dhclient and other tap-based tools
> may consider switching to this style.
>

Alexei,
I want to support this work but i am having difficulties. I see your
point as i hope you see mine. In my opinion, it is a stalemate.
We need Dave to make the call.

To repeat what i said earlier:
The only known user at this point is bpf. cls_bpf and cls_act could both
look at the AT field, find where they are being invoked from and react
accordingly. This is not very hard for a coder to do and the user
injecting the policy doesnt need to know about it.
If you do that then i think you need to also inform users downstream
from bpf that they should expect to see the packet at the Link header
and not the network header.


cheers,
jamal

PS:- note that __netif_receive_skb_core() at the beginning is what sets 
all these headers.
