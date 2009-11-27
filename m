From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: ucc_geth doesn't work properly with vlans enabled.
Date: Fri, 27 Nov 2009 10:08:26 -0500
Message-ID: <20091127150826.GA13458@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:38074 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753126AbZK0PGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 10:06:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just started using vlans on our powerpc platform, and we noticed that
we were getting dropped packets when using the vlan interfaces.
After a bit of debuging it turned out that dropping the MUT on the
client machine to 1496 made the problem go away, which was of course
also very suspicious.

So looking through the driver I found the max packet length is set to 1518
which of course is the right size for a 1500byte packet as long as it is
not vlan tagged.  The UCC happens to have support for recognizing vlan
tagged packets and dynamically increasing the allowed size in the vlan
tagged case by 4 bytes which is great if it works.  Well it turns out,
that feature works, but isn't actually enabled in the driver.  The code
to handle activating it is there, but there is no code anywhere to ever
set that parameter.

Specifically:

        if (ug_info->dynamicMaxFrameLength)
                remoder |= REMODER_DYNAMIC_MAX_FRAME_LENGTH;

This code works fine, but ug_info->dynamicMaxFrameLength is never touched
anywhere other than being memset to 0 initially as part of the struct.

So a simple hack of:

        if (ug_info->dynamicMaxFrameLength || 1)
                remoder |= REMODER_DYNAMIC_MAX_FRAME_LENGTH;

makes it work perfectly with vlans, but is obviously not the right way
to solve this.

What would be the right way to solve this?  What was the intent here I
wonder when it was written?  Certainly the current behaviour means vlans
can't be used on this driver.

-- 
Len Sorensen
