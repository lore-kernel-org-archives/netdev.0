From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: Acquire device lock when releasing device
Date: Sun, 27 Nov 2011 19:06:00 +0200
Message-ID: <20111127170558.GA31970@redhat.com>
References: <1321607982-16283-1-git-send-email-levinsasha928@gmail.com>
	<20111127164925.GA24941@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111127164925.GA24941@redhat.com>
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

On Sun, Nov 27, 2011 at 06:49:27PM +0200, Michael S. Tsirkin wrote:
> On Fri, Nov 18, 2011 at 11:19:42AM +0200, Sasha Levin wrote:
> > Device lock should be held when releasing a device, and specifically
> > when calling vhost_dev_cleanup(). Otherwise, RCU complains about it:
> > 
> > [ 2025.642835] ===============================
> > [ 2025.643838] [ INFO: suspicious RCU usage. ]
> > [ 2025.645182] -------------------------------
> > [ 2025.645927] drivers/vhost/vhost.c:475 suspicious rcu_dereference_protected() usage!
> > [ 2025.647329]
> > [ 2025.647330] other info that might help us debug this:
> > [ 2025.647331]
> > [ 2025.649042]
> > [ 2025.649043] rcu_scheduler_active = 1, debug_locks = 1
> > [ 2025.650235] no locks held by trinity/21042.
> > [ 2025.650971]
> > [ 2025.650972] stack backtrace:
> > [ 2025.651789] Pid: 21042, comm: trinity Not tainted 3.2.0-rc2-sasha-00057-ga9098b3 #5
> > [ 2025.653342] Call Trace:
> > [ 2025.653792]  [<ffffffff810b4a6a>] lockdep_rcu_suspicious+0xaf/0xb9
> > [ 2025.654916]  [<ffffffff818d4c2c>] vhost_dev_cleanup+0x342/0x3ac
> > [ 2025.655985]  [<ffffffff818d4f18>] vhost_net_release+0x48/0x7f
> > [ 2025.657247]  [<ffffffff811416e3>] fput+0x11e/0x1dc
> > [ 2025.658091]  [<ffffffff8113f1ec>] filp_close+0x6e/0x79
> > [ 2025.658964]  [<ffffffff81089ed7>] put_files_struct+0xcc/0x196
> > [ 2025.659971]  [<ffffffff8108a034>] exit_files+0x46/0x4f
> > [ 2025.660865]  [<ffffffff8108a716>] do_exit+0x264/0x75c
> > [ 2025.662201]  [<ffffffff8113f490>] ? fsnotify_modify+0x60/0x68
> > [ 2025.663260]  [<ffffffff81bbdbca>] ? sysret_check+0x2e/0x69
> > [ 2025.664269]  [<ffffffff8108acc1>] do_group_exit+0x83/0xb1
> > [ 2025.665448]  [<ffffffff8108ad01>] sys_exit_group+0x12/0x16
> > [ 2025.666396]  [<ffffffff81bbdb92>] system_call_fastpath+0x16/0x1b
> > 
> > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> > Cc: kvm@vger.kernel.org
> > Cc: virtualization@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > ---
> >  drivers/vhost/net.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 882a51f..c9be601 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -586,6 +586,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
> >  	struct socket *tx_sock;
> >  	struct socket *rx_sock;
> >  
> > +	mutex_lock(&n->dev.mutex);
> >  	vhost_net_stop(n, &tx_sock, &rx_sock);
> >  	vhost_net_flush(n);
> >  	vhost_dev_cleanup(&n->dev);
> > @@ -596,6 +597,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
> >  	/* We do an extra flush before freeing memory,
> >  	 * since jobs can re-queue themselves. */
> >  	vhost_net_flush(n);
> > +	mutex_unlock(&n->dev.mutex);
> >  	kfree(n);
> >  	return 0;
> >  }
> 
> This calls fput fom release under lock which is generally a bad idea,
> as locks become nested then. For example, consider what would happen if this
> somehow triggers a release which in turn needs the same mutex.
> 
> And, we are releasing the device, so it seems better to check
> that no one has the lock.
> How about the following instead? What do you think?
> 
> -->
> 
> vhost: fix release path lockdep checks
> 
> We shouldn't hold any locks on release path. Pass a flag to
> vhost_dev_cleanup to use the lockdep info correctly.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> ---

Sorry, this got cut short. Here's the full patch (1st chunk was
missing).  Does this solve the problem for you?


diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8b16d16..9bba4b3 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -598,7 +598,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 
 	vhost_net_stop(n, &tx_sock, &rx_sock);
 	vhost_net_flush(n);
-	vhost_dev_cleanup(&n->dev);
+	vhost_dev_cleanup(&n->dev, false);
 	if (tx_sock)
 		fput(tx_sock->file);
 	if (rx_sock)
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index a8c95ef..96f9769 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -424,7 +424,7 @@ long vhost_dev_reset_owner(struct vhost_dev *dev)
 	if (!memory)
 		return -ENOMEM;
 
-	vhost_dev_cleanup(dev);
+	vhost_dev_cleanup(dev, true);
 
 	memory->nregions = 0;
 	RCU_INIT_POINTER(dev->memory, memory);
@@ -455,8 +455,8 @@ int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
 	return j;
 }
 
-/* Caller should have device mutex */
-void vhost_dev_cleanup(struct vhost_dev *dev)
+/* Caller should have device mutex if and only if locked is set */
+void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 {
 	int i;
 
@@ -493,7 +493,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	dev->log_file = NULL;
 	/* No one will access memory at this point */
 	kfree(rcu_dereference_protected(dev->memory,
-					lockdep_is_held(&dev->mutex)));
+					locked ==
+						lockdep_is_held(&dev->mutex)));
 	RCU_INIT_POINTER(dev->memory, NULL);
 	WARN_ON(!list_empty(&dev->work_list));
 	if (dev->worker) {
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3e8cc3..97e18d3 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -164,7 +164,7 @@ struct vhost_dev {
 long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
 long vhost_dev_check_owner(struct vhost_dev *);
 long vhost_dev_reset_owner(struct vhost_dev *);
-void vhost_dev_cleanup(struct vhost_dev *);
+void vhost_dev_cleanup(struct vhost_dev *, bool locked);
 long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
 int vhost_vq_access_ok(struct vhost_virtqueue *vq);
 int vhost_log_access_ok(struct vhost_dev *);
