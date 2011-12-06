From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Understanding HFSC
Date: Mon, 05 Dec 2011 22:42:55 -0500 (EST)
Message-ID: <d16d88d7-5fa5-4552-acf9-32222cfdb495@jasiiieee>
References: <4EDB69C7.6080209@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:56226 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932851Ab1LFCmg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 21:42:36 -0500
In-Reply-To: <4EDB69C7.6080209@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much, Michal, for taking the time to answer these in depth.  I know they are detailed and long questions and I'm sure you have other demands on your time! I'll respond in-line - John

----- Original Message -----
> From: "Michal Soltys" <soltys@ziu.info>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: netdev@vger.kernel.org
> Sent: Sunday, December 4, 2011 7:38:31 AM
> Subject: Re: Understanding HFSC
> 
> On 11-12-04 05:57, John A. Sullivan III wrote:
><snip>
> > One of the most confusing bits to me is, does the m1 rate apply to
> > each flow handled by the class or only to the entire class once it
> > becomes active?
> 
> Where a packet lands is (generally) determined by tc filters and/or
> iptables' mark/classify targets. All the packets that end in some
> leaf
> node, are governed by that node's realtime service curve, and at
> times
> when that criterion is not used - at the ratio of virtual times
> (coming
> from linkshare service curves) between that node and its siblings.
> Regardless of curve used - smallest vt (linkshare criterion) or
> smallest
> dt from all eligible (realtime criterion) wins, and the leaf with one
> will fulfill the dequeue call.
> 
> If you need more fine grained control "below" such leaf node - you
> need
> to either use deeper hierarchy with presumably "simpler" qdiscs
> attached
> (but more complex marking setup), or shallower hierarchy with more
> elaborate qdiscs attached. Think of work conserving qdiscs such as:
> sfq,
> drr - paired with appropriate tc filters (tc-flow perhaps ?) as
> needed.

Hmm . . . If I understand your response correctly, that's the answer I was hoping was not the case :( It sounds like the queue is ignorant of the flow, i.e., it only knows that it has a packet and wants to know if it should dequeue it.  It has no idea that packet 1 is from an existing conversation and packet 2 is from a new one that needs to be jumped to the head of the overall queue if packet 1 and 2 are in the same leaf class.  Let me illustrate with two separate examples to see if I understand.  In the first example, we have periodic traffic such as VoIP and, in the second, we have bulk traffic which is being sent as fast as the originating system can send it.  In both cases, let's assume there is another class which is always backlogged.

In the first case, we are sending 222 byte RTP VoIP packets every 20ms.  Thus, we set rt umax to 222, dmax to 5ms, and rate to some number more than sufficient to handle VoIP.  I think the umax/dmax setting means we reduce deadline time for the RTP packet but only for the first one.  So I start one VoIP conversation, the first packet is "accelerated" and the rest keep arriving in 20ms intervals.  These are having their deadline times calculated according to the rt rate and not the accelerated umax/dmax slope.  1ms after one of those RTP packets arrives, an RTP from a new VoIP session arrives.  Is deadline calculated for this first packet of the new conversation from umax/dmax or rate? I would hope it would be umax/dmax but, since it sounds like the class does not distinguish between separa
 te flows, it will be calculated at rate since we have already exceeded the intersection of m1 and m2.  Hmm . . . or does the time between the VoIP packets arriving every 20ms mean the queue actually is no longer backlogged and therefore resets the service curve so that each packet is effectively on the m1 slope rather than the m2 slope?

So let's go to the second scenario which does not involve periodic packets but a constant flow.  This is the example someone cited of using HFSC to accelerate the text portion of a web page.  So, we have typical text of 80kbits and want no more than 100ms delay serving that initial bit of text. So rt umax 80kbits dmax 100ms rate 500kbits Someone connects to the web server and we serve the first 80kbits at 800kbits per second and start streaming a large embedded video at 500kbits per second.  While that video is being sent, a second user connects to the web server.  Is there initial 80kbits of text sent at 800kbits per second or 500?
> 
> Btw - check out the very latest iproute2 tree - there're fresh
> tc-hfsc(7) and tc-stab(8) manuals added. I tried to make them as
> detailed as possible, but I might have overshot a bit - so opinion of
> someone getting into hfsc territory is invaluable. You can read them
> (if
> installing fresh iproute2 is out of question) with simple:
> 
> nroff -mandoc -rLL=<width>n <page> | less
> 
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob_plain;f=man/man7/tc-hfsc.7;hb=HEAD
> http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob_plain;f=man/man8/tc-stab.8;hb=HEAD
> 
><snip>
Thanks.  I think I already read this once or twice on-line but read it again from cover to cover from your links to ensure I had the latest and greatest.  Each time, it makes more sense - John
