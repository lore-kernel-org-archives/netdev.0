From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv4 iproute2 1/2] lib/libnetlink: re malloc buff if size
 is not enough
Date: Fri, 29 Sep 2017 10:54:40 -0700
Message-ID: <20170929105440.7edaec1f@xeon-e3>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
        <1506605626-1744-2-git-send-email-haliu@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Hangbin Liu <haliu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:43979 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdI2Rys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:54:48 -0400
Received: by mail-pf0-f182.google.com with SMTP id y29so188163pff.0
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:54:48 -0700 (PDT)
In-Reply-To: <1506605626-1744-2-git-send-email-haliu@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Sep 2017 21:33:45 +0800
Hangbin Liu <haliu@redhat.com> wrote:

>  
> +static int __rtnl_recvmsg(int fd, struct msghdr *msg, int flags)
> +{
> +	int len;
> +
> +	do {
> +		len = recvmsg(fd, msg, flags);
> +	} while (len < 0 && (errno == EINTR || errno == EAGAIN));
> +
> +	if (len < 0) {
> +		fprintf(stderr, "netlink receive error %s (%d)\n",
> +			strerror(errno), errno);
> +		return -errno;
> +	}
> +
> +	if (len == 0) {
> +		fprintf(stderr, "EOF on netlink\n");
> +		return -ENODATA;
> +	}
> +
> +	return len;
> +}
> +
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
> +
> +	if (answer)
> +		*answer = buf;
> +	else
> +		free(buf);
> +
> +	return len;
> +}

Doubling the number of system calls per message is not going to make
users with 5,000,000 routes or 1000 vlans, or 10,000 tunnels happy.
Please rethink this.
