From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] Add bridge ifindex to bridge fdb notify msgs
Date: Tue, 27 May 2014 09:37:13 -0700
Message-ID: <20140527093713.512824b0@nehalam.linuxnetplumber.net>
References: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:39884 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbaE0QhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 12:37:16 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so9528538pbb.21
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 09:37:16 -0700 (PDT)
In-Reply-To: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2014 21:39:46 -0700
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds NDA_MASTER attribute to neighbour attributes enum for
> bridge/master ifindex. And adds NDA_MASTER to bridge fdb notify msgs.
> 
> Today bridge fdb notifications dont contain bridge information.
> Userspace can derive it from the port information in the fdb
> notification. However this is tricky in some scenarious.
> 
> Example, bridge port delete notification comes before bridge fdb
> delete notifications. And we have seen problems in userspace
> when using libnl where, the bridge fdb delete notification handling code
> does not understand which bridge this fdb entry is part of because
> the bridge and port association has already been deleted.
> And these notifications (port membership and fdb) are generated on
> separate rtnl groups.
> 
> Fixing the order of notifications could possibly solve the problem
> for some cases (I can submit a separate patch for that).
> 
> This patch chooses to add NDA_MASTER to bridge fdb notify msgs
> because it not only solves the problem described above, but also helps
> userspace avoid another lookup into link msgs to derive the master index.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/uapi/linux/neighbour.h |    1 +
>  net/bridge/br_fdb.c            |    3 +++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
> index d3ef583..4a1d7e9 100644
> --- a/include/uapi/linux/neighbour.h
> +++ b/include/uapi/linux/neighbour.h
> @@ -24,6 +24,7 @@ enum {
>  	NDA_PORT,
>  	NDA_VNI,
>  	NDA_IFINDEX,
> +	NDA_MASTER,
>  	__NDA_MAX
>  };
>  
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9203d5a..019bb93 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -565,6 +565,8 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
>  
>  	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
>  		goto nla_put_failure;
> +	if (nla_put_u32(skb, NDA_MASTER, br->dev->ifindex))
> +		goto nla_put_failure;
>  	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
>  	ci.ndm_confirmed = 0;
>  	ci.ndm_updated	 = jiffies_to_clock_t(now - fdb->updated);
> @@ -586,6 +588,7 @@ static inline size_t fdb_nlmsg_size(void)
>  {
>  	return NLMSG_ALIGN(sizeof(struct ndmsg))
>  		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
> +		+ nla_total_size(sizeof(u32)) /* NDA_MASTER */
>  		+ nla_total_size(sizeof(u16)) /* NDA_VLAN */
>  		+ nla_total_size(sizeof(struct nda_cacheinfo));
>  }

I like the idea of this, but the new attribute needs to be part of the set
as well as notify and display infrastructure.
