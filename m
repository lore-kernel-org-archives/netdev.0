From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next] rtnetlink: bridge: use ext_ack instead of
 printk
Date: Tue, 10 Oct 2017 08:18:46 -0600
Message-ID: <9c01905a-92e1-1246-35ee-2a60ac11733e@gmail.com>
References: <20171010113236.8889-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36219 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756116AbdJJOSy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:18:54 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so18625429pfk.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:18:54 -0700 (PDT)
In-Reply-To: <20171010113236.8889-1-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/17 5:32 AM, Florian Westphal wrote:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e84d108cfee4..19ea53a5210f 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -3066,21 +3066,22 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
>  }
>  EXPORT_SYMBOL(ndo_dflt_fdb_add);
>  
> -static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
> +static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid,
> +			 struct netlink_ext_ack *exta)
>  {
>  	u16 vid = 0;
>  
>  	if (vlan_attr) {
>  		if (nla_len(vlan_attr) != sizeof(u16)) {
> -			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan\n");
> +			NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with invalid vlan");

I realize you are keeping the existing wording, but the messages are
moving from out of line pr_info to inline message in response to a user
command.  From a user's perspective the RTM_NEWNEIGH and DELNEIGH do not
add much value, and the add and del in the bridge command tells which it
is. So in this case just emit "Invalid vlan id".

Although this failure is an invalid vlan attribute as opposed to an
invalid vlan id which is what the next message checks. So the message
needs to be updated as well.


>  			return -EINVAL;
>  		}
>  
>  		vid = nla_get_u16(vlan_attr);
>  
>  		if (!vid || vid >= VLAN_VID_MASK) {
> -			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan id %d\n",
> -				vid);
> +			NL_SET_ERR_MSG(exta,
> +				       "RTM_NEWNEIGH with invalid vlan id");
>  			return -EINVAL;
>  		}
>  	}
