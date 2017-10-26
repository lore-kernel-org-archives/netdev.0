From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv5 iproute2 net-next 2/2] lib/libnetlink: re malloc buff if
 size is not enough
Date: Wed, 25 Oct 2017 20:59:01 -0600
Message-ID: <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
References: <1508982107-28474-1-git-send-email-liuhangbin@gmail.com>
 <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53518 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdJZC7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 22:59:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id t188so1442953pfd.10
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 19:59:03 -0700 (PDT)
In-Reply-To: <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/17 7:41 PM, Hangbin Liu wrote:
> +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
> +{
> +	struct iovec *iov = msg->msg_iov;
> +	char *buf;
> +	int len;
> +
> +	iov->iov_base = NULL;
> +	iov->iov_len = 0;
> +
> +	len = __rtnl_recvmsg(fd, msg, MSG_PEEK | MSG_TRUNC);
> +	if (len < 0)
> +		return len;
> +
> +	buf = malloc(len);
> +	if (!buf) {
> +		fprintf(stderr, "malloc error: not enough buffer\n");
> +		return -ENOMEM;
> +	}
> +
> +	iov->iov_base = buf;
> +	iov->iov_len = len;
> +
> +	len = __rtnl_recvmsg(fd, msg, 0);
> +	if (len < 0) {
> +		free(buf);
> +		return len;
> +	}

The kernel needs a flag that says "give me the message of the buffer is
large enough; if not just PEEK and tell me the length." That would avoid
the double call in most cases.
