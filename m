From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 12:15:40 +0200
Message-ID: <1491819340.2455.7.camel@sipsolutions.net>
References: <20170408183444.2796-1-johannes@sipsolutions.net>
         <20170408183444.2796-2-johannes@sipsolutions.net>
         (sfid-20170408_203507_265684_7230C4D6)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35448 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbdDJKPo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 06:15:44 -0400
In-Reply-To: <20170408183444.2796-2-johannes@sipsolutions.net> (sfid-20170408_203507_265684_7230C4D6)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> @@ -2300,14 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
        rep = __nlmsg_put(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
>  			  NLMSG_ERROR, payload, 0);
>  	errmsg = nlmsg_data(rep);
>  	errmsg->error = err;

This is still wrong - now the message length is too short.

At the very least,

> -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh-
> >nlmsg_len : sizeof(*nlh));
> +	memcpy(&errmsg->msg, nlh,
> +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
> +						 : sizeof(*nlh));
> +
> +	if (err && nlk->flags & NETLINK_F_EXT_ACK && extack) {
> +		if (extack->_msg)
> +			WARN_ON(nla_put_string(skb,
> NLMSGERR_ATTR_MSG,
> +					       extack->_msg));
> +		if (extack->bad_attr &&
> +		    !WARN_ON((u8 *)extack->bad_attr < in_skb->data
> ||
> +			     (u8 *)extack->bad_attr >= in_skb->data
> +
> +						       in_skb->len))
> +			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
> +					    (u8 *)extack->bad_attr -
> +					    in_skb->data));
> +		if (extack->missing_attr)
> +			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
> +					    extack->missing_attr));
> +	}

I need to add
 rep->nlmsg_len = skb->len;

>  	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid,
> MSG_DONTWAIT);

Here, but at that point I think it makes sense to rewrite this nlmsg
put stuff here as well.

johannes
