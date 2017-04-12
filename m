From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 09:06:48 -0600
Message-ID: <dbc81431-487b-f218-a4c6-2caa44783d97@cumulusnetworks.com>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34065 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753527AbdDLPGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 11:06:48 -0400
Received: by mail-oi0-f54.google.com with SMTP id g204so35048847oib.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 08:06:48 -0700 (PDT)
In-Reply-To: <20170412123408.22012-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/17 6:34 AM, Johannes Berg wrote:
> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> index b2c9c26ea30f..7df88770e029 100644
> --- a/include/uapi/linux/netlink.h
> +++ b/include/uapi/linux/netlink.h
> @@ -69,6 +69,10 @@ struct nlmsghdr {
>  #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
>  #define NLM_F_APPEND	0x800	/* Add to end of list		*/
>  
> +/* Flags for ACK message */
> +#define NLM_F_CAPPED	0x100	/* request was capped */
> +#define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
> +
>  /*
>     4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
>     4.4BSD CHANGE	NLM_F_REPLACE
> @@ -101,6 +105,33 @@ struct nlmsghdr {
>  struct nlmsgerr {
>  	int		error;
>  	struct nlmsghdr msg;
> +	/*
> +	 * followed by the message contents unless NETLINK_CAP_ACK was set
> +	 * or the ACK indicates success (error == 0)
> +	 * message length is aligned with NLMSG_ALIGN()
> +	 */
> +	/*
> +	 * followed by TLVs defined in enum nlmsgerr_attrs
> +	 * if NETLINK_EXT_ACK was set
> +	 */
> +};
> +
> +/**
> + * enum nlmsgerr_attrs - nlmsgerr attributes
> + * @NLMSGERR_ATTR_UNUSED: unused
> + * @NLMSGERR_ATTR_MSG: error message string (string)
> + * @NLMSGERR_ATTR_OFFS: offset of the invalid attribute in the original
> + *	 message, counting from the beginning of the header (u32)
> + * @__NLMSGERR_ATTR_MAX: number of attributes
> + * @NLMSGERR_ATTR_MAX: highest attribute number
> + */
> +enum nlmsgerr_attrs {
> +	NLMSGERR_ATTR_UNUSED,
> +	NLMSGERR_ATTR_MSG,

There was a discussion about side effects of adding strings (bloat,
internationalization). Should ATTR_MSG be removed until that is ironed
out? Leaving it in suggests it is ok to start adding strings.
