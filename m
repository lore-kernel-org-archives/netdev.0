From: "Cohen, Guy" <guy.cohen@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 18:34:37 +0300
Message-ID: <D0122E209EBF8D4CAB38EC6A8AF244E502AB2937@hasmsx412.ger.corp.intel.com>
References: <1181573285.4077.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38980 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbXFKPep convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 11:34:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181573285.4077.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more details inside regarding wireless QoS.

jamal wrote:
> On Mon, 2007-11-06 at 17:30 +0300, Cohen, Guy wrote:
> 
> >
> > For WiFi devices the HW often implements the scheduling, especially
when
> > QoS (WMM/11e/11n) is implemented. There are few traffic queues
defined
> > by the specs and the selection of the next queue to transmit a
packet
> > from, is determined in real time, just when there is a tx
opportunity.
> > This cannot be predicted in advance since it depends on the medium
usage
> > of other stations.
> 
> WMM is a strict prio mechanism.
> The parametrization very much favors the high prio packets when the
> tx opportunity to send shows up.

Sorry, but this not as simple as you describe it. WMM is much more
complicated. WMM defines the HW queues as virtually multiple clients
that compete on the medium access individually. Each implements a
contention-based medium access. The Access Point publishes to the
clients the medium access parameters (e.g. back off parameters) that are
different for each access category (virtual client). There is _not_ a
strict priority assigned to each access category. The behavior of each
access category totally depends on the medium usage of other clients and
is totally different for each access category. This cannot be predicated
at the host SW.

> > Hence, to make it possible for wireless devices to use the qdisc
> > mechanism properly, the HW queues should _ALL_ be non-empty at all
> > times, whenever data is available in the upper layers.
> 
> agreed.
> 
> > Or in other
> > words, the upper layers should not block a specific queue because of
the
> > usage of any other queue.
> 
> This is where we are going to disagree.
> There is no way the stack will send the driver packets which are low
> prio if there are some which are high prio. There is therefore, on
> contention between low and high prio, no way for low prio packets to
> obstruct the high prio packets;

And this is not the right behavior for a WLAN stack. QoS in WLAN doesn't
favor strictly one access category over another, but defines some softer
and smarter prioritization. This is implemented in the HW/Firmware. I
just think that providing a per-queue controls (start/stop) will allow
WLAN drivers/Firmware/HW to do that while still using qdisc (and it will
work properly even when one queue is full and others are empty).

> however, it is feasible that high prio
> packets will obstruct low prio packets (which is fine).

No this is _not_ fine. Just to emphasize again, WMM doesn't define
priority in the way it is implemented in airplane boarding (Pilots
first, Business passengers next, couch passengers at the end), but more
like _distributed_ weights prioritization (between all the multiple
queues of all the clients on the channel).

As a side note, in one of the WFA WMM certification tests, the AP
changes the medium access parameters of the access categories in a way
that favors a lower access category. This is something very soft that
cannot be reflected in any intuitive way in the host SW.

> cheers,
> jamal
