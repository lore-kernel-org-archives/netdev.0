From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Fri, 29 Feb 2008 14:24:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802290941120.18002@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
 <Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
 <20080228171011.fc56eace.akpm@linux-foundation.org>
 <20080228233514.63b7136e.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1639218683-1204271164=:18002"
Cc: Guillaume Chazarain <guichaz@gmail.com>,
	Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60317 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756966AbYB2MZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 07:25:03 -0500
In-Reply-To: <20080228233514.63b7136e.billfink@mindspring.com>
Content-ID: <Pine.LNX.4.64.0802291408120.13029@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1639218683-1204271164=:18002
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0802291159241.13029@kivilampi-30.cs.helsinki.fi>

On Thu, 28 Feb 2008, Bill Fink wrote:

> On Thu, 28 Feb 2008, Andrew Morton wrote:
> 
> > On Thu, 28 Feb 2008 10:22:27 +0200 (EET) "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> > 
> > > [PATCH] TCP debug S+L (for 2.6.25-rcs, incompatible with 2.6.24.y)
> > > 
> > > ---
> > >  include/net/tcp.h     |    9 +++-
> > >  net/ipv4/tcp_input.c  |   18 +++++++-
> > >  net/ipv4/tcp_ipv4.c   |  127 +++++++++++++++++++++++++++++++++++++++++++++++++
> > >  net/ipv4/tcp_output.c |   23 +++++++--
> > 
> > I'll put this in -mm, see if we can flush anything out.

Ok, thanks. Were you aware of the considerable cpu consumption it will 
cause...? I.e., scanning throught the write queue in a number of place per 
ACK will certainly show up if somebody tests with netperf or so... ;-)
...Just please make sure it won't leak into mainline (for sure you would 
have done that without this explicit note :-)).

Good thing in that debug patch is that it catches inconsistencies 
immediately when they happen even if the cheap trap (which is in mainline) 
wouldn't ever see them because the situation would correct itself due to 
some other event.

> > Please let me know if/when it's obsolete, updated, etc.

Ok. Since many seem to now reporting this, I suppose the cause is 
relatively easy to find.

> > What is "S+L"?
> 
> I'll let Ilpo give the definitive answer.  But to test if I'm starting
> to grasp this, I'll give my understanding.  I believe 'S' means that a
> transmitted TCP skb has been acknowledged by a SACK, while 'L' means
> that a transmitted SKB is believed lost.  Since the 'S' state implies
> that the packet has actually been successfully received, it should not be
> possible for it to be considered lost ('L' state).  Thus an "S+L" state
> for a TCP skb is an internally inconsistent state and an indication of
> a TCP bug.
> 
> Anyone feel free to correct me if I'm way off base in my understanding.

Yes, this is exactly what it means. There's a big comment about them in 
the net/ipv4/tcp_input.c too. I answered to a similar question (but Bill 
mostly told all of it already):
  http://marc.info/?l=linux-netdev&m=120099888912383&w=2

We can do only cheap checking for sacked_out+lost_out > packets_out in 
mainline, and if that's true those warnings get printed but they won't 
necessarily tell the location of the bug because there might be 
considerable "latency" before that check triggers. On the other hand, this 
S+L debug patch verifies skb's ->sacked bitmaps against sacked/lost_out 
counters in multiple places per ACK and will catch the inconsistencies 
immediately at the site where they occurred (even if sacked_out + lost_out 
would still be below or equal to packets_out).



-- 
 i.
---696243703-1639218683-1204271164=:18002--
