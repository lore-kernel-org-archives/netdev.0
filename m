From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: WARN_ON in commit 0ffdaf5 "net/sock: add WARN_ON(parent->sk) in
 sock_graft()"
Date: Fri, 4 Aug 2017 07:19:29 -0400
Message-ID: <20170804111929.GD16796@oracle.com>
References: <598456CE.7020702@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Guoqing Jiang <gqjiang@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35936 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751342AbdHDLTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 07:19:40 -0400
Content-Disposition: inline
In-Reply-To: <598456CE.7020702@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (08/04/17 19:13), Guoqing Jiang wrote:
> 
> HI,
> 
> With commit 0ffdaf5b41cf4435ece14d1d3e977ce69012a20d "net/sock: add
> WARN_ON(parent->sk) in sock_graft()",
> I can see the WARN_ON is triggered easily by dlm subsystem.
> 
> tcp_accept_from_sock() in  fs/dlm/lowcomms.c has the following snippet:
> 
> 1.    result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
>                                       SOCK_STREAM, IPPROTO_TCP, &newsock);
>         sk is set by the path "sock_create_kern -> __sock_creat ->
> pf->create => inet_create -> sock_init_data"
>     ...
> 2.    result = con->sock->ops->accept(con->sock, newsock, O_NONBLOCK, true);
>         Then sock_graft is called by "con->sock->ops->accept => inet_accept
> -> sock_graft "
> 
> Does it mean call accept() after the just created socket is not a acceptable
> behavior? Any comment will be appreciate, thanks.
> 

It means that you have a sk leak, just like rds-tcp did. See
	https://patchwork.ozlabs.org/patch/780356/
for a discussion.

You should be calling sock_create_lite, instead of sock_create_kern.

The ->sk that triggers the WARN_ON is the one that is leaking (you will
see that the ->sk befrore the ->accept (i.e., the one set up by  sock_create_kern)
is different than the one after ->accept)

--Sowmini
