From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Wed, 26 Jul 2017 11:05:57 +0200
Message-ID: <CAK8P3a3UBfg6=GJ5UKEENnN-qoFuxaO4yo2Lqy65gN0zP4Nw-w@mail.gmail.com>
References: <20170725153046.44726-1-arnd@arndb.de> <20170725153046.44726-2-arnd@arndb.de>
 <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Deepak Khungar <deepak.khungar@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2017 at 6:36 PM, Michael Chan <michael.chan@broadcom.com> wrote:
> On Tue, Jul 25, 2017 at 8:29 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> The sriov_lock is used to serialize the sriov code with the vfr code.
>> However, when SRIOV is disabled, the lock is not there at all, leading
>> to a build error:
>>
>> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c: In function 'bnxt_dl_eswitch_mode_set':
>> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:410:16: error: 'struct bnxt' has no member named 'sriov_lock'
>>
>> We can either provide the mutex in this configuration, too, or
>> disable both SRIOV and VFR together. This implements the first
>> approach, since it seems like a reasonable configuration for
>> guest kernels to have, and the extra lock will be harmless when
>> there is no contention.
>>
>> Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> Sathya already sent 3 patches to fix some of these issues.  But I need
> to rework one of his patch and resend.

Ok, thanks. I just ran into one more issue, and don't know if that's included
as well. If not, please also add the patch below (or fold it into the one
that adds the switchdev dependency to the ethernet driver):

8<----------
Subject: [PATCH] RDMA/bnxt_re: add NET_SWITCHDEV dependency

The rdma side of BNXT enables the ethernet driver and has a list
of its dependencies. However, the ethernet driver now also depends
on NET_SWITCHDEV, so we have to add that dependency for both:

warning: (INFINIBAND_BNXT_RE) selects BNXT which has unmet direct
dependencies (NETDEVICES && ETHERNET && NET_VENDOR_BROADCOM && PCI &&
MAY_USE_DEVLINK && NET_SWITCHDEV)

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/infiniband/hw/bnxt_re/Kconfig
b/drivers/infiniband/hw/bnxt_re/Kconfig
index 19982a4a9bba..0c296f00e74f 100644
--- a/drivers/infiniband/hw/bnxt_re/Kconfig
+++ b/drivers/infiniband/hw/bnxt_re/Kconfig
@@ -1,6 +1,7 @@
 config INFINIBAND_BNXT_RE
     tristate "Broadcom Netxtreme HCA support"
     depends on ETHERNET && NETDEVICES && PCI && INET && DCB
+    depends on NET_SWITCHDEV
     select NET_VENDOR_BROADCOM
     select BNXT
     ---help---
