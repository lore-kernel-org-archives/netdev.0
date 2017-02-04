From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: [PATCH net-next 0/4] bridge: improve cache utilization
Date: Sat,  4 Feb 2017 18:05:05 +0100
Message-ID: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi all,
This is the first set which begins to deal with the bad bridge cache
access patterns. The first patch rearranges the bridge and port structs
a little so the frequently (and closely) accessed members are in the same
cache line. The second patch then moves the garbage collection to a
workqueue trying to improve system responsiveness under load (many fdbs)
and more importantly removes the need to check if the matched entry is
expired in __br_fdb_get which was a major source of false-sharing.
The third patch is a preparation for the final one which
If properly configured, i.e. ports bound to CPUs (thus updating "updated"
locally) then the bridge's HitM goes from 100% to 0%, but even without
binding we get a win because previously every lookup that iterated over
the hash chain caused false-sharing due to the first cache line being
used for both mac/vid and used/updated fields.

Some results from tests I've run:
(note that these were run in good conditions for the baseline, everything
 ran on a single NUMA node and there were only 3 fdbs)

1. baseline
100% Load HitM on the fdbs (between everyone who has done lookups and hit
                            one of the 3 hash chains of the communicating
                            src/dst fdbs)
Overall 5.06% Load HitM for the bridge, first place in the list

2. patched & ports bound to CPUs
0% Local load HitM, bridge is not even in the c2c report list
Also there's 3% consistent improvement in netperf tests.

Thanks,
 Nik

Nikolay Aleksandrov (4):
  bridge: modify bridge and port to have often accessed fields in one
    cache line
  bridge: move to workqueue gc
  bridge: move write-heavy fdb members in their own cache line
  bridge: fdb: write to used and updated at most once per jiffy

 net/bridge/br_device.c    |  1 +
 net/bridge/br_fdb.c       | 34 +++++++++++++++++-----------
 net/bridge/br_if.c        |  2 +-
 net/bridge/br_input.c     |  3 ++-
 net/bridge/br_ioctl.c     |  2 +-
 net/bridge/br_netlink.c   |  2 +-
 net/bridge/br_private.h   | 57 +++++++++++++++++++++++------------------------
 net/bridge/br_stp.c       |  2 +-
 net/bridge/br_stp_if.c    |  4 ++--
 net/bridge/br_stp_timer.c |  2 --
 net/bridge/br_sysfs_br.c  |  2 +-
 11 files changed, 59 insertions(+), 52 deletions(-)

-- 
2.1.4
