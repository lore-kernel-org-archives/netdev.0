From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH net-next 2/3] vsock: fix vsock_dequeue/enqueue_accept race
Date: Tue, 15 Aug 2017 22:15:39 +0000
Message-ID: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "'gregkh@linuxfoundation.org'" <'gregkh@linuxfoundation.org'>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Stephen Hemminger" <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        "Asias He" <asias@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "Vitaly Kuznetsov" <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        "Marcelo Cerri" <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
To: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With the current code, when vsock_dequeue_accept() is removing a sock
from the list, nothing prevents vsock_enqueue_accept() from adding a new
sock into the list concurrently. We should add a lock to protect the list.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: Andy King <acking@vmware.com>
Cc: Dmitry Torokhov <dtor@vmware.com>
Cc: George Zhang <georgezhang@vmware.com>
Cc: Jorgen Hansen <jhansen@vmware.com>
Cc: Reilly Grant <grantr@vmware.com>
Cc: Asias He <asias@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Cathy Avery <cavery@redhat.com>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/vmw_vsock/af_vsock.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index dfc8c51e..b7b2c66 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -126,6 +126,7 @@ static struct proto vsock_proto =3D {
=20
 static const struct vsock_transport *transport;
 static DEFINE_MUTEX(vsock_register_mutex);
+static DEFINE_SPINLOCK(vsock_accept_queue_lock);
=20
 /**** EXPORTS ****/
=20
@@ -406,7 +407,10 @@ void vsock_enqueue_accept(struct sock *listener, struc=
t sock *connected)
=20
 	sock_hold(connected);
 	sock_hold(listener);
+
+	spin_lock(&vsock_accept_queue_lock);
 	list_add_tail(&vconnected->accept_queue, &vlistener->accept_queue);
+	spin_unlock(&vsock_accept_queue_lock);
 }
 EXPORT_SYMBOL_GPL(vsock_enqueue_accept);
=20
@@ -423,7 +427,10 @@ static struct sock *vsock_dequeue_accept(struct sock *=
listener)
 	vconnected =3D list_entry(vlistener->accept_queue.next,
 				struct vsock_sock, accept_queue);
=20
+	spin_lock(&vsock_accept_queue_lock);
 	list_del_init(&vconnected->accept_queue);
+	spin_unlock(&vsock_accept_queue_lock);
+
 	sock_put(listener);
 	/* The caller will need a reference on the connected socket so we let
 	 * it call sock_put().
--=20
2.7.4
