From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 1 Oct 2009 11:18:20 -0400
Message-ID: <20091001151820.GA2895@tuxdriver.com>
References: <20090924180048.14503.9579.stgit@tikku> <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com> <20090925044258.GA2722@tuxdriver.com> <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com> <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com> <20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33387 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbZJAPTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 11:19:49 -0400
Content-Disposition: inline
In-Reply-To: <87fxa3qjt2.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2009 at 05:18:33PM +0300, Kalle Valo wrote:
> "John W. Linville" <linville@tuxdriver.com> writes:
> 
> > On Fri, Sep 25, 2009 at 09:53:35AM -0700, Luis R. Rodriguez wrote:
> >
> >> So for Wake-on-Wireless I ran into the same, ethtool just did not
> >> offer the same wake up events needed for wireless. I could have
> >> technically used ethtool and expanded it to support wireless but it
> >> just seemed dirty.
> >> 
> >> I agree that using ethtool seems overkill compared to the patches
> >> you posted.
> >
> > I think you either overestimate the amount of trouble for implementing
> > (minimal) ethtool support or you underestimate the amount of
> > functionality available through that interface.
> 
> I'm not worried about the implementation complexity, and as your
> patches show it was easy. My concern is the overall design for
> wireless devices. Instead of using nl80211 for everything, with some
> features we would use nl80211/iw and with some ethtool. That's just
> confusing and I don't like that. I would prefer that nl80211 provides
> everything, it makes things so much easier.

Well, if the hw/fw version numbers were the only thing then I'd
probably say it's not a big deal.  But having ethtool support is nice
in that it makes a familiar tool work for us.  Among other things,
this probably helps with some distro scripts that don't work quite
right without it.  Plus, there is lots of debugging stuff that could
be turned-on without having to write new tools.

I suppose I understand the 'one API' idea, but why duplicate
functionality?  Anyway, adding a couple of ioctl calls isn't a
big deal.  And don't forget, we are still network drivers too...

> > That, or you just don't like using something named "eth"tool for
> > wireless -- but hey, let's be honest about the frames we
> > send/receive to/from the kernel... :-)
> 
> I don't have a problem with the name :) But ethernet is still so much
> different from 802.11 that there isn't that much to share and we in
> wireless will need different features.
> 
> One example is the hw version, ethtool only provides u32 to userspace
> and moves the burden of translating hw id to the user. For us a string
> is much better choise because when debuggin we need to often (or
> always?) know the chip version.

Look at the way most drivers set the version (using each byte as a
field).  If you want prettier output, adding a parser to the userland
ethtool is fairly trivial.  It looks something like the patch below...

> But this is not something I will start fighting about. If you still
> think that ethtool is the way to go, I'm perfectly fine with it.
> 
> >> The ethtool interface provides functionality for viewing and modifying
> > eeprom contents, dumping registers, trigger self-tests, basic driver
> > info, getting and setting message reporting levels, external card
> > identification (hey, _could_ be useful!), and some other bits like
> > checksum offload that might(?) be useful in the future.  I understand
> > regarding the WoW vs. WoL issue but probably the answer is just to
> > add a new method for WoW...?
> 
> I took a look at ethtool help output from debian unstable and I think
> this is the set of features we can use in wireless:
> 
>         ethtool -i|--driver DEVNAME     Show driver information
>         ethtool -d|--register-dump DEVNAME      Do a register dump
>                 [ raw on|off ]
>                 [ file FILENAME ]
>         ethtool -e|--eeprom-dump DEVNAME        Do a EEPROM dump
>                 [ raw on|off ]
>                 [ offset N ]
>                 [ length N ]
>         ethtool -E|--change-eeprom DEVNAME      Change bytes in device
>         EEPROM
>                 [ magic N ]
>                 [ offset N ]
>                 [ value N ]
>         ethtool -p|--identify DEVNAME   Show visible port
>         identification (e.g. blinking)
>                [ TIME-IN-SECONDS ]
>         ethtool -t|--test DEVNAME       Execute adapter self test
>                [ online | offline ]
 
I agree with the above.

> But here are the features which I doubt we will ever use:
> 
>         ethtool -s|--change DEVNAME     Change generic options
>                 [ speed %%d ]
>                 [ duplex half|full ]
>                 [ port tp|aui|bnc|mii|fibre ]
>                 [ autoneg on|off ]
>                 [ advertise %%x ]
>                 [ phyad %%d ]
>                 [ xcvr internal|external ]
>                 [ wol p|u|m|b|a|g|s|d... ]
>                 [ sopass %%x:%%x:%%x:%%x:%%x:%%x ]
>                 [ msglvl %%d ] 
>         ethtool -a|--show-pause DEVNAME Show pause options
>         ethtool -A|--pause DEVNAME      Set pause options
>                 [ autoneg on|off ]
>                 [ rx on|off ]
>                 [ tx on|off ]

I agree that the above are ethernet-specific.

>         ethtool -c|--show-coalesce DEVNAME      Show coalesce options
>         ethtool -C|--coalesce DEVNAME   Set coalesce options
>                 [adaptive-rx on|off]
>                 [adaptive-tx on|off]
>                 [rx-usecs N]
>                 [rx-frames N]
>                 [rx-usecs-irq N]
>                 [rx-frames-irq N]
>                 [tx-usecs N]
>                 [tx-frames N]
>                 [tx-usecs-irq N]
>                 [tx-frames-irq N]
>                 [stats-block-usecs N]
>                 [pkt-rate-low N]
>                 [rx-usecs-low N]
>                 [rx-frames-low N]
>                 [tx-usecs-low N]
>                 [tx-frames-low N]
>                 [pkt-rate-high N]
>                 [rx-usecs-high N]
>                 [rx-frames-high N]
>                 [tx-usecs-high N]
>                 [tx-frames-high N]
>                 [sample-interval N]

These _could_ be useful if wireless becomes more
performance-oriented...

>         ethtool -g|--show-ring DEVNAME  Query RX/TX ring parameters
>         ethtool -G|--set-ring DEVNAME   Set RX/TX ring parameters
>                 [ rx N ]
>                 [ rx-mini N ]
>                 [ rx-jumbo N ]
>                 [ tx N ]

Wireless devices have ring buffers, no?

>         ethtool -k|--show-offload DEVNAME       Get protocol offload
>                 information
>         ethtool -K|--offload DEVNAME    Set protocol offload
>                 [ rx on|off ]
>                 [ tx on|off ]
>                 [ sg on|off ]
>                 [ tso on|off ]
>                 [ ufo on|off ]
>                 [ gso on|off ]
>                 [ gro on|off ]
>                 [ lro on|off ]

Again, if wireless devices become performance-oriented...

>         ethtool -r|--negotiate DEVNAME  Restart N-WAY negotation

Ethernet-specific...might could be overloaded for wireless to trigger
reassoc...?

>         ethtool -n|--show-nfc DEVNAME   Show Rx network flow
>                 classificationoptions
>                 [ rx-flow-hash
>                 tcp4|udp4|ah4|sctp4|tcp6|udp6|ah6|sctp6 ]
>         ethtool -N|--config-nfc DEVNAME Configure Rx network flow
>                 classification options
>                 [ rx-flow-hash tcp4|udp4|ah4|sctp4|tcp6|udp6|ah6|sctp6
>                 m|v|t|s|d|f|n|r... ]

Long-shot, but no reason it couldn't be used in wireless... :-)

Anyway, it doesn't really matter if we don't use the whole API -- many
older ethernet devices don't support all these features.  The point
is that the API exists and has some overlap with our needs.  It is a
driver-oriented API, with nitty-gritty stuff that need not clutter a
configuraiton API like cfg80211.  There is even the potential of us
adding our own extensions (e.g. WoW) that are also device-oriented.

Anyway, between the link detection and making distro scripts work
plus enabling a familiar tool for basic driver info I think this is
a win.  So much the better if some drivers move to ethtool for register
dumping, setting message verbosity, querying/changing eeprom values,
etc, etc...

John

P.S.  The aforementioned path for userland ethtool...(theorhetical,
not even compiled...)

>From aa92d32ac1cca57bdd3439013b0c7777bdf1217c Mon Sep 17 00:00:00 2001
From: John W. Linville <linville@tuxdriver.com>
Date: Thu, 1 Oct 2009 11:01:32 -0400
Subject: [PATCH] add support for at76c50x-usb driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 Makefile.am    |    2 +-
 at76c50x-usb.c |   32 ++++++++++++++++++++++++++++++++
 ethtool.c      |    1 +
 3 files changed, 34 insertions(+), 1 deletions(-)
 create mode 100644 at76c50x-usb.c

diff --git a/Makefile.am b/Makefile.am
index eac65fe..a384949 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,7 +8,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
-		  smsc911x.c
+		  smsc911x.c at76c50x-usb.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/at76c50x-usb.c b/at76c50x-usb.c
new file mode 100644
index 0000000..295d1cb
--- /dev/null
+++ b/at76c50x-usb.c
@@ -0,0 +1,32 @@
+#include <stdio.h>
+#include "ethtool-util.h"
+
+static char hw_versions[] = {
+        "503_ISL3861",
+        "503_ISL3863",
+        "        503",
+        "    503_ACC",
+        "        505",
+        "   505_2958",
+        "       505A",
+        "     505AMX",
+};
+
+int
+at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u8 version = (u8)(regs->version >> 24);
+	u8 rev_id = (u8)(regs->version);
+	char *ver_string;
+
+	if(version != 0)
+		return -1;
+
+	ver_string = hw_versions[rev_id];
+	fprintf(stdout,
+		"Hardware Version                    %s\n",
+		ver_string);
+
+	return 0;
+}
+
diff --git a/ethtool.c b/ethtool.c
index 0110682..7608750 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1189,6 +1189,7 @@ static struct {
 	{ "sky2", sky2_dump_regs },
         { "vioc", vioc_dump_regs },
         { "smsc911x", smsc911x_dump_regs },
+        { "at76c50x-usb", at76c50x_usb_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
-- 
1.6.2.5
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
