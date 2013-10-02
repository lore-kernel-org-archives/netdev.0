From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 2 Oct 2013 15:35:07 -0500
Message-ID: <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
 <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:59942 "EHLO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753552Ab3JBUfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:35:12 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so3263247iec.30
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 13:35:11 -0700 (PDT)
In-Reply-To: <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 11:09:25AM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-02 at 12:34 -0500, Shawn Bohrer wrote:
> > On Tue, Oct 01, 2013 at 01:52:49PM -0700, Eric Dumazet wrote:
> > > On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> > > > The removal of the routing cache introduced a performance regression for
> > > > some UDP workloads since a dst lookup must be done for each packet.
> > > > This change caches the dst per socket in a similar manner to what we do
> > > > for TCP by implementing early_demux.
> > > > 
> > > > For UDP multicast we can only cache the dst if there is only one
> > > > receiving socket on the host.  Since caching only works when there is
> > > > one receiving socket we do the multicast socket lookup using RCU.
> > > 
> > > For unicast, we should find a matching socket for early demux only if
> > > this is a connected socket.
> > > 
> > > Otherwise, forwarding setups will break.
> > > 
> > > You probably need to add a minimum score to __udp4_lib_lookup()
> > 
> > Perhaps I'm missing something but I don't think a minimum score would
> > work because compute_score() and compute_score2() have several ways of
> > returning a score of lets say 4 and I don't think they all mean the
> > socket is connected.
> 
> Just change how score is computed. The existing +4 values are not hard
> coded anywhere.
> 
> You want to compute a score so that a single compare against a threshold
> is enough to tell you what's going on, before even taking a refcount on
> the socket.

Sorry, I must be a little slow today.  I understand what you are
suggesting but I don't see how to implement it with a score.  Or at
least not without potentially changing existing behavior.  For example
I could make the inet->inet_daddr case add +100 to the score and I
would know that a score >= 100 was connected.  However, this would
unfairly favor that one case making a socket that only had a matching
inet_daddr be better than one that only had a matching inet_dport,
sk_bound_dev_if, and inet_rcv_saddr.

The other possibility I can think of would be to use a bit mask so I
could see which tests passed and I could compute a score by counting
the set bits.  This would probably work since most of the tests
currently add an equal weight of 4 except for the one
(sk->sk_family == PF_INET) test which I'm not sure how to handle using
this strategy.

Did you have something specific in mind with your suggestion?

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
