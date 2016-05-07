From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Sat, 7 May 2016 08:50:49 -0600
Message-ID: <572E00C9.4050109@cumulusnetworks.com>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
 <1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
 <20160507113025.67c3ab43@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33699 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbcEGOu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 10:50:56 -0400
Received: by mail-io0-f170.google.com with SMTP id f89so138486528ioi.0
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 07:50:56 -0700 (PDT)
In-Reply-To: <20160507113025.67c3ab43@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/16 2:30 AM, Shmulik Ladkani wrote:
> Hi David,
>
> On Fri,  6 May 2016 18:49:40 -0700 David Ahern <dsa@cumulusnetworks.com> wrote:
>> +static bool ipv6_ndisc_frame(const struct sk_buff *skb)
>> +{
>> +	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
>> +	size_t hlen = sizeof(*ipv6h);
>> +	bool rc = false;
>> +
>> +	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
>> +		const struct icmp6hdr *icmph;
>> +
>> +		if (skb->len < hlen + sizeof(*icmph))
>> +			goto out;
>> +
>> +		icmph = (struct icmp6hdr *)(skb->data + sizeof(*ipv6h));
>> +		switch (icmph->icmp6_type) {
>
> Don't we need an additional pskb_may_pull here?
>
> If I get it right, 'ipv6_rcv' only assures sizeof(ipv6hdr) to be in the
> linear header (unless it's a NEXTHDR_HOP, which is not the case here).

yes, I inadvertently dropped this:

commit 65c38aa653c14df49e19faad74bd375f36e61c57
Author: David Ahern <dsa@cumulusnetworks.com>
Date:   Tue Feb 23 10:10:26 2016 -0800

     net: vrf: Remove direct access to skb->data

when I forward ported this patch. Will fix and re-send.

>
>> +static inline
>> +struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
>> +{
>> +	struct net_device *master = NULL;
>> +
>> +	if (netif_is_l3_slave(skb->dev))
>> +		master = netdev_master_upper_dev_get_rcu(skb->dev);
>> +
>> +	else if (netif_is_l3_master(skb->dev))
>> +		master = skb->dev;
>> +
>> +	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
>> +		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);
>
> In the case where netif_is_l3_master(skb->dev) is true, can you explain
> why we need to pass it through the l3mdev_l3_rcv callback again?

what do you mean again? This is only time the l3mdev_l3_rcv method is 
called on a packet.
