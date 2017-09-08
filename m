From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Fri, 8 Sep 2017 16:51:13 +0200
Message-ID: <20170908145113.GA30028@orbyte.nwl.cc>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
 <20170908110247.GS2399@orbyte.nwl.cc>
 <20170908140131.GU5465@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37334 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755906AbdIHOvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 10:51:16 -0400
Content-Disposition: inline
In-Reply-To: <20170908140131.GU5465@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Sep 08, 2017 at 10:01:31PM +0800, Hangbin Liu wrote:
[...]
> > > diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> > > index be7ac86..37cfb5a 100644
> > > --- a/lib/libnetlink.c
> > > +++ b/lib/libnetlink.c
> > > @@ -402,6 +402,59 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
> > >  	}
> > >  }
> > >  
> > > +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **buf)
> > > +{
> > > +	struct iovec *iov;
> > > +	int len = -1, buf_len = 32768;
> > > +	char *buffer = *buf;
> > 
> > Isn't it possible to make 'buffer' static instead of the two 'buf'
> > variables in rtnl_dump_filter_l() and __rtnl_talk()? Then we would have
> > only a single buffer which is shared between both functions instead of
> > two which are independently allocated.
> 
> I was also thinking of this before. But in function ipaddrlabel_flush()
> 
> 	if (rtnl_dump_filter(&rth, flush_addrlabel, NULL) < 0)
> 
> It will cal rtnl_dump_filter_l() first via
> rtnl_dump_filter() -> rtnl_dump_filter_nc() -> rtnl_dump_filter_l().
> 
> Then call rtnl_talk() later via call back
> a->filter(&nladdr, h, a->arg1) -> flush_addrlabel() -> rtnl_talk()
> 
> So if we only use one static buffer in rtnl_recvmsg(). Then it will be written
> at lease twice.

Oh yes, in that case we really can't have a single buffer.

[...]
> > > +		buf_len = len;
> > 
> > For this to work you have to make buf_len static too, otherwise you will
> > unnecessarily reallocate the buffer. Oh, and that also requires the
> > single buffer (as pointed out above) because you will otherwise use a
> > common buf_len for both static buffers passed to this function.
> 
> Since we have to use two static bufffers. So how about check like
> 
> 	if (len > strlen(buffer))

I don't think that will work. We are reusing the buffer and it contains
binary data, so a NUL byte may appear anywhere. I fear you will have to
change rtnl_recvmsg() to accept a buflen parameter which callers have to
define statically together with the buffer pointer.

Regarding Michal's concern about reentrancy, maybe we should go into a
different direction and make rtnl_recvmsg() return a newly allocated
buffer which the caller has to free.

[...]
> > When retrying inside rtnl_recvmsg(), it won't return 0 anymore. I
> > believe the whole 'while (1)' loop could go away then.
> > 
> 
> Like Michal said, there may have multi netlink packets?

Ah yes, I missed that.

Thanks, Phil
