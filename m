From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [BUG] mvneta: mirabox ethernet only works if initialized by
 uboot
Date: Fri, 9 Aug 2013 09:50:40 +0200
Message-ID: <20130809095040.46cd3dd8@skate>
References: <CACzLR4vv4kNVVkFx46jwcmB=hk_aT_XRrvU-Mpc0ZKdEQ-c_Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42855 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S967569Ab3HIHuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 03:50:52 -0400
In-Reply-To: <CACzLR4vv4kNVVkFx46jwcmB=hk_aT_XRrvU-Mpc0ZKdEQ-c_Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ethan Tuttle,

On Thu, 8 Aug 2013 22:31:37 -0700, Ethan Tuttle wrote:
> I ran into this issue after upgrading my mirabox from the old marvell
> kernel to 3.11-rc4.  Although ethernet interfaces are present, and
> 'link up' is reported, it isn't possible to send or receive packets.
> I'm using a vanilla kernel with .config from ArchLinuxARM[1].
> 
> Jochen De Smet posted a more detailed report[2] and a work-around on
> the Fedora ARM list: if an interface is started using the dhcp command
> in uboot, ethernet works in linux.
> 
> I reproduced the issue on -rc3 and -rc1 as well, so it isn't a recent
> regression.
> 
> It should be easy to reproduce on a mirabox, even when tftping a
> kernel: just try to use the other interface :).
> 
> Reporting here because I don't see any other reports to the
> maintainers.  I'm happy to provide more debug output or test patches
> if it will help.

This issue is well-known to me, but I unfortunately never had the time
to investigate it. I have a patch that makes it disappear, but I don't
think the patch is the right fix.

I don't have the Mirabox with me at the moment. If you're willing to
help, what would be nice would be to compare the values of the Ethernet
MAC registers and the values of the Ethernet PHY registers between the
working and non-working interfaces.

The reason I believe the patch is wrong is because the mvneta driver
uses the kernel phylib, and software based PHY polling, so it should be
the responsibility of the software to configure the PHY. However, what
the patch does is enable a feature of the hardware that makes it poll
and configure the PHY by itself automatically. While it looks nice, it
doesn't play nicely with the phylib framework of the kernel.

Best regards,

Thomas

The patch below:
==

This bit was missing, causing only the port initialized by u-boot
to work correctly.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c68481b..c006359 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -684,6 +684,9 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	}
 
 	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
+
+	mvreg_write(pp, MVNETA_UNIT_CONTROL,
+	            mvreg_read(pp, MVNETA_UNIT_CONTROL) | MVNETA_PHY_POLLING_ENABLE);
 }
 
 /* Stop the Ethernet port activity */


Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
