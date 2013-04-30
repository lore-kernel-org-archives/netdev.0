From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: check mac type from ethtool_regs.version
Date: Tue, 30 Apr 2013 16:23:32 +0100
Message-ID: <1367335412.2941.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366953168-17509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26448 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932669Ab3D3PXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 11:23:39 -0400
In-Reply-To: <1366953168-17509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 22:12 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch cleans up the mac type checks by using ethtool_regs.version
> provided by the driver. This change eliminates the need to add device IDs
> every time they are added to the driver.
> 
> This patch depends on a driver change that will add the mac_type to the
> upper 8 bits of ethtool_regs.version.
> 
> Note that when using ethtool with this patch with a version of ixgbe that
> does not provide the mac_type in ethtool_regs.version the register dump
> may be incomplete. However this issue would've existed previously for
> device IDs that were not added to ethtool.
[...]

I don't think this is acceptable; ethtool should remain backward
compatible if at all possible.

It seems like this would work with both old and new drivers:

diff --git a/ixgbe.c b/ixgbe.c
index dae11d4..9b005f2 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -133,10 +133,13 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	u8 i;
 	enum ixgbe_mac_type mac_type;
 
-	if (version != 1)
+	if (version == 0)
 		return -1;
 
-	mac_type = ixgbe_get_mac_type(hw_device_id);
+	/* The current driver reports the MAC type, but older versions
+	 * only report the device ID so we have to infer the MAC type.
+	 */
+	mac_type = version > 1 ? version : ixgbe_get_mac_type(hw_device_id);
 
 	reg = regs_buff[1065];
 	fprintf(stdout,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
