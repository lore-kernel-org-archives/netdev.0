From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v3 2/2] mpls: fix mpls route deletes to not check
 for route scope
Date: Tue, 02 Jun 2015 15:03:26 -0700
Message-ID: <556E282E.2040501@cumulusnetworks.com>
References: <1433226567-23302-3-git-send-email-roopa@cumulusnetworks.com> <87a8wholtc.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, davem@davemloft.net,
	rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:34624 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbFBWD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 18:03:29 -0400
Received: by qcej9 with SMTP id j9so22870141qce.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 15:03:28 -0700 (PDT)
In-Reply-To: <87a8wholtc.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/2/15, 2:13 PM, Eric W. Biederman wrote:
> So I just stopped and looked at what is happening.  When you originally
> reported this you said (or at least I understood) that rtm_scope was not
> being set in iproute.  I assumed that meant it was not being touched
> and it was taking a default value of zero (or else it was possibly
> floating).  Having looked neither is true.  iproute sets rtm_scope
> to RT_SCOPE_NOWHERE during delete deliberately to act as a wild card.
>
> In the kernel in other protocols currently ipv4 treats RT_SCOPE_NOWHERE
> as a wild card during delete, decnet treats RT_SCOPE_NOWHERE as a wild
> card during delete, the remaining protocols (ipv6, phonet, and can) that
> implement RTM_DELROUTE do not look at rtm_scope at all.  Further ipv6
> and phonet set rtm_scope to RT_SCOPE_UNIVERSE when dumped.
>
> Which says to me that we have semantics in the kernel that no one has
> let userspace know about, and that scares me when there is a
> misunderstanding between the kernel and userspace about what fields
> mean.  That inevitabily leads to bugs.  The kind of bugs that I have
> to create security fixes for recently.
>
> So I really think we should fix this in userspace so that that someone
> reading iproute will have a chance at knowing that this scopes do not
> exist in ipv6 and mpls and that scope logic is just noise in those
> cases.
ack,  i did start with handling both type and scope
in iproute2. I misunderstood you when you said you did not care
abt the scope in earlier comments. so i made the kernel not care abt the
scope. :) but only handled type in 'iproute2' in v2.  now its clear. I 
do have a similar patch like below.
sorry abt the iterations. I will respin (If you prefer to post your 
below patch yourself, pls do. I am ok either way. Thanks.
>
> Something like:
>
>  From 837dddea49af874fe750ab0712b3ef8066a2f55a Mon Sep 17 00:00:00 2001
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Tue, 2 Jun 2015 15:51:31 -0500
> Subject: [PATCH] iproute: When deleting routes don't always set the scope to RT_SCOPE_NOWHERE
>
> IPv6 and MPLS do not implement scopes on addresses and using
> RT_SCOPE_NOWHERE is just confusing noise.  Use RT_SCOPE_UNIVERSE
> instead so that it is clear what is actually happening in the code.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   ip/iproute.c | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index fba475f65314..e9b991fdf62f 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1136,6 +1136,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   	if (nhs_ok)
>   		parse_nexthops(&req.n, &req.r, argc, argv);
>   
> +	if (req.r.rtm_family == AF_UNSPEC)
> +		req.r.rtm_family = AF_INET;
> +
>   	if (!table_ok) {
>   		if (req.r.rtm_type == RTN_LOCAL ||
>   		    req.r.rtm_type == RTN_BROADCAST ||
> @@ -1144,7 +1147,10 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   			req.r.rtm_table = RT_TABLE_LOCAL;
>   	}
>   	if (!scope_ok) {
> -		if (req.r.rtm_type == RTN_LOCAL ||
> +		if (req.r.rtm_family == AF_INET6 ||
> +		    req.r.rtm_family == AF_MPLS)
> +			req.r.rtm_scope = RT_SCOPE_UNIVERSE;
> +		else if (req.r.rtm_type == RTN_LOCAL ||
>   		    req.r.rtm_type == RTN_NAT)
>   			req.r.rtm_scope = RT_SCOPE_HOST;
>   		else if (req.r.rtm_type == RTN_BROADCAST ||
> @@ -1160,9 +1166,6 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   		}
>   	}
>   
> -	if (req.r.rtm_family == AF_UNSPEC)
> -		req.r.rtm_family = AF_INET;
> -
>   	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
>   		return -2;
>   
