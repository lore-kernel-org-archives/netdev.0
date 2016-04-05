From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 4/6] ppp: invert lock ordering between ppp_mutex and
 rtnl_lock
Date: Tue, 5 Apr 2016 02:56:27 +0200
Message-ID: <ca8fe7c647b3122d54520c0c07f0e3f32f4a922f.1459807527.git.g.nault@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1459807527.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since ppp_create_interface() is the only place[1] holding both ppp_mutex
and rtnl_lock(), we can reverse lock ordering to allow taking ppp_mutex
when rtnl_lock is already held.
This will be necessary for creating PPP interfaces from an rtnetlink
callback.

[1]: There may actually be exceptions. When operating on PPP channels,
ppp_ioctl() can call lower level ioctl callbacks (chan->ops->ioctl())
with ppp_mutex locked. More review would be necessary to ensure no such
callback would ever call rtnl_lock(). OTOH, with proper locking inside
the ->ioctl() callbacks, ppp_mutex might be removed entirely from this
part of the code.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index c81e257..8aaedb8 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2796,8 +2796,8 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 	 */
 	dev_net_set(dev, net);
 
-	mutex_lock(&ppp_mutex);
 	rtnl_lock();
+	mutex_lock(&ppp_mutex);
 	mutex_lock(&pn->all_ppp_mutex);
 
 	if (file->private_data) {
@@ -2847,15 +2847,15 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 	atomic_inc(&ppp_unit_count);
 
 	mutex_unlock(&pn->all_ppp_mutex);
-	rtnl_unlock();
 	mutex_unlock(&ppp_mutex);
+	rtnl_unlock();
 
 	return 0;
 
 out2:
 	mutex_unlock(&pn->all_ppp_mutex);
-	rtnl_unlock();
 	mutex_unlock(&ppp_mutex);
+	rtnl_unlock();
 	free_netdev(dev);
 out1:
 	return ret;
-- 
2.8.0.rc3

