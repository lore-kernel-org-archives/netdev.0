From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [Linuxptp-devel] RFC [PATCH 2/3] PTP: use flags to request HW
 features
Date: Thu, 31 Oct 2013 08:12:58 +0100
Message-ID: <20131031071256.GB5226@netboy>
References: <1383159637-8165-1-git-send-email-fbl@redhat.com>
 <1383159637-8165-3-git-send-email-fbl@redhat.com>
 <20131030214841.GZ13373@plex.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: linuxptp-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:37365 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab3JaHNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 03:13:10 -0400
Received: by mail-wg0-f53.google.com with SMTP id y10so2304515wgg.8
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 00:13:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131030214841.GZ13373@plex.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 07:48:41PM -0200, Flavio Leitner wrote:
> On Wed, Oct 30, 2013 at 05:00:36PM -0200, Flavio Leitner wrote:
> > Currently the user space can't tell which delay mechanism
> > (E2E/P2P) or transport is needed in the ioctl(). Therefore,
> > PTP silently fails when the hardware doesn't support a
> > certain delay mechanism or transport.

[ For netdev readers, the text below repeats what I posted to the
  linuxptp-devel list. ]

SIOCSHWTSTAMP is bad enough already. Let's not make it even
uglier. ETHTOOL is a better place for this kind of thing. The
ethtool_ts_info has plenty of reserved fields, and drivers could
use them to advertise these capabilities without the risk of
breaking user space.

We already check each port's capabilities using the ethtool ioctl.
It makes perfect sense to have two calls. First, tell me what is
available, then, I'll tell you what I want. That is easy.

In contrast, the closed loop feedback of SIOCSHWTSTAMP is really
awful. The whole rx_filter field is designed around the inadequacies
of an early intel card, and the choices are obsolete and mostly
useless. There isn't even any mention of pdelay. Ptp4l is already
bad enough with the filter1, filter2 probing. Let's just leave that
ioctl alone.

On Wed, Oct 30, 2013 at 07:46:58PM -0200, Flavio Leitner wrote:
> What about the transport?

I suggest offering the following bits in the ethtool rx|tx_reserved
fields:

TS_SYNC        (1<<0) /* silly, PTP is not possible without this */
TS_DELAY_REQ   (1<<1)
TS_PDELAY_REQ  (1<<2)
TS_PDELAY_RESP (1<<3)

TS_ON_LAYER2   (1<<4)
TS_ON_IPV4     (1<<5)
TS_ON_IPV6     (1<<6)

> And feature combination?

My goal for linuxptp (and for the PHC subsystem) is to offer a kind of
reference implementation. I have no inclination to support every last
broken hardware out there. However, I agree that we should try to
support poorly designed cards if we can, but not at the price of
making ugly interfaces for the everyone.

Drivers with weird restrictions (for example, supports PDelay_Req but
only on IPv6) will have to just advertise one working combination.

The intel ixp465 is an example of design that we cannot ever support
in linuxptp. It can time stamp *either* the master role's events or
the slave role's events, but not both. Brilliant.

[ This chip is thankfully now obsolete, but the time stamping IP core
  found its way into the phc_gbe, but with the worst mistakes
  corrected. ]

Thanks,
Richard
