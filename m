From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH v2 3/5] netlink: allow sending extended ACK with cookie on
 success
Date: Sat, 8 Apr 2017 15:07:04 -0400
Message-ID: <3176866b-3e8d-4669-796f-8292d68a5511@cumulusnetworks.com>
References: <20170408183444.2796-1-johannes@sipsolutions.net>
 <20170408183444.2796-4-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408183444.2796-4-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

since a v3 is coming another small cleanup ...


On 4/8/17 2:34 PM, Johannes Berg wrote:
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index c74f56a4fcf1..98e55a59c97e 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2336,20 +2339,27 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
>  	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
>  						 : sizeof(*nlh));
>  
> -	if (err && nlk->flags & NETLINK_F_EXT_ACK && extack) {
> -		if (extack->_msg)
> -			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
> -					       extack->_msg));
> -		if (extack->bad_attr &&
> -		    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
> -			     (u8 *)extack->bad_attr >= in_skb->data +
> -						       in_skb->len))
> -			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
> -					    (u8 *)extack->bad_attr -
> -					    in_skb->data));
> -		if (extack->missing_attr)
> -			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
> -					    extack->missing_attr));
> +	if (nlk->flags & NETLINK_F_EXT_ACK) {
> +		if (err && extack) {

push the extack into the flags if check

> +			if (extack->_msg)
> +				WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
> +						       extack->_msg));
> +			if (extack->bad_attr &&
> +			    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
> +				     (u8 *)extack->bad_attr >= in_skb->data +
> +							       in_skb->len))
> +				WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
> +						    (u8 *)extack->bad_attr -
> +						    in_skb->data));
> +			if (extack->missing_attr)
> +				WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
> +						    extack->missing_attr));
> +		} else if (!err && extack) {

and here too

> +			if (extack->cookie_len)
> +				WARN_ON(nla_put(skb, NLMSGERR_ATTR_COOKIE,
> +						extack->cookie_len,
> +						extack->cookie));
> +		}
