From: Oded Gabbay <oded.gabbay@amd.com>
Subject: [BUG] 3.19-rc1 net: less interrupt masking in NAPI
Date: Sat, 10 Jan 2015 22:39:27 +0200
Message-ID: <54B18DFF.80400@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	"Bridgman, John" <John.Bridgman@amd.com>,
	"Elifaz, Dana" <Dana.Elifaz@amd.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Commit d75b1ade567ffab085e8adbbdacf0092d10cd09c breaks my "Qualcomm Atheros
AR8161 Gigabit Ethernet (rev 10)" Ethernet controller, which is handled by
the alx network driver.

ogabbay@odedg-ubuntu:~$ lspci -s 01:00.0 -k
01:00.0 Ethernet controller:
	Qualcomm Atheros AR8161 Gigabit Ethernet (rev 10)
	Subsystem: Qualcomm Atheros Device 1071
	Kernel driver in use: alx

I have this controller on a mobile platform of AMD APU Kaveri, which I use
to test amdkfd, and from 3.19-rc1 the network stopped working when trying to
transfer files through scp or nfs.

I bisected the kernel (from 3.18.0 to 3.19-rc1) and reached this commit.

Here is the log of the bisect:

git bisect start
# bad: [97bf6af1f928216fd6c5a66e8a57bfa95a659672] Linux 3.19-rc1
git bisect bad 97bf6af1f928216fd6c5a66e8a57bfa95a659672

# good: [b2776bf7149bddd1f4161f14f79520f17fc1d71d] Linux 3.18
git bisect good b2776bf7149bddd1f4161f14f79520f17fc1d71d

# bad: [70e71ca0af244f48a5dcf56dc435243792e3a495] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect bad 70e71ca0af244f48a5dcf56dc435243792e3a495

# good: [e28870f9b3e92cd3570925089c6bb789c2603bc4] Merge tag
'backlight-for-linus-3.19' of
git://git.kernel.org/pub/scm/linux/kernel/git/lee/backlight
git bisect good e28870f9b3e92cd3570925089c6bb789c2603bc4

# bad: [450fa21942fe2c37f0c9f52d1a33bbc081eee288] sh_eth: Remove redundant
alignment adjustment
git bisect bad 450fa21942fe2c37f0c9f52d1a33bbc081eee288

# bad: [5c8d19da950861d0482abc0ac3481acca34b008f] e100e: use
netdev_rss_key_fill() helper
git bisect bad 5c8d19da950861d0482abc0ac3481acca34b008f

# good: [bf515fb11ab539c76d04f0e3c5216ed41f41d81f] Merge tag
'mac80211-next-for-john-2014-11-04' of
git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next
git bisect good bf515fb11ab539c76d04f0e3c5216ed41f41d81f

# bad: [2c99cd914d4fed9160d98849c9dd38034616768e] Merge branch 'amd-xgbe-next'
git bisect bad 2c99cd914d4fed9160d98849c9dd38034616768e

# good: [3d762a0f0ab9cb4a6b5993db3ce56c92f9f90ab2] net: dsa: Add support for
reading switch registers with ethtool
git bisect good 3d762a0f0ab9cb4a6b5993db3ce56c92f9f90ab2

# bad: [8ce0c8254f15229aa99fc6c04141f28c446e5f8c] Merge branch 'master' of
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
git bisect bad 8ce0c8254f15229aa99fc6c04141f28c446e5f8c

# good: [f0c65567b3c1b23f79e8a49139580a3872a68d1f] Merge branch
'sunvnet-multi-tx-queue'
git bisect good f0c65567b3c1b23f79e8a49139580a3872a68d1f

# bad: [547f2735c20023d7b50a791b1b17cacb652e9237] Merge branch 'mlx4-next'
git bisect bad 547f2735c20023d7b50a791b1b17cacb652e9237

# good: [4cdb1e2e3d3495423db558d3bb7ed11d66aabce7] net: shrink struct
softnet_data
git bisect good 4cdb1e2e3d3495423db558d3bb7ed11d66aabce7

# bad: [0a98455666ec87378148a1dde97f1ce5baf75a64] net/mlx4_core: Protect
port type setting by mutex
git bisect bad 0a98455666ec87378148a1dde97f1ce5baf75a64

# bad: [6e8066999800d90d52af5c84ac49ebf683d14cdc] net/mlx4_core: Prevent VF
from changing port configuration
git bisect bad 6e8066999800d90d52af5c84ac49ebf683d14cdc

# bad: [d75b1ade567ffab085e8adbbdacf0092d10cd09c] net: less interrupt
masking in NAPI
git bisect bad d75b1ade567ffab085e8adbbdacf0092d10cd09c

# first bad commit: [d75b1ade567ffab085e8adbbdacf0092d10cd09c]
net: less interrupt masking in NAPI

Could you please solve this issue as it renders my board quite useless.

If you need more info, please ask.

Thanks,
	Oded
