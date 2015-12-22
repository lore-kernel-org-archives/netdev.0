From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 08/17] ipv6: Add ipv6_renew_options_kern() that
 accepts a kernel mem pointer.
Date: Tue, 22 Dec 2015 14:28:03 +0100
Message-ID: <56794FE3.7050507@stressinduktion.org>
References: <1450784813-18304-9-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>
To: Huw Davies <huw@codeweavers.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:39536 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932293AbbLVNh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 08:37:27 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5F8DF20D60
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 08:28:05 -0500 (EST)
In-Reply-To: <1450784813-18304-9-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.12.2015 12:46, Huw Davies wrote:
> The functionality is equivalent to ipv6_renew_options() except
> that the newopt pointer is in kernel, not user, memory
> 
> The kernel memory implementation will be used by the CALIPSO network
> labelling engine, which needs to be able to set IPv6 hop-by-hop
> options.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>
> ---
>  include/net/ipv6.h |   6 +++
>  net/ipv6/exthdrs.c | 131 ++++++++++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 125 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 9a5c9f0..5a72ffd 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -304,6 +304,12 @@ struct ipv6_txoptions *ipv6_renew_options(struct sock *sk,
>  					  int newtype,
>  					  struct ipv6_opt_hdr __user *newopt,
>  					  int newoptlen);
> +struct ipv6_txoptions *
> +ipv6_renew_options_kern(struct sock *sk,
> +			struct ipv6_txoptions *opt,
> +			int newtype,
> +			struct ipv6_opt_hdr *newopt,
> +			int newoptlen);
>  struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
>  					  struct ipv6_txoptions *opt);
>  
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index ea7c4d6..9426b26 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -734,11 +734,16 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
>  EXPORT_SYMBOL_GPL(ipv6_dup_options);
>  
>  static int ipv6_renew_option(void *ohdr,
> -			     struct ipv6_opt_hdr __user *newopt, int newoptlen,
> +			     struct ipv6_opt_hdr __user *newopt_user,
> +			     struct ipv6_opt_hdr *newopt,
> +			     int newoptlen,
>  			     int inherit,
>  			     struct ipv6_opt_hdr **hdr,
>  			     char **p)


This looks quite ugly to me.

Wouldn't it be possible to do something like this:


ipv6_renew_option_kern(...)
{
	int ret;
	const mm_segment_t old_fs = get_fs();
	set_fs(KERNEL_DS);
	ret = ipv6_renew_option(...); // maybe you need to forcefully cast the
user away here
	set_fs(old_fs);
	return ret;
}

Bye,
Hannes
