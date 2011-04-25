From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] net-ethtool: Convert (hw_/vlan_/wanted_)features
 fields from u32 type to u64.
Date: Sun, 24 Apr 2011 22:28:24 -0700 (PDT)
Message-ID: <20110424.222824.193712645.davem@davemloft.net>
References: <1303515367-25595-2-git-send-email-maheshb@google.com>
	<1303515367-25595-3-git-send-email-maheshb@google.com>
	<1303623041.3032.97.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751052Ab1DYF26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 01:28:58 -0400
In-Reply-To: <1303623041.3032.97.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 24 Apr 2011 06:30:40 +0100

> If we think 64 bits will be enough for the next 10 years, then let's
> just go with a single 64-bit feature word.  If we're not so sure then
> then the ethtool API should continue to allow for multiple words
> (whether 32-bit or 64-bit).

I think the ethtool facing stuff should stay as is.

Having total flexibility internally is important.

I know some people had reservations about using the bitmap
interfaces, but that's what they exist for.  The approach for
the conversion just wasn't right.

My humble suggestion is:

1) Abstract away every access to these feature sets, like this.

   void netdev_set_feature(struct net_device *netdev, int feature);
   void netdev_clear_feature(struct net_device *netdev, int feature);
   bool netdev_test_feature(struct net_device *netdev, int feature);

   Then you can use whatever representation you want, without having
   to edit hundreds of files every time we want to change how these
   feature sets are stored.

   Thus, after this, future changes will be painless.

   This is a multi-commit change.  First you add the interfaces,
   then you change the access sites in logical groups.

2) Write translators between the internal representation and the
   ethtool user-visible data structures we have for this stuff.

3) Pick an extensible set implementation and use it.

We may need to have a type that gets used to pass feature sets
around, and if that's absolutely needed, then fine.  But it has
to be a typedef or similar, so that it can be changed without
having to change every function signature every time we want to
change the representation.


