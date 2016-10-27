From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net-next iproute2 1/2] libnetlink: Add test for error code
 returned from netlink reply
Date: Wed, 26 Oct 2016 20:52:56 -0700
Message-ID: <20161026205256.162e1d25@xeon-e3>
References: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
        <1477510208-20292-2-git-send-email-gorcunov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34062 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932802AbcJ0Dwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 23:52:43 -0400
Received: by mail-pf0-f170.google.com with SMTP id n85so8793620pfi.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 20:52:43 -0700 (PDT)
In-Reply-To: <1477510208-20292-2-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Oct 2016 22:30:07 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

>  
>  				if (h->nlmsg_type == NLMSG_DONE) {
> +					int len;
> +
> +					/*
> +					 * The kernel reports if there is
> +					 * no inet-diag module present in
> +					 * the system via negative length
> +					 * as error code.
> +					 */
> +					if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
> +						fprintf(stderr, "Truncated length reply\n");
> +						return -1;
> +					}
> +					len = *(int *)NLMSG_DATA(h);
> +					if (len < 0) {
> +						errno = -len;
> +						if (errno == ENOENT ||
> +						    errno == EOPNOTSUPP)
> +							return -1;
> +						perror("RTNETLINK answers");
> +						return len;
> +					}
>  					found_done = 1;
>  					break; /* process next filter */
>  				

This looks like a mistake in how you implemented the functionality in the kernel.
Despite what it looks like, all netlink request/reply functionality reports
errors in current implementation by returning error to the sendmsg request.

What you added implies that the new kernel api is wrong, or many other usages
are wrong.  Please fix the kernel.
