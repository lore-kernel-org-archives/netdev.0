From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via
 /proc/net/ipv6_route
Date: Sat, 16 Jun 2012 09:07:23 -0400
Message-ID: <20120616130723.GA8388@neilslaptop.think-freely.org>
References: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
 <20120615105655.GA22945@hmsreliant.think-freely.org>
 <20120615.153240.1699971156820399680.davem@davemloft.net>
 <20120615.221502.1196734470412725503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44032 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755475Ab2FPNHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 09:07:34 -0400
Content-Disposition: inline
In-Reply-To: <20120615.221502.1196734470412725503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 15, 2012 at 10:15:02PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 15 Jun 2012 15:32:40 -0700 (PDT)
> 
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Fri, 15 Jun 2012 06:56:55 -0400
> > 
> >> On Fri, Jun 15, 2012 at 11:00:17AM +0200, Thomas Graf wrote:
> >>> /proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
> >>> handler is installed in ip6_route_net_init() whereas fib_table_hash is
> >>> allocated in fib6_net_init() _after_ the proc handler has been installed.
> >>> 
> >>> This opens up a short time frame to access fib_table_hash with its pants
> >>> down.
> >>> 
> >>> fib6_init() as a whole can't be moved to an earlier position as it also
> >>> registers the rtnetlink message handlers which should be registered at
> >>> the end. Therefore split it into fib6_init() which is run early and
> >>> fib6_init_late() to register the rtnetlink message handlers.
> >>> 
> >>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >> Reviewed-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > Applied.
> > 
> > Since you're snooping around in here, you might notice that on network
> > namespace shutdown, we leak all user configured ipv6 FIB rules.
> 
> Thomas, this patch is buggy.
> 
> We will now initialize fib6_init() before ip6_net_route_net_ops is registerd.
> 
> This causes fib6_net_init() to run before net->ipv6.ip6_null_entry it
> initialized.
> 
> Any route lookup will crash when we dereference a root's ->leaf
> because it will be NULL.
> 
Perhaps the flag on the proc file like we discussed might be the better way to
go after all here Thomas.
