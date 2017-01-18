From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V5 0/3] vhost_net tx batching
Date: Wed, 18 Jan 2017 15:02:00 +0800
Message-ID: <1484722923-7698-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wexu@redhat.com, stefanha@redhat.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
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

Hi:

This series tries to implement tx batching support for vhost. This was
done by using MSG_MORE as a hint for under layer socket. The backend
(e.g tap) can then batch the packets temporarily in a list and
submit it all once the number of bacthed exceeds a limitation.

Tests shows obvious improvement on guest pktgen over over
mlx4(noqueue) on host:

                                     Mpps  -+%
        rx-frames = 0                0.91  +0%
        rx-frames = 4                1.00  +9.8%
        rx-frames = 8                1.00  +9.8%
        rx-frames = 16               1.01  +10.9%
        rx-frames = 32               1.07  +17.5%
        rx-frames = 48               1.07  +17.5%
        rx-frames = 64               1.08  +18.6%
        rx-frames = 64 (no MSG_MORE) 0.91  +0%

Changes from V4:
- stick to NAPI_POLL_WEIGHT for rx-frames is user specify a value
  greater than it.
Changes from V3:
- use ethtool instead of module parameter to control the maximum
  number of batched packets
- avoid overhead when MSG_MORE were not set and no packet queued
Changes from V2:
- remove uselss queue limitation check (and we don't drop any packet now)
Changes from V1:
- drop NAPI handler since we don't use NAPI now
- fix the issues that may exceeds max pending of zerocopy
- more improvement on available buffer detection
- move the limitation of batched pacekts from vhost to tuntap

Please review.

Thanks

Jason Wang (3):
  vhost: better detection of available buffers
  vhost_net: tx batching
  tun: rx batching

 drivers/net/tun.c     | 76 +++++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/net.c   | 23 ++++++++++++++--
 drivers/vhost/vhost.c |  8 ++++--
 3 files changed, 96 insertions(+), 11 deletions(-)

-- 
2.7.4
