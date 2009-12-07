From: Simon Horman <horms@verge.net.au>
Subject: Re: Request for help with iproute2 bugs.
Date: Mon, 7 Dec 2009 14:47:24 +1100
Message-ID: <20091207034724.GB419@verge.net.au>
References: <20091123103742.GA14713@amd64.fatal.se>
 <20091203010824.GA19810@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	532152@bugs.debian.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45391 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146AbZLGDrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 22:47:19 -0500
Content-Disposition: inline
In-Reply-To: <20091203010824.GA19810@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 12:08:27PM +1100, Simon Horman wrote:
> On Mon, Nov 23, 2009 at 11:37:42AM +0100, Andreas Henriksson wrote:
> > Hello everybody!
> > 
> > This is a desperate attempt at finding people with time and motivation
> > to look into bugs that has been reported against the iproute package
> > in the debian bug tracking system. The reported bugs are usually
> > not Debian-specific...
> > 
> > You'll find the complete list at http://bugs.debian.org/iproute
> > If you have comments, please email them to <bugnumber>@bugs.debian.org
> > 
> > 
> > Here's a list of interesting candidates, hopefully you'll find some useful
> > comments if you follow the link (usually last comment at the bottom):
> > 
> > http://bugs.debian.org/532152 - incorrectly enumerates existing addresses.
> >   iproute: 'ip addr flush' exits with error on first try
> 
> I've taken a stab at this one.
> 

Any feedback?

> To: Andreas Henriksson <andreas@fatal.se>
> Cc: netdev@vger.kernel.org, shemminger@vyatta.com, 532152@bugs.debian.org
> Subject: [rfc] iproute2: flush secondary addresses before primary ones
> Date: Thu, 03 Dec 2009 12:05:55 +1100
> 
> Unless promote_secondaries has been active deleting the primary address of
> an interface will automatically delete all the secondary addresses.
> 
> In the case where ip flush requests the primary then secondary addresses to
> be removed - which is the order the addresses are returned by the kernel -
> this will cause an error as by the time the request to remove a secondary
> address is made it will be missing as it will have been deleted in the
> course of deleting the primary address.
> 
> This approach to solving this problem orders requests for the
> deletion of secondary addresses before primary ones providing
> rtnl_dump_filter_l(), a version of rtnl_dump_filter() that
> iterates over a list of filters. And by providing two specialised
> filters print_addrinfo_secondary() and print_addrinfo_primary().
> 
> rtnl_dump_filter_l() first iterates over all addresses using
> print_addrinfo_secondary(), which appends secondary addresses to the
> request buffer.  Then again using print_addrinfo_primary() which appends
> primary addresses.
> 
> This approach should work regardless of it promote_secondaries is
> active or not. And regardless of if any primary of secondary addresses
> are present or not.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
>  include/libnetlink.h |   12 +++++++
>  ip/ipaddress.c       |   43 +++++++++++++++++++++++++
>  lib/libnetlink.c     |   84 +++++++++++++++++++++++++++++---------------------
>  3 files changed, 104 insertions(+), 35 deletions(-)
> 
> I'm not sure if this is the right place for this change,
> but this patch seems worth posting for discussion.
> 
> Index: iproute2/lib/libnetlink.c
> ===================================================================
> --- iproute2.orig/lib/libnetlink.c	2009-12-03 09:40:21.000000000 +0900
> +++ iproute2/lib/libnetlink.c	2009-12-03 09:40:26.000000000 +0900
> @@ -172,11 +172,8 @@ int rtnl_dump_request(struct rtnl_handle
>  	return sendmsg(rth->fd, &msg, 0);
>  }
>  
> -int rtnl_dump_filter(struct rtnl_handle *rth,
> -		     rtnl_filter_t filter,
> -		     void *arg1,
> -		     rtnl_filter_t junk,
> -		     void *arg2)
> +int rtnl_dump_filter_l(struct rtnl_handle *rth,
> +		       const struct rtnl_dump_filter_arg *arg)
>  {
>  	struct sockaddr_nl nladdr;
>  	struct iovec iov;
> @@ -191,7 +188,7 @@ int rtnl_dump_filter(struct rtnl_handle 
>  	iov.iov_base = buf;
>  	while (1) {
>  		int status;
> -		struct nlmsghdr *h;
> +		const struct rtnl_dump_filter_arg *a;
>  
>  		iov.iov_len = sizeof(buf);
>  		status = recvmsg(rth->fd, &msg, 0);
> @@ -209,40 +206,45 @@ int rtnl_dump_filter(struct rtnl_handle 
>  			return -1;
>  		}
>  
> -		h = (struct nlmsghdr*)buf;
> -		while (NLMSG_OK(h, status)) {
> -			int err;
> +		for (a = arg; a->filter; a++) {
> +			struct nlmsghdr *h = (struct nlmsghdr*)buf;
>  
> -			if (nladdr.nl_pid != 0 ||
> -			    h->nlmsg_pid != rth->local.nl_pid ||
> -			    h->nlmsg_seq != rth->dump) {
> -				if (junk) {
> -					err = junk(&nladdr, h, arg2);
> -					if (err < 0)
> -						return err;
> +			while (NLMSG_OK(h, status)) {
> +				int err;
> +
> +				if (nladdr.nl_pid != 0 ||
> +				    h->nlmsg_pid != rth->local.nl_pid ||
> +				    h->nlmsg_seq != rth->dump) {
> +					if (a->junk) {
> +						err = a->junk(&nladdr, h,
> +							      a->arg2);
> +						if (err < 0)
> +							return err;
> +					}
> +					goto skip_it;
>  				}
> -				goto skip_it;
> -			}
>  
> -			if (h->nlmsg_type == NLMSG_DONE)
> -				return 0;
> -			if (h->nlmsg_type == NLMSG_ERROR) {
> -				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
> -				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
> -					fprintf(stderr, "ERROR truncated\n");
> -				} else {
> -					errno = -err->error;
> -					perror("RTNETLINK answers");
> +				if (h->nlmsg_type == NLMSG_DONE)
> +					return 0;
> +				if (h->nlmsg_type == NLMSG_ERROR) {
> +					struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
> +					if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
> +						fprintf(stderr,
> +							"ERROR truncated\n");
> +					} else {
> +						errno = -err->error;
> +						perror("RTNETLINK answers");
> +					}
> +					return -1;
>  				}
> -				return -1;
> -			}
> -			err = filter(&nladdr, h, arg1);
> -			if (err < 0)
> -				return err;
> +				err = a->filter(&nladdr, h, a->arg1);
> +				if (err < 0)
> +					return err;
>  
>  skip_it:
> -			h = NLMSG_NEXT(h, status);
> -		}
> +				h = NLMSG_NEXT(h, status);
> +			}
> +		} while (0);
>  		if (msg.msg_flags & MSG_TRUNC) {
>  			fprintf(stderr, "Message truncated\n");
>  			continue;
> @@ -254,6 +256,20 @@ skip_it:
>  	}
>  }
>  
> +int rtnl_dump_filter(struct rtnl_handle *rth,
> +		     rtnl_filter_t filter,
> +		     void *arg1,
> +		     rtnl_filter_t junk,
> +		     void *arg2)
> +{
> +	const struct rtnl_dump_filter_arg a[2] = {
> +		{ .filter = filter, .arg1 = arg1, .junk = junk, .arg2 = arg2 },
> +		{ .filter = NULL,   .arg1 = NULL, .junk = NULL, .arg2 = NULL }
> +	};
> +
> +	return rtnl_dump_filter_l(rth, a);
> +}
> +
>  int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
>  	      unsigned groups, struct nlmsghdr *answer,
>  	      rtnl_filter_t junk,
> Index: iproute2/include/libnetlink.h
> ===================================================================
> --- iproute2.orig/include/libnetlink.h	2009-12-03 09:40:21.000000000 +0900
> +++ iproute2/include/libnetlink.h	2009-12-03 09:40:26.000000000 +0900
> @@ -27,10 +27,22 @@ extern int rtnl_dump_request(struct rtnl
>  
>  typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
>  			     struct nlmsghdr *n, void *);
> +
> +struct rtnl_dump_filter_arg
> +{
> +	rtnl_filter_t filter;
> +	void *arg1;
> +	rtnl_filter_t junk;
> +	void *arg2;
> +};
> +
> +extern int rtnl_dump_filter_l(struct rtnl_handle *rth,
> +			      const struct rtnl_dump_filter_arg *arg);
>  extern int rtnl_dump_filter(struct rtnl_handle *rth, rtnl_filter_t filter,
>  			    void *arg1,
>  			    rtnl_filter_t junk,
>  			    void *arg2);
> +
>  extern int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
>  		     unsigned groups, struct nlmsghdr *answer,
>  		     rtnl_filter_t junk,
> Index: iproute2/ip/ipaddress.c
> ===================================================================
> --- iproute2.orig/ip/ipaddress.c	2009-12-03 09:40:21.000000000 +0900
> +++ iproute2/ip/ipaddress.c	2009-12-03 09:43:10.000000000 +0900
> @@ -539,6 +539,27 @@ int print_addrinfo(const struct sockaddr
>  	return 0;
>  }
>  
> +int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
> +			   void *arg)
> +{
> +	struct ifaddrmsg *ifa = NLMSG_DATA(n);
> +
> +	if (!ifa->ifa_flags & IFA_F_SECONDARY)
> +		return 0;
> +
> +	return print_addrinfo(who, n, arg);
> +}
> +
> +int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
> +			     void *arg)
> +{
> +	struct ifaddrmsg *ifa = NLMSG_DATA(n);
> +
> +	if (ifa->ifa_flags & IFA_F_SECONDARY)
> +		return 0;
> +
> +	return print_addrinfo(who, n, arg);
> +}
>  
>  struct nlmsg_list
>  {
> @@ -700,12 +721,32 @@ static int ipaddr_list_or_flush(int argc
>  		filter.flushe = sizeof(flushb);
>  
>  		while (round < MAX_ROUNDS) {
> +			const struct rtnl_dump_filter_arg a[3] = {
> +				{
> +					.filter = print_addrinfo_secondary,
> +					.arg1 = stdout,
> +					.junk = NULL,
> +					.arg2 = NULL
> +				},
> +				{
> +					.filter = print_addrinfo_primary,
> +					.arg1 = stdout,
> +					.junk = NULL,
> +					.arg2 = NULL
> +				},
> +				{
> +					.filter = NULL,
> +					.arg1 = NULL,
> +					.junk = NULL,
> +					.arg2 = NULL
> +				},
> +			};
>  			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
>  				perror("Cannot send dump request");
>  				exit(1);
>  			}
>  			filter.flushed = 0;
> -			if (rtnl_dump_filter(&rth, print_addrinfo, stdout, NULL, NULL) < 0) {
> +			if (rtnl_dump_filter_l(&rth, a) < 0) {
>  				fprintf(stderr, "Flush terminated\n");
>  				exit(1);
>  			}

