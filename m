From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH v3 0/4] e1000e msi-x fixes
Date: Mon,  9 Nov 2015 15:50:17 -0800
Message-ID: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

For this series:


Benjamin Poirier (4):
  e1000e: Remove unreachable code
  e1000e: Do not read icr in Other interrupt
  e1000e: Do not write lsc to ics in msi-x mode
  e1000e: Fix msi-x interrupt automask

 drivers/net/ethernet/intel/e1000e/defines.h |  3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 66 ++++++++++++-----------------
 2 files changed, 30 insertions(+), 39 deletions(-)

Changes in v3:
Preserve LSC in IMS, LSC events are not delivered otherwise.
Disable CTRL_EXT.IAME to prevent IMC write on ICR read from external
program.

Changes in v2:
Address review comments from Alexander Duyck: extend cleanup of Other
interrupt handler and use tx_ring->ims_val.


The first three patches cleanup handling of Other interrupts and the
last patch fixes tx and rx interrupts. Please consider reading the
description for that patch before proceeding. I believe that the
following simple tracing statements are helpful in detecting the problem
fixed by the last patch.

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a09d1e4..29b8c6e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1942,6 +1942,9 @@ static irqreturn_t e1000_intr_msix_rx(int __always_unused irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_hw *hw = &adapter->hw;
+
+	trace_printk("%s: rxq0 irq ims 0x%08x\n", netdev->name, er32(IMS));
 
 	/* Write the ITR value calculated at the end of the
 	 * previous interrupt.
@@ -1956,6 +1959,7 @@ static irqreturn_t e1000_intr_msix_rx(int __always_unused irq, void *data)
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
 		__napi_schedule(&adapter->napi);
+		trace_printk("%s: scheduling napi\n", netdev->name);
 	}
 	return IRQ_HANDLED;
 }
@@ -2663,6 +2667,8 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
 	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 1, work_done = 0;
 
+	trace_printk("%s: poll starting ims 0x%08x\n", poll_dev->name,
+		     er32(IMS));
 	adapter = netdev_priv(poll_dev);
 
 	if (!adapter->msix_entries ||
@@ -2680,6 +2686,8 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
 			e1000_set_itr(adapter);
 		napi_complete_done(napi, work_done);
 		if (!test_bit(__E1000_DOWN, &adapter->state)) {
+			trace_printk("%s: will enable rxq0 irq\n",
+				     poll_dev->name);
 			if (adapter->msix_entries)
 				ew32(IMS, adapter->rx_ring->ims_val);
 			else

-------- 8< --------

With that patch but without the patches in this series we can see that rx irqs
occur at unexpected times:

          <idle>-0     [000] .Ns.  1986.887517: e1000e_poll: eth1: will enable rxq0 irq
          <idle>-0     [000] d.h.  1986.896654: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01500004
          <idle>-0     [000] d.h.  1986.896657: e1000_intr_msix_rx: eth1: scheduling napi
          <idle>-0     [000] d.H.  1986.896662: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01500004
          <idle>-0     [000] ..s.  1986.896667: e1000e_poll: eth1: poll starting ims 0x01500004
Warning: many interrupts (2) before napi
          <idle>-0     [000] ..s.  1986.896685: e1000e_poll: eth1: will enable rxq0 irq

          <idle>-0     [000] d.h.  1990.688870: e1000_intr_msix_rx: eth1: scheduling napi
          <idle>-0     [000] ..s.  1990.688875: e1000e_poll: eth1: poll starting ims 0x01500004
          <idle>-0     [000] dNH.  1990.688913: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01500004
Warning: interrupt inside napi
          <idle>-0     [000] .Ns.  1990.688916: e1000e_poll: eth1: will enable rxq0 irq
          <idle>-0     [000] d.h.  1990.729688: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01500004

Here's a typical sequence after applying the patches in this series. Notice
that ims is changed. Another printk at the end of e1000e_poll would show it to
be 0x01500004.

          <idle>-0     [000] d.h. 23547.977917: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01400004
          <idle>-0     [000] d.h. 23547.977922: e1000_intr_msix_rx: eth1: scheduling napi
          <idle>-0     [000] ..s. 23547.977928: e1000e_poll: eth1: poll starting ims 0x01400004
          <idle>-0     [000] ..s. 23547.977961: e1000e_poll: eth1: will enable rxq0 irq

Finally, here's the script I used to generate the warnings above:

#!/usr/bin/python3

import sys
import re
import pprint


class NaE(Exception):
    "Not an Event"
    pass

class Event:
    def __init__(self, line):
        # sample events:
        #  <idle>-0     [000] d.h.  2025.256536: e1000_intr_msix_rx: eth1: rxq0 irq ims 0x01500004
        #  <idle>-0     [000] d.h.  2025.256539: e1000_intr_msix_rx: eth1: scheduling napi
        #  <idle>-0     [000] ..s.  2025.256544: e1000e_poll: eth1: poll starting ims 0x01500004
        #  <idle>-0     [000] ..s.  2025.256558: e1000e_poll: eth1: will enable rxq0 irq
        retval = re.match(" +<?(?P<comm>.*)>?-(?P<pid>[0-9]+) +\[(?P<cpu>.*)\] (?P<flags>[^ ]+) +(?P<time>[0-9.]+): (?P<funcname>[^:]+): (?P<ifname>[^:]+): (?P<args>.*)", line)
        if retval:
            self.comm = retval.group("comm")
            self.pid = retval.group("pid")
            self.cpu = retval.group("cpu")
            self.flags = retval.group("flags")
            self.time = retval.group("time")
            self.funcname = retval.group("funcname")
            self.ifname = retval.group("ifname")
            self.args = retval.group("args")
        else:
            raise NaE


class Machine:
    pass

class State:
    def __init__(self, machine):
        self.machine = machine

    def entry(self, event):
        pass

    def transition(self, event):
        "self.machine should be considered read-only in transition"
        return State(self.machine)

    def run(self, event):
        pass

    def exit(self, event):
        pass

    def advance(self, event):
            nextState = self.transition(event)
            if (nextState != self):
                self.exit(event)
                nextState.entry(event)
            nextState.run(event)
            return nextState

# general receive processing machine
def enteringNapi(machine, event):
    if event.args.startswith("poll starting"):
        return True
    else:
        return False

def exitingNapi(machine, event):
    if event.args.startswith("will enable"):
        return True
    else:
        return False

class OutsideNapi(State):
    def entry(self, event):
        self.machine.intr = []

    def transition(self, event):
        if enteringNapi(self.machine, event):
            return InsideNapi(self.machine)
        else:
            return self

    def run(self, event):
        if event.args.startswith("rxq0 irq"):
            self.machine.intr.append(event)

    def exit(self, event):
        if len(self.machine.intr) > 1:
            print("Warning: many interrupts (%d) before napi at %s" % (
                len(self.machine.intr), event.time,))

class InsideNapi(State):
    def transition(self, event):
        if exitingNapi(self.machine, event):
            return OutsideNapi(self.machine)
        else:
            return self

    def run(self, event):
        if event.args.startswith("rxq0 irq"):
            print("Warning: interrupt inside napi")

class UnknownState(State):
    def transition(self, event):
        if enteringNapi(self.machine, event):
            return InsideNapi(self.machine)
        elif exitingNapi(self.machine, event):
            return ExitingNapi(self.machine)
        else:
            return self


if __name__ == '__main__':
    debug = False

    state = UnknownState(Machine())

    for line in sys.stdin:
        print(line, end='')
        try:
            event = Event(line)
        except NaE:
            pass
        else:
            if debug:
                pprinter.pprint(event)
            state = state.advance(event)

-- 
2.6.2
