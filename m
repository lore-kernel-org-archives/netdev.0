From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 21:43:41 -0500
Message-ID: <20160312024341.GA26486@oracle.com>
References: <20160311182949.GG3383@oracle.com>
 <20160311110927.5c559421@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42214 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbcCLCns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 21:43:48 -0500
Content-Disposition: inline
In-Reply-To: <20160311110927.5c559421@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/11/16 11:09), Stephen Hemminger wrote:
> Module parameters are a problem for distributions and should only be used
> as a last resort.

I dont know the history of what the distibution problem is, but I
did try to use sysctl as an alternative for this. I'm starting to 
believe that this is one case where module params, with all their 
problems, are the least evil option. Here's what I find if I use sysctl:

- being able to tune the sndbuf and rcvbuf actually gives me a noticeable
  2X perf improvement over the default for DB/Cluster request/response
  transactions, where the classic req size is 8K bytes, response is 256
  bytes, and there are a large number of such concurrent transactions
  queued up on the kernel tcp socket. (The defaults work well for 
  larger packet sizes, but as I noted in the commit, packet sizes vary
  in actual deployment).

Assuming I use sysctl:

- by the time the admin gets to execute the sysctl, the kernel listen
  socket for RDS_TCP_PORT would already have been created, and an 
  arbitrary number of accept/connect (kernel) endpoints may have been
  created.  According to tcp(7), you should be setting the buf sizes before
  connect/listen. So using sysctl means you have to reset a variable
  number of existing cluster connections. All this can be done, but 
  adds a large mass of confusing code to reset kernel sockets and 
  also get the cluster HA/failover right.

- at first I thought sysctl was attractive because it was netns aware,
  but found that it is  only superficially so. The ->proc_handler does
  not pass in the struct net *, and setting up the ctl_table's ->data
  to a per-net var is not simple thing to do. Thus, even though
  register_net_sysctl() takes a net * pointer, my handler has to do
  extra ugly things to get to per-net vars.

I dont know if there is a better alternative than sysctl/module_param
for achieving what I'm trying to do, which is to set up the params
for the kernel sockets before creating them. If yes, some 
hints/rtfms would be helpful.

--Sowmini
