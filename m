From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH 2/7] ethtool: avoid resource leak of strings in
 do_gprivflags
Date: Mon, 3 Oct 2016 13:54:26 -0400
Message-ID: <20161003175426.GC43474@redhat.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
 <1475265381-28937-3-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35918 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbcJCRyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 13:54:35 -0400
Received: by mail-pa0-f44.google.com with SMTP id qn7so63226202pac.3
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 10:54:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1475265381-28937-3-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 03:56:16PM -0400, John W. Linville wrote:
> Coverity issue: 1363119
> Fixes: e1ee596326ae ("Add support for querying and setting private flags")
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  ethtool.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index aa3ef5ed2f75..0885a61097ad 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -4205,7 +4205,7 @@ static int do_gprivflags(struct cmd_context *ctx)
>  	struct ethtool_gstrings *strings;
>  	struct ethtool_value flags;
>  	unsigned int i;
> -	int max_len = 0, cur_len;
> +	int max_len = 0, cur_len, rc;
>  
>  	if (ctx->argc != 0)
>  		exit_bad_args();
> @@ -4215,11 +4215,13 @@ static int do_gprivflags(struct cmd_context *ctx)
>  				1);
>  	if (!strings) {
>  		perror("Cannot get private flag names");
> -		return 1;
> +		rc = 1;
> +		goto err;

This goto looks redundant, since all you're doing at err is re-checking if
strings is non-null to free it.

>  	if (strings->len == 0) {
>  		fprintf(stderr, "No private flags defined\n");
> -		return 1;
> +		rc = 1;
> +		goto err;
>  	}
>  	if (strings->len > 32) {
>  		/* ETHTOOL_GPFLAGS can only cover 32 flags */
> @@ -4230,7 +4232,8 @@ static int do_gprivflags(struct cmd_context *ctx)
>  	flags.cmd = ETHTOOL_GPFLAGS;
>  	if (send_ioctl(ctx, &flags)) {
>  		perror("Cannot get private flags");
> -		return 1;
> +		rc = 1;
> +		goto err;
>  	}
>  
>  	/* Find longest string and align all strings accordingly */
> @@ -4248,7 +4251,12 @@ static int do_gprivflags(struct cmd_context *ctx)
>  		       (const char *)strings->data + i * ETH_GSTRING_LEN,
>  		       (flags.data & (1U << i)) ? "on" : "off");
>  
> -	return 0;
> +	rc = 0;
> +
> +err:
> +	if (strings)
> +		free(strings);
> +	return rc;
>  }
>  
>  static int do_sprivflags(struct cmd_context *ctx)
> -- 
> 2.7.4
> 

-- 
Jarod Wilson
jarod@redhat.com
