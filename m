From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv3 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Thu, 21 Sep 2017 15:20:02 +0800
Message-ID: <20170921072002.GM5465@leo.usersys.redhat.com>
References: <1505871820-31580-1-git-send-email-liuhangbin@gmail.com>
 <1505871820-31580-2-git-send-email-liuhangbin@gmail.com>
 <20170920095605.1ea527fc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33960 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdIUHUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:20:14 -0400
Received: by mail-pg0-f67.google.com with SMTP id u18so2995978pgo.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 00:20:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170920095605.1ea527fc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
On Wed, Sep 20, 2017 at 09:56:05AM -0700, Stephen Hemminger wrote:
> > +realloc:
> > +	bufp = realloc(buf, buf_len);
> > +
> > +	if (bufp == NULL) {
> 
> Minor personal style issue:
> To me, blank lines are like paragraphs in writing.
> Code reads better assignment and condition check are next to
> each other.

OK, I will remove the blank lines.
> 
> > +recv:
> > +	len = recvmsg(fd, msg, flag);
> > +
> > +	if (len < 0) {
> > +		if (errno == EINTR || errno == EAGAIN)
> > +			goto recv;
> > +		fprintf(stderr, "netlink receive error %s (%d)\n",
> > +			strerror(errno), errno);
> > +		free(buf);
> > +		return -errno;
> > +	}
> > +
> > +	if (len == 0) {
> > +		fprintf(stderr, "EOF on netlink\n");
> > +		free(buf);
> > +		return -ENODATA;
> > +	}
> > +
> > +	if (len > buf_len) {
> > +		buf_len = len;
> > +		flag = 0;
> > +		goto realloc;
> > +	}
> > +
> > +	if (flag != 0) {
> > +		flag = 0;
> > +		goto recv;
> 
> Although I programmed in BASIC years ago. I never liked code
> with loops via goto. To me it indicates the logic is not well thought
> through.  Not sure exactly how to rearrange the control flow, but it
> should be possible to rewrite this so that it reads cleaner.

Hmm, if we remove goto. Then the logic should look like

	bufp = realloc(buf, buf_len);
	/* check bufp and set msg */

	len = recvmsg(fd, msg, flag);
	/* check len */

	if (len > buf_len) {
		buf_len = len;
		bufp = realloc(buf, buf_len);
		/* check bufp and set msg */

		len = recvmsg(fd, msg, flag);
		/* check len */
	}

	len = recvmsg(fd, msg, flag);
	/* check len */

Or maybe we can set buf_len very small first. Then it will force to realloc at
the second time. And the code would like

	int buf_len = 16;
	bufp = realloc(buf, buf_len);
	/* check bufp and set msg */

	len = recvmsg(fd, msg, flag);
	/* check len */

	buf_len = len;
	bufp = realloc(buf, buf_len);
	/* check bufp and set msg */

	len = recvmsg(fd, msg, flag);
	/* check len */

What do you think?

Thanks
Hangbin
