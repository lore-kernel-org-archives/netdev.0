From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: [BUGFIX PATCH 0/2] Bugfixes for brcmfmac
Date: Mon, 15 Aug 2016 18:40:41 +0900
Message-ID: <147125403645.9434.8008546579326856373.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here are 2 patches for fixing bugs which I recently faced on my PC.

There are 2 bugs I've hit on brcmfmac, one issue was critical,
the other was just found when I investigated the first issue.

1) when I shutdown or reboot my pc with wifi, it always stopped
 when disabling networking. I tried to just disable wifi and saw
 task hung up messages on dmesg.
 All those taskes were blocked on rtnl_lock according to the
 stacktrace, and found a suspicious task in the list. Actually
 the wpa_supplicant is blocked while stopping the interface.

2) I also tried to get more information about that and enabled
 DEBUG_ATOMIC_SLEEP and got another warning in brcmfmac. That
 warned a mutex (which can yeild/sleep) is held in !TASK_RUNNING
 state. I've found a mutex is held when in wait_event_timeout()
 condition parameter.

I traced the source code and found that #1 was caused by double
locking of rtnl_lock in brcmfmac driver, because it doesn't
check the rtnl_lock is already held in a path (actually, other
paths checked that). So I fixed it by checking rtnl_locked and
skip locking rtnl_lock. It works, but not seems the best way
to fix, since original code (rtnl_lock locking around
cfg80211_unregister_wdev) itself looks add-hoc. Anyway, since
I don't have any knowladge of this subsystem, I'd like to ask
maintainer's help.

To fix #2 issue, I've checked the mutex (vif_event_lock) in
struct brcmf_cfg80211_vif_event just protect updating other
members and can be replaced by a spinlock because in the
protected regions are not involving any scheduler related
code.


Thank you,
---

Masami Hiramatsu (2):
      brcmfmac: Check rtnl_lock is locked when removing interface
      brcmfmac: Change vif_event_lock to spinlock


 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   26 ++++++++++----------
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |    8 ++++--
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.h |    2 +-
 5 files changed, 21 insertions(+), 19 deletions(-)

--
Masami Hiramatsu <mhiramat@kernel.org>
