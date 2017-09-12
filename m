From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Tue, 12 Sep 2017 11:09:26 +0200
Message-ID: <20170912090926.j7vwhq6a57c5d6wx@unicorn.suse.cz>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
 <20170908110247.GS2399@orbyte.nwl.cc>
 <20170908140131.GU5465@leo.usersys.redhat.com>
 <20170908145113.GA30028@orbyte.nwl.cc>
 <20170911071955.GZ5465@leo.usersys.redhat.com>
 <20170912084748.m4wz6kxfclc2mkxd@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33454 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751472AbdILJJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 05:09:28 -0400
Content-Disposition: inline
In-Reply-To: <20170912084748.m4wz6kxfclc2mkxd@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 10:47:48AM +0200, Michal Kubecek wrote:
> On Mon, Sep 11, 2017 at 03:19:55PM +0800, Hangbin Liu wrote:
> > On Fri, Sep 08, 2017 at 04:51:13PM +0200, Phil Sutter wrote:
> > > Regarding Michal's concern about reentrancy, maybe we should go into a
> > > different direction and make rtnl_recvmsg() return a newly allocated
> > > buffer which the caller has to free.
> > 
> > Hmm... But we could not free the buf in __rtnl_talk(). Because in
> > __rtnl_talk() we assign the answer with the buf address and return to caller.
> > 
> > 	for (h = (struct nlmsghdr *)buf; status >= sizeof(*h); ) {
> > 		[...]
> > 		if (answer) {
> > 			*answer= h;
> > 			return 0;
> > 		}
> > 	}
> > 
> > And the caller will keep use it in later code. Since there are plenty of
> > functions called rtnl_talk. I think it would be much more complex to free
> > the buffer every time.
> > 
> > 
> > Hi Michal,
> > 
> > Would you like to tell me more about your concern with reentrancy? It's looks
> > arpd doesn't call rtnl_talk() or rtnl_dump_filter_l().
> 
> I checked again and arpd indeed isn't a problem. It doesn't seem to call
> any of the two functions (directly or indirectly) and while it's linked
> with "-lpthread", it's not really multithreaded.
> 
> But my concern was rather about other potential users of libnetlink
> (i.e. those which are not part of iproute2). I must admit, though, that
> I'm not sure if libnetlink code is reentrant as of now. (And people are
> discouraged from using it in its own manual page.)
> 
> That being said, I still like Phil's idea for a different reason. While
> investigating the issue with "ip link show dev eth ..." which led me to
> commit 6599162b958e ("iplink: check for message truncation in
> iplink_get()"), I quickly peeked at some other callers of rtnl_talk()
> and I'm afraid there may be others which wouldn't handle truncated
> message correctly. I assume the maxlen argument was always chosen to be
> sufficient for any expected messages but as the example of iplink_get()
> shows, messages returned by kernel my grow over time.
> 
> That's why I like the idea of __rtnl_talk() returning a pointer to newly
> allocated buffer (of sufficient size) rather than copying the response
> into a buffer provided by caller and potentially truncating it.

I'm sorry, I managed to forget that your patch 2 does already address
this problem. But the fact that any caller must keep in mind that he
must not call the same function again until the previous response is no
longer needed still feels like a trap. It's something you need to keep
in mind (where "you" in fact means any future contributor) and it's
easy to forget. That's why I prefer the reentrant functions like
strerror_r() or localtime_r() even in code which is not intended to be
multithreaded. Getting an object which is "mine" to do with whatever
I want until I no longer need it feels like a cleaner interface to me.

Michal Kubecek
