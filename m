From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Tue, 02 Jul 2013 13:16:38 -0700
Message-ID: <1372796198.4979.20.camel@edumazet-glaptop>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
	 <51CC996F.3020507@hp.com>
	 <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com>
	 <51CCA4C2.7050301@hp.com>
	 <20130627215411.GC5936@sbohrermbp13-local.rgmadvisors.com>
	 <51CCB6A3.9080806@hp.com>
	 <20130627224444.GE5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:47718 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758Ab3GBUQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 16:16:42 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so6155092obc.34
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 13:16:42 -0700 (PDT)
In-Reply-To: <20130627224444.GE5936@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 17:44 -0500, Shawn Bohrer wrote:
> On Thu, Jun 27, 2013 at 03:03:15PM -0700, Rick Jones wrote:
> > On 06/27/2013 02:54 PM, Shawn Bohrer wrote:
> > >On Thu, Jun 27, 2013 at 01:46:58PM -0700, Rick Jones wrote:
> > >>How do you know that time is actually contention and not simply
> > >>acquire and release overhead?
> > >
> > >Excellent point, and that could be the problem with my thinking.  I
> > >just now tried (unsuccessfully) to use lockstat to see if there was
> > >any contention reported.  I read Documentation/lockstat.txt and
> > >followed the instructions but the lock in question did not appear to
> > >be in the output.  I think I'm going to have to go with the assumption
> > >that this is just acquire and release overhead.
> > 
> > I think there is a way to get perf to "annotate" (iirc that is the
> > term it uses) the report to show hits at the instruction level.
> > Ostensibly one could then look and see how many of the hits were for
> > the acquire/release part of the routine, and how much was for the
> > actual contention.
> 
> Yep, so ~1% of my total time is in _raw_spin_lock and using perf
> annotate it appears that maybe only 5-6% percent of that is actually
> contention and the rest is acquire/release.  Looks like I need to look
> elsewhere for my performance improvements.  Thanks Rick for your help!
> Below is the output of perf annotate if your curious.

It seems multicast reception could benefit from the 'hcount' infra added
in commit fdcc8aa953a1123 ("udp: add a counter into udp_hslot")

That is : if udp hash slot has few sockets (apparently in your case, at
most one socket per hash slot), we can perform RCU lookup as in unicast
case.

__udp4_lib_mcast_deliver() had to use a spin_lock() protection because
we had no idea of the number of sockets we could find, as we use a
stack[256 / sizeof(struct sock *)] to hold socket pointers, and one
incoming message had to be delivered exactly once per socket.
