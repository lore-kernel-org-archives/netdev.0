From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: BUG: rwlock bad magic on CPU#1, NetworkManager/
Date: Thu, 14 May 2015 01:30:00 -0700
Message-ID: <20150514083000.GA9624@hudson.localdomain>
References: <20150513214939.GA4755@hudson.localdomain>
 <1431558331.6773.35.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431558331.6773.35.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan, Johannes,

On Wed, May 13, 2015 at 06:05:31PM -0500, Dan Williams wrote:
> On Wed, 2015-05-13 at 14:49 -0700, Jeremiah Mahler wrote:
> > all,
> > 
> > Running the latest linux-next (20150513) on an Acer C720 causes the
> > machine to lockup as the window manager is started.  The following BUG
> > messages and trace are found in the logs from the failed boot (full log
> > is attached).
> > 
> > May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-adsl.so
[...]
> > May 13 14:25:25 newt kernel: RIP  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
> > 
> > If I disable NetworkManager
> > 
> >   systemctl disable NetworkManager.service
> > 
> > and reboot, everything works, except networking is down.
> > 
> > So somehow NetworkManager is triggering a fault although I am not sure
> > how.  Any suggestions for what to try next are welcome.
> 
> NM is triggering the fault, but only by doing a normal operation of
> opening the netdevice.  The fault lies in the mac80211 stack's LED
> handling somewhere.
> 
> Dan
> 

Thanks for you help Dan.  I found the faulty patch.

The following commit introduces a bug (as described earlier in this
thread) which will lockup some machines when a netdevice is opened.

  From 8d5c25856859bd826aca4b88103552a80b344cef Mon Sep 17 00:00:00 2001
  From: Johannes Berg <johannes.berg@intel.com>
  Date: Thu, 23 Apr 2015 12:19:22 +0200
  Subject: [PATCH] mac80211: make LED triggering depend on activation
  
  When LED triggers are compiled in, but not used, mac80211 will still
  call them to update the status. This isn't really a problem for the
  assoc and radio ones, but the TX/RX (and to a certain extend TPT)
  ones can be called very frequently (for every packet.)
  
  In order to avoid that when they're not used, track their activation
  and call the corresponding trigger (and in the TPT case, account for
  throughput) only when the trigger is actually used by an LED.
  
  Additionally, make those trigger functions inlines since theyre only
  used once in the remaining code.
  
  Signed-off-by: Johannes Berg <johannes.berg@intel.com>
  ---
   net/mac80211/ieee80211_i.h |   7 +-
   net/mac80211/led.c         | 239 +++++++++++++++++++++++++++++----------------
   net/mac80211/led.h         |  44 ++++++---
   net/mac80211/main.c        |   4 +-
   4 files changed, 194 insertions(+), 100 deletions(-)

-- 
- Jeremiah Mahler
