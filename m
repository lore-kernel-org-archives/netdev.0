From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/4] r8152: fix scheduling napi
Date: Wed, 25 Jan 2017 10:50:50 +0800
Message-ID: <1394712342-15778-236-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scheduling the napi during the following periods would let it be ignored.
And the events wouldn't be handled until next napi_schedule() is called.

1. after napi_disable and before napi_enable().
2. after all actions of napi function is completed and before calling
   napi_complete().

If no next napi_schedule() is called, tx or rx would stop working.

In order to avoid these situations, the followings solutions are applied.

1. prevent start_xmit() from calling napi_schedule() during runtime suspend
   or after napi_disable().
2. re-schedule the napi for tx if it is necessary.
3. check if any rx is finished or not after napi_enable().

Hayes Wang (4):
  r8152: avoid start_xmit to call napi_schedule during autosuspend
  r8152: avoid start_xmit to schedule napi when napi is disabled
  r8152: re-schedule napi for tx
  r8152: check rx after napi is enabled

 drivers/net/usb/r8152.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

-- 
2.7.4
