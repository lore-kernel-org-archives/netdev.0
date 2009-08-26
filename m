From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Wed, 26 Aug 2009 21:03:35 +0200
Message-ID: <20090826190335.GA3009@ami.dom.local>
References: <200908251416.13888.denys@visp.net.lb>
 <20090825200306.GA3020@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:53932 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbZHZTDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 15:03:48 -0400
Received: by fxm17 with SMTP id 17so367104fxm.37
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 12:03:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090825200306.GA3020@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 10:03:06PM +0200, Jarek Poplawski wrote:
> Denys Fedoryschenko wrote, On 08/25/2009 01:16 PM:
> ...
> > But this one maybe will overflow because of limitations in iproute2.
> > 
> > PPoE_146 ~ # ./tc -s -d qdisc show dev ppp13
> > qdisc tbf 8004: root rate 96000bit burst 797465b/8 mpu 0b lat 275.4s
> >  Sent 82867 bytes 123 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> > qdisc ingress ffff: parent ffff:fff1 ----------------
> >  Sent 506821 bytes 1916 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> > 
> > So maybe all of that just wrong way of using TBF.
> 
> I guess so; I've just recollected you described it some time ago. If
> it were done only with TBF it would mean very large surges with line
> speed and probably a lot of drops by ISP. Since you're ISP, you
> probably drop this with HTB or something (then you should mention it
> describing the problem) or keep very long queues which means great
> latencies. Probably there is a lot of TCP resending btw. Using TBF
> with HTB etc. is considered wrong idea anyway. (But if it works for
> you shouldn't care.)
> 
> > At same time this means, if HTB and policers in filters done same way, that 
> > QoS in Linux cannot do similar to squid delay pools feature:
> > 
> > First 10Mb give with 1Mbit/s, then slow 64Kbit/s. If user use less than 64K - 
> > recharge with that unused bandwidth a "10 Mb / 1Mbit bucket".

So I thought about it a little more and I'm quite sure this idea with
large buckets is wrong/ineffective. I guess you could "describe" it
in HTB something like this:

tc class add dev ppp0 parent 1:3 classid 1:4 htb rate 64kbit\
   burst 10mb cburst 10mb
tc class add dev ppp0 parent 1:4 classid 1:4 htb rate 64kbit ceil 1mbit\
   cburst 10mb

(Of course, there would be this overflow problem with 2.6.31-rc and
so big buffers.)

So, the main point is: if somebody didn't send his/her 64Kbits long
time ago it usually means it's lost and can't be shared later. You
could try your luck, but e.g. if at the moment all users use their
64Kbits plus one of them 'thinks' he/she can send "saved" bits, it
means some other guy doesn't get his/her minimum (they send together
but some bytes will be dropped or queued).

It would work OK if you've reserved 1mbit per 64Kbit user but I guess
it's not what you do. So, IMHO, it should be better to use classical
methods to guarantee these 64Kbit with reasonable latency, plus
additonal borrowing with ceil and reasonable (much smaller buffers)
yet.

Jarek P.
