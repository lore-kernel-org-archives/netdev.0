From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Wed, 19 Jan 2011 11:38:17 -0800
Message-ID: <20110119113817.0819ddf1@s6510>
References: <20101209.122033.183046393.davem@davemloft.net>
	<20101216132812.2d7fd885@nehalam>
	<m1mxo5tcx6.fsf@fess.ebiederm.org>
	<20101216.182656.226781473.davem@davemloft.net>
	<20110119191823.GC8442@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	brian.haley@hp.com, netdev@vger.kernel.org, maheshkelkar@gmail.com,
	lorenzo@google.com, yoshfuji@linux-ipv6.org, stable@kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54215 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab1ASTiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 14:38:21 -0500
In-Reply-To: <20110119191823.GC8442@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Jan 2011 20:18:23 +0100
Jiri Bohac <jbohac@suse.cz> wrote:

> Hi,
> 
> 
> The commit (29ba5fed1bbd09c2cba890798c8f9eaab251401d) causes
> another regression:
> 
> Prior to the commit, on a freshly booted system, when I do:
> 	sysctl net.ipv6.conf.all.disable_ipv6=1
> Then any attempt to connect to ::1 will fail immediately with
> "Network is unreachable" (e.g. "ping6 ::1" or "telnet ::1 22".
> 
> After the commit, doing
> 	sysctl net.ipv6.conf.all.disable_ipv6=1
> makes connection attempts to ::1 wait for a long time before they fail.
> 
> This is caused by the local route which is now left configured. 
> "ip -6 r l table all" has an additional line in its output:
> 	local ::1 via :: dev lo  table local  proto none  metric 0  mtu 16436 rtt 40ms rttvar 40ms cwnd 3 advmss 16376 hoplimit 0
> 
> With both ::1 and 127.0.0.1 specified for localhost in
> /etc/hosts, disabling ipv6 now breaks many applications
> connecting to localhost. Deleting the local route manually solves
> the problems.
> 
> Could this be reverted, please?
> 
> I have the feeling that Eric's patch is the safest solution we
> have so far:
> 
> > Finding the real bug is beyond me right now, but fixing the regression
> > in disable_ipv6 is simple.  We can just delete ::1 when we bring down
> > the loopback interface, and it will be restored automatically when we
> > bring the loopback interface back up.
> > 
> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> > ---
> > Index: linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
> > ===================================================================
> > --- linux-2.6.37-rc5.x86_64.orig/net/ipv6/addrconf.c
> > +++ linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
> > @@ -2727,6 +2727,7 @@ static int addrconf_ifdown(struct net_de
> >  		/* If just doing link down, and address is permanent
> >  		   and not link-local, then retain it. */
> >  		if (!how &&
> > +		    !ipv6_addr_loopback(&ifa->addr) &&
> >  		    (ifa->flags&IFA_F_PERMANENT) &&
> >  		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
> >  			list_move_tail(&ifa->if_list, &keep_list);
> 

Eric's patch has other regressions, see the discussion.
