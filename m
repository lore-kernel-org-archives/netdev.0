From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Sat, 11 Apr 2015 08:46:58 +0200
Message-ID: <5528C362.4070207@iogearbox.net>
References: <1428708792-5872-1-git-send-email-ast@plumgrid.com> <1428708792-5872-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46739 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbbDKGrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 02:47:15 -0400
In-Reply-To: <1428708792-5872-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2015 01:33 AM, Alexei Starovoitov wrote:
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
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Yes, that's the suggested alternative for the constraints we're having.
Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
