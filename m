From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16187] New: Carrier detection failed in dhcpcd
 when link is up
Date: Mon, 21 Jun 2010 14:21:38 -0700
Message-ID: <20100621142138.3416b5d0.akpm@linux-foundation.org>
References: <bug-16187-10286@https.bugzilla.kernel.org/>
	<20100615142418.f47e8abd.akpm@linux-foundation.org>
	<20100618061641.GA7039@lackof.org>
	<8DD2590731AB5D4C9DBF71A877482A900158F12BEA@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"casteyde.christian@free.fr" <casteyde.christian@free.fr>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48833 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758444Ab0FUVWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 17:22:47 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A900158F12BEA@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Jun 2010 08:04:36 -0700
"Allan, Bruce W" <bruce.w.allan@intel.com> wrote:

> On Thursday, June 17, 2010 11:17 PM, Grant Grundler wrote:
> > On Tue, Jun 15, 2010 at 02:24:18PM -0700, Andrew Morton wrote:
> >> 
> >> (switched to email.  Please respond via emailed reply-to-all, not
> >> via the bugzilla web interface).
> > 
> > I've resync to linus' tree (2.6.35-rc3) and reviewed the output of:
> >     git diff v2.6.34 drivers/net/tulip/
> > 
> > I don't see anything that would affect how link state
> > changes get reported to user space.
> > 
> > I'm not inclined to believe this is a tulip "bug" unless
> > core netdev behavior changed and tulip is not longer
> > doing the right thing.
> > 
> > hth,
> > grant
> 
> I don't believe this is a tulip specific bug - the same thing has been reported against e1000e and bnx2 (IIRC); I have not had the time to investigate further.

So it's affecting three drivers.

One thing which changed in there recently is

: commit b2db756449f63f98049587f7ede4a8e85e0c79b1
: Author:     YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
: AuthorDate: Sat Mar 20 16:11:12 2010 -0700
: Commit:     David S. Miller <davem@davemloft.net>
: CommitDate: Sat Mar 20 16:11:12 2010 -0700
:
:    ipv6: Reduce timer events for addrconf_verify().

So perhaps someone could test the simple reversion patch, below?

I couldn't locate these e1000e and bnx2 bug reports so I couldn't cc
the reporters :(

I'm seeing several patches on netdev "use netif_carrier_off to prevent
tx timeout".  Is that related?


 net/ipv6/addrconf.c |   27 ++++-----------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

diff -puN net/ipv6/addrconf.c~revert-2 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c~revert-2
+++ a/net/ipv6/addrconf.c
@@ -100,10 +100,6 @@
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 #define TIME_DELTA(a, b) ((unsigned long)((long)(a) - (long)(b)))
 
-#define ADDRCONF_TIMER_FUZZ_MINUS	(HZ > 50 ? HZ/50 : 1)
-#define ADDRCONF_TIMER_FUZZ		(HZ / 4)
-#define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
-
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
@@ -3159,15 +3155,15 @@ int ipv6_chk_home_addr(struct net *net, 
 
 static void addrconf_verify(unsigned long foo)
 {
-	unsigned long now, next, next_sec, next_sched;
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
+	unsigned long now, next;
 	int i;
 
 	rcu_read_lock_bh();
 	spin_lock(&addrconf_verify_lock);
 	now = jiffies;
-	next = round_jiffies_up(now + ADDR_CHECK_FREQUENCY);
+	next = now + ADDR_CHECK_FREQUENCY;
 
 	del_timer(&addr_chk_timer);
 
@@ -3181,8 +3177,7 @@ restart:
 				continue;
 
 			spin_lock(&ifp->lock);
-			/* We try to batch several events at once. */
-			age = (now - ifp->tstamp + ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
+			age = (now - ifp->tstamp) / HZ;
 
 			if (ifp->valid_lft != INFINITY_LIFE_TIME &&
 			    age >= ifp->valid_lft) {
@@ -3252,21 +3247,7 @@ restart:
 		}
 	}
 
-	next_sec = round_jiffies_up(next);
-	next_sched = next;
-
-	/* If rounded timeout is accurate enough, accept it. */
-	if (time_before(next_sec, next + ADDRCONF_TIMER_FUZZ))
-		next_sched = next_sec;
-
-	/* And minimum interval is ADDRCONF_TIMER_FUZZ_MAX. */
-	if (time_before(next_sched, jiffies + ADDRCONF_TIMER_FUZZ_MAX))
-		next_sched = jiffies + ADDRCONF_TIMER_FUZZ_MAX;
-
-	ADBG((KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
-	      now, next, next_sec, next_sched));
-
-	addr_chk_timer.expires = next_sched;
+	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
 	add_timer(&addr_chk_timer);
 	spin_unlock(&addrconf_verify_lock);
 	rcu_read_unlock_bh();
_

