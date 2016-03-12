From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 19:21:26 -0800
Message-ID: <CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
References: <20160311182949.GG3383@oracle.com>
	<20160311110927.5c559421@xeon-e3>
	<20160312024341.GA26486@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33408 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbcCLDV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 22:21:28 -0500
Received: by mail-lb0-f178.google.com with SMTP id k15so180430942lbg.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 19:21:27 -0800 (PST)
In-Reply-To: <20160312024341.GA26486@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 6:43 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/11/16 11:09), Stephen Hemminger wrote:
>> Module parameters are a problem for distributions and should only be used
>> as a last resort.
>
> I dont know the history of what the distibution problem is, but I
> did try to use sysctl as an alternative for this. I'm starting to
> believe that this is one case where module params, with all their
> problems, are the least evil option. Here's what I find if I use sysctl:
>
> - being able to tune the sndbuf and rcvbuf actually gives me a noticeable
>   2X perf improvement over the default for DB/Cluster request/response
>   transactions, where the classic req size is 8K bytes, response is 256
>   bytes, and there are a large number of such concurrent transactions
>   queued up on the kernel tcp socket. (The defaults work well for
>   larger packet sizes, but as I noted in the commit, packet sizes vary
>   in actual deployment).
>
> Assuming I use sysctl:
>
> - by the time the admin gets to execute the sysctl, the kernel listen
>   socket for RDS_TCP_PORT would already have been created, and an
>   arbitrary number of accept/connect (kernel) endpoints may have been
>   created.  According to tcp(7), you should be setting the buf sizes before
>   connect/listen. So using sysctl means you have to reset a variable
>   number of existing cluster connections. All this can be done, but
>   adds a large mass of confusing code to reset kernel sockets and
>   also get the cluster HA/failover right.
>
> - at first I thought sysctl was attractive because it was netns aware,
>   but found that it is  only superficially so. The ->proc_handler does
>   not pass in the struct net *, and setting up the ctl_table's ->data
>   to a per-net var is not simple thing to do. Thus, even though
>   register_net_sysctl() takes a net * pointer, my handler has to do
>   extra ugly things to get to per-net vars.
>
> I dont know if there is a better alternative than sysctl/module_param
> for achieving what I'm trying to do, which is to set up the params
> for the kernel sockets before creating them. If yes, some
> hints/rtfms would be helpful.
>
You could consider and alternate model where connection management
(connect, listen, etc.) is performed in a userspace daemon and the
attached to the kernel (pretty much like KCM does). This moves
complexity out of kernel, and gives you the flexibility to configure
arbitrarily configure TCP sockets (like the 4 setsockopts in
rds_tcp_keepalive could be configurable). The other cool thing this
would allow is switching an existing TCP connection into RDS mode
(like is done with several protocols on an http port).

Tom

> --Sowmini
>
