From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv2 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Tue, 19 Sep 2017 11:05:20 +0800
Message-ID: <20170919030520.GL5465@leo.usersys.redhat.com>
References: <1505296780-8444-1-git-send-email-liuhangbin@gmail.com>
 <1505296780-8444-2-git-send-email-liuhangbin@gmail.com>
 <20170918075504.gdx4q7je5uneefgg@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37134 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbdISDFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 23:05:31 -0400
Received: by mail-pg0-f66.google.com with SMTP id v5so1276840pgn.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 20:05:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170918075504.gdx4q7je5uneefgg@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Mon, Sep 18, 2017 at 09:55:05AM +0200, Michal Kubecek wrote:
> > +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
> > +{
> > +	struct iovec *iov;
> > +	int len = -1, buf_len = 32768;
> > +	char *bufp, *buf = NULL;
> > +
> > +	int flag = MSG_PEEK | MSG_TRUNC;
> > +
> > +realloc:
> > +	bufp = realloc(buf, buf_len);
> > +
> > +	if (bufp == NULL) {
> > +		fprintf(stderr, "malloc error: not enough buffer\n");
> > +		free(buf);
> > +		return -ENOMEM;
> > +	}
> > +	buf = bufp;
> > +	iov = msg->msg_iov;
> > +	iov->iov_base = buf;
> > +	iov->iov_len = buf_len;
> > +
> > +recv:
> > +	len = recvmsg(fd, msg, flag);
> > +
> > +	if (len < 0) {
> > +		if (errno == EINTR || errno == EAGAIN)
> > +			goto recv;
> > +		fprintf(stderr, "netlink receive error %s (%d)\n",
> > +			strerror(errno), errno);
> 
> free(buf);
> 
> > +		return len;
> 
> Maybe we should return -errno (saved before calling fprintf()) to be
> consistent.
> 
> > +	}
> > +
> > +	if (len == 0) {
> > +		fprintf(stderr, "EOF on netlink\n");
> 
> free(buf);

Will fix these three issues.

> > @@ -471,19 +516,23 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
> >  
> >  				if (h->nlmsg_type == NLMSG_ERROR) {
> >  					rtnl_dump_error(rth, h);
> > +					free(buf);
> >  					return -1;
> >  				}
> >  
> >  				if (!rth->dump_fp) {
> >  					err = a->filter(&nladdr, h, a->arg1);
> > -					if (err < 0)
> > +					if (err < 0) {
> > +						free(buf);
> >  						return err;
> > +					}
> >  				}
> >  
> >  skip_it:
> >  				h = NLMSG_NEXT(h, msglen);
> >  			}
> >  		}
> > +		free(buf);
> 
> We only free the last buffer returned by rtnl_recvmsg() this way. IMHO
> this free(buf) should be moved inside the loop.

Do you mean the outside while loop or the for loop? I think we could not put
it inside the for loop, because we may need the buf multi times based on arg.

	while (1) {
		status = rtnl_recvmsg(rth->fd, &msg, &buf);

		for (a = arg; a->filter; a++) {
			struct nlmsghdr *h = (struct nlmsghdr *)buf;
			while (NLMSG_OK(h, msglen)) {
				[...]
skip_it:
				h = NLMSG_NEXT(h, msglen);
			}
		}
		free(buf);
		[...]
	}

Thanks
Hangbin
