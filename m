From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 0/6] net device rx busy polling support in vhost_net
Date: Thu, 31 Mar 2016 13:50:33 +0800
Message-ID: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series try to add net device rx busy polling support in
vhost_net. This is done through:

- adding socket rx busy polling support for tun/macvtap by marking
  napi_id.
- vhost_net will try to find the net device through napi_id and do
  busy polling if possible.

TCP_RR tests on two mlx4s show some improvements:

smp=1 queue=1
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +4%/   +3%/   +3%/   +3%/  +22%
    1/    50/   +2%/   +2%/   +2%/   +2%/    0%
    1/   100/   +1%/    0%/   +1%/   +1%/   -1%
    1/   200/   +2%/   +1%/   +2%/   +2%/    0%
   64/     1/   +1%/   +3%/   +1%/   +1%/   +1%
   64/    50/    0%/    0%/    0%/    0%/   -1%
   64/   100/   +1%/    0%/   +1%/   +1%/    0%
   64/   200/    0%/    0%/   +2%/   +2%/    0%
  256/     1/   +2%/   +2%/   +2%/   +2%/   +2%
  256/    50/   +3%/   +3%/   +3%/   +3%/    0%
  256/   100/   +1%/   +1%/   +2%/   +2%/    0%
  256/   200/    0%/    0%/   +1%/   +1%/   +1%
 1024/     1/   +2%/   +2%/   +2%/   +2%/   +2%
 1024/    50/   -1%/   -1%/   -1%/   -1%/   -2%
 1024/   100/   +1%/   +1%/    0%/    0%/   -1%
 1024/   200/   +2%/   +1%/   +2%/   +2%/    0%

smp=8 queue=1
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +1%/   -5%/   +1%/   +1%/    0%
    1/    50/   +1%/    0%/   +1%/   +1%/   -1%
    1/   100/   -1%/   -1%/   -2%/   -2%/   -4%
    1/   200/    0%/    0%/    0%/    0%/   -1%
   64/     1/   -2%/  -10%/   -2%/   -2%/   -2%
   64/    50/   -1%/   -1%/   -1%/   -1%/   -2%
   64/   100/   -1%/    0%/    0%/    0%/   -1%
   64/   200/   -1%/   -1%/    0%/    0%/    0%
  256/     1/   +7%/  +25%/   +7%/   +7%/   +7%
  256/    50/   +2%/   +2%/   +2%/   +2%/   -1%
  256/   100/   -1%/   -1%/   -1%/   -1%/   -3%
  256/   200/   +1%/    0%/    0%/    0%/    0%
 1024/     1/   +5%/  +15%/   +5%/   +5%/   +4%
 1024/    50/    0%/    0%/   -1%/   -1%/   -1%
 1024/   100/   -1%/   -1%/   -1%/   -1%/   -2%
 1024/   200/   -1%/    0%/   -1%/   -1%/   -1%

smp=8 queue=8
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +5%/   +2%/   +5%/   +5%/    0%
    1/    50/   +2%/   +2%/   +3%/   +3%/  -20%
    1/   100/   +5%/   +5%/   +5%/   +5%/  -13%
    1/   200/   +8%/   +8%/   +6%/   +6%/  -12%
   64/     1/    0%/   +4%/    0%/    0%/  +18%
   64/    50/   +6%/   +5%/   +5%/   +5%/   -7%
   64/   100/   +4%/   +4%/   +5%/   +5%/  -12%
   64/   200/   +5%/   +5%/   +5%/   +5%/  -12%
  256/     1/    0%/   -3%/    0%/    0%/   +1%
  256/    50/   +3%/   +3%/   +3%/   +3%/   -2%
  256/   100/   +6%/   +5%/   +5%/   +5%/  -11%
  256/   200/   +4%/   +4%/   +4%/   +4%/  -13%
 1024/     1/    0%/   -3%/    0%/    0%/   -6%
 1024/    50/   +1%/   +1%/   +1%/   +1%/  -10%
 1024/   100/   +4%/   +4%/   +5%/   +5%/  -11%
 1024/   200/   +4%/   +5%/   +4%/   +4%/  -12%

Thanks

Jason Wang (6):
  net: skbuff: don't use union for napi_id and sender_cpu
  tuntap: socket rx busy polling support
  macvtap: socket rx busy polling support
  net: core: factor out core busy polling logic to sk_busy_loop_once()
  net: export napi_by_id()
  vhost_net: net device rx busy polling support

 drivers/net/macvtap.c   |  4 ++++
 drivers/net/tun.c       |  3 ++-
 drivers/vhost/net.c     | 22 ++++++++++++++++--
 include/linux/skbuff.h  | 10 ++++----
 include/net/busy_poll.h |  8 +++++++
 net/core/dev.c          | 62 ++++++++++++++++++++++++++++---------------------
 6 files changed, 75 insertions(+), 34 deletions(-)

-- 
2.5.0
