From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv4 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Fri, 29 Sep 2017 20:20:36 +0200
Message-ID: <20170929182036.kroth4yhx4itaoc2@unicorn.suse.cz>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-2-git-send-email-haliu@redhat.com>
 <20170929105440.7edaec1f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hangbin Liu <haliu@redhat.com>, netdev@vger.kernel.org,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44259 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752255AbdI2SUi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 14:20:38 -0400
Content-Disposition: inline
In-Reply-To: <20170929105440.7edaec1f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 10:54:40AM -0700, Stephen Hemminger wrote:
> On Thu, 28 Sep 2017 21:33:45 +0800
> Hangbin Liu <haliu@redhat.com> wrote:
> 
> >  
> > +static int __rtnl_recvmsg(int fd, struct msghdr *msg, int flags)
> > +{
> > +	int len;
> > +
> > +	do {
> > +		len = recvmsg(fd, msg, flags);
> > +	} while (len < 0 && (errno == EINTR || errno == EAGAIN));
> > +
> > +	if (len < 0) {
> > +		fprintf(stderr, "netlink receive error %s (%d)\n",
> > +			strerror(errno), errno);
> > +		return -errno;
> > +	}
> > +
> > +	if (len == 0) {
> > +		fprintf(stderr, "EOF on netlink\n");
> > +		return -ENODATA;
> > +	}
> > +
> > +	return len;
> > +}
> > +
> > +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
> > +{
> > +	struct iovec *iov = msg->msg_iov;
> > +	char *buf;
> > +	int len;
> > +
> > +	iov->iov_base = NULL;
> > +	iov->iov_len = 0;
> > +
> > +	len = __rtnl_recvmsg(fd, msg, MSG_PEEK | MSG_TRUNC);
> > +	if (len < 0)
> > +		return len;
> > +
> > +	buf = malloc(len);
> > +	if (!buf) {
> > +		fprintf(stderr, "malloc error: not enough buffer\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	iov->iov_base = buf;
> > +	iov->iov_len = len;
> > +
> > +	len = __rtnl_recvmsg(fd, msg, 0);
> > +	if (len < 0) {
> > +		free(buf);
> > +		return len;
> > +	}
> > +
> > +	if (answer)
> > +		*answer = buf;
> > +	else
> > +		free(buf);
> > +
> > +	return len;
> > +}
> 
> Doubling the number of system calls per message is not going to make
> users with 5,000,000 routes or 1000 vlans, or 10,000 tunnels happy.
> Please rethink this.

I'm not sure it's possible to avoid this if we want to be able to get
rid of a preset message length limit. If you call recvmsg() without
MSG_PEEK and your buffer isn't sufficiently large, the message is lost.
And once you use MSG_PEEK, you need another syscall to remove the
message from the queue even if you read all data. In other words, to be
sure you don't lose the reply, you have to do two syscalls.

One alternative I can see would be calling recvmsg() without MSG_PEEK
(but with reasonably large buffer) and repeating the request if the
buffer is not large enough (and caller is actually interested in the
answer). But I don't think this is desirable either as that would result
in even worse overhead.

Michal Kubecek
