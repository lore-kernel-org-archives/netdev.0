From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ss: implement -M option to get all memory
 information
Date: Wed, 25 Apr 2012 10:41:28 -0700
Message-ID: <20120425104128.4d6e13e1@nehalam.linuxnetplumber.net>
References: <4F97A48F.4010109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab2DYRlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 13:41:32 -0400
In-Reply-To: <4F97A48F.4010109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 15:15:27 +0800
Shan Wei <shanwei88@gmail.com> wrote:

> From: Shan Wei <davidshan@tencent.com>
> 
> INET_DIAG_SKMEMINFO is used to monitor socket memory information
> which contains more information than INET_DIAG_MEMINFO.
> 
> -m option is retained for old kernel that don't surpport INET_DIAG_SKMEMINFO.
> 
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  misc/ss.c |   27 +++++++++++++++++++++++++--
>  1 files changed, 25 insertions(+), 2 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 5f70a26..3c8befd 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -45,6 +45,7 @@ int show_options = 0;
>  int show_details = 0;
>  int show_users = 0;
>  int show_mem = 0;
> +int show_skmem = 0;
>  int show_tcpinfo = 0;
>  
>  int netid_width;
> @@ -1410,6 +1411,19 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
>  			printf(" rcv_space:%d", info->tcpi_rcv_space);
>  
>  	}
> +
> +	if (tb[INET_DIAG_SKMEMINFO]) {
> +		const unsigned int *skmeminfo =  RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
> +		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u)",
> +			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
> +			skmeminfo[SK_MEMINFO_RCVBUF],
> +			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
> +			skmeminfo[SK_MEMINFO_SNDBUF],
> +			skmeminfo[SK_MEMINFO_FWD_ALLOC],
> +			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
> +			skmeminfo[SK_MEMINFO_OPTMEM]);
> +	}
> +
>  }
>  
>  static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
> @@ -1466,7 +1480,7 @@ static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
>  			printf("%08x", r->id.idiag_cookie[1]);
>   		printf("%08x", r->id.idiag_cookie[0]);
>  	}
> -	if (show_mem || show_tcpinfo) {
> +	if (show_mem || show_tcpinfo || show_skmem) {
>  		printf("\n\t");
>  		tcp_show_info(nlh, r);
>  	}
> @@ -1508,6 +1522,9 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
>  	if (show_mem)
>  		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
>  
> +	if (show_skmem)
> +		req.r.idiag_ext |= (1<<(INET_DIAG_SKMEMINFO-1));
> +
>  	if (show_tcpinfo) {
>  		req.r.idiag_ext |= (1<<(INET_DIAG_INFO-1));
>  		req.r.idiag_ext |= (1<<(INET_DIAG_VEGASINFO-1));
> @@ -2581,6 +2598,8 @@ static void _usage(FILE *dest)
>  "   -o, --options       show timer information\n"
>  "   -e, --extended      show detailed socket information\n"
>  "   -m, --memory        show socket memory usage\n"
> +"   -M, --skmem         show socket memory information.\n"
> +"                       this option which will replace -m, is valid since Linux 3.3.\n"

Please don't add reference to kernel version.
Why does this need to be a new option? Maybe just do the right thing
if present in the netlink response?
