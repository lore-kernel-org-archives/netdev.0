From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] bridge: orphan frags on local receive
Date: Tue, 25 Feb 2014 11:53:18 +0800
Message-ID: <530C13AE.9030906@redhat.com>
References: <530B4534.3000106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Qin Chuanyu <qinchuanyu@huawei.com>, davem@davemloft.net,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbaBYDx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 22:53:27 -0500
In-Reply-To: <530B4534.3000106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 09:12 PM, Qin Chuanyu wrote:
> with vhost tx zero_copy, guest nic might get hang when host reserving
> skb in socket queue delivered by guest, the case has been solved in
> tun, it also been needed by bridge. This could easily happened when a
> LAST_ACK state tcp occuring between guest and host.
>
> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
> ---
>  net/bridge/br_input.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 28d5446..744e27a 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -117,6 +117,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
>          br->dev->stats.multicast++;
>      } else if ((dst = __br_fdb_get(br, dest, vid)) &&
>              dst->is_local) {
> +        if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> +            goto drop;
>          skb2 = skb;
>          /* Do not forward the packet since it's local. */
>          skb = NULL;
> @@ -136,6 +138,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  out:
>      return 0;
>  drop:
> +    skb_tx_error(skb);
>      kfree_skb(skb);
>      goto out;
>  }

Pretty similar to the issue we found for non-work conserving qdiscs. The
questions is whether or not should we audit all such cases ( I believe
we could find even more ) and does the skb_orphan_frags(), or doing
something like switch to use data copy in this case

I will post a patch that switch to use data copy when the number of
pending DMAs exceed a limit. Looks like it can help here.

Another question is whether or nor do we need a skb_orphan() here now
(at least for packets from tun) ?
