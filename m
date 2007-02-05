From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 19:07:53 +0100
Message-ID: <200702051907.53220.IvDoorn@gmail.com>
References: <200701312016.50524.IvDoorn@gmail.com> <200702051843.20802.IvDoorn@gmail.com> <200702051847.00737.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:49886 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbXBESIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:08:15 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2204645nfa
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 10:08:14 -0800 (PST)
In-Reply-To: <200702051847.00737.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > > Not all hardware are capable of generating their own RTS frames.
> > > > This patch will add support for creating the RTS frame in software,
> > > > when the driver requests this through the flag
> > > > IEEE80211_HW_SOFTWARE_RTS
> > > 
> > > It seems this is not the ideal solution. Most of drivers needing
> > > software RTS would need to remember the RTS frame somewhere (as they
> > > need to pass it together with the actual frame).
> > 
> > Well in case of rt2x00 (I am not sure which other drivers also need software RTS)
> > the rts packet is just inserted inside the packet ring and is treated as a regular
> > packet/fragment that has just been inserted by the driver.
> > 
> > This patch just adds this additional packet just before the real packet, and in case
> > the real packet could not be send the rts packet is stored in the
> > ieee80211_tx_stored_packet structure to be send later.
> 
> Ok, I see. But this is not going to work with bcm43xx.
> 
> I also sent a fix for rt2x00 to work with my patchset.

Did you already send that patchset to the netdev list?
Because I haven't seen a patch series about rts for d80211 yet.

> > > A better solution would be either to pass a pointer to RTS frame data
> > > in tx_control or to create a function returning RTS frame.
> > 
> > In case of rt2x00 this would deliver more problems, especially since it will use
> > a ring entry to send the rts frame and in case of rt2500usb and rt73usb it will
> > need a sk_buff structure since it needs to pass it to the device (where the sk_buff
> > will have some free tx_header_room for the descriptor.)
> 
> I don't understand this.
> You need to put in into the ring either way.

The new rt2500usb and rt73usb packet ring handling no longer use a DMA buffer
but instead send the sk_buffer->data pointer to the USB layer.
The solution as suggested by Jiri could be handled by making sure the rts allocated
buffer will also have a tx header room as set in the tx_header_room field. But I am not
sure if that would be a better solution than putting the rts packet in a sk_buffer that is being
send out just before the real packet...

For the timing problem you mentioned, another solution could be implemented,
like already mentioned on the d80211 TODO list, the dscape stack should be able
to send a signal to the driver that the last fragment was handed over, this signal can
be used by the driver to start sending out the queued packets. This would at least work
for rt2x00 where especially for PCI devices _no_ packets are being send until the TX ring
has been kicked.

Ivo

