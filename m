From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 17:45:19 -0700
Message-ID: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34213 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbbDKApU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 20:45:20 -0400
Received: by wgso17 with SMTP id o17so32111850wgs.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 17:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 4:33 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
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

Why the flag needs to be visible to user-space? IOW, why users
should learn the knowledge of the need of this flag?

The problem you try to solve is kernel's implementation problem,
users should not care, so we should make some effort to make ingress
align with egress, rather than making more differences.

The more I look at you patch, no matter where you put that flag into,
the more I think it is a workaround. _Maybe_ it fits for short-term,
but you introduce a new API which can't be removed once merged.

This issue should have been there for a rather long time, so it is not
urgent, take some effect to make ingress align with egress, we would
get more benefits.
