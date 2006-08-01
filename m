From: Karol Lewandowski <kl@jasmine.eu.org>
Subject: Re: [DSCAPE] rate_control needs some form of reference counting
Date: Tue, 1 Aug 2006 17:16:32 +0200
Message-ID: <20060801151632.GA1754@riddly.domek.prywatny>
References: <20060729215645.GE1464@riddly.domek.prywatny> <20060801161023.1e66d844@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arz222.internetdsl.tpnet.pl ([83.17.211.222]:15313 "EHLO
	riddly.domek.prywatny") by vger.kernel.org with ESMTP
	id S1751338AbWHAPQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 11:16:35 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060801161023.1e66d844@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 04:10:23PM +0200, Jiri Benc wrote:
> On Sat, 29 Jul 2006 23:56:45 +0200, Karol Lewandowski wrote:

> The fix is not easy. In fact, it's as hard as to fix it by implementing
> a feature that allows to use different rate control algorithm for each
> device. Given the fact the problem doesn't occur in normal conditions,
> it's a low priority for me (unless there is a volunteer to fix it). It
> needs to be fixed before d80211 is merged, though (sigh).

I volunteer to provide this simple fix:

--- ieee80211.c.orig	2006-08-01 16:24:41.000000000 +0200
+++ ieee80211.c	2006-08-01 16:53:01.000000000 +0200
@@ -4462,7 +4462,8 @@
 	if (result < 0)
 		goto fail_if_sysfs;
 
-	if (rate_control_initialize(local) < 0) {
+	result = rate_control_initialize(local);
+	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
 		       "algorithm\n", dev->name);
 		goto fail_rate;


Without that ieee80211_register_hw was returning value from previous
check:

>>>	result = ieee80211_sysfs_add_netdevice(dev);
	rtnl_unlock();
	if (result < 0)
		goto fail_if_sysfs;

	if (rate_control_initialize(local) < 0) {
		printk(KERN_DEBUG "%s: Failed to initialize rate control "
		       "algorithm\n", dev->name);
		goto fail_rate;
	}


This fixes that oops.  Problem remains, though.  I suppose that oops
would happen anyway if someone would do:

  # modprobe rate_control   # loads 80211
  # modprobe rt2500pci

(Driver needs to initialize cleanly here, mine has some (different)
problem so I'm just guessing here...)

 # rmmod rate_control

<oops here>, I think.
 

> I suppose you don't have automatic loading of modules enabled, right?

Yes, I've disabled it.

-- 
This signature intentionally says nothing.
