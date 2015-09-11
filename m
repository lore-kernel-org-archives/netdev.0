From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: fix race on protocol/netns initialization
Date: Fri, 11 Sep 2015 15:00:42 -0700 (PDT)
Message-ID: <20150911.150042.103516475042652216.davem@davemloft.net>
References: <55F1DD37.1080900@gmail.com>
	<d4d786dc6ae30a18e80435ffdee55f8c9582c3dc.1441916456.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, David.Laight@ACULAB.COM
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbbIKWAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 18:00:44 -0400
In-Reply-To: <d4d786dc6ae30a18e80435ffdee55f8c9582c3dc.1441916456.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 10 Sep 2015 17:31:15 -0300

> Consider sctp module is unloaded and is being requested because an user
> is creating a sctp socket.
> 
> During initialization, sctp will add the new protocol type and then
> initialize pernet subsys:
 ...
> The problem is that after those calls to sctp_v{4,6}_protosw_init(), it
> is possible for userspace to create SCTP sockets like if the module is
> already fully loaded. If that happens, one of the possible effects is
> that we will have readers for net->sctp.local_addr_list list earlier
> than expected and sctp_net_init() does not take precautions while
> dealing with that list, leading to a potential panic but not limited to
> that, as sctp_sock_init() will copy a bunch of blank/partially
> initialized values from net->sctp.
> 
> The race happens like this:
 ...
> Simply inverting the initialization order between
> register_pernet_subsys() and sctp_v4_protosw_init() is not possible
> because register_pernet_subsys() will create a control sctp socket, so
> the protocol must be already visible by then. Deferring the socket
> creation to a work-queue is not good specially because we loose the
> ability to handle its errors.
> 
> So, as suggested by Vlad, the fix is to split netns initialization in
> two moments: defaults and control socket, so that the defaults are
> already loaded by when we register the protocol, while control socket
> initialization is kept at the same moment it is today.
> 
> Fixes: 4db67e808640 ("sctp: Make the address lists per network namespace")
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable, thanks.
