From: Jesse Gross <jesse@nicira.com>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx path
Date: Wed, 30 Jan 2013 13:54:08 -0800
Message-ID: <CAEP_g=-pdossS=kAVzQMuvTnKU-Sg9PvskiocqcxdsBDtbvdCw@mail.gmail.com>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:44707 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755776Ab3A3Vyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 16:54:31 -0500
Received: by mail-ob0-f198.google.com with SMTP id dn14so11719702obc.5
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 13:54:28 -0800 (PST)
In-Reply-To: <1359535089-18348-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 12:38 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> skb_gso_segment() is almost always called in tx path,
> except for openvswitch. It calls this function when
> it receives the packet and tries to queue it to user-space.
> In this special case, the ->ip_summed check inside
> skb_gso_segment() is no longer true, as ->ip_summed value
> has different meanings on rx path.

I don't think that this is really specific to Open vSwitch - it's
possible that skb_gso_segment() could be called in the transmit path
after bridging.  I also don't really think that it is true any more
that the meaning of skb->ip_summed is different on receive vs.
transmit paths (this was definitely not the case in the past).
However, it's certainly possible to see different types of packets.

> This patch adjusts skb_gso_segment() so that we can at least
> avoid such warnings on checksum.

When do you see GSO packets with CHECKSUM_NONE on receive?

> diff --git a/net/core/dev.c b/net/core/dev.c
> index a87bc74..f6e7b3f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2347,7 +2356,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
>         rcu_read_lock();
>         list_for_each_entry_rcu(ptype, &offload_base, list) {
>                 if (ptype->type == type && ptype->callbacks.gso_segment) {
> -                       if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
> +                       if (unlikely(skb_needs_check(skb))) {
>                                 err = ptype->callbacks.gso_send_check(skb);
>                                 segs = ERR_PTR(err);
>                                 if (err || skb_gso_ok(skb, features))

Even if we don't warn we likely still need to fix the checksum.

> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index d8c13a9..0b75964 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -302,7 +302,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
>         int err;
>
>         segs = skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM);
> -       if (IS_ERR(segs))
> +       if (IS_ERR_OR_NULL(segs))
>                 return PTR_ERR(segs);

In what case would we expect that NULL is returned here?
