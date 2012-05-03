From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ss: implement -M option to get all memory
 information
Date: Thu, 3 May 2012 08:25:26 -0700
Message-ID: <20120503082526.492f7f81@nehalam.linuxnetplumber.net>
References: <4F97A48F.4010109@gmail.com>
	<20120425104128.4d6e13e1@nehalam.linuxnetplumber.net>
	<4F99FEA1.2000700@gmail.com>
	<20120427102138.67bd6b3a@nehalam.linuxnetplumber.net>
	<4FA1021E.6030905@gmail.com>
	<20120502120042.5420644a@s6510.linuxnetplumber.net>
	<4FA24458.6020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37374 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755927Ab2ECPZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 11:25:30 -0400
In-Reply-To: <4FA24458.6020105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 May 2012 16:39:52 +0800
Shan Wei <shanwei88@gmail.com> wrote:

> Stephen Hemminger said, at 2012/5/3 3:00:
> 
> > 
> > This looks good, is the skmeminfo a superset of the old meminfo?
> 
> 
> Yes, skmeminfo is a superset of old meminfo.
> Using this can get more socket memory information. 
> 
> > But your code is broken on 64 bit. skmeminfo in kernel is an array of __u32!
> 
> 
> OK. here is a new version.
> 
> ----
> [PATCH] ss: use new INET_DIAG_SKMEMINFO option to get more memory information for tcp socket
> 
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  misc/ss.c |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 5f70a26..bd60548 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1336,7 +1336,17 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
>  	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
>  		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
>  
> -	if (tb[INET_DIAG_MEMINFO]) {
> +	if (tb[INET_DIAG_SKMEMINFO]) {
> +		const __u32 *skmeminfo =  RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
> +		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u)",
> +			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
> +			skmeminfo[SK_MEMINFO_RCVBUF],
> +			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
> +			skmeminfo[SK_MEMINFO_SNDBUF],
> +			skmeminfo[SK_MEMINFO_FWD_ALLOC],
> +			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
> +			skmeminfo[SK_MEMINFO_OPTMEM]);
> +	}else if (tb[INET_DIAG_MEMINFO]) {
>  		const struct inet_diag_meminfo *minfo
>  			= RTA_DATA(tb[INET_DIAG_MEMINFO]);
>  		printf(" mem:(r%u,w%u,f%u,t%u)",
> @@ -1505,8 +1515,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
>  	memset(&req.r, 0, sizeof(req.r));
>  	req.r.idiag_family = AF_INET;
>  	req.r.idiag_states = f->states;
> -	if (show_mem)
> +	if (show_mem) {
>  		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
> +		req.r.idiag_ext |= (1<<(INET_DIAG_SKMEMINFO-1));
> +	}
>  
>  	if (show_tcpinfo) {
>  		req.r.idiag_ext |= (1<<(INET_DIAG_INFO-1));

This looks good, I will apply it
