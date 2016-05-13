From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 0/6] hv_netvsc: avoid races on mtu change/set
 channels
Date: Fri, 13 May 2016 13:55:19 +0200
Message-ID: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Changes since v1:
- Rebased to net-next [Haiyang Zhang]

Original description:

MTU change and set channels operations are implemented as netvsc device
re-creation destroying internal structures (struct net_device stays). This
is really unfortunate but there is no support from Hyper-V host to do it
in a different way. Such re-creation is unsurprisingly racy, Haiyang
reported a crash when netvsc_change_mtu() is racing with
netvsc_link_change() but I was able to identify additional races upon
investigation. Both netvsc_set_channels() and netvsc_change_mtu() race
against:
1) netvsc_link_change()
2) netvsc_remove()
3) netvsc_send()

To solve these issues without introducing new locks some refactoring is
required. We need to get rid of very complex link graph in all the
internal structures and avoid traveling through structures which are being
removed.

Vitaly Kuznetsov (6):
  hv_netvsc: move start_remove flag to net_device_context
  hv_netvsc: use start_remove flag to protect netvsc_link_change()
  hv_netvsc: untangle the pointer mess
  hv_netvsc: get rid of struct net_device pointer in struct
    netvsc_device
  hv_netvsc: synchronize netvsc_change_mtu()/netvsc_set_channels() with
    netvsc_remove()
  hv_netvsc: set nvdev link after populating chn_table

 drivers/net/hyperv/hyperv_net.h   |  17 ++--
 drivers/net/hyperv/netvsc.c       | 136 +++++++++++++----------------
 drivers/net/hyperv/netvsc_drv.c   | 178 ++++++++++++++++++++++----------------
 drivers/net/hyperv/rndis_filter.c |  82 +++++++++---------
 4 files changed, 215 insertions(+), 198 deletions(-)

-- 
2.5.5
