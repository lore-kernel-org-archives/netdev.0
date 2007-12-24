From: Al Viro <viro@ftp.linux.org.uk>
Subject: [RFC] skge csum problems
Date: Mon, 24 Dec 2007 09:43:52 +0000
Message-ID: <20071224094352.GU8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56413 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbXLXJny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 04:43:54 -0500
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.63 #1 (Red Hat Linux))
	id 1J6jqj-0000mc-0K
	for netdev@vger.kernel.org; Mon, 24 Dec 2007 09:43:53 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Both variants of skge (drivers/net and drivers/net/sk98lin/ resp.)
have the same problem with rx checksums.  They pick checksum from rx
descriptor and use it as-is.  Normally that would be the right thing to
do.  However, skge is told to byteswap descriptors on big-endian boxen.

Checksum is fixed-endian and we want it that way; IOW, what we end up
storing in skb->csum should be fixed-endian as well.  Unless the card
is smart enough to byteswap everything in rx descriptor _except_ the
checksum, we have a trouble - we get a value converted to host-endian
by the general byteswap in descriptor and we must convert it to fixed-endian
ourselves.

FWIW, FreeBSD sk_if sidesteps that mess by not telling the card to 
byteswap, so that's not too informative.  Datasheet on
http://people.freebsd.org/~wpaul/SysKonnect/xmacii_datasheet_rev_c_9-29.pdf
is not clear on what's going on with checksum in byteswapping mode either...

Could somebody with that sucker on a card (all instances I have here are
on-board ones in little-endian boxen) test what's really going on for
big-endian hosts with either driver?
