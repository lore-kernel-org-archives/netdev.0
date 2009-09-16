From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [E1000-devel] [BUG 2.6.30+] e100 sometimes causes oops during
	resume
Date: Wed, 16 Sep 2009 03:44:48 +0200
Message-ID: <20090916014448.GA1070@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Graham, David" <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:60313 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbZIPBow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 21:44:52 -0400
Content-Disposition: inline
In-Reply-To: <13830B75AD5A2F42848F92269B11996F5BF592C3@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 03:54:20PM -0700, Graham, David wrote:

> A v2.6.30..v2.6.31 diff shows that this is probably exposed by
> Rafael Wysocki's commit 6905b1f1, which now allows systems with e100
> to sleep. If I understand correctly, it looks like these systems
> simply couldn't sleep before. Is that right Rafael?.

Probably true, but that wasn't the case for my (I guess
ACPI-controlled) system.


> I don't think its likely that the commit is a direct cause of the
> problem, but that the suspend/resume cycle now allows us to see
> another issue.

>From my (very limited) understanding commit message is at least in
conflict with patch body.

Precisely patch was supposed to "Fix this problem by ignoring the
return value of pci_set_power_state() in __e100_power_off()."

That patch is doing something rather different -- it returns 0, yes,
but it also ignores 'wake' bool as set by __e100_shutdown().  That
seems wrong to me.


--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2895,12 +2895,13 @@ static void __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 static int __e100_power_off(struct pci_dev *pdev, bool wake)
 {
-       if (wake) {
+       if (wake)
                return pci_prepare_to_sleep(pdev);
-       } else {
-               pci_wake_from_d3(pdev, false);
-               return pci_set_power_state(pdev, PCI_D3hot);
-       }
+
+       pci_wake_from_d3(pdev, false);
+       pci_set_power_state(pdev, PCI_D3hot);
+
+       return 0;
 }


Correct patch would be that (hand-made), right?


+++ b/drivers/net/e100.c
@@ -2895,12 +2895,13 @@ static void __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 static int __e100_power_off(struct pci_dev *pdev, bool wake)
 {
        if (wake) {
                return pci_prepare_to_sleep(pdev);
        } else {
                pci_wake_from_d3(pdev, false);
-               return pci_set_power_state(pdev, PCI_D3hot);
+               pci_set_power_state(pdev, PCI_D3hot);
        }
+
+       return 0;
 }

I can test, or rather -- start testing this tommorow, if this makes
sense to you.

Thanks.
