From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V8 net-next 0/6] xen-net{back,
	front}: Multiple transmit and receive queues
Date: Wed, 14 May 2014 14:52:24 +0100
Message-ID: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org



This patch series implements multiple transmit and receive queues (i.e.
multiple shared rings) for the xen virtual network interfaces.

The series is split up as follows:
 - Patch 1 brings the 'grant_copy_op' array back into struct xenvif, in
   preparation for multi-queue support. See the patch itself for more details.
- Patches 2 and 4 factor out the queue-specific data for netback and
  netfront respectively, and modify the rest of the code to use these
  as appropriate.
- Patches 3 and 5 introduce new XenStore keys to negotiate and use
  multiple shared rings and event channels, and code to connect these
  as appropriate.
- Patch 6 documents the XenStore keys required for the new feature
  in include/xen/interface/io/netif.h

All other transmit and receive processing remains unchanged, i.e. there
is a kthread per queue and a NAPI context per queue.

The performance of these patches has been analysed in detail, with
results available at:

http://wiki.xenproject.org/wiki/Xen-netback_and_xen-netfront_multi-queue_performance_testing

To summarise:
  * Using multiple queues allows a VM to transmit at line rate on a 10
    Gbit/s NIC, compared with a maximum aggregate throughput of 6 Gbit/s
    with a single queue.
  * For intra-host VM--VM traffic, eight queues provide 171% of the
    throughput of a single queue; almost 12 Gbit/s instead of 6 Gbit/s.
  * There is a corresponding increase in total CPU usage, i.e. this is a
    scaling out over available resources, not an efficiency improvement.
  * Results depend on the availability of sufficient CPUs, as well as the
    distribution of interrupts and the distribution of TCP streams across
    the queues.

Queue selection is currently achieved via an L4 hash on the packet (i.e.
TCP src/dst port, IP src/dst address) and is not negotiated between the
frontend and backend, since only one option exists. Future patches to
support other frontends (particularly Windows) will need to add some
capability to negotiate not only the hash algorithm selection, but also
allow the frontend to specify some parameters to this.

Note that queue selection is a decision by the transmitting system about
which queue to use for a particular packet. In general, the algorithm
may differ between the frontend and the backend with no adverse effects.

Queue-specific XenStore entries for ring references and event channels
are stored hierarchically, i.e. under .../queue-N/... where N varies
from 0 to one less than the requested number of queues (inclusive). If
only one queue is requested, it falls back to the flat structure where
the ring references and event channels are written at the same level as
other vif information.

V8:
- Squash the queue error handling code into patch 3.
- Update the documentation (patch 6) according to comments on the
  equivalent patch to Xen.

V7:
- Rebase on latest net-next, which includes the netback grant mapping
  patch series from Zoltan Kiss
- Reduce QUEUE_NAME_SIZE by 1 to avoid double-counting the trailing '\0'
- Simplify the queue hashing by using (hash % num_queues) instead of
  multiply & shift.
- Add ratelimited warning for invalid queue selection.
- Fix error handling to correctly tear down already setup queues.
- Use dev->real_num_tx_queues instead of separately maintaining a
  count of the number of queues.

V6:
- Use 'max_queues' as the module param. name for both netback and netfront.

V5:
- Fix bug in xenvif_free() that could lead to an attempt to transmit an
  skb after the queue structures had been freed.
- Improve the XenStore protocol documentation in netif.h.
- Fix IRQ_NAME_SIZE double-accounting for null terminator.
- Move rx_gso_checksum_fixup stat into struct xenvif_stats (per-queue).
- Don't initialise a local variable that is set in both branches (xspath).

V4:
- Add MODULE_PARM_DESC() for the multi-queue parameters for netback
  and netfront modules.
- Move del_timer_sync() in netfront to after unregister_netdev, which
  restores the order in which these functions were called before applying
  these patches.

V3:
- Further indentation and style fixups.

V2:
- Rebase onto net-next.
- Change queue->number to queue->id.
- Add atomic operations around the small number of stats variables that
  are not queue-specific or per-cpu.
- Fixup formatting and style issues.
- XenStore protocol changes documented in netif.h.
- Default max. number of queues to num_online_cpus().
- Check requested number of queues does not exceed maximum.

--
Andrew J. Bennieston
