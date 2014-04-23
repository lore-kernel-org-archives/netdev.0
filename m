From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] rtnetlink: Warn when interface's information won't
 fit in our packet
Date: Wed, 23 Apr 2014 18:20:14 +0400
Message-ID: <5357CC1E.6070609@cogentembedded.com>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au> <1398237665-26980-2-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, neepatel@cisco.com, benve@cisco.com,
	davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: David Gibson <david@gibson.dropbear.id.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:44593 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbaDWOUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:20:17 -0400
Received: by mail-la0-f54.google.com with SMTP id e16so522414lan.41
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 07:20:16 -0700 (PDT)
In-Reply-To: <1398237665-26980-2-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-04-2014 11:21, David Gibson wrote:

> Without IFLA_EXT_MASK specified, the information reported for a single
> interface in response to RTM_GETLINK is expected to fit within a netlink
> packet of NLMSG_GOODSIZE.

> If it doesn't, however, things will go badly wrong,  When listing all
> interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
> message in a packet as the end of the listing and omit information for
> that interface and all subsequent ones.  This can cause getifaddrs(3) to
> enter an infinite loop.

> This patch won't fix the problem, but it will WARN_ON() making it easier to
> track down what's going wrong.

> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> ---
>   net/core/rtnetlink.c | 16 +++++++++++-----
>   1 file changed, 11 insertions(+), 5 deletions(-)

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index d4ff417..5331db2 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
[...]
> @@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>   		hlist_for_each_entry_rcu(dev, head, index_hlist) {
>   			if (idx < s_idx)
>   				goto cont;
> -			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> -					     NETLINK_CB(cb->skb).portid,
> -					     cb->nlh->nlmsg_seq, 0,
> -					     NLM_F_MULTI,
> -					     ext_filter_mask) <= 0)
> +			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> +					       NETLINK_CB(cb->skb).portid,
> +					       cb->nlh->nlmsg_seq, 0,
> +					       NLM_F_MULTI,
> +					       ext_filter_mask);
> +			/* If we ran out of room on the first message,
> +			 * we're in trouble */

    Hm, comment style... multi-line comments in the networking code should 
look like this:

/* bla
  * bla
  */

> +			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
> +
> +			if (err <= 0)

WBR, Sergei
