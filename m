From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Fri, 8 Sep 2017 22:01:31 +0800
Message-ID: <20170908140131.GU5465@leo.usersys.redhat.com>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
 <20170908110247.GS2399@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33398 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdIHOBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:01:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so1476945pfk.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 07:01:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170908110247.GS2399@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil,

Thanks for the comments, see replies bellow.

On Fri, Sep 08, 2017 at 01:02:47PM +0200, Phil Sutter wrote:
> Hi Hangbin,
> 
> On Fri, Sep 08, 2017 at 06:14:56PM +0800, Hangbin Liu wrote:
> [...]
> > diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> > index be7ac86..37cfb5a 100644
> > --- a/lib/libnetlink.c
> > +++ b/lib/libnetlink.c
> > @@ -402,6 +402,59 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
> >  	}
> >  }
> >  
> > +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **buf)
> > +{
> > +	struct iovec *iov;
> > +	int len = -1, buf_len = 32768;
> > +	char *buffer = *buf;
> 
> Isn't it possible to make 'buffer' static instead of the two 'buf'
> variables in rtnl_dump_filter_l() and __rtnl_talk()? Then we would have
> only a single buffer which is shared between both functions instead of
> two which are independently allocated.

I was also thinking of this before. But in function ipaddrlabel_flush()

	if (rtnl_dump_filter(&rth, flush_addrlabel, NULL) < 0)

It will cal rtnl_dump_filter_l() first via
rtnl_dump_filter() -> rtnl_dump_filter_nc() -> rtnl_dump_filter_l().

Then call rtnl_talk() later via call back
a->filter(&nladdr, h, a->arg1) -> flush_addrlabel() -> rtnl_talk()

So if we only use one static buffer in rtnl_recvmsg(). Then it will be written
at lease twice.

The path looks like bellow in function rtnl_dump_filter_l()

	while (1) {
		status = rtnl_recvmsg(rth->fd, &msg, &buf);	<== write buf

		for (a = arg; a->filter; a++) {
			struct nlmsghdr *h = (struct nlmsghdr *)buf;	<== assign buf to h

			while (NLMSG_OK(h, msglen)) {

				if (!rth->dump_fp) {
					err = a->filter(&nladdr, h, a->arg1);	<== buf changed via rtnl_talk()
				}

				h = NLMSG_NEXT(h, msglen);	<== so h will also be changed
			}
		}
	}

That's why I have to use two static buffers.
> 
> > +
> > +	int flag = MSG_PEEK | MSG_TRUNC;
> > +
> > +	if (buffer == NULL)
> > +re_malloc:
> > +		buffer = malloc(buf_len);
> 
> I think using realloc() here is more appropriate since there is no need
> to free the buffer in beforehand and calling realloc(NULL, len) is
> equivalent to calling malloc(len). I think 'realloc' is also a better
> name for the goto label.

Good idea.
> 
> > +	if (buffer == NULL) {
> > +		fprintf(stderr, "malloc error: no enough buffer\n");
> 
> Minor typo here: s/no/not/
> 
> > +		return -1;
> 
> Return -ENOMEM?
> 
> > +	}
> > +
> > +	iov = msg->msg_iov;
> > +	iov->iov_base = buffer;
> > +	iov->iov_len = buf_len;
> > +
> > +re_recv:
> 
> Just call this 'recv'? (Not really important though.)
> 
> > +	len = recvmsg(fd, msg, flag);
> > +
> > +	if (len < 0) {
> > +		if (errno == EINTR || errno == EAGAIN)
> > +			return 0;
> 
> Instead of returning 0 (which makes callers retry), goto re_recv?

Yes, will fix this.
> 
> > +		fprintf(stderr, "netlink receive error %s (%d)\n",
> > +			strerror(errno), errno);
> > +		return len;
> > +	}
> > +
> > +	if (len == 0) {
> > +		fprintf(stderr, "EOF on netlink\n");
> > +		return -1;
> 
> Return -ENODATA here? (Initially I though about -EOF, but EOF is -1 so
> that would be incorrect).
> 
> > +	}
> > +
> > +	if (len > buf_len) {
> > +		free(buffer);
> 
> If you use realloc() above, this can be dropped.

Yes.
> 
> > +		buf_len = len;
> 
> For this to work you have to make buf_len static too, otherwise you will
> unnecessarily reallocate the buffer. Oh, and that also requires the
> single buffer (as pointed out above) because you will otherwise use a
> common buf_len for both static buffers passed to this function.

Since we have to use two static bufffers. So how about check like

	if (len > strlen(buffer))

> 
> > +		flag = 0;
> > +		goto re_malloc;
> > +	}
> > +
> > +	if (flag != 0) {
> > +		flag = 0;
> > +		goto re_recv;
> > +	}
> > +
> > +	*buf = buffer;
> > +	return len;
> > +}
> > +
> >  int rtnl_dump_filter_l(struct rtnl_handle *rth,
> >  		       const struct rtnl_dump_filter_arg *arg)
> >  {
> > @@ -413,31 +466,20 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
> >  		.msg_iov = &iov,
> >  		.msg_iovlen = 1,
> >  	};
> > -	char buf[32768];
> > +	static char *buf = NULL;
> 
> If you keep the static buffer in rtnl_recvmsg(), there is no need to
> assign NULL here.
> 
> >  	int dump_intr = 0;
> >  
> > -	iov.iov_base = buf;
> >  	while (1) {
> >  		int status;
> >  		const struct rtnl_dump_filter_arg *a;
> >  		int found_done = 0;
> >  		int msglen = 0;
> >  
> > -		iov.iov_len = sizeof(buf);
> > -		status = recvmsg(rth->fd, &msg, 0);
> > -
> > -		if (status < 0) {
> > -			if (errno == EINTR || errno == EAGAIN)
> > -				continue;
> > -			fprintf(stderr, "netlink receive error %s (%d)\n",
> > -				strerror(errno), errno);
> > -			return -1;
> > -		}
> > -
> > -		if (status == 0) {
> > -			fprintf(stderr, "EOF on netlink\n");
> > -			return -1;
> > -		}
> > +		status = rtnl_recvmsg(rth->fd, &msg, &buf);
> > +		if (status < 0)
> > +			return status;
> > +		else if (status == 0)
> > +			continue;
> 
> When retrying inside rtnl_recvmsg(), it won't return 0 anymore. I
> believe the whole 'while (1)' loop could go away then.
> 

Like Michal said, there may have multi netlink packets?

Thanks
Hangbin
