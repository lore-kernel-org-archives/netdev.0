From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 0/3] basic busy polling support for vhost_net
Date: Fri, 26 Feb 2016 16:42:41 +0800
Message-ID: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, RAPOPORT@il.ibm.com
To: kvm@vger.kernel.org, mst@redhat.com,
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

This series tries to add basic busy polling for vhost net. The idea is
simple: at the end of tx/rx processing, busy polling for new tx added
descriptor and rx receive socket for a while. The maximum number of
time (in us) could be spent on busy polling was specified ioctl.

Test A were done through:

- 50 us as busy loop timeout
- Netperf 2.6
- Two machines with back to back connected mlx4
- Guest with 8 vcpus and 1 queue

Results:
- TCP_RR was imporved obviously (at most 27%). And cpu utilizaton was
  also improved in this case.
- No obvious differences in Guest RX throughput.
- Guest TX throughput was also improved.

TCP_RR:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/  +27%/    0%/  +27%/  +27%/  +25%
    1/    50/   +2%/   +1%/   +2%/   +2%/   -4%
    1/   100/   +2%/   +1%/   +3%/   +3%/  -14%
    1/   200/   +2%/   +2%/   +5%/   +5%/  -15%
   64/     1/  +20%/  -13%/  +20%/  +20%/  +20%
   64/    50/  +17%/  +14%/  +16%/  +16%/  -11%
   64/   100/  +14%/  +12%/  +14%/  +14%/  -35%
   64/   200/  +16%/  +15%/   +9%/   +9%/  -28%
  256/     1/  +19%/   -6%/  +19%/  +19%/  +18%
  256/    50/  +18%/  +15%/  +16%/  +16%/   +3%
  256/   100/  +11%/   +9%/  +12%/  +12%/   -1%
  256/   200/   +5%/   +8%/   +4%/   +4%/  +64%
  512/     1/  +20%/    0%/  +20%/  +20%/   -2%
  512/    50/  +12%/  +10%/  +12%/  +12%/   +8%
  512/   100/  +11%/   +7%/  +10%/  +10%/   -5%
  512/   200/   +3%/   +2%/   +3%/   +3%/   -5%
 1024/     1/  +19%/   -2%/  +19%/  +19%/  +18%
 1024/    50/  +13%/  +10%/  +12%/  +12%/    0%
 1024/   100/   +9%/   +8%/   +8%/   +8%/  -16%
 1024/   200/   +3%/   +4%/   +3%/   +3%/  -14%
 Guest RX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/  -12%/  -10%/   +2%/   +1%/  +42%
   64/     4/   -3%/   -5%/   +2%/   -1%/    0%
   64/     8/   -1%/   -5%/   -1%/   -2%/    0%
  512/     1/   +5%/  -13%/   +6%/   +9%/  +17%
  512/     4/   -3%/   -9%/   +6%/   +4%/  -14%
  512/     8/   -2%/   -7%/    0%/    0%/   -1%
 1024/     1/  +18%/  +31%/  -12%/  -11%/  -31%
 1024/     4/    0%/   -9%/   -1%/   -6%/   -7%
 1024/     8/   -3%/   -8%/   -2%/   -4%/    0%
 2048/     1/    0%/   -1%/    0%/   -4%/   +5%
 2048/     4/    0%/   +2%/    0%/    0%/    0%
 2048/     8/    0%/   -6%/    0%/   -3%/   -1%
 4096/     1/   -1%/   +2%/  -14%/   -5%/   +8%
 4096/     4/    0%/   +1%/    0%/   +1%/   -1%
 4096/     8/   -1%/   -1%/   -2%/   -2%/   -3%
16384/     1/    0%/    0%/   +4%/   +5%/    0%
16384/     4/    0%/   +5%/   +7%/   +9%/    0%
16384/     8/   +1%/   +1%/   +3%/   +3%/   +2%
65535/     1/    0%/  +12%/   -1%/   +2%/   -2%
65535/     4/    0%/    0%/   -2%/   -2%/   +2%
65535/     8/   -1%/   -1%/   -4%/   -4%/    0%
Guest TX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/  -16%/  -21%/   -2%/  -12%/   +1%
   64/     4/   -6%/   -2%/   -1%/   +6%/   -7%
   64/     8/   +4%/   +4%/   -2%/   +1%/  +30%
  512/     1/  -32%/  -33%/  -11%/  +62%/ +314%
  512/     4/  +30%/  +20%/  -22%/  -17%/  -14%
  512/     8/  +24%/  +12%/  -21%/  -10%/   -6%
 1024/     1/   +1%/   -7%/   +2%/  +51%/  +75%
 1024/     4/  +10%/   +9%/  -11%/  -19%/  -10%
 1024/     8/  +13%/   +7%/  -11%/  -13%/  -12%
 2048/     1/  +17%/    0%/   +1%/  +35%/  +78%
 2048/     4/  +15%/  +14%/  -17%/  -24%/  -15%
 2048/     8/  +11%/   +9%/  -15%/  -20%/  -12%
 4096/     1/   +3%/   -7%/    0%/  +21%/  +48%
 4096/     4/   +3%/   +4%/   -9%/  -19%/  +41%
 4096/     8/  +15%/  +13%/  -33%/  -28%/  -15%
16384/     1/   +5%/   -8%/   -4%/  -10%/ +323%
16384/     4/  +13%/   +5%/  -15%/  -11%/ +147%
16384/     8/   +8%/   +6%/  -25%/  -27%/  -31%
65535/     1/   +8%/    0%/   +5%/    0%/  +45%
65535/     4/  +10%/   +1%/   +7%/   -8%/ +151%
65535/     8/   +5%/    0%/   +1%/  -16%/  -29%

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
size /-+% /
1 /-5.55%/
64 /+1.11%/
256 /+2.33%/
512 /-0.03%/
1024 /+1.14%/
4096 /+0.00%/
16384/+0.00%/

Guest RX:
size /-+% /
1 /-5.11%/
64 /-0.55%/
256 /-2.35%/
512 /-3.39%/
1024 /+6.8% /
4096 /-0.01%/
16384/+0.00%/

TCP_RR:
size /-+% /
1 /+9.79% /
64 /+4.51% /
256 /+6.47% /
512 /-3.37% /
1024 /+6.15% /
4096 /+14.88%/
16384/-2.23% /

Changes from V2:
- rename vhost_vq_more_avail() to vhost_vq_avail_empty(). And return
  false we __get_user() fails.
- do not bother premmptions/timers for good path.
- use vhost_vring_state as ioctl parameter instead of reinveting a new
  one.
- add the unit of timeout (us) to the comment of new added ioctls

Changes from V1:
- remove the buggy vq_error() in vhost_vq_more_avail().
- leave vhost_enable_notify() untouched.

Changes from RFC V3:
- small tweak on the code to avoid multiple duplicate conditions in
  critical path when busy loop is not enabled.
- add the test result of multiple VMs

Changes from RFC V2:
- poll also at the end of rx handling
- factor out the polling logic and optimize the code a little bit
- add two ioctls to get and set the busy poll timeout
- test on ixgbe (which can give more stable and reproducable numbers)
  instead of mlx4.

Changes from RFC V1:
- add a comment for vhost_has_work() to explain why it could be
  lockless
- add param description for busyloop_timeout
- split out the busy polling logic into a new helper
- check and exit the loop when there's a pending signal
- disable preemption during busy looping to make sure lock_clock() was
  correctly used.

Jason Wang (3):
  vhost: introduce vhost_has_work()
  vhost: introduce vhost_vq_avail_empty()
  vhost_net: basic polling support

 drivers/vhost/net.c        | 79 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/vhost/vhost.c      | 35 ++++++++++++++++++++
 drivers/vhost/vhost.h      |  3 ++
 include/uapi/linux/vhost.h |  6 ++++
 4 files changed, 118 insertions(+), 5 deletions(-)

-- 
2.5.0
