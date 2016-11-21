From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH] VSOCK: add loopback to virtio_transport
Date: Mon, 21 Nov 2016 12:40:33 +0000
Message-ID: <BY2PR0501MB20563DC7163282F633F7A30EDAB50@BY2PR0501MB2056.namprd05.prod.outlook.com>
References: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "cavery@redhat.com" <cavery@redhat.com>,
        Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
        "David S . Miller" <davem@davemloft.net>
To: Stefan Hajnoczi <stefanha@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0047.outbound.protection.outlook.com ([104.47.33.47]:44981
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752299AbcKUSOX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 13:14:23 -0500
In-Reply-To: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

That should make it on par with the VMCI transport.

Thanks,
J=F8rgen

________________________________________
From: Stefan Hajnoczi <stefanha@redhat.com>
Sent: Thursday, November 17, 2016 4:49 PM
To: netdev@vger.kernel.org
Cc: cavery@redhat.com; Claudio Imbrenda; Jorgen S. Hansen; David S . Miller=
; Stefan Hajnoczi
Subject: [PATCH] VSOCK: add loopback to virtio_transport

The VMware VMCI transport supports loopback inside virtual machines.
This patch implements loopback for virtio-vsock.

Flow control is handled by the virtio-vsock protocol as usual.  The
sending process stops transmitting on a connection when the peer's
receive buffer space is exhausted.

Cathy Avery <cavery@redhat.com> noticed this difference between VMCI and
virtio-vsock when a test case using loopback failed.  Although loopback
isn't the main point of AF_VSOCK, it is useful for testing and
virtio-vsock must match VMCI semantics so that userspace programs run
regardless of the underlying transport.

My understanding is that loopback is not supported on the host side with
VMCI.  Follow that by implementing it only in the guest driver, not the
vhost host driver.

Cc: Jorgen Hansen <jhansen@vmware.com>
Reported-by: Cathy Avery <cavery@redhat.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/vmw_vsock/virtio_transport.c | 57 ++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 57 insertions(+)

diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_transp=
ort.c
index 936d7ee..f2c4071 100644
--- a/net/vmw_vsock/virtio_transport.c
+++ b/net/vmw_vsock/virtio_transport.c
@@ -44,6 +44,10 @@ struct virtio_vsock {
        spinlock_t send_pkt_list_lock;
        struct list_head send_pkt_list;

+       struct work_struct loopback_work;
+       spinlock_t loopback_list_lock;
+       struct list_head loopback_list;
+
        atomic_t queued_replies;

        /* The following fields are protected by rx_lock.  vqs[VSOCK_VQ_RX]
@@ -74,6 +78,42 @@ static u32 virtio_transport_get_local_cid(void)
        return vsock->guest_cid;
 }

+static void virtio_transport_loopback_work(struct work_struct *work)
+{
+       struct virtio_vsock *vsock =3D
+               container_of(work, struct virtio_vsock, loopback_work);
+       LIST_HEAD(pkts);
+
+       spin_lock_bh(&vsock->loopback_list_lock);
+       list_splice_init(&vsock->loopback_list, &pkts);
+       spin_unlock_bh(&vsock->loopback_list_lock);
+
+       mutex_lock(&vsock->rx_lock);
+       while (!list_empty(&pkts)) {
+               struct virtio_vsock_pkt *pkt;
+
+               pkt =3D list_first_entry(&pkts, struct virtio_vsock_pkt, li=
st);
+               list_del_init(&pkt->list);
+
+               virtio_transport_recv_pkt(pkt);
+       }
+       mutex_unlock(&vsock->rx_lock);
+}
+
+static int virtio_transport_send_pkt_loopback(struct virtio_vsock *vsock,
+                                             struct virtio_vsock_pkt *pkt)
+{
+       int len =3D pkt->len;
+
+       spin_lock_bh(&vsock->loopback_list_lock);
+       list_add_tail(&pkt->list, &vsock->loopback_list);
+       spin_unlock_bh(&vsock->loopback_list_lock);
+
+       queue_work(virtio_vsock_workqueue, &vsock->loopback_work);
+
+       return len;
+}
+
 static void
 virtio_transport_send_pkt_work(struct work_struct *work)
 {
@@ -159,6 +199,10 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *pkt=
)
                return -ENODEV;
        }

+       if (le32_to_cpu(pkt->hdr.dst_cid) =3D=3D vsock->guest_cid) {
+               return virtio_transport_send_pkt_loopback(vsock, pkt);
+       }
+
        if (pkt->reply)
                atomic_inc(&vsock->queued_replies);

@@ -510,10 +554,13 @@ static int virtio_vsock_probe(struct virtio_device *v=
dev)
        mutex_init(&vsock->event_lock);
        spin_lock_init(&vsock->send_pkt_list_lock);
        INIT_LIST_HEAD(&vsock->send_pkt_list);
+       spin_lock_init(&vsock->loopback_list_lock);
+       INIT_LIST_HEAD(&vsock->loopback_list);
        INIT_WORK(&vsock->rx_work, virtio_transport_rx_work);
        INIT_WORK(&vsock->tx_work, virtio_transport_tx_work);
        INIT_WORK(&vsock->event_work, virtio_transport_event_work);
        INIT_WORK(&vsock->send_pkt_work, virtio_transport_send_pkt_work);
+       INIT_WORK(&vsock->loopback_work, virtio_transport_loopback_work);

        mutex_lock(&vsock->rx_lock);
        virtio_vsock_rx_fill(vsock);
@@ -539,6 +586,7 @@ static void virtio_vsock_remove(struct virtio_device *v=
dev)
        struct virtio_vsock *vsock =3D vdev->priv;
        struct virtio_vsock_pkt *pkt;

+       flush_work(&vsock->loopback_work);
        flush_work(&vsock->rx_work);
        flush_work(&vsock->tx_work);
        flush_work(&vsock->event_work);
@@ -565,6 +613,15 @@ static void virtio_vsock_remove(struct virtio_device *=
vdev)
        }
        spin_unlock_bh(&vsock->send_pkt_list_lock);

+       spin_lock_bh(&vsock->loopback_list_lock);
+       while (!list_empty(&vsock->loopback_list)) {
+               pkt =3D list_first_entry(&vsock->loopback_list,
+                                      struct virtio_vsock_pkt, list);
+               list_del(&pkt->list);
+               virtio_transport_free_pkt(pkt);
+       }
+       spin_unlock_bh(&vsock->loopback_list_lock);
+
        mutex_lock(&the_virtio_vsock_mutex);
        the_virtio_vsock =3D NULL;
        vsock_core_exit();
