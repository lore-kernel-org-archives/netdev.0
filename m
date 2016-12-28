From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 0/3] vhost net tx batching
Date: Wed, 28 Dec 2016 16:09:28 +0800
Message-ID: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
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

Hi:

This series tries to implement tx batching support for vhost. This was
done by using MSG_MORE as a hint for under layer socket. The backend
(e.g tap) can then batch the packets temporarily in a list and
submit it all once the number of bacthed exceeds a limitation.

Tests shows obvious improvement on guest pktgen over over
mlx4(noqueue) on host:

                    Mpps  -+%
        rx_batched=0  0.90  +0%
        rx_batched=4  0.97  +7.8%
        rx_batched=8  0.97  +7.8%
        rx_batched=16 0.98  +8.9%
        rx_batched=32 1.03  +14.4%
        rx_batched=48 1.09  +21.1%
        rx_batched=64 1.02  +13.3%

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

 drivers/net/tun.c     | 66 ++++++++++++++++++++++++++++++++++++++++++++-------
 drivers/vhost/net.c   | 23 +++++++++++++++---
 drivers/vhost/vhost.c |  8 +++++--
 3 files changed, 84 insertions(+), 13 deletions(-)

-- 
2.7.4
