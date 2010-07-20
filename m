From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 20 Jul 2010 12:20:32 +1000
Message-ID: <20100720122032.88e0fcd9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Dike <jdike@addtoit.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/vhost/net.c between commit
1680e9063ea28099a1efa8ca11cee069cc7a9bc3 ("vhost-net: avoid flush under
lock") from the net-current tree and commit
dd1f4078f0d2de74a308f00a2dffbd550cfba59f ("vhost-net: minor cleanup")
from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/vhost/net.c
index d219070,107af9e..0000000
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@@ -527,15 -527,12 +527,14 @@@ static long vhost_net_set_backend(struc
  
  	/* start polling new socket */
  	oldsock = vq->private_data;
- 	if (sock == oldsock)
- 		goto done;
+ 	if (sock != oldsock){
+                 vhost_net_disable_vq(n, vq);
+                 rcu_assign_pointer(vq->private_data, sock);
+                 vhost_net_enable_vq(n, vq);
+ 	}
  
- 	vhost_net_disable_vq(n, vq);
- 	rcu_assign_pointer(vq->private_data, sock);
- 	vhost_net_enable_vq(n, vq);
- done:
 +	mutex_unlock(&vq->mutex);
 +
  	if (oldsock) {
  		vhost_net_flush_vq(n, index);
  		fput(oldsock->file);
