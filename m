From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: [BISECTED][REGRESSION] Loading Hyper-V network drivers is racy in
 3.14+ on Hyper-V 2012 R2
Date: Sun, 6 Jul 2014 21:18:00 +0100
Message-ID: <20140706201800.GA10587@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

With the 3.14 kernel Hyper-V no longer reliably enables its networking
devices in time on cloud images leading to network devices permanently
remaining offline.

After a painful round of bisection I've narrowed this down to commit
b679ef73edc251f6d200a7dd2396e9fef9e36fc3 :

# bad: [455c6fdbd219161bd09b1165f11699d6d73de11c] Linux 3.14
# good: [d8ec26d7f8287f5788a494f56e8814210f0e64be] Linux 3.13
git bisect start 'v3.14' 'v3.13'
# good: [82c477669a4665eb4e52030792051e0559ee2a36] Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 82c477669a4665eb4e52030792051e0559ee2a36
# bad: [ca2a650f3dfdc30d71d21bcbb04d2d057779f3f9] Merge branch 'for-linus' of git://git.infradead.org/users/vkoul/slave-dma
git bisect bad ca2a650f3dfdc30d71d21bcbb04d2d057779f3f9
# bad: [205e2210daa975d92ace485a65a31ccc4077fe1a] iwlwifi: disable TX AMPDU by default for iwldvm
git bisect bad 205e2210daa975d92ace485a65a31ccc4077fe1a
# bad: [09db30805300e9ed5ad43d4d339115cf1d9c84e1] dccp: re-enable debug macro
git bisect bad 09db30805300e9ed5ad43d4d339115cf1d9c84e1
# bad: [d9120198ddef2c0b61ca6659ace41b7c1e7c8f08] clk: shmobile: rcar-gen2: Use kick bit to allow Z clock frequency change
git bisect bad d9120198ddef2c0b61ca6659ace41b7c1e7c8f08
# bad: [1b07da516ee25250f458c76c012ebe4cd677a84f] hyperv: Move state setting for link query
git bisect bad 1b07da516ee25250f458c76c012ebe4cd677a84f
# bad: [53611c0ce9f6e2fa2e31f9ab4ad8c08c512085ba] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 53611c0ce9f6e2fa2e31f9ab4ad8c08c512085ba
# bad: [a34fe10750ebe524a39f97bd78ab4d232a554edb] parisc: locks: remove redundant arch_*_relax operations
git bisect bad a34fe10750ebe524a39f97bd78ab4d232a554edb
# bad: [004e5cf743086990e5fc04a14437b3966d7fa9a2] Merge branch 'exynos-drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/daeinki/drm-exynos into drm-fixes
git bisect bad 004e5cf743086990e5fc04a14437b3966d7fa9a2
# bad: [a4ecdf82f8ea49f7d3a072121dcbd0bf3a7cb93a] Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect bad a4ecdf82f8ea49f7d3a072121dcbd0bf3a7cb93a
# bad: [c60f7d5a8e7c639de5d9dfe07e1e91d302d506e4] Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux
git bisect bad c60f7d5a8e7c639de5d9dfe07e1e91d302d506e4
# bad: [bf21d605bf7d18d2b3cdb1c19fc1b2a1549c1f11] Merge branch 'drm-fixes-3.14' of git://people.freedesktop.org/~agd5f/linux into drm-fixes
git bisect bad bf21d605bf7d18d2b3cdb1c19fc1b2a1549c1f11
# bad: [07ae78c9798b79bad3d3adf983c94ba23fde54d4] drm/radeon/cik: stop the sdma engines in the enable() function
git bisect bad 07ae78c9798b79bad3d3adf983c94ba23fde54d4
# bad: [7848865914c6a63ead674f0f5604b77df7d3874f] drm/radeon: fix runpm disabling on non-PX harder
git bisect bad 7848865914c6a63ead674f0f5604b77df7d3874f
# bad: [e9e352e9100b98aed1a5fb9e33355c29fb07d5b1] Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/olof/chrome-platform
git bisect bad e9e352e9100b98aed1a5fb9e33355c29fb07d5b1
# good: [6e1f586d31ad49063da391db12632b31c7b00d76] qlcnic: Fix SR-IOV cleanup code path
git bisect good 6e1f586d31ad49063da391db12632b31c7b00d76
# good: [562e74fefc36eb57286455c68a60f2776659a7e1] Merge tag 'cris-for-3.14' of git://jni.nu/cris
git bisect good 562e74fefc36eb57286455c68a60f2776659a7e1
# good: [f1499382f114231cbd1e3dee7e656b50ce9d8236] Merge tag 'xfs-for-linus-v3.14-rc1-2' of git://oss.sgi.com/xfs/xfs
git bisect good f1499382f114231cbd1e3dee7e656b50ce9d8236
# good: [0e47c969c65e213421450c31043353ebe3c67e0c] Merge tag 'for-linus-20140127' of git://git.infradead.org/linux-mtd
git bisect good 0e47c969c65e213421450c31043353ebe3c67e0c
# bad: [30c867eebfbd1c25310aec9f152578deaf793080] Merge tag 'blackfin-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/realmz6/blackfin-linux
git bisect bad 30c867eebfbd1c25310aec9f152578deaf793080
# bad: [c044dc2132d19d8c643cdd340f21afcec177c046] qeth: fix build of s390 allmodconfig
git bisect bad c044dc2132d19d8c643cdd340f21afcec177c046
# bad: [d922e1cb1ea17ac7f0a5c3c2be98d4bd80d055b8] net: Document promote_secondaries
git bisect bad d922e1cb1ea17ac7f0a5c3c2be98d4bd80d055b8
# good: [f2ebd477f141bc09b10fb8deb612a4d9b8999bba] bonding: restructure locking of bond_ab_arp_probe()
git bisect good f2ebd477f141bc09b10fb8deb612a4d9b8999bba
# bad: [b679ef73edc251f6d200a7dd2396e9fef9e36fc3] hyperv: Add support for physically discontinuous receive buffer
git bisect bad b679ef73edc251f6d200a7dd2396e9fef9e36fc3
# good: [a452ce345d63ddf92cd101e4196569f8718ad319] net: Fix memory leak if TPROXY used with TCP early demux
git bisect good a452ce345d63ddf92cd101e4196569f8718ad319
# good: [731073b9c99d46c6b6c01184f67ee6f75fd7a163] sky2: initialize napi before registering device
git bisect good 731073b9c99d46c6b6c01184f67ee6f75fd7a163
# first bad commit: [b679ef73edc251f6d200a7dd2396e9fef9e36fc3] hyperv: Add support for physically discontinuous receive buffer

commit b679ef73edc251f6d200a7dd2396e9fef9e36fc3
Author: Haiyang Zhang <haiyangz@microsoft.com>
Date:   Mon Jan 27 15:03:42 2014 -0800

    hyperv: Add support for physically discontinuous receive buffer
    
    This will allow us to use bigger receive buffer, and prevent allocation failure
    due to fragmented memory.
    
    Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
    Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

The problem can be intermittent (sometimes it happens rarely, sometimes
it happens seemingly every boot) so I used the following script to
perform a check:

#!/bin/bash
ok=1
pass=0
bootcount=$(</root/bootcount)
bootcount=$((bootcount + 1))
while [[ $ok -ne 0 ]] && [[ $pass -lt 10 ]]; do
        pass=$((pass + 1))
        ping -qc 1 kernel.org
        ok=$?
        if [[ $ok -eq 0 ]]; then
                echo $bootcount > /root/bootcount
                sync
                reboot
        fi
        sleep 1
done
echo "No network"
read

With kernels equal to or after b679ef73edc251f6d200a7dd2396e9fef9e36fc3
the system will usually stop rebooting before 20 passes but the most
extreme cases were always less than 100. With a pre
b679ef73edc251f6d200a7dd2396e9fef9e36fc3 kernel it did over 390 passes
before I manually stopped it.

Originally filed on https://bugzilla.redhat.com/show_bug.cgi?id=1095387
and then on https://bugzilla.kernel.org/show_bug.cgi?id=78771 but
without reply...

Might also be related to
http://thread.gmane.org/gmane.linux.kernel/1711873/focus=1733398
(Regression in hyperv network driver in 3.14).

-- 
Sitsofe | http://sucs.org/~sits/
