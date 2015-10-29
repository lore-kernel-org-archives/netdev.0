From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next rfc V2 0/2] basic busy polling support for vhost_net
Date: Thu, 29 Oct 2015 04:45:24 -0400
Message-ID: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to add basic busy polling for vhost net. The idea is
simple: at the end of tx processing, busy polling for new tx added
descriptor and rx receive socket for a while. The maximum number of
time (in us) could be spent on busy polling was specified through
module parameter.

Test were done through:

- 50 us as busy loop timeout
- Netperf 2.6
- Two machines with back to back connected mlx4
- Guest with 8 vcpus and 1 queue

Result shows very huge improvement on both tx (at most 158%) and rr
(at most 53%) while rx is as much as in the past. Most cases the cpu
utilization is also improved:

Guest TX:
size/session/+thu%/+normalize%
   64/     1/  +17%/   +6%
   64/     4/   +9%/  +17%
   64/     8/  +34%/  +21%
  512/     1/  +48%/  +40%
  512/     4/  +31%/  +20%
  512/     8/  +39%/  +22%
 1024/     1/ +158%/  +99%
 1024/     4/  +20%/  +11%
 1024/     8/  +40%/  +18%
 2048/     1/ +108%/  +74%
 2048/     4/  +21%/   +7%
 2048/     8/  +32%/  +14%
 4096/     1/  +94%/  +77%
 4096/     4/   +7%/   -6%
 4096/     8/   +9%/   -4%
16384/     1/  +33%/   +9%
16384/     4/  +10%/   -6%
16384/     8/  +19%/   +2%
65535/     1/  +15%/   -6%
65535/     4/   +8%/   -9%
65535/     8/  +14%/    0%

Guest RX:
size/session/+thu%/+normalize%
   64/     1/   -3%/   -3%
   64/     4/   +4%/  +20%
   64/     8/   -1%/   -1%
  512/     1/  +20%/  +12%
  512/     4/   +1%/   +3%
  512/     8/    0%/   -5%
 1024/     1/   +9%/   -2%
 1024/     4/    0%/   +5%
 1024/     8/   +1%/    0%
 2048/     1/    0%/   +3%
 2048/     4/   -2%/   +3%
 2048/     8/   -1%/   -3%
 4096/     1/   -8%/   +3%
 4096/     4/    0%/   +2%
 4096/     8/    0%/   +5%
16384/     1/   +3%/    0%
16384/     4/   +2%/   +2%
16384/     8/    0%/  +13%
65535/     1/    0%/   +3%
65535/     4/   +2%/   -1%
65535/     8/   +1%/  +14%

TCP_RR:
size/session/+thu%/+normalize%
    1/     1/   +8%/   -6%
    1/    50/  +18%/  +15%
    1/   100/  +22%/  +19%
    1/   200/  +25%/  +23%
   64/     1/   +2%/  -19%
   64/    50/  +46%/  +39%
   64/   100/  +47%/  +39%
   64/   200/  +50%/  +44%
  512/     1/    0%/  -28%
  512/    50/  +50%/  +44%
  512/   100/  +53%/  +47%
  512/   200/  +51%/  +58%
 1024/     1/   +3%/  -14%
 1024/    50/  +45%/  +37%
 1024/   100/  +53%/  +49%
 1024/   200/  +48%/  +55%

Changes from V1:
- Add a comment for vhost_has_work() to explain why it could be
  lockless
- Add param description for busyloop_timeout
- Split out the busy polling logic into a new helper
- Check and exit the loop when there's a pending signal
- Disable preemption during busy looping to make sure lock_clock() was
  correctly used.

Todo:
- Make the busyloop timeout could be configure per VM through ioctl.

Please review.

Thanks

Jason Wang (2):
  vhost: introduce vhost_has_work()
  vhost_net: basic polling support

 drivers/vhost/net.c   | 54 +++++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/vhost.c |  7 +++++++
 drivers/vhost/vhost.h |  1 +
 3 files changed, 58 insertions(+), 4 deletions(-)

-- 
1.8.3.1
