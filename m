From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 v2] ss: Refactor to use macro for define diag nl
 request
Date: Thu, 30 Oct 2014 18:39:25 +0200
Message-ID: <20141030163925.GA18896@angus-think.wlc.globallogic.com>
References: <1413705696-2315-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:65511 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758431AbaJ3Qsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:48:36 -0400
Received: by mail-wg0-f46.google.com with SMTP id x13so4720251wgg.19
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 09:48:35 -0700 (PDT)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id gg18sm9583467wic.21.2014.10.30.09.48.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 09:48:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413705696-2315-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 11:01:36AM +0300, Vadim Kochan wrote:
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  misc/ss.c | 56 +++++++++++++++++---------------------------------------
>  1 file changed, 17 insertions(+), 39 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 2420b51..d067e5f 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -41,6 +41,19 @@
>  #include <linux/packet_diag.h>
>  #include <linux/netlink_diag.h>
>  
> +#define DIAG_REQUEST(_req, _r)						    \
> +	struct {							    \
> +		struct nlmsghdr nlh;					    \
> +		_r;							    \
> +	} _req = {							    \
> +		.nlh = {						    \
> +			.nlmsg_type = SOCK_DIAG_BY_FAMILY,		    \
> +			.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST,\
> +			.nlmsg_seq = 123456,				    \
> +			.nlmsg_len = sizeof(_req),			    \
> +		},							    \
> +	}
> +
>  #if HAVE_SELINUX
>  #include <selinux/selinux.h>
>  #else
> @@ -1795,10 +1808,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
>  static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
>  {
>  	struct sockaddr_nl nladdr;
> -	struct {
> -		struct nlmsghdr nlh;
> -		struct inet_diag_req_v2 r;
> -	} req;
> +	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
>  	char    *bc = NULL;
>  	int	bclen;
>  	struct msghdr msg;
> @@ -1811,11 +1821,6 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
>  	memset(&nladdr, 0, sizeof(nladdr));
>  	nladdr.nl_family = AF_NETLINK;
>  
> -	req.nlh.nlmsg_len = sizeof(req);
> -	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
> -	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
> -	req.nlh.nlmsg_pid = 0;
> -	req.nlh.nlmsg_seq = 123456;
>  	memset(&req.r, 0, sizeof(req.r));
>  	req.r.sdiag_family = family;
>  	req.r.sdiag_protocol = protocol;
> @@ -2577,16 +2582,7 @@ close_it:
>  
>  static int unix_show_netlink(struct filter *f, FILE *dump_fp)
>  {
> -	struct {
> -		struct nlmsghdr nlh;
> -		struct unix_diag_req r;
> -	} req;
> -
> -	memset(&req, 0, sizeof(req));
> -	req.nlh.nlmsg_len = sizeof(req);
> -	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
> -	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
> -	req.nlh.nlmsg_seq = 123456;
> +	DIAG_REQUEST(req, struct unix_diag_req r);
>  
>  	req.r.sdiag_family = AF_UNIX;
>  	req.r.udiag_states = f->states;
> @@ -2778,21 +2774,12 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
>  static int packet_show_netlink(struct filter *f, FILE *dump_fp)
>  {
>  	int fd;
> -	struct {
> -		struct nlmsghdr nlh;
> -		struct packet_diag_req r;
> -	} req;
> +	DIAG_REQUEST(req, struct packet_diag_req r);
>  	char	buf[8192];
>  
>  	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
>  		return -1;
>  
> -	memset(&req, 0, sizeof(req));
> -	req.nlh.nlmsg_len = sizeof(req);
> -	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
> -	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
> -	req.nlh.nlmsg_seq = 123456;
> -
>  	req.r.sdiag_family = AF_PACKET;
>  	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
>  
> @@ -3091,16 +3078,7 @@ static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
>  
>  static int netlink_show_netlink(struct filter *f, FILE *dump_fp)
>  {
> -	struct {
> -		struct nlmsghdr nlh;
> -		struct netlink_diag_req r;
> -	} req;
> -
> -	memset(&req, 0, sizeof(req));
> -	req.nlh.nlmsg_len = sizeof(req);
> -	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
> -	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
> -	req.nlh.nlmsg_seq = 123456;
> +	DIAG_REQUEST(req, struct netlink_diag_req r);
>  
>  	req.r.sdiag_family = AF_NETLINK;
>  	req.r.sdiag_protocol = NDIAG_PROTO_ALL;
> -- 
> 2.1.0
> 

Please ignore this patch because of conflicts with master, will resend v3.

Regards,
