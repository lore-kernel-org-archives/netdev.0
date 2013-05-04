From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: ixgbe: RTNL assertion failed
Date: Sat, 4 May 2013 21:05:05 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866464C28E2AE@ORSMSX110.amr.corp.intel.com>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
 <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
 <20130504015406.GP2619@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36078 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603Ab3EDVFd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 May 2013 17:05:33 -0400
In-Reply-To: <20130504015406.GP2619@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Ben Hutchings [mailto:ben@decadent.org.uk]
> Sent: Friday, May 03, 2013 6:54 PM
> To: Skidmore, Donald C
> Cc: Stephen Hemminger; Kirsher, Jeffrey T; netdev@vger.kernel.org
> Subject: Re: ixgbe: RTNL assertion failed
> 
> On Fri, May 03, 2013 at 11:17:39PM +0000, Skidmore, Donald C wrote:
> > > -----Original Message-----
> > > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > > owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> > > Sent: Friday, May 03, 2013 12:09 PM
> > > To: Kirsher, Jeffrey T
> > > Cc: netdev@vger.kernel.org
> > > Subject: ixgbe: RTNL assertion failed
> > >
> > > Running 3.9 kernel, ixgbe is splatting on resume from suspend.
> > >
> > > [26430.213254] ixgbe 0000:01:00.0: setting latency timer to 64
> > > [26430.213257]
> > > RTNL: assertion failed at
> > > /build/buildd-linux_3.2.41-2-amd64-Wvc92F/linux-
> > > 3.2.41/net/core/dev.c (1758) [26430.213259] Pid: 7839, comm:
> > > kworker/u:1 Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 [26430.213261]
> Call Trace:
> [...]
> > I'm having a little problem finding a path were we call
> > netif_set_real_num_tx_queues without holding RTNL in net-next.  While
> > looking over the stack dump one of our engineers noticed the text "Not
> > tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 ".  Could this mean I'm
> > looking over the wrong source?  It would make me feel better as I'm
> > not seeing anything as is. :)
> 
> Indeed, this is not 3.9.
> 
> The version of ixgbe in this Debian kernel has bql support backported, but is
> otherwise the same as in 3.2.41.  I assume that this bug has been fixed some
> time between 3.2 and 3.9, but no-one requested that the fix be included in
> stable branches.  Please can you identify the fix?
> 
> Ben.
> 
> --
> Ben Hutchings
> We get into the habit of living before acquiring the habit of thinking.
>                                                               - Albert Camus

I believe this is the patch:

commit 34948a947d1a576c10afee6d14792fd237549577
Author: Benjamin Poirier <bpoirier@suse.de>
Date:   Fri Apr 6 07:20:21 2012 +0000

    ixgbe: add missing rtnl_lock in PM resume path

    Upon resume from standby, ixgbe may trigger the ASSERT_RTNL() in
    netif_set_real_num_tx_queues(). The call stack is:
        netif_set_real_num_tx_queues
        ixgbe_set_num_queues
        ixgbe_init_interrupt_scheme
        ixgbe_resume

    Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
    Tested-by: Stephen Ko <stephen.s.ko@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/i
index dac7c01..9e2be8c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4836,7 +4836,9 @@ static int ixgbe_resume(struct pci_dev *pdev)

        pci_wake_from_d3(pdev, false);

+       rtnl_lock();
        err = ixgbe_init_interrupt_scheme(adapter);
+       rtnl_unlock();
        if (err) {
                e_dev_err("Cannot initialize interrupts for device\n");
                return err;


Thanks,
-Don Skidmore <donald.c.skidmore@intel.com> 
