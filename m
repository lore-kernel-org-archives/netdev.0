From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ss: Use generic handle_netlink_request for
 packet
Date: Thu, 30 Oct 2014 19:11:17 +0200
Message-ID: <20141030171117.GA24619@angus-think.wlc.globallogic.com>
References: <1413470432-28588-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:59396 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934323AbaJ3RU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 13:20:26 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so4183537wgh.25
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 10:20:25 -0700 (PDT)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id 4sm9343868wjx.39.2014.10.30.10.20.24
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 10:20:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413470432-28588-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2014 at 05:40:32PM +0300, Vadim Kochan wrote:
> Get rid of self-handling and creating of Netlink socket for show packet
> socket stats.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  misc/ss.c | 80 +++------------------------------------------------------------
>  1 file changed, 3 insertions(+), 77 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 2420b51..b3cc455 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2777,17 +2777,11 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
>  
>  static int packet_show_netlink(struct filter *f, FILE *dump_fp)
>  {
> -	int fd;
>  	struct {
>  		struct nlmsghdr nlh;
>  		struct packet_diag_req r;
> -	} req;
> -	char	buf[8192];
> -
> -	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
> -		return -1;
> +	} req = {};
>  
> -	memset(&req, 0, sizeof(req));
>  	req.nlh.nlmsg_len = sizeof(req);
>  	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
>  	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
> @@ -2796,76 +2790,8 @@ static int packet_show_netlink(struct filter *f, FILE *dump_fp)
>  	req.r.sdiag_family = AF_PACKET;
>  	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
>  
> -	if (send(fd, &req, sizeof(req), 0) < 0) {
> -		close(fd);
> -		return -1;
> -	}
> -
> -	while (1) {
> -		ssize_t status;
> -		struct nlmsghdr *h;
> -		struct sockaddr_nl nladdr;
> -		socklen_t slen = sizeof(nladdr);
> -
> -		status = recvfrom(fd, buf, sizeof(buf), 0,
> -				  (struct sockaddr *) &nladdr, &slen);
> -		if (status < 0) {
> -			if (errno == EINTR)
> -				continue;
> -			perror("OVERRUN");
> -			continue;
> -		}
> -		if (status == 0) {
> -			fprintf(stderr, "EOF on netlink\n");
> -			goto close_it;
> -		}
> -
> -		if (dump_fp)
> -			fwrite(buf, 1, NLMSG_ALIGN(status), dump_fp);
> -
> -		h = (struct nlmsghdr*)buf;
> -		while (NLMSG_OK(h, status)) {
> -			int err;
> -
> -			if (h->nlmsg_seq != 123456)
> -				goto skip_it;
> -
> -			if (h->nlmsg_type == NLMSG_DONE)
> -				goto close_it;
> -
> -			if (h->nlmsg_type == NLMSG_ERROR) {
> -				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
> -				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
> -					fprintf(stderr, "ERROR truncated\n");
> -				} else {
> -					errno = -err->error;
> -					if (errno != ENOENT)
> -						fprintf(stderr, "UDIAG answers %d\n", errno);
> -				}
> -				close(fd);
> -				return -1;
> -			}
> -			if (!dump_fp) {
> -				err = packet_show_sock(h, f);
> -				if (err < 0) {
> -					close(fd);
> -					return err;
> -				}
> -			}
> -
> -skip_it:
> -			h = NLMSG_NEXT(h, status);
> -		}
> -
> -		if (status) {
> -			fprintf(stderr, "!!!Remnant of size %zd\n", status);
> -			exit(1);
> -		}
> -	}
> -
> -close_it:
> -	close(fd);
> -	return 0;
> +	return handle_netlink_request(f, dump_fp, &req.nlh, sizeof(req),
> +			packet_show_sock);
>  }
>  
>  
> -- 
> 2.1.0
> 

This patch conflicts with master branch, will re-send v2 later.

Regards,
