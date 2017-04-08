From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 8 Apr 2017 14:26:18 -0400
Message-ID: <46f42c2a-db2a-78b5-37c8-0ee5bb0443f8@cumulusnetworks.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34603 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751777AbdDHS0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:26:20 -0400
Received: by mail-io0-f176.google.com with SMTP id a103so283702ioj.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 11:26:20 -0700 (PDT)
In-Reply-To: <20170408174900.12820-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 1:48 PM, Johannes Berg wrote:
> @@ -2267,21 +2284,37 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  }
>  EXPORT_SYMBOL(__netlink_dump_start);
>  
> -void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
> +void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
> +		 const struct netlink_ext_ack *extack)
>  {
>  	struct sk_buff *skb;
>  	struct nlmsghdr *rep;
>  	struct nlmsgerr *errmsg;
>  	size_t payload = sizeof(*errmsg);
> +	size_t acksize = sizeof(*errmsg);
>  	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
>  
>  	/* Error messages get the original request appened, unless the user
> -	 * requests to cap the error message.
> +	 * requests to cap the error message, and get extra error data if
> +	 * requested.
>  	 */
> -	if (!(nlk->flags & NETLINK_F_CAP_ACK) && err)
> -		payload += nlmsg_len(nlh);
> +	if (err) {
> +		if (!(nlk->flags & NETLINK_F_CAP_ACK))
> +			payload += nlmsg_len(nlh);
> +		acksize = payload;
> +		if (nlk->flags & NETLINK_F_EXT_ACK) {
> +			if (extack && extack->_msg)
> +				acksize +=
> +					nla_total_size(strlen(extack->_msg) + 1);
> +			if (extack && extack->bad_attr)
> +				acksize += nla_total_size(sizeof(u32));
> +			if (extack &&
> +			    (extack->missing_attr || extack->bad_attr))
> +				acksize += nla_total_size(sizeof(u16));

If you create a v3, the extack check can by pulled up to the (flags &
NETLINK_F_EXT_ACK) check.


> +		}
> +	}
>  
> -	skb = nlmsg_new(payload, GFP_KERNEL);
> +	skb = nlmsg_new(acksize, GFP_KERNEL);
>  	if (!skb) {
>  		struct sock *sk;
>  
> @@ -2300,14 +2333,35 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>  			  NLMSG_ERROR, payload, 0);
>  	errmsg = nlmsg_data(rep);
>  	errmsg->error = err;
> -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
> +	memcpy(&errmsg->msg, nlh,
> +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
> +						 : sizeof(*nlh));
> +
> +	if (err && nlk->flags & NETLINK_F_EXT_ACK) {
> +		if (extack && extack->_msg)
> +			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
> +					       extack->_msg));
> +		if (extack && extack->bad_attr &&
> +		    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
> +			     (u8 *)extack->bad_attr >= in_skb->data +
> +						       in_skb->len))
> +			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
> +					    (u8 *)extack->bad_attr -
> +					    in_skb->data));
> +		if (extack && extack->missing_attr)
> +			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
> +					    extack->missing_attr));

same here
