From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress qdisc
 in __netif_receive_skb_core
Date: Fri, 10 Apr 2015 18:14:29 -0700
Message-ID: <CAHA+R7PXy_kOn3pUOdGvU4L3n-EgH8cXNCmGQfaDQTUNaP2S4w@mail.gmail.com>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36693 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbbDKBOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:14:30 -0400
Received: by wgsk9 with SMTP id k9so32285749wgs.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:14:29 -0700 (PDT)
In-Reply-To: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 2:07 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Even if we make use of classifier and actions from the egress
> path, we're going into handle_ing() executing additional code
> on a per-packet cost for ingress qdisc, just to realize that
> nothing is attached on ingress.
>
> Instead, this can just be blinded out as a no-op entirely with
> the use of a static key. On input fast-path, we already make
> use of static keys in various places, e.g. skb time stamping,
> in RPS, etc. It makes sense to not waste time when we're assured
> that no ingress qdisc is attached anywhere.

So the following code is slow enough to deserve a static key
optimization?

struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);

if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
    goto out;


>
> Enabling/disabling of that code path is being done via two
> helpers, namely net_{inc,dec}_ingress_queue(), that are being
> invoked under RTNL mutex when a ingress qdisc is being either
> initialized or destructed.


Since static key can't be embedded into net_device, I doubt
it is useful to have a static key here, since qdisc is per net device.
