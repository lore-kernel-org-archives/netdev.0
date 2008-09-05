From: Ben Dooks <ben-linux@fluff.org>
Subject: include/linux/skbuff.h: checksumming documentation
Date: Fri, 5 Sep 2008 17:47:11 +0100
Message-ID: <20080905164711.GB4318@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:51552 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754690AbYIEQrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 12:47:14 -0400
Received: from ben by kira.home.fluff.org with local (Exim 4.69)
	(envelope-from <ben@fluff.org.uk>)
	id 1KbeSl-0007l3-Gq
	for netdev@vger.kernel.org; Fri, 05 Sep 2008 17:47:11 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been reading the documentation on the checksumming of packets
with respect to adding the hardware tcp/udp/ip checksumming features
of the DM900A and DM9000B chips.

Looking at the received packets documentation (as follows):

 *      UNNECESSARY: device parsed packet and wouldbe verified checksum.
 *              skb->csum is undefined.
 *            It is bad option, but, unfortunately, many of vendors do this.
 *            Apparently with secret goal to sell you new device, when you
 *            will add new protocol to your host. F.e. IPv6. 8)

The first line does not make sense, and the rest of it is an
unslightly rant about hardware manufacturers.

I think this comment is a bit hard, hardware is not like software
where when something new comes along you can simply recompile. It is
difficult to make a device which will cope with any protocol that
comes along in the future.

Following on:

 *      COMPLETE: the most generic way. Device supplied checksum of _all_
 *          the packet as seen by netif_rx in skb->csum.
 *          NOTE: Even if device supports only some protocols, but
 *          is able to produce some skb->csum, it MUST use COMPLETE,
 *          not UNNECESSARY.

So, where does this get applied to? From examination of some of the
other drivers this seems to be the contents of skb->ip_summed in the
skb.

Another problem with this is that it is ambiguous to how far the
protocol support reaches to change COMPLETE to UNNECESSARY... does it
cover the contents of this skb, the packet received, or all the
packets the device receives?

For a device that supports IP checksumming for IPv4 and UDP and TCP
over IPv4, then would the following pseudo-code be correct:

	if (packet_is_ipv4) {
		if (payload_is_udp() || payload_is_tcp()) {
			/* the TCP/UDP packet passed checksumming */

			skb->ip_csummed = CHECKSUM_UNNECESSARY;
		} else {
			/* the ip checksum passed, but we do not know
			 * what protocol is within the IP payload such
			 * as ICMP, etc. */
			skb->ip_csummed = ??
		}
	} else
		/* cannot handled non ipv4 packets */
		ski->ip_csummed = CHECKSUM_NONE;

I will have to research what the chip does with checksumming on IP
fragments as, IIRC, the UDP and TCP checksums cover the entriety of
the data before fragmentation.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
