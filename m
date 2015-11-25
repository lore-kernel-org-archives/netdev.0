From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 0/3] basic busy polling support for vhost_net
Date: Wed, 25 Nov 2015 15:11:26 +0800
Message-ID: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to add basic busy polling for vhost net. The idea is
simple: at the end of tx/rx processing, busy polling for new tx added
descriptor and rx receive socket for a while. The maximum number of
time (in us) could be spent on busy polling was specified ioctl.

Test A were done through:

- 50 us as busy loop timeout
- Netperf 2.6
- Two machines with back to back connected ixgbe
- Guest with 1 vcpu and 1 queue

Results:
- For stream workload, ioexits were reduced dramatically in medium
  size (1024-2048) of tx (at most -43%) and almost all rx (at most
  -84%) as a result of polling. This compensate for the possible
  wasted cpu cycles more or less. That porbably why we can still see
  some increasing in the normalized throughput in some cases.
- Throughput of tx were increased (at most 50%) expect for the huge
  write (16384). And we can send more packets in the case (+tpkts were
  increased).
- Very minor rx regression in some cases.
- Improvemnt on TCP_RR (at most 17%).

Guest TX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/  +18%/  -10%/   +7%/  +11%/    0%
   64/     2/  +14%/  -13%/   +7%/  +10%/    0%
   64/     4/   +8%/  -17%/   +7%/   +9%/    0%
   64/     8/  +11%/  -15%/   +7%/  +10%/    0%
  256/     1/  +35%/   +9%/  +21%/  +12%/  -11%
  256/     2/  +26%/   +2%/  +20%/   +9%/  -10%
  256/     4/  +23%/    0%/  +21%/  +10%/   -9%
  256/     8/  +23%/    0%/  +21%/   +9%/   -9%
  512/     1/  +31%/   +9%/  +23%/  +18%/  -12%
  512/     2/  +30%/   +8%/  +24%/  +15%/  -10%
  512/     4/  +26%/   +5%/  +24%/  +14%/  -11%
  512/     8/  +32%/   +9%/  +23%/  +15%/  -11%
 1024/     1/  +39%/  +16%/  +29%/  +22%/  -26%
 1024/     2/  +35%/  +14%/  +30%/  +21%/  -22%
 1024/     4/  +34%/  +13%/  +32%/  +21%/  -25%
 1024/     8/  +36%/  +14%/  +32%/  +19%/  -26%
 2048/     1/  +50%/  +27%/  +34%/  +26%/  -42%
 2048/     2/  +43%/  +21%/  +36%/  +25%/  -43%
 2048/     4/  +41%/  +20%/  +37%/  +27%/  -43%
 2048/     8/  +40%/  +18%/  +35%/  +25%/  -42%
16384/     1/    0%/  -12%/   -1%/   +8%/  +15%
16384/     2/    0%/  -10%/   +1%/   +4%/   +5%
16384/     4/    0%/  -11%/   -3%/    0%/   +3%
16384/     8/    0%/  -10%/   -4%/    0%/   +1%

Guest RX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/   -2%/  -21%/   +1%/   +2%/  -75%
   64/     2/   +1%/   -9%/  +12%/    0%/  -55%
   64/     4/    0%/   -6%/   +5%/   -1%/  -44%
   64/     8/   -5%/   -5%/   +7%/  -23%/  -50%
  256/     1/   -8%/  -18%/  +16%/  +15%/  -63%
  256/     2/    0%/   -8%/   +9%/   -2%/  -26%
  256/     4/    0%/   -7%/   -8%/  +20%/  -41%
  256/     8/   -8%/  -11%/   -9%/  -24%/  -78%
  512/     1/   -6%/  -19%/  +20%/  +18%/  -29%
  512/     2/    0%/  -10%/  -14%/   -8%/  -31%
  512/     4/   -1%/   -5%/  -11%/   -9%/  -38%
  512/     8/   -7%/   -9%/  -17%/  -22%/  -81%
 1024/     1/    0%/  -16%/  +12%/   +9%/  -11%
 1024/     2/    0%/  -11%/    0%/   +3%/  -30%
 1024/     4/    0%/   -4%/   +2%/   +6%/  -15%
 1024/     8/   -3%/   -4%/   -8%/   -8%/  -70%
 2048/     1/   -8%/  -23%/  +36%/  +22%/  -11%
 2048/     2/    0%/  -12%/   +1%/   +3%/  -29%
 2048/     4/    0%/   -3%/  -17%/  -15%/  -84%
 2048/     8/    0%/   -3%/   +1%/   -3%/  +10%
16384/     1/    0%/  -11%/   +4%/   +7%/  -22%
16384/     2/    0%/   -7%/   +4%/   +4%/  -33%
16384/     4/    0%/   -2%/   -2%/   -4%/  -23%
16384/     8/   -1%/   -2%/   +1%/  -22%/  -40%

TCP_RR:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/  +11%/  -26%/  +11%/  +11%/  +10%
    1/    25/  +11%/  -15%/  +11%/  +11%/    0%
    1/    50/   +9%/  -16%/  +10%/  +10%/    0%
    1/   100/   +9%/  -15%/   +9%/   +9%/    0%
   64/     1/  +11%/  -31%/  +11%/  +11%/  +11%
   64/    25/  +12%/  -14%/  +12%/  +12%/    0%
   64/    50/  +11%/  -14%/  +12%/  +12%/    0%
   64/   100/  +11%/  -15%/  +11%/  +11%/    0%
  256/     1/  +11%/  -27%/  +11%/  +11%/  +10%
  256/    25/  +17%/  -11%/  +16%/  +16%/   -1%
  256/    50/  +16%/  -11%/  +17%/  +17%/   +1%
  256/   100/  +17%/  -11%/  +18%/  +18%/   +1%

Test B were done through:

- 50us as busy loop timeout
- Netperf 2.6
- Two machines with back to back connected ixgbe
- Two guests each wich 1 vcpu and 1 queue
- pin two vhost threads to the same cpu on host to simulate the cpu
  contending

Results:
- In this radical case, we can still get at most 14% improvement on
  TCP_RR.
- For guest tx stream, minor improvemnt with at most 5% regression in
  one byte case. For guest rx stream, at most 5% regression were seen.

Guest TX:
size /-+%   /
1    /-5.55%/
64   /+1.11%/
256  /+2.33%/
512  /-0.03%/
1024 /+1.14%/
4096 /+0.00%/
16384/+0.00%/

Guest RX:
size /-+%   /
1    /-5.11%/
64   /-0.55%/
256  /-2.35%/
512  /-3.39%/
1024 /+6.8% /
4096 /-0.01%/
16384/+0.00%/

TCP_RR:
size /-+%    /
1    /+9.79% /
64   /+4.51% /
256  /+6.47% /
512  /-3.37% /
1024 /+6.15% /
4096 /+14.88%/
16384/-2.23% /

Changes from RFC V3:
- small tweak on the code to avoid multiple duplicate conditions in
  critical path when busy loop is not enabled.
- Add the test result of multiple VMs

Changes from RFC V2:
- poll also at the end of rx handling
- factor out the polling logic and optimize the code a little bit
- add two ioctls to get and set the busy poll timeout
- test on ixgbe (which can give more stable and reproducable numbers)
  instead of mlx4.

Changes from RFC V1:
- Add a comment for vhost_has_work() to explain why it could be
  lockless
- Add param description for busyloop_timeout
- Split out the busy polling logic into a new helper
- Check and exit the loop when there's a pending signal
- Disable preemption during busy looping to make sure lock_clock() was
  correctly used.

Jason Wang (3):
  vhost: introduce vhost_has_work()
  vhost: introduce vhost_vq_more_avail()
  vhost_net: basic polling support

 drivers/vhost/net.c        | 72 ++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/vhost.c      | 48 +++++++++++++++++++++++++------
 drivers/vhost/vhost.h      |  3 ++
 include/uapi/linux/vhost.h | 11 +++++++
 4 files changed, 120 insertions(+), 14 deletions(-)

-- 
2.5.0
