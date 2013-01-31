From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx
 path
Date: Wed, 30 Jan 2013 22:46:29 -0500 (EST)
Message-ID: <20130130.224629.25122487947508141.davem@davemloft.net>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123Ab3AaDqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 22:46:31 -0500
In-Reply-To: <1359535089-18348-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 30 Jan 2013 16:38:09 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> skb_gso_segment() is almost always called in tx path,
> except for openvswitch. It calls this function when
> it receives the packet and tries to queue it to user-space.
> In this special case, the ->ip_summed check inside
> skb_gso_segment() is no longer true, as ->ip_summed value
> has different meanings on rx path.
> 
> This patch adjusts skb_gso_segment() so that we can at least
> avoid such warnings on checksum.
> 
> I am not very sure if this is a real fix or just a workaround,
> at least this patch works fine for me, the kernel warning inside
> skb_gso_segment() disappears and the traffic is normal too.
> 
> (Note I only tested it on 2.6.32, but ->ip_summed has never
> been changed since then.)
> 
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Instead of having the crazy test, make the caller
tell the context, TX or RX.

struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
				  netdev_features_t features,
				  bool tx_path);

static inline struct sk_buff *
skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
{
	__skb_gso_segment(skb, features, true);
}
