From: Ingo Molnar <mingo@elte.hu>
Subject: [bisected] Re: [bug] networking broke, ssh: connect to port 22:
	Protocol error
Date: Wed, 6 Feb 2008 14:35:06 +0100
Message-ID: <20080206133506.GA21202@elte.hu>
References: <20080206113829.GA14793@elte.hu> <20080206.034243.243568099.davem@davemloft.net> <20080206122248.GA5233@elte.hu> <20080206.043246.63923682.davem@davemloft.net> <20080206131129.GB9950@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57700 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762293AbYBFNfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 08:35:30 -0500
Content-Disposition: inline
In-Reply-To: <20080206131129.GB9950@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> yeah, although various other upstream breakages prevented real long 
> randconfig series in the past 2-3 days. I'd say it's either in this 
> pull from your tree:

ok, i have bisected it down but the result made no sense, so i 
double-checked it and noticed that the .config mutated during the test.

the diff below is the diff between the 'good' and 'bad' .config, with 
this notable detail:

 @@ -2336,7 +2350,7 @@ CONFIG_SECURITY_NETWORK=y
  CONFIG_SECURITY_CAPABILITIES=y
  # CONFIG_SECURITY_FILE_CAPABILITIES is not set
  # CONFIG_SECURITY_ROOTPLUG is not set
 -# CONFIG_SECURITY_SMACK is not set
 +CONFIG_SECURITY_SMACK=y
  CONFIG_XOR_BLOCKS=m
  CONFIG_ASYNC_CORE=m
  CONFIG_ASYNC_MEMCPY=m

so i disabled CONFIG_SECURITY_SMACK, and viola, just 2 hours of hard 
work later networking works on my testbox again :-/

And we have this 1 day old commit:

  commit e114e473771c848c3cfec05f0123e70f1cdbdc99
  Author: Casey Schaufler <casey@schaufler-ca.com>
  Date:   Mon Feb 4 22:29:50 2008 -0800

      Smack: Simplified Mandatory Access Control Kernel

that adds SMACK.

So unlike some other security modules like SELINUX, enabling SMACK 
breaks un-aware userspace and breaks TCP networking?

I dont think that's expected behavior - and i'd definitely like to 
enable SMACK in automated tests to check for regressions, etc.

	Ingo

--- .config.good	2008-02-06 14:13:35.000000000 +0100
+++ .config.bad	2008-02-06 14:17:28.000000000 +0100
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
 # Linux kernel version: 2.6.24
-# Wed Feb  6 14:11:27 2008
+# Wed Feb  6 14:15:22 2008
 #
 # CONFIG_64BIT is not set
 CONFIG_X86_32=y
@@ -94,15 +94,16 @@ CONFIG_FUTEX=y
 CONFIG_ANON_INODES=y
 # CONFIG_EPOLL is not set
 CONFIG_SIGNALFD=y
-CONFIG_TIMERFD=y
+# CONFIG_TIMERFD is not set
 CONFIG_EVENTFD=y
 # CONFIG_SHMEM is not set
 # CONFIG_VM_EVENT_COUNTERS is not set
 # CONFIG_SLAB is not set
 # CONFIG_SLUB is not set
 CONFIG_SLOB=y
-# CONFIG_PROFILING is not set
+CONFIG_PROFILING=y
 # CONFIG_MARKERS is not set
+CONFIG_OPROFILE=y
 CONFIG_HAVE_OPROFILE=y
 # CONFIG_KPROBES is not set
 CONFIG_HAVE_KPROBES=y
@@ -691,7 +692,7 @@ CONFIG_MAC80211_RC_DEFAULT=""
 # CONFIG_MAC80211_RC_PID is not set
 # CONFIG_MAC80211_RC_SIMPLE is not set
 # CONFIG_MAC80211_DEBUGFS is not set
-# CONFIG_MAC80211_DEBUG_PACKET_ALIGNMENT is not set
+CONFIG_MAC80211_DEBUG_PACKET_ALIGNMENT=y
 # CONFIG_MAC80211_DEBUG is not set
 CONFIG_IEEE80211=m
 # CONFIG_IEEE80211_DEBUG is not set
@@ -744,6 +745,7 @@ CONFIG_CDROM_PKTCDVD=y
 CONFIG_CDROM_PKTCDVD_BUFFERS=8
 CONFIG_CDROM_PKTCDVD_WCACHE=y
 CONFIG_ATA_OVER_ETH=y
+CONFIG_VIRTIO_BLK=y
 # CONFIG_MISC_DEVICES is not set
 # CONFIG_IDE is not set
 
@@ -796,9 +798,19 @@ CONFIG_BLK_DEV_3W_XXXX_RAID=y
 CONFIG_SCSI_3W_9XXX=m
 CONFIG_SCSI_ACARD=y
 # CONFIG_SCSI_AACRAID is not set
-# CONFIG_SCSI_AIC7XXX is not set
-# CONFIG_SCSI_AIC7XXX_OLD is not set
-# CONFIG_SCSI_AIC79XX is not set
+CONFIG_SCSI_AIC7XXX=y
+CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
+CONFIG_AIC7XXX_RESET_DELAY_MS=5000
+# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
+CONFIG_AIC7XXX_DEBUG_MASK=0
+# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
+CONFIG_SCSI_AIC7XXX_OLD=m
+CONFIG_SCSI_AIC79XX=y
+CONFIG_AIC79XX_CMDS_PER_DEVICE=32
+CONFIG_AIC79XX_RESET_DELAY_MS=5000
+CONFIG_AIC79XX_DEBUG_ENABLE=y
+CONFIG_AIC79XX_DEBUG_MASK=0
+# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
 CONFIG_SCSI_AIC94XX=m
 # CONFIG_AIC94XX_DEBUG is not set
 CONFIG_SCSI_DPT_I2O=m
@@ -1181,6 +1193,7 @@ CONFIG_NETCONSOLE=y
 CONFIG_NETPOLL=y
 # CONFIG_NETPOLL_TRAP is not set
 CONFIG_NET_POLL_CONTROLLER=y
+# CONFIG_VIRTIO_NET is not set
 CONFIG_ISDN=y
 # CONFIG_ISDN_I4L is not set
 # CONFIG_ISDN_CAPI is not set
@@ -2043,7 +2056,8 @@ CONFIG_INFINIBAND_AMSO1100=m
 CONFIG_INFINIBAND_AMSO1100_DEBUG=y
 # CONFIG_INFINIBAND_CXGB3 is not set
 CONFIG_MLX4_INFINIBAND=m
-# CONFIG_INFINIBAND_NES is not set
+CONFIG_INFINIBAND_NES=m
+CONFIG_INFINIBAND_NES_DEBUG=y
 CONFIG_INFINIBAND_IPOIB=m
 CONFIG_INFINIBAND_IPOIB_CM=y
 CONFIG_INFINIBAND_IPOIB_DEBUG=y
@@ -2336,7 +2350,7 @@ CONFIG_SECURITY_NETWORK=y
 CONFIG_SECURITY_CAPABILITIES=y
 # CONFIG_SECURITY_FILE_CAPABILITIES is not set
 # CONFIG_SECURITY_ROOTPLUG is not set
-# CONFIG_SECURITY_SMACK is not set
+CONFIG_SECURITY_SMACK=y
 CONFIG_XOR_BLOCKS=m
 CONFIG_ASYNC_CORE=m
 CONFIG_ASYNC_MEMCPY=m
@@ -2396,7 +2410,9 @@ CONFIG_CRYPTO_AUTHENC=y
 # CONFIG_CRYPTO_HW is not set
 CONFIG_VIRTUALIZATION=y
 # CONFIG_LGUEST is not set
-# CONFIG_VIRTIO_PCI is not set
+CONFIG_VIRTIO=y
+CONFIG_VIRTIO_RING=y
+CONFIG_VIRTIO_PCI=y
 # CONFIG_VIRTIO_BALLOON is not set
 
 #

