From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 0/7] Stacked vlan TSO
Date: Thu, 26 Mar 2015 14:01:13 +0900
Message-ID: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>, Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On the basis of Netdev 0.1 discussion[1], I made a patch set to enable
TSO for packets with multiple vlans.

Currently, packets with multiple vlans are always segmented by software,
which is caused by that netif_skb_features() drops most feature flags
for multiple tagged packets.

To allow NICs to segment them, we need to get rid of that check from core.
Fortunately, recently introduced ndo_features_check() can be used to
move the check to each driver, and this patch set is based on the idea.

For the initial patch set, I chose 3 drivers, bonding, team, and igb, as
candidates to enable TSO. I tested them and confirmed they works fine
with this change.

Here are samples of performance test results. As I expected, %sys gets
pretty lower than before.

* TEST1: vlan (.1Q) on vlan (.1ad) on igb (I350)

- before

$ netperf -t TCP_STREAM -H 192.168.10.1 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.02     933.72

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.13      0.00     11.28      0.01      0.00     88.58

- after

$ netperf -t TCP_STREAM -H 192.168.10.1 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.01     936.13

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.24      0.00      4.17      0.01      0.00     95.58


* TEST2: vlan (.1Q) on bridge (.1ad vlan filtering) on team on igb (I350)

- before

$ netperf -t TCP_STREAM -H 192.168.10.1 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.01     936.28

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.41      0.00     11.57      0.01      0.00     88.01

- after

$ netperf -t TCP_STREAM -H 192.168.10.1 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.02     935.72

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.14      0.00      7.66      0.01      0.00     92.19


In addition to above, I tested these configurations:
- vlan (.1Q) on vlan (1.ad) on bonding on igb (I350)
- vlan (.1Q) on vlan (1.Q) on igb (I350)
- vlan (.1Q) on vlan (1.Q) on team on igb (I350)
And didn't find any problem.


[1] https://netdev01.org/sessions/18
    https://netdev01.org/docs/netdev01_bof_8021ad_makita_150212.pdf

Toshiaki Makita (7):
  vlan: Add features for stacked vlan device
  vlan: Introduce helper functions to check if skb is tagged
  net: Move check for multiple vlans to drivers
  net: Introduce passthru_features_check
  bonding: Don't segment multiple tagged packets on bonding device
  team: Don't segment multiple tagged packets on team device
  igb: Enable TSO for stacked vlan

 drivers/net/bonding/bond_main.c                  |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  1 +
 drivers/net/ethernet/intel/igb/igb_main.c        |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  1 +
 drivers/net/team/team.c                          |  1 +
 include/linux/if_vlan.h                          | 67 ++++++++++++++++++++++++
 include/linux/netdevice.h                        |  3 ++
 net/8021q/vlan_dev.c                             |  1 +
 net/core/dev.c                                   | 41 +++++++--------
 10 files changed, 96 insertions(+), 22 deletions(-)

-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
