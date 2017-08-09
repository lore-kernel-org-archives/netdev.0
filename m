From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH v2 iproute2] lib: Dump ext-ack string by default
Date: Wed, 9 Aug 2017 00:38:35 -0700
Message-ID: <9bc620b6-cd6e-a65e-7079-bb4d757312c4@oracle.com>
References: <1502202614-389-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50092 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbdHIHij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 03:38:39 -0400
In-Reply-To: <1502202614-389-1-git-send-email-dsahern@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/17 7:30 AM, David Ahern wrote:
> In time, errfn can be implemented for link, route, etc commands to
> give a much more detailed response (e.g., point to the attribute
> that failed). Doing so is much more complicated to process the
> message and convert attribute ids to names.
> 
> In any case the error string returned by the kernel should be dumped
> to the user, so make that happen now.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
> v2
> - check that errmsg is non-null
> 
>   lib/libnetlink.c | 15 ++++++++++-----
>   1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index 145de2cb0ccf..063f5cd6c7b1 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -61,7 +61,6 @@ static int err_attr_cb(const struct nlattr *attr, void *data)
>   	return MNL_CB_OK;
>   }
>   
> -
>   /* dump netlink extended ack error message */
>   static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
>   {
> @@ -72,9 +71,6 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
>   	const char *errmsg = NULL;
>   	uint32_t off = 0;
>   
> -	if (!errfn)
> -		return 0;
> -
>   	/* no TLVs, nothing to do here */
>   	if (!(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
>   		return 0;
> @@ -99,7 +95,16 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
>   			err_nlh = &err->msg;
>   	}
>   
> -	return errfn(errmsg, off, err_nlh);
> +	if (errfn)
> +		return errfn(errmsg, off, err_nlh);
> +
> +	if (errmsg) {
> +		fprintf(stderr, "Error: %s\n", errmsg);

Should the above output end with a period '.'? All the error messages in the 
Kernel are statements without a terminating period, so the output will look 
something like this..

Error: Minimally Geneve ID and Remote IP address are required
Error: Provided Ethernet address is not unicast
Error: Provided link layer address is not Ethernet

Thanks,
~Girish




> +
> +		return 1;
> +	}
> +
> +	return 0;
>   }
>   #else
>   #warning "libmnl required for error support"
> 
