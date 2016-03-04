From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 0/3] basic busy polling support for vhost_net
Date: Fri,  4 Mar 2016 06:24:50 -0500
Message-ID: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, borntraeger@de.ibm.com, RAPOPORT@il.ibm.com
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

This series tries to add basic busy polling for vhost net. The idea is
simple: at the end of tx/rx processing, busy polling for new tx added
descriptor and rx receive socket for a while. The maximum number of
time (in us) could be spent on busy polling was specified ioctl.

Test A were done through:

- 50 us as busy loop timeout
- Netperf 2.6
- Two machines with back to back connected mlx4
- Guest with 1 vcpus and 1 queue

Results:
- Obvious improvements (%5 - 20%) for latency (TCP_RR).
- Get a better or minor regression on most of the TX tests, but see
  some regression on 4096 size.
- Except for 8 sessions of 4096 size RX, have a better or same
  performance.
- CPU utilization were incrased as expected.

TCP_RR:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +8%/  -32%/   +8%/   +8%/   +7%
    1/    50/   +7%/  -19%/   +7%/   +7%/   +1%
    1/   100/   +5%/  -21%/   +5%/   +5%/    0%
    1/   200/   +5%/  -21%/   +7%/   +7%/   +1%
   64/     1/  +11%/  -29%/  +11%/  +11%/  +10%
   64/    50/   +7%/  -19%/   +8%/   +8%/   +2%
   64/   100/   +8%/  -18%/   +9%/   +9%/   +2%
   64/   200/   +6%/  -19%/   +6%/   +6%/    0%
  256/     1/   +7%/  -33%/   +7%/   +7%/   +6%
  256/    50/   +7%/  -18%/   +7%/   +7%/    0%
  256/   100/   +9%/  -18%/   +8%/   +8%/   +2%
  256/   200/   +9%/  -18%/  +10%/  +10%/   +3%
 1024/     1/  +20%/  -28%/  +20%/  +20%/  +19%
 1024/    50/   +8%/  -18%/   +9%/   +9%/   +2%
 1024/   100/   +6%/  -19%/   +5%/   +5%/    0%
 1024/   200/   +8%/  -18%/   +9%/   +9%/   +2%
Guest TX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/   -5%/  -28%/  +11%/  +12%/  +10%
   64/     4/   -2%/  -26%/  +13%/  +13%/  +13%
   64/     8/   -6%/  -29%/   +9%/  +10%/  +10%
  512/     1/  +15%/   -7%/  +13%/  +11%/   +3%
  512/     4/  +17%/   -6%/  +18%/  +13%/  +11%
  512/     8/  +14%/   -7%/  +13%/   +7%/   +7%
 1024/     1/  +27%/   -2%/  +26%/  +29%/  +12%
 1024/     4/   +8%/   -9%/   +6%/   +1%/   +6%
 1024/     8/  +41%/  +12%/  +34%/  +20%/   -3%
 4096/     1/  -22%/  -21%/  -36%/  +81%/+1360%
 4096/     4/  -57%/  -58%/ +286%/  +15%/+2074%
 4096/     8/  +67%/  +70%/  -45%/   -8%/  +63%
16384/     1/   -2%/   -5%/   +5%/   -3%/  +80%
16384/     4/    0%/    0%/    0%/   +4%/ +138%
16384/     8/    0%/    0%/    0%/   +1%/  +41%
65535/     1/   -3%/   -6%/   +2%/  +11%/ +113%
65535/     4/   -2%/   -1%/   -2%/   -3%/ +484%
65535/     8/    0%/   +1%/    0%/   +2%/  +40%
Guest RX:
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
   64/     1/  +31%/   -3%/   +8%/   +8%/   +8%
   64/     4/  +11%/  -17%/  +13%/  +14%/  +15%
   64/     8/   +4%/  -23%/  +11%/  +11%/  +12%
  512/     1/  +24%/    0%/  +18%/  +14%/   -8%
  512/     4/   +4%/  -15%/   +6%/   +5%/   +6%
  512/     8/  +26%/    0%/  +21%/  +10%/   +3%
 1024/     1/  +88%/  +47%/  +69%/  +44%/  -30%
 1024/     4/  +18%/   -5%/  +19%/  +16%/   +2%
 1024/     8/  +15%/   -4%/  +13%/   +8%/   +1%
 4096/     1/   -3%/   -5%/   +2%/   -2%/  +41%
 4096/     4/   +2%/   +3%/  -20%/  -14%/  -24%
 4096/     8/  -43%/  -45%/  +69%/  -24%/  +94%
16384/     1/   -3%/  -11%/  +23%/   +7%/  +42%
16384/     4/   -3%/   -3%/   -4%/   +5%/ +115%
16384/     8/   -1%/    0%/   -1%/   -3%/  +32%
65535/     1/   +1%/    0%/   +2%/    0%/  +66%
65535/     4/   -1%/   -1%/    0%/   +4%/ +492%
65535/     8/    0%/   -1%/   -1%/   +4%/  +38%

Changes from V3:
- drop single_task_running()
- use cpu_relax_lowlatency() instead of cpu_relax()

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

 drivers/vhost/net.c        | 78 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/vhost/vhost.c      | 35 +++++++++++++++++++++
 drivers/vhost/vhost.h      |  3 ++
 include/uapi/linux/vhost.h |  6 ++++
 4 files changed, 117 insertions(+), 5 deletions(-)

-- 
1.8.3.1
