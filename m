From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Wed, 7 Jul 2010 09:18:32 +0200
Message-ID: <20100707071832.GA2816@riccoc20.at.omicron.at>
References: <cover.1278307573.git.richard.cochran@omicron.at>
 <a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
 <AANLkTikEF3B-0JGvqosY5jMaChbpYctOmKW1jJKOWsQE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58201 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab0GGHSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 03:18:36 -0400
Received: by bwz1 with SMTP id 1so3988004bwz.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 00:18:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTikEF3B-0JGvqosY5jMaChbpYctOmKW1jJKOWsQE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 06, 2010 at 12:09:10PM -0500, Andy Fleming wrote:
> allowed in interrupt context.  *Certainly*, once you *do* allow MII
> transactions in interrupt context, you *cannot* use spin_lock().  You
> at least have to use spin_lock_irq[save].

Okay, I see. Before the change to mutexes the code used spin_lock_bh.

> Also, I agree with David's comments, and Grant's.  There's got to be
> another way to do this.

I understand what troubles you about the proposed changes. However, I
cannot see a better way to get a PHY time stamp other than to read it
out during the napi poll and hard_xmit functions. It is a chicken and
egg problem.

Consider the receive path:

1. PTP Packet passed through PHY. PHY recognizes it and stores a time
   stamp along with some UID from the packet.

2. Napi calls the MAC driver's poll function.

3. MAC driver acquires packet. At this point, if we want to have a
   hardware time stamp, we must read it out over the mdio bus, before
   handing the packet over to the stack via netif_receive_skb().

If we decide to defer the packet delivery (in step 3), we have to know
whether the PHY will have a time stamp for this packet. The only way
to do this is to compare the UIDs, but that requires reading it over
the mdio bus.

One could simply defer *all* packets, but that would really stink.

Possibly, we could defer all likely packets, for example all PTP
packets. Changing all the MAC driver to call a time stamping hook that
conditionally consumes the skbuffs would also stink. Could the packet
be deferred by the stack, early in netif_receive_skb? If so, a work
queue could read the PHY and then deliver the deferred packets at some
later time.

IMHO, it better just to check for a PHY time stamp immediately, and
live with the performance hit. I believe that PTP users will accept
this. Naturally, it requires allowing reading the mdio bus in two
non-sleeping contexts.

There are perhaps other ways to provide PHY time stamps, but I am
doubtful that they would work better, in general. The National
Semiconductor PHYTER can provide the time stamps as status frames, and
it can also insert time stamps directly into the incoming and
outgoing frames.

* Using status frames is an attractive idea, because it obviates the
  need to read over the mdio bus. However, you still have the problem
  of matching the status frames to the PTP packets.

* Inserting a time stamp into outgoing frames presents no problems
  (this is the so called "PTP one step" operation). However, for
  incoming frames the PHYTER inserts the time stamp into the PTP
  message at a programmable offset. This invalidates the UDP checksum
  for PTPv1 packets (PTPv2 checksums will be automatically corrected.)

Even if we implement one of these alternatives, I am not sure that
other PHYs will also offer the same capabilities as the PHYTER.

Well, there you have it. I welcome any ideas on how to go about
offering PHY time stamping.

Thanks,
Richard





