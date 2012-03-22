From: Steve Glass <stevie.glass@gmail.com>
Subject: Re: vhost question
Date: Thu, 22 Mar 2012 11:48:31 +1000
Message-ID: <4F6A84EF.9060105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37824 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab2CVBsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 21:48:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


Just some further information concerning my earlier question
concerning vhost and virtio.

I'm using virtio to implement an emulated mac80211 device in the
guest. A simple network simulation will be used to control delivery of
frames between guests and for this I am using the vhost approach.

A simple first-cut attempt at the tx and rx kick handlers are given
below. When the guest transmits frames the vhost's TX kick handler is
executed and copies the buffers onto a queue for the intended
recipient(s). When the vhost's RX kick handler is run it copies the
buffer from the queue and notifies the client that the buffers have
been used.

The problem is that if there are no frames in the queue when the guest
rx kick handler runs then it has to exit and I have to arrange that it
runs again. That's done in the current prototype by having the guests
poll using a timer - which is ugly and inefficient. Can I get the
vhost tx kick handler to wake the appropriate vhost rx kick handler?
How can I achieve this?

Many thanks,

Steve

static void
handle_rx(struct vhost_work *work)
{
        int n;
        unsigned out, in, frames;
        struct transmission *t;
        struct vhost_poll *p = container_of(work, struct vhost_poll,
work);
        struct vhost_virtqueue *vq =
                container_of(p, struct vhost_virtqueue, poll);
        struct vhost_node *node =
                container_of(vq, struct vhost_node, vqs[WLAN_VQ_RX]);
        struct vhost_dev *dev = &node->vdev;

        mutex_lock(&vq->mutex);
        vhost_disable_notify(dev, vq);
        while (!queue_empty(&node->rxq)) {
                n = vhost_get_vq_desc(dev,
                                      vq,
                                      vq->iov,
                                      ARRAY_SIZE(vq->iov),
                                      &out,
                                      &in,
                                      NULL,
                                      NULL);
                if (0 < n || n == vq->num)
                        break;
                t = queue_pop(&node->rxq);
                BUG_ON(copy_to_user(vq->iov[0].iov_base, t->buf,
t->buf_sz));
                vq->iov[0].iov_len = t->buf_sz;
                vhost_add_used(vq, n, out);
                transmission_free(t);
                ++frames;
        }
        if (frames)
                vhost_signal(dev, vq);
        vhost_enable_notify(dev, vq);
        mutex_unlock(&vq->mutex);
}

static void
handle_tx(struct vhost_work *work)
{
        int n;
        unsigned out, in;
        struct transmission *t;
        struct vhost_node *receiver;

        struct vhost_poll *p =
                container_of(work, struct vhost_poll, work);
        struct vhost_virtqueue *vq =
                container_of(p, struct vhost_virtqueue, poll);
        struct vhost_node *w =
                container_of(vq, struct vhost_node, vqs[WLAN_VQ_TX]);
        struct vhost_dev *dev = &w->vdev;

        mutex_lock(&vq->mutex);
        do {
                vhost_disable_notify(dev, vq);
                n = vhost_get_vq_desc(dev,
                                      vq,
                                      vq->iov,
                                      ARRAY_SIZE(vq->iov),
                                      &out,
                                      &in,
                                      NULL,
                                      NULL);
                while (n >= 0 && n != vq->num) {
                        receiver = net_get_receiver(w);
                        if ((receiver) && (t = transmission_alloc())) {
                                BUG_ON(copy_from_user(t->buf,
                                                      vq->iov[1].iov_base,
                                                     
vq->iov[1].iov_len));
                                t->buf_sz = vq->iov[1].iov_len;
                                queue_push(&receiver->rxq, t);
                                // ToDo: kick receiver's handle_rx
                        }
                        vhost_add_used(vq, n, out);
                        n = vhost_get_vq_desc(dev,
                                              vq,
                                              vq->iov,
                                              ARRAY_SIZE(vq->iov),
                                              &out,
                                              &in,
                                              NULL,
                                              NULL);
                }
                vhost_signal(dev, vq);
        } while (vhost_enable_notify(dev, vq));
        mutex_unlock(&vq->mutex);
}
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9qhO4ACgkQW7aAm65EWy7w4wCgrzGB2Zit4rWUzMjwpJEJnIfj
xDsAoLBDMj+4MVrjPS5upgDSIGOi4IzL
=Ms/+
-----END PGP SIGNATURE-----
