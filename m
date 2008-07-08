From: Bill Fink <billfink@mindspring.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 02:02:35 -0400
Message-ID: <20080708020235.388a7bd5.billfink@mindspring.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:59541 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbYGHGCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 02:02:42 -0400
In-Reply-To: <20080708045443.GA7726@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jul 2008, Evgeniy Polyakov wrote:

> On Mon, Jul 07, 2008 at 02:49:12PM -0700, David Miller (davem@davemloft.net) wrote:
> > There is no reason these days to ever explicitly set the socket
> > buffer sizes on TCP sockets under Linux.
> > 
> > If something is going wrong it's a bug and we should fix it.
> 
> Just for the reference: autosizing is (was?) not always working correctly
> for some workloads at least couple of years ago.
> For example I worked with small enough embedded systems with 16-32 MB
> of RAM where socket buffer size never grew up more than 200Kb (100mbit
> network), but workload was very bursty, so if remote system froze for
> several milliseconds (and sometimes upto couple of seconds), socket
> buffer was completely filled with new burst of data and either sending
> started to sleep or returned EAGAIN, which resulted in semi-realtime
> data to be dropped.
> 
> Setting buffer size explicitely to large enough value like 8Mb fixed
> this burst issues. Another fix was to allocate data each time it becomes
> ready and copy portion to this buffer, but allocation was quite slow,
> which led to unneded latencies, which again could lead to data loss.

I admittedly haven't tested on the latest greatest kernel versions,
but the testing I have done on large RTT 10-GigE networks, if I want
to get the ultimate TCP performance I still need to explicitly set
the socket buffer sizes, although I give kudos to the autotuning which
does remarkably well.  Here's a comparison across an ~72 ms RTT
10-GigE path (sender is 2.6.20.7 and receiver is 2.6.22.9).

Autotuning (30-second TCP test with 1-second interval reports):

# nuttcp -T30 -i1 192.168.21.82
nuttcp-6.0.1: Using beta version: retrans interface/output subject to change
              (to suppress this message use "-f-beta")

    7.2500 MB /   1.01 sec =   60.4251 Mbps     0 retrans
   43.6875 MB /   1.00 sec =  366.4509 Mbps     0 retrans
  169.4375 MB /   1.00 sec = 1421.2296 Mbps     0 retrans
  475.3125 MB /   1.00 sec = 3986.8873 Mbps     0 retrans
  827.6250 MB /   1.00 sec = 6942.0247 Mbps     0 retrans
  877.6250 MB /   1.00 sec = 7361.2792 Mbps     0 retrans
  878.1250 MB /   1.00 sec = 7365.7750 Mbps     0 retrans
  878.4375 MB /   1.00 sec = 7368.2710 Mbps     0 retrans
  878.3750 MB /   1.00 sec = 7367.7173 Mbps     0 retrans
  878.7500 MB /   1.00 sec = 7370.6932 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.6818 Mbps     0 retrans
  879.1875 MB /   1.00 sec = 7374.5546 Mbps     0 retrans
  878.6875 MB /   1.00 sec = 7370.3754 Mbps     0 retrans
  878.2500 MB /   1.00 sec = 7366.3742 Mbps     0 retrans
  878.6875 MB /   1.00 sec = 7370.6407 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.4239 Mbps     0 retrans
  878.5000 MB /   1.00 sec = 7368.8174 Mbps     0 retrans
  879.0625 MB /   1.00 sec = 7373.4766 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.4386 Mbps     0 retrans
  878.3125 MB /   1.00 sec = 7367.2152 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.3723 Mbps     0 retrans
  878.6250 MB /   1.00 sec = 7369.8585 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.4460 Mbps     0 retrans
  875.5000 MB /   1.00 sec = 7373.0401 Mbps     0 retrans
  878.8125 MB /   1.00 sec = 7371.5123 Mbps     0 retrans
  878.3750 MB /   1.00 sec = 7367.5037 Mbps     0 retrans
  878.5000 MB /   1.00 sec = 7368.9647 Mbps     0 retrans
  879.4375 MB /   1.00 sec = 7376.6073 Mbps     0 retrans
  878.8750 MB /   1.00 sec = 7371.8891 Mbps     0 retrans
  878.4375 MB /   1.00 sec = 7368.3521 Mbps     0 retrans

23488.6875 MB /  30.10 sec = 6547.0228 Mbps 81 %TX 49 %RX 0 retrans

Same test but with explicitly specified 100 MB socket buffer:

# nuttcp -T30 -i1 -w100m 192.168.21.82
nuttcp-6.0.1: Using beta version: retrans interface/output subject to change
              (to suppress this message use "-f-beta")

    7.1250 MB /   1.01 sec =   59.4601 Mbps     0 retrans
  120.3750 MB /   1.00 sec = 1009.7464 Mbps     0 retrans
  859.4375 MB /   1.00 sec = 7208.5832 Mbps     0 retrans
  939.3125 MB /   1.00 sec = 7878.9965 Mbps     0 retrans
  935.5000 MB /   1.00 sec = 7847.0249 Mbps     0 retrans
  934.8125 MB /   1.00 sec = 7841.1248 Mbps     0 retrans
  933.8125 MB /   1.00 sec = 7832.7291 Mbps     0 retrans
  933.1875 MB /   1.00 sec = 7827.5727 Mbps     0 retrans
  932.1875 MB /   1.00 sec = 7819.1300 Mbps     0 retrans
  933.1250 MB /   1.00 sec = 7826.8059 Mbps     0 retrans
  933.3125 MB /   1.00 sec = 7828.6760 Mbps     0 retrans
  933.0000 MB /   1.00 sec = 7825.9608 Mbps     0 retrans
  932.6875 MB /   1.00 sec = 7823.1753 Mbps     0 retrans
  932.0625 MB /   1.00 sec = 7818.0268 Mbps     0 retrans
  931.7500 MB /   1.00 sec = 7815.6088 Mbps     0 retrans
  931.0625 MB /   1.00 sec = 7809.7717 Mbps     0 retrans
  931.5000 MB /   1.00 sec = 7813.3711 Mbps     0 retrans
  931.8750 MB /   1.00 sec = 7816.4931 Mbps     0 retrans
  932.0625 MB /   1.00 sec = 7817.8157 Mbps     0 retrans
  931.5000 MB /   1.00 sec = 7813.4180 Mbps     0 retrans
  931.6250 MB /   1.00 sec = 7814.5134 Mbps     0 retrans
  931.6250 MB /   1.00 sec = 7814.4821 Mbps     0 retrans
  931.3125 MB /   1.00 sec = 7811.7124 Mbps     0 retrans
  930.8750 MB /   1.00 sec = 7808.0818 Mbps     0 retrans
  931.0625 MB /   1.00 sec = 7809.6233 Mbps     0 retrans
  930.6875 MB /   1.00 sec = 7806.6964 Mbps     0 retrans
  931.2500 MB /   1.00 sec = 7811.0164 Mbps     0 retrans
  931.3125 MB /   1.00 sec = 7811.9077 Mbps     0 retrans
  931.3750 MB /   1.00 sec = 7812.3617 Mbps     0 retrans
  931.4375 MB /   1.00 sec = 7812.6750 Mbps     0 retrans

26162.6875 MB /  30.15 sec = 7279.7648 Mbps 93 %TX 54 %RX 0 retrans

As you can see, the autotuned case maxed out at about 7.37 Gbps,
whereas by explicitly specifying a 100 MB socket buffer it was
possible to achieve a somewhat higher rate of about 7.81 Gbps.
Admittedly the autotuning did great, with a difference of only
about 6 %, but if you want to squeeze the last drop of performance
out of your network, explicitly setting the socket buffer sizes
can still be helpful in certain situations (perhaps newer kernels
have reduced the gap even more).

But I would definitely agree with the general recommendation to
just take advantage of the excellent Linux TCP autotuning for most
common scenarios.

						-Bill
