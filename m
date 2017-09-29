From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Fri, 29 Sep 2017 15:06:55 +0200
Message-ID: <20170929130655.qokb6b55cozj5oor@unicorn.suse.cz>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Hangbin Liu <haliu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42993 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750877AbdI2NG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 09:06:57 -0400
Content-Disposition: inline
In-Reply-To: <1506605626-1744-3-git-send-email-haliu@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 09:33:46PM +0800, Hangbin Liu wrote:
> From: Hangbin Liu <liuhangbin@gmail.com>
> 
> This is an update for 460c03f3f3cc ("iplink: double the buffer size also in
> iplink_get()"). After update, we will not need to double the buffer size
> every time when VFs number increased.
> 
> With call like rtnl_talk(&rth, &req.n, NULL, 0), we can simply remove the
> length parameter.
> 
> With call like rtnl_talk(&rth, nlh, nlh, sizeof(req), I add a new variable
> answer to avoid overwrite data in nlh, because it may has more info after
> nlh. also this will avoid nlh buffer not enough issue.
> 
> We need to free answer after using.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---

Reviewed-by: Michal Kubecek <mkubecek@suse.cz>

> diff --git a/ip/link_gre.c b/ip/link_gre.c
> index 9ea2970..35782ca 100644
> --- a/ip/link_gre.c
> +++ b/ip/link_gre.c
> @@ -68,7 +68,6 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
>  	struct {
>  		struct nlmsghdr n;
>  		struct ifinfomsg i;
> -		char buf[16384];
>  	} req = {
>  		.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
>  		.n.nlmsg_flags = NLM_F_REQUEST,
> @@ -76,6 +75,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
>  		.i.ifi_family = preferred_family,
>  		.i.ifi_index = ifi->ifi_index,
>  	};
> +	struct nlmsghdr *answer = NULL;
>  	struct rtattr *tb[IFLA_MAX + 1];
>  	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
>  	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
> @@ -100,19 +100,20 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
>  	__u32 erspan_idx = 0;
>  
>  	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
> -		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
> +		if (rtnl_talk(&rth, &req.n, &answer) < 0) {
>  get_failed:
>  			fprintf(stderr,
>  				"Failed to get existing tunnel info.\n");
> +			free(answer);
>  			return -1;
>  		}

Took me a moment to realize answer is still NULL if we get here via
failed rtnl_talk() but non-NULL if we get here via "goto get_failed"
later. Nice trick. :-)

Michal Kubecek
