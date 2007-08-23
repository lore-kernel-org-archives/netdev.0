From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/10 Rev4] [Doc] HOWTO Documentation for batching
Date: Thu, 23 Aug 2007 08:18:38 +0530
Message-ID: <OFB5DC8914.619DEA4F-ON65257340.000F62BA-65257340.000F7073@in.ibm.com>
References: <20070822085013.d20e1fd4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:51790 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489AbXHWCrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 22:47:36 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7N2pMEY309278
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:51:22 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N2lWgT4608248
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:47:32 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N2lTZL030719
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 12:47:31 +1000
In-Reply-To: <20070822085013.d20e1fd4.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

Thanks for your suggestions. Will clean up those changes.

- KK

Randy Dunlap <randy.dunlap@oracle.com> wrote on 08/22/2007 09:20:13 PM:

> On Wed, 22 Aug 2007 13:58:58 +0530 Krishna Kumar wrote:
>
> > Add Documentation describing batching skb xmit capability.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >  batching_skb_xmit.txt |   78
++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 78 insertions(+)
> >
> > diff -ruNp org/Documentation/networking/batching_skb_xmit.txt
> new/Documentation/networking/batching_skb_xmit.txt
> > --- org/Documentation/networking/batching_skb_xmit.txt   1970-01-01
05:30:
> 00.000000000 +0530
> > +++ new/Documentation/networking/batching_skb_xmit.txt   2007-08-22
10:21:
> 19.000000000 +0530
> > @@ -0,0 +1,78 @@
> > +       HOWTO for batching skb xmit support
> > +       -----------------------------------
> > +
> > +Section 1: What is batching skb xmit
> > +Section 2: How batching xmit works vs the regular xmit
> > +Section 3: How drivers can support batching
> > +Section 4: How users can work with batching
> > +
> > +
> > +Introduction: Kernel support for batching skb
> > +----------------------------------------------
> > +
> > +A new capability to support xmit of multiple skbs is provided in the
netdevice
> > +layer. Drivers which enable this capability should be able to process
multiple
> > +skbs in a single call to their xmit handler.
> > +
> > +
> > +Section 1: What is batching skb xmit
> > +-------------------------------------
> > +
> > +   This capability is optionally enabled by a driver by setting the
> > +   NETIF_F_BATCH_SKBS bit in dev->features. The pre-requisite for a
>
>                                                      prerequisite
>
> > +   driver to use this capability is that it should have a reasonably
>
>    I would say "reasonably-sized".
>
> > +   sized hardware queue that can process multiple skbs.
> > +
> > +
> > +Section 2: How batching xmit works vs the regular xmit
> > +-------------------------------------------------------
> > +
> > +   The network stack gets called from upper layer protocols with a
single
> > +   skb to transmit. This skb is first enqueue'd and an attempt is made
to
>
>                                            enqueued
>
> > +   transmit it immediately (via qdisc_run). However, events like tx
lock
> > +   contention, tx queue stopped, etc, can result in the skb not
getting
>
>                                       etc.,
>
> > +   sent out and it remains in the queue. When the next xmit is called
or
> > +   when the queue is re-enabled, qdisc_run could potentially find
> > +   multiple packets in the queue, and iteratively send them all out
> > +   one-by-one.
> > +
> > +   Batching skb xmit is a mechanism to exploit this situation where
all
> > +   skbs can be passed in one shot to the device. This reduces driver
> > +   processing, locking at the driver (or in stack for ~LLTX drivers)
> > +   gets amortized over multiple skbs, and in case of specific drivers
> > +   where every xmit results in a completion processing (like IPoIB) -
> > +   optimizations can be made in the driver to request a completion for
> > +   only the last skb that was sent which results in saving interrupts
> > +   for every (but the last) skb that was sent in the same batch.
> > +
> > +   Batching can result in significant performance gains for systems
that
> > +   have multiple data stream paths over the same network interface
card.
> > +
> > +
> > +Section 3: How drivers can support batching
> > +---------------------------------------------
> > +
> > +   Batching requires the driver to set the NETIF_F_BATCH_SKBS bit in
> > +   dev->features.
> > +
> > +   The driver's xmit handler should be modified to process multiple
skbs
> > +   instead of one skb. The driver's xmit handler is called either with
a
>
>
an
>
> > +   skb to transmit or NULL skb, where the latter case should be
handled
> > +   as a call to xmit multiple skbs. This is done by sending out all
skbs
> > +   in the dev->skb_blist list (where it was added by the core stack).
> > +
> > +
> > +Section 4: How users can work with batching
> > +---------------------------------------------
> > +
> > +   Batching can be disabled for a particular device, e.g. on desktop
> > +   systems if only one stream of network activity for that device is
> > +   taking place, since performance could be slightly affected due to
> > +   extra processing that batching adds (unless packets are getting
> > +   sent fast resulting in stopped queue's). Batching can be enabled if
>
>                                        queues).
>
> > +   more than one stream of network activity per device is being done,
> > +   e.g. on servers; or even desktop usage with multiple browser, chat,
> > +   file transfer sessions, etc.
> > +
> > +   Per device batching can be enabled/disabled by passing 'on' or
'off'
> > +   respectively to ethtool.
>
>    with what other parameter(s), e.g.,
>
>    ethtool <dev> batching on/off ?
>
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code
***

