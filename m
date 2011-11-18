From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] vhost-net: Acquire device lock when releasing device
Date: Fri, 18 Nov 2011 11:19:42 +0200
Message-ID: <1321607982-16283-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
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

Device lock should be held when releasing a device, and specifically
when calling vhost_dev_cleanup(). Otherwise, RCU complains about it:

[ 2025.642835] ===============================
[ 2025.643838] [ INFO: suspicious RCU usage. ]
[ 2025.645182] -------------------------------
[ 2025.645927] drivers/vhost/vhost.c:475 suspicious rcu_dereference_protected() usage!
[ 2025.647329]
[ 2025.647330] other info that might help us debug this:
[ 2025.647331]
[ 2025.649042]
[ 2025.649043] rcu_scheduler_active = 1, debug_locks = 1
[ 2025.650235] no locks held by trinity/21042.
[ 2025.650971]
[ 2025.650972] stack backtrace:
[ 2025.651789] Pid: 21042, comm: trinity Not tainted 3.2.0-rc2-sasha-00057-ga9098b3 #5
[ 2025.653342] Call Trace:
[ 2025.653792]  [<ffffffff810b4a6a>] lockdep_rcu_suspicious+0xaf/0xb9
[ 2025.654916]  [<ffffffff818d4c2c>] vhost_dev_cleanup+0x342/0x3ac
[ 2025.655985]  [<ffffffff818d4f18>] vhost_net_release+0x48/0x7f
[ 2025.657247]  [<ffffffff811416e3>] fput+0x11e/0x1dc
[ 2025.658091]  [<ffffffff8113f1ec>] filp_close+0x6e/0x79
[ 2025.658964]  [<ffffffff81089ed7>] put_files_struct+0xcc/0x196
[ 2025.659971]  [<ffffffff8108a034>] exit_files+0x46/0x4f
[ 2025.660865]  [<ffffffff8108a716>] do_exit+0x264/0x75c
[ 2025.662201]  [<ffffffff8113f490>] ? fsnotify_modify+0x60/0x68
[ 2025.663260]  [<ffffffff81bbdbca>] ? sysret_check+0x2e/0x69
[ 2025.664269]  [<ffffffff8108acc1>] do_group_exit+0x83/0xb1
[ 2025.665448]  [<ffffffff8108ad01>] sys_exit_group+0x12/0x16
[ 2025.666396]  [<ffffffff81bbdb92>] system_call_fastpath+0x16/0x1b

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/vhost/net.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 882a51f..c9be601 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -586,6 +586,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	struct socket *tx_sock;
 	struct socket *rx_sock;
 
+	mutex_lock(&n->dev.mutex);
 	vhost_net_stop(n, &tx_sock, &rx_sock);
 	vhost_net_flush(n);
 	vhost_dev_cleanup(&n->dev);
@@ -596,6 +597,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
+	mutex_unlock(&n->dev.mutex);
 	kfree(n);
 	return 0;
 }
-- 
1.7.8.rc1
