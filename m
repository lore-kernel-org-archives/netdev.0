From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Sat, 7 May 2016 11:30:25 +0300
Message-ID: <20160507113025.67c3ab43@halley>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
	<1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34290 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcEGIaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 04:30:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id n129so12235051wmn.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 01:30:29 -0700 (PDT)
In-Reply-To: <1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri,  6 May 2016 18:49:40 -0700 David Ahern <dsa@cumulusnetworks.com> wrote:
> +static bool ipv6_ndisc_frame(const struct sk_buff *skb)
> +{
> +	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
> +	size_t hlen = sizeof(*ipv6h);
> +	bool rc = false;
> +
> +	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
> +		const struct icmp6hdr *icmph;
> +
> +		if (skb->len < hlen + sizeof(*icmph))
> +			goto out;
> +
> +		icmph = (struct icmp6hdr *)(skb->data + sizeof(*ipv6h));
> +		switch (icmph->icmp6_type) {

Don't we need an additional pskb_may_pull here?

If I get it right, 'ipv6_rcv' only assures sizeof(ipv6hdr) to be in the
linear header (unless it's a NEXTHDR_HOP, which is not the case here).

> +static inline
> +struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
> +{
> +	struct net_device *master = NULL;
> +
> +	if (netif_is_l3_slave(skb->dev))
> +		master = netdev_master_upper_dev_get_rcu(skb->dev);
> +
> +	else if (netif_is_l3_master(skb->dev))
> +		master = skb->dev;
> +
> +	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
> +		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);

In the case where netif_is_l3_master(skb->dev) is true, can you explain
why we need to pass it through the l3mdev_l3_rcv callback again?

Regards,
Shmulik
