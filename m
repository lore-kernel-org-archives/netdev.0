From: Jeff Garzik <jeff@garzik.org>
Subject: Driver writer hints (was [PATCH 3/4] Add ETHTOOL_[GS]PFLAGS sub-ioctls)
Date: Fri, 10 Aug 2007 16:45:11 -0400
Message-ID: <46BCCE57.1060802@garzik.org>
References: <20070810202426.GA25050@havoc.gtf.org> <20070810202630.GB25095@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45487 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758882AbXHJUpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:45:17 -0400
In-Reply-To: <20070810202630.GB25095@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> commit 4901236cec047029b970261b95e47d6be60f523e
> Author: Jeff Garzik <jeff@garzik.org>
> Date:   Fri Aug 10 15:52:06 2007 -0400
> 
>     [ETHTOOL] Introduce ->{get,set}_priv_flags, ETHTOOL_[GS]PFLAGS
>     
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
>  include/linux/ethtool.h |    8 +++++++-
>  net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 45 insertions(+), 1 deletion(-)


This change permits driver writers to allow userspace to enable/disable 
driver-specific boolean options on a per-interface basis.  This is best 
illustrated by describing how userland uses this:

(this is very similar to how the get-stats and self-test operations 
currently work)

1) Userland issues ETHTOOL_GDRVINFO, to obtain the n_priv_flags value.

2) Userland issues ETHTOOL_GSTRINGS (ETH_SS_PRIV_FLAGS) to obtain an 
array of strings.  Each element in this array maps to a bit in the list 
of driver-private flags.  Array element #0 is the tag (name) for bit #0. 
  Array element #5 is the tag for bit #5.  etc.

If we are getting (retrieving) flags:

	3) Userland issues ETHTOOL_GPFLAGS, to obtain a 32-bit bitmap

	4) Userland prints out a tag returned from ETHTOOL_GSTRINGS
	   for each bit set to one in the bitmap.  If a bit is set,
	   but there is no string to describe it, that bit is ignored.
	   (i.e. a list of 5 strings is returned, but bit 24 is set)

If we are setting flags:

	3) Userland issues ETHTOOL_GPFLAGS, to obtain 32-bit bitmap

	4) Userland parses command line, which has a series of strings
	   in the format of "+option" (set flag) and "-option" (clear
	   flag).

	5) Userland sets and clears bits in the 32-bit bitmap, by
	   matching the command line-supplied data with strings returned
	   by ETHTOOL_GSTRINGS.

	6) If the bitmap has changed, send it back to the driver using
	   ETHTOOL_SPFLAGS.

In this way, you can see that the actual bit numbers are irrelevant, and 
need not be a fixed part of the ABI.  Everything is named-based.

This name-based stuff only applies to the private flags.  The 
ETHTOOL_[GS]FLAGS operations /do/ fix the bit numbers in stone, in the 
ABI.  There is no name list associated with ETHTOOL_[GS]FLAGS].  The 
userland interface does, however, use names rather than bit numbers, for 
ease of use.

Another attribute is worth pointing out at this point:  ETHTOOL_SFLAGS 
and ETHTOOL_SPFLAGS both permit atomic retrieval/setting of groups of 
features all at once.  IMO this is a nice addition to ethtool as well, 
where previously you had to issue separate ioctls for each feature, 
which might result in repeated NIC resets [depending on driver 
implementation].

Get-flags and get-priv-flags are unpriveleged operations.  Set-flags and 
set-priv-flags require CAP_NET_ADMIN like other ethtool sub-ioctls.

Drivers should return -EINVAL if userland attempts to set an invariant 
(read-only) flag to something other than its constant value.

