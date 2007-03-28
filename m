From: Jens Thiele <karme@berlios.de>
Subject: traffic shaping with NAT: IFB as IMQ replacement?
Date: Wed, 28 Mar 2007 18:54:52 +0200
Message-ID: <m27it09n5w.fsf@quark.karme-net.hirschau>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lartc@mailman.ds9a.nl, Jamal Hadi Salim <hadi@znyx.com>,
	linuximq@yahoogroups.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-11.arcor-online.net ([151.189.21.51]:34009 "EHLO
	mail-in-11.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753496AbXC2Nru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 09:47:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Sorry for the many Ccs, but I hope to reach all parties involved.
I want to do traffic shaping with NAT and I wanted to do it with IFB
instead of IMQ [1]. I tried a lot of things but now I am stuck (and
maybe confused).

The setup:
               eth0             eth1
WAN/(Internet) <-> Linux Router <-> LAN

Linux router:
- does NAT for the LANs
- runs local processes communicating with the WAN/Internet

Incoming and outgoing traffic on eth0 should be subject to "traffic
shaping". I put quotes here, because it seems the term policing would
be used for the incoming traffic directed at the router itself. It is
not an ideal solution to drop incoming packets, but assuming TCP,
intelligent dropping ("shaping") is still much better than plain rate
limiting or no action at all. (see also parts of [2]). If there is a
better solution than "ingress shaping" available or being worked on,
please tell me.

First of all: Why is it difficult?
Because you can't use the advanced qdics (htb, cbq, ...) on ingres
directly (only the ingress "qdisc").

Using IMQ it is quite straightforward to work around this limitation.

It seems IFB is intented as IMQ replacement [3]

I managed to use IFB as IMQ replacement in a setup without NAT.
But when NAT is involved I am in trouble because when I want to classify
the packets they still have the translated addresses. I could live with
the translated addresses if I could use netfilter connection tracking
information to classify the packets [4]. This was also discussed in the
thread [3]:

Jamal Hadi Salim writes:
> [...] Instead the plan is to have a contrack related action. This
> action will selectively either query/create contrack state on incoming packets.
> Packets could then be redirected to dummy based on what happens -> eg 
> on incoming packets; if we find they are of known state we could send to
> a different queue than one which didnt have existing state. This
> all however is dependent on whatever rules the admin enters. [...] "


I tried something like:
tc filter add dev ... match all ... \
   action ipt -j CONNMARK --restore-mark \
   action ipt -j LOG --log-prefix "..." \
   action continue
tc filter add dev ... handle <some-mark> \
   action ipt -j LOG --log-prefix "..."

to no avail. I couldn't find any information whether this is possible
now or what steps it would take to implement this?

Greetings
Jens

PS:
similar threads on the LARTC mailing list:
http://thread.gmane.org/gmane.linux.network.routing/25922
http://www.spinics.net/lists/lartc/msg19965.html
(many more)

[1] IMQ: http://www.linuximq.net/
[2] "shaping": http://mailman.ds9a.nl/pipermail/lartc/2004q3/013093.html
[3] IFB: netdev mailing list thread "dummy as IMQ replacement"
    Message-Id: 1107123123.8021.80.camel@jzny.localdomain
    http://marc.info/?l=linux-netdev&m=110712327422706&w=2

[4] Note: I think using the old policer [Symbol: NET_CLS_POLICE [=n] Prompt: Traffic
Policing (obsolete)] this maybe works? It seems ingress policing happens
after netfilter PREROUTING if you use NET_CLS_POLICE but using
NET_CLS_ACT it happens before netfilter PREROUTING?
(see also: sch_ingress.c and
http://mailman.ds9a.nl/pipermail/lartc/2005q4/017782.html)
But then again it is marked as obsolete and I need NET_CLS_ACT to
redirect to the IFB?!
