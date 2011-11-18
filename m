From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [BUG] e1000: possible deadlock scenario caught by lockdep
Date: Fri, 18 Nov 2011 15:17:04 -0800
Message-ID: <20111118151704.0000007b@unknown>
References: <1321579620.3533.29.camel@frodo>
	<20111118085737.0000387f@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111118085737.0000387f@unknown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Nov 2011 08:57:37 -0800
Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:

> CC'd netdev, and e1000-devel
> 
> On Thu, 17 Nov 2011 17:27:00 -0800
> Steven Rostedt <rostedt@goodmis.org> wrote:
> > Here you see that we are calling cancel_delayed_work_sync(&adapter->watchdog_task);
> > 
> > The problem is that adapter->watchdog_task grabs the mutex &adapter->mutex.
> > 
> > If the work has started and it blocked on that mutex, the
> > cancel_delayed_work_sync() will block indefinitely and we have a
> > deadlock.
> > 
> > Not sure what's the best way around this. Can we call e1000_down()
> > without grabbing the adapter->mutex?
> 
> Thanks for the report, I'll look at it today and see if I can work out
> a way to avoid the bonk.

this is a proposed patch to fix the issue:
if it works for you please let me know and I will submit it officially
through our process

e1000: fix lockdep splat in shutdown handler

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

as reported by Steven Rostedt, e1000 has a lockdep splat added
during the recent merge window.  The issue is that
cancel_delayed_work is called while holding our private mutex.

There is no reason that I can see to hold the mutex during pci
shutdown, it was more just paranoia that I put the mutex_lock
around the call to e1000_down.

in a quick survey lots of drivers handle locking differently when
being called by the pci layer.  The assumption here is that we
don't need the mutexes' protection in this function because
the driver could not be unloaded while in the shutdown handler
which is only called at reboot or poweroff.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ethernet/intel/e1000/e1000_main.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index cf480b5..97b46ba 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4716,8 +4716,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	netif_device_detach(netdev);
 
-	mutex_lock(&adapter->mutex);
-
 	if (netif_running(netdev)) {
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
@@ -4725,10 +4723,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
-	if (retval) {
-		mutex_unlock(&adapter->mutex);
+	if (retval)
 		return retval;
-	}
 #endif
 
 	status = er32(STATUS);
@@ -4783,8 +4779,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
 
-	mutex_unlock(&adapter->mutex);
-
 	pci_disable_device(pdev);
 
 	return 0;
