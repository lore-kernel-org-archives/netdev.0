From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug#708995: iptables firewall is dropping GRO'd packets
Date: Mon, 20 May 2013 17:53:25 -0700
Message-ID: <1369097605.3301.203.camel@edumazet-glaptop>
References: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
	 <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, 708995@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42047 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3EUAx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 20:53:27 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx1so140582pab.41
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 17:53:27 -0700 (PDT)
In-Reply-To: <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 01:28 +0100, Ben Hutchings wrote:
> I'm seeing packet loss when forwarding from a LAN to PPP, whenever GRO
> kicks in on the LAN interface.
> 
> On Mon, 2013-05-20 at 05:48 +0100, Ben Hutchings wrote:
> [...]
> > The Windows system is connected to the LAN interface (int0).  Turning
> > off GRO on this interface works around the problem.  But since GRO is
> > on by default, it clearly ought to work properly with iptables.
> > 
> > I'll try to work out where the drops are occurring, but the
> > perf net_dropmonitor script is also broken...
> [...]
> 
> I've fixed that script and now I can see that it's not iptables but
> tbf_enqueue() that is dropping the GRO'd packets.  I do traffic-shaping
> on the PPP link like this:
> 
> tc qdisc replace dev ppp0 root tbf rate 420kbit latency 50ms burst 1540
> 
> The local TCP will never generate an skb larger than the burst size
> because it knows the PPP interface can't do GSO or TSO.  And the wifi
> network doesn't seem to be fast enough for GRO to have much of an
> effect.  But a peer on the wired network can trigger GRO and this
> produces an skb that exceeds the burst size.
> 
> Is this a bug in sch_tbf, or should I accept it as a limitation?  It
> seems like it should do GSO on entry to the queue if necessary.
> 

This has been discussed on netdev this year.

Jiri Pirko was working on this. 

(thread :  tbf: take into account gso skbs)
