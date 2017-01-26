From: Halil Pasic <pasic@linux.vnet.ibm.com>
Subject: [BUG/RFC] vhost: net: big endian viring access despite virtio 1
Date: Thu, 26 Jan 2017 18:39:14 +0100
Message-ID: <a08f491a-1320-607e-f450-d32ce2c9e2f5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Greg Kurz <groug@kaod.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
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


Hi!

Recently I have been investigating some strange migration problems on
s390x.

It turned out under certain circumstances vhost_net corrupts avail.idx by
using wrong endianness.

I managed to track the problem down (I'm pretty sure). It boils down to
the following.

When stopping vhost userspace (QEMU) calls vhost_net_set_backend with
the fd argument set to -1, this leads to is_le being reset in
vhost_vq_init_access.  On a BE system resetting to legacy means resetting
to BE. Usually this is not a problem, but in the case when oldubufs is not
zero (which is not likely if no network stress applied) it is a problem.
That code path needs to write avail.idx, and ends up using wrong
endianness when doing that (but only on a BE system).

That is the story in prose, now let's see the corresponding code annotated
with some comments.

from drivers/vhost/net.c:
static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
{
/* [..] some not too interesting stuff  */
        sock = get_socket(fd);
/* fd == -1 --> sock == NULL */
        if (IS_ERR(sock)) {
                r = PTR_ERR(sock);
                goto err_vq;
        }

        /* start polling new socket */
        oldsock = vq->private_data;
        if (sock != oldsock) {
                ubufs = vhost_net_ubuf_alloc(vq,
                                             sock && vhost_sock_zcopy(sock));
                if (IS_ERR(ubufs)) {
                        r = PTR_ERR(ubufs);
                        goto err_ubufs;
                }

                vhost_net_disable_vq(n, vq);
==>             vq->private_data = sock; 
/* now vq->private_data is NULL */
==>             r = vhost_vq_init_access(vq);
                if (r)
                        goto err_used;
/* vq endianness has been reset to BE on s390 */
                r = vhost_net_enable_vq(n, vq);
                if (r)
                        goto err_used;

==>             oldubufs = nvq->ubufs;
/* here oldubufs might become != 0 */               
                nvq->ubufs = ubufs;

                n->tx_packets = 0;
                n->tx_zcopy_err = 0;
                n->tx_flush = false;
        }
        mutex_unlock(&vq->mutex);

        if (oldubufs) {
                vhost_net_ubuf_put_wait_and_free(oldubufs);
                mutex_lock(&vq->mutex);
==>             vhost_zerocopy_signal_used(n, vq);
/* tries to update virtqueue structures; endianness is BE on s390
 * now (but should be LE for virtio-1) */
                mutex_unlock(&vq->mutex);
        }
/*[..] rest of the function */
}


from drivers/vhost/vhost.c:

int vhost_vq_init_access(struct vhost_virtqueue *vq)
{
        __virtio16 last_used_idx;
        int r;
        bool is_le = vq->is_le;

        if (!vq->private_data) {
==>             vhost_reset_is_le(vq);
/* resets to native endianness and returns */
                return 0;
        }

==>      vhost_init_is_le(vq);
/* here we init is_le */

        r = vhost_update_used_flags(vq);
        if (r)
                goto err;
        vq->signalled_used_valid = false;
        if (!vq->iotlb &&
            !access_ok(VERIFY_READ, &vq->used->idx, sizeof vq->used->idx)) {
                r = -EFAULT;
                goto err;
        }
        r = vhost_get_user(vq, last_used_idx, &vq->used->idx);
        if (r) {
                vq_err(vq, "Can't access used idx at %p\n",
                       &vq->used->idx);
                goto err;
        }
        vq->last_used_idx = vhost16_to_cpu(vq, last_used_idx);
        return 0;

err:
        vq->is_le = is_le;
        return r;
}

AFAIU this can be fixed very simply by omitting the reset. Below the
patch. I'm not sure though, the endianness handling ain't simple in
vhost. Am I going in the right direction?

We have a test (on s390x only) running for a couple of hours now and so
far so good but it's a bit early to announce it is tested  for s390x.
If the patch is reasonable, I'm intend to do a version with proper
attribution and stuff.

By the way the reset was first introduced by 
https://lkml.org/lkml/2015/4/10/226 (dug it up in the hope that reasons
for the reset were discussed -- but no enlightenment for me).

Finally I would like to credit Dave Gilbert for hinting that the
unreasonable avail.idx may be due to an endianness problem and Michael A.
Tebolt for reporting the bug and testing.

-------------------------8<--------------
>From b26e2bbdc03832a0204ee2b42967a1b49a277dc8 Mon Sep 17 00:00:00 2001
From: Halil Pasic <pasic@linux.vnet.ibm.com>
Date: Thu, 26 Jan 2017 00:06:15 +0100
Subject: [PATCH] vhost: remove useless/dangerous reset of is_le

The reset of is_le does no good, but it contributes its fair share to a
bug in vhost_net, which occurs if we have some oldubufs when stopping and
setting a fd = -1 as a backend. Instead of doing something convoluted in
vhost_net, let's just get rid of the reset.

Signed-off-by: Halil Pasic <pasic@linux.vnet.ibm.com>
Fixes: commit 2751c9882b94 
---
 drivers/vhost/vhost.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index d643260..08072a2 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1714,10 +1714,8 @@ int vhost_vq_init_access(struct vhost_virtqueue *vq)
        int r;
        bool is_le = vq->is_le;

-       if (!vq->private_data) {
-               vhost_reset_is_le(vq);
+       if (!vq->private_data)
                return 0;
-       }

        vhost_init_is_le(vq);

-- 
2.8.4
