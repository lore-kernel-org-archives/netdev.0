From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] xen-netback: fix fragment detection in checksum
 setup
Date: Sat, 30 Nov 2013 16:13:57 -0500 (EST)
Message-ID: <20131130.161357.1101467615641418549.davem@davemloft.net>
References: <1385722328-32875-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3K3VN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 16:13:58 -0500
In-Reply-To: <1385722328-32875-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 29 Nov 2013 10:52:08 +0000

> @@ -1166,15 +1166,27 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>  	struct iphdr *iph = (void *)skb->data;
>  	unsigned int header_size;
>  	unsigned int off;
> +	bool fragment;
>  	int err = -EPROTO;
>  
> +	fragment = false;
> +
>  	off = sizeof(struct iphdr);
>  
>  	header_size = skb->network_header + off + MAX_IPOPTLEN;
>  	maybe_pull_tail(skb, header_size);
>  
> +	if (iph->frag_off & htons(IP_OFFSET | IP_MF))
> +		fragment = true;

This function has a serious problem.

maybe_pull_tail() can change skb->data, therefore this "iph" pointer
can become invalid, you're essentially dereferencing garbage if
maybe_pull_tail() actually does any work.

Secondly, do you really (even rate limited) want to span the system
log just because some ipv4 fragmented frames end up here?  That
doesn't make any sense to me.  Maybe bump a statistic or something
like that, but a log message triggerable by a remote entity?  No way.
