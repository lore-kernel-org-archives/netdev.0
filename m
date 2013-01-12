From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over firewire
Date: Sat, 12 Jan 2013 09:27:30 +0100
Message-ID: <20130112092730.2cd18294@stein>
References: <50EF1AEB.1080704@gmail.com>
	<50EFE095.2040505@linux-ipv6.org>
	<50F10C53.4000803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:57320 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab3ALI1v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 03:27:51 -0500
In-Reply-To: <50F10C53.4000803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 Stephan Gatzka wrote:
> 
> > And, last but big issue is, well, packet inspection at
> > driver level.  For example, you use ndisc_parse_options()
> > and code depends on CONFIG_IPV6=y.
> 
> Good point. Of course I can make firewire-net dependent from IPv6.
> 
> The other option is to build a separate firewire_ipv6 module. 
> Implementing that looks easy enough. From the original firewire net 
> driver I just need a hook to register a function that investigates 
> incoming packets for IPv6 link layer option. In addition, 
> fwnet_peer_find_by_guid must be exported.
> 
> Stefan, what is your opinion on that?

>From your previous patch it looks like that the RFC 3146 related parts in
drivers/firewire/net.c are just a few places that can be enclosed into
#if/#endif blocks.  That way, firewire-net will be built according to the
same Kconfig switches as before, and gets RFC 3146 capability if
CONFIG_IPV6=y or =m.

#if/#endif are generally not very nice, but in this case I think they can
be kept localized and thus are more beneficial than hurtful.

There is a catch:  Since both net/ipv6/Kconfig::IPV6 and
drivers/firewire/Kconfig::FIREWIRE_NET are tristate variables, we need to
prevent CONFIG_FIREWIRE_NET=y while CONFIG_IPV6=m.  One way to do that
would be like it was done for the infrared remote control support in the
firedtv driver which depends on the CONFIG_INPUT tristate variable.  This
was solved like this:
  - The helper variable drivers/media/firewire/Kconfig::DVB_FIREDTV_INPUT
    was added.
  - This variable is true if CONFIG_INPUT=y,
    or if CONFIG_DVB_FIREDTV=m and CONFIG_INPUT=m.
    In other words, if CONFIG_INPUT=m and CONFIG_DVB_FIREDTV=y, firedtv
    silently loses support for remote control input.
  - The respective firedtv parts are of course made dependent on
    CONFIG_DVB_FIREDTV.  In this case, only
    drivers/media/firewire/firedtv.h and drivers/media/firewire/Makefile
    are minimally affected.

So, if implemented like that, the special case of CONFIG_FIREWIRE_NET=y &&
CONFIG_IPV6=m would mean that firewire-net would be built but would lack
RFC 3146 support.

With a little bit more Kconfig related effort one could solve it such that
CONFIG_FIREWIRE_NET=y && CONFIG_IPV6=m would actually put RFC 3146 support
into firewire-net but would force it to be built modular instead of
statically.

Not sure which way is preferrable.  Cc'ing netdev.

In case of CONFIG_IPV6=n however, people should still be able to build
firewire-net with its current RFC 2734-only feature set.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
