From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 5/5] e1000e: Avoid receiver overrun
        interrupt bursts
Date: Fri, 15 Sep 2017 00:38:22 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6A05EC@ORSMSX101.amr.corp.intel.com>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-5-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
To: Benjamin Poirier <bpoirier@suse.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721183627.13373-5-bpoirier@suse.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of Benjamin Poirier
> Sent: Friday, July 21, 2017 11:36 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Subject: [Intel-wired-lan] [PATCH 5/5] e1000e: Avoid receiver overrun
> interrupt bursts
> 
> When e1000e_poll() is not fast enough to keep up with incoming traffic, the
> adapter (when operating in msix mode) raises the Other interrupt to signal
> Receiver Overrun.
> 
> This is a double problem because 1) at the moment e1000_msix_other()
> assumes that it is only called in case of Link Status Change and 2) if the
> condition persists, the interrupt is repeatedly raised again in quick
> succession.
> 
> Ideally we would configure the Other interrupt to not be raised in case of
> receiver overrun but this doesn't seem possible on this adapter. Instead,
> we handle the first part of the problem by reverting to the practice of
> reading ICR in the other interrupt handler, like before commit 16ecba59bc33
> ("e1000e: Do not read ICR in Other interrupt"). Thanks to commit
> 0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask") which cleared IAME
> from CTRL_EXT, reading ICR doesn't interfere with RxQ0, TxQ0 interrupts
> anymore. We handle the second part of the problem by not re-enabling the
> Other interrupt right away when there is overrun. Instead, we wait until
> traffic subsides, napi polling mode is exited and interrupts are
> re-enabled.
> 
> Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Fixes: 16ecba59bc33 ("e1000e: Do not read ICR in Other interrupt")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---
>  drivers/net/ethernet/intel/e1000e/defines.h |  1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c  | 33
> +++++++++++++++++++++++------
>  2 files changed, 27 insertions(+), 7 deletions(-)
> 

I get an error and a few warnings out of checkpatch from this, but I think the error is false (thinking the reference to a commit in the description is this commit, a fixes commit or something like that) and I'm more concerned with the fix than the warnings, so...

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Here is the checkpatch output in case anyone has a different opinion on the severity:
-------------
u1484:[0]/usr/src/kernels/next-queue> git format-patch d81d1e6 -1 --stdout|./scripts/checkpatch.pl -
ERROR: Please use git commit description style 'commit <12+ chars of sha1> ("<title line>")' - ie: 'commit 0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask")'
#20:
0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask") which cleared IAME

WARNING: braces {} are not necessary for single statement blocks
#73: FILE: drivers/net/ethernet/intel/e1000e/netdev.c:1931:
+               if (!test_bit(__E1000_DOWN, &adapter->state)) {
+                       mod_timer(&adapter->watchdog_timer, jiffies + 1);
+               }

WARNING: braces {} are not necessary for single statement blocks
#83: FILE: drivers/net/ethernet/intel/e1000e/netdev.c:1936:
+       if (enable && !test_bit(__E1000_DOWN, &adapter->state)) {
                ew32(IMS, E1000_IMS_OTHER);
        }

total: 1 errors, 2 warnings, 0 checks, 59 lines checked

NOTE: For some of the reported defects, checkpatch may be able to
      mechanically convert to the typical style using --fix or --fix-inplace.

Your patch has style problems, please review.

NOTE: If any of the errors are false positives, please report
      them to the maintainer, see CHECKPATCH in MAINTAINERS.
u1484:[0]/usr/src/kernels/next-queue>
