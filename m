From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 08:36:06 -0500
Message-ID: <20090729133606.GB31730@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com> <1248295301-30930-6-git-send-email-danms@us.ibm.com> <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com> <4A6F6B19.9010508@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:50288 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810AbZG2NgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 09:36:12 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6TDWjkK020416
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 07:32:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6TDa7Zn196852
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 07:36:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6TDa6Xx026259
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 07:36:07 -0600
Content-Disposition: inline
In-Reply-To: <4A6F6B19.9010508@librato.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Oren Laadan (orenl@librato.com):
> > OL> Does the following bypass security checks for sys_connect() ?

[ on sock_unix_restore()->sock_unix_restore_connected()->sock_unix_join() ]

> > 
> > I don't think so.  We're basically replicating sys_socketpair() here,
> > which does not do a security check, presumably because all you're
> > doing is hooking two sockets together that both belong to you.  That's
> > not to say that we're as safe as that limited operation, but I don't
> > think it's totally clear.  Perhaps someone more confident will
> > comment.
> 
> Yes, please ... Serge ?
> 
> To me it sounds plausible. If we adopt it, then a comment in the
> code is worthwhile.

I'm not sure what Oren means "sounds plausible" or should be adopted.
Using a common helper with sys_connect()?

At the moment you miss out on the security_socket_connect() call.  That
may be not as important for unix sockets, but it does look like selinux +
netlabel can label unix sockets as well.  So I'm not convinced we can
just ignore it, as once we start properly LSM-labeling tasks and
sockets we may need to do that to ensure proper restart under selinux.

The other thing is that some new fancy doohicky might require another
hook in sys_connect, which may or may not be needed for this path.
If coded this way, we may not find out until someone reports some
subtle failure long after the fact.

Still your code is so customized that perhaps an explicit
security_socket_connect() call in your sock_unix_join() may be the
way to go...

-serge
