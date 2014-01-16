From: <srinivas.kandagatla@st.com>
Subject: [PATCH v2 0/9] net: stmmac PM related fixes.
Date: Thu, 16 Jan 2014 10:48:41 +0000
Message-ID: <1389869321-27411-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	<linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Hi Peppe/Dave,

During PM_SUSPEND_FREEZE testing, I have noticed that PM support in STMMAC is
partly broken. I had to re-arrange the code to do PM correctly. There were lot
of things I did not like personally and some bits did not work in the first
place. I thought this is the nice opportunity to clean the mess up.

Here is what I did:
 any
1> Test PM suspend freeze via pm_test
It did not work for following reasons.
 - If the power to gmac is removed when it enters in low power state.
stmmac_resume could not cope up with such behaviour, it was expecting the ip
register contents to be still same as before entering low power, This
assumption is wrong. So I started to add some code to do Hardware
initialization, thats when I started to re-arrange the code. stmmac_open
contains both resource and memory allocations and hardware initialization. I
had to separate these two things in two different functions.

These two patches do that
  net: stmmac: move dma allocation to new function
  net: stmmac: move hardware setup for stmmac_open to new function

And rest of the other patches are fixing the loose ends, things like mdio
reset, which might be necessary in cases likes hibernation(I did not test).

In hibernation cases the driver was just unregistering with subsystems and
releasing resources which I did not like and its not necessary to do this as
part of PM. So using the same stmmac_suspend/resume made more sense for
hibernation cases than using stmmac_open/release.
Also fixed a NULL pointer dereference bug too.

2> Test WOL via PM_SUSPEND_FREEZE
Did get an wakeup interrupt, but could not wakeup a freeze system.
So I had to add pm_wakeup_event to the driver.
net: stmmac: notify the PM core of a wakeup event. patch.

Also few patches like 
  net: stmmac: make stmmac_mdio_reset non-static
  net: stmmac: restore pinstate in pm resume.
helps the resume function to reset the phy and put back the pins in default
state.

Changes since RFC:
	- Rebased to net-next on Dave's suggestion.

All these patches are Acked by Peppe.

Thanks,
srini

Srinivas Kandagatla (9):
  net: stmmac: support max-speed device tree property
  net: stmmac: mdio: remove reset gpio free
  net: stmmac: move dma allocation to new function
  net: stmmac: move hardware setup for stmmac_open to new function
  net: stmmac: make stmmac_mdio_reset non-static
  net: stmmac: fix power management suspend-resume case
  net: stmmac: use suspend functions for hibernation
  net: stmmac: restore pinstate in pm resume.
  net: stmmac: notify the PM core of a wakeup event.

 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  361 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   48 +--
 include/linux/stmmac.h                             |    1 +
 5 files changed, 209 insertions(+), 208 deletions(-)

-- 
1.7.6.5
