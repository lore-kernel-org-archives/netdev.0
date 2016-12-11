From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vsock/virtio: fix src/dst cid format
Date: Sun, 11 Dec 2016 04:54:46 +0200
Message-ID: <20161211045205-mutt-send-email-mst@kernel.org>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
 <1481038106-24899-10-git-send-email-mst@redhat.com>
 <a0dcb733-ab1c-ac66-2300-fcb90fbacea2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a0dcb733-ab1c-ac66-2300-fcb90fbacea2@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 12:31:56PM +0800, Jason Wang wrote:
> 
> 
> On 2016年12月06日 23:41, Michael S. Tsirkin wrote:
> > These fields are 64 bit, using le32_to_cpu and friends
> > on these will not do the right thing.
> > Fix this up.
> > 
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >   net/vmw_vsock/virtio_transport_common.c | 14 +++++++-------
> >   1 file changed, 7 insertions(+), 7 deletions(-)
> > 
> > diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
> > index 6120384..22e99c4 100644
> > --- a/net/vmw_vsock/virtio_transport_common.c
> > +++ b/net/vmw_vsock/virtio_transport_common.c
> > @@ -606,9 +606,9 @@ static int virtio_transport_reset_no_sock(struct virtio_vsock_pkt *pkt)
> >   		return 0;
> >   	pkt = virtio_transport_alloc_pkt(&info, 0,
> > -					 le32_to_cpu(pkt->hdr.dst_cid),
> > +					 le64_to_cpu(pkt->hdr.dst_cid),
> >   					 le32_to_cpu(pkt->hdr.dst_port),
> > -					 le32_to_cpu(pkt->hdr.src_cid),
> > +					 le64_to_cpu(pkt->hdr.src_cid),
> >   					 le32_to_cpu(pkt->hdr.src_port));
> 
> Looking at sockaddr_vm, svm_cid is "unsigned int", do we really want 64 bit
> here?

Can't change the protocol at this point.


> >   	if (!pkt)
> >   		return -ENOMEM;
> > @@ -823,7 +823,7 @@ virtio_transport_send_response(struct vsock_sock *vsk,
> >   	struct virtio_vsock_pkt_info info = {
> >   		.op = VIRTIO_VSOCK_OP_RESPONSE,
> >   		.type = VIRTIO_VSOCK_TYPE_STREAM,
> > -		.remote_cid = le32_to_cpu(pkt->hdr.src_cid),
> > +		.remote_cid = le64_to_cpu(pkt->hdr.src_cid),
> >   		.remote_port = le32_to_cpu(pkt->hdr.src_port),
> >   		.reply = true,
> >   	};
> > @@ -863,9 +863,9 @@ virtio_transport_recv_listen(struct sock *sk, struct virtio_vsock_pkt *pkt)
> >   	child->sk_state = SS_CONNECTED;
> >   	vchild = vsock_sk(child);
> > -	vsock_addr_init(&vchild->local_addr, le32_to_cpu(pkt->hdr.dst_cid),
> > +	vsock_addr_init(&vchild->local_addr, le64_to_cpu(pkt->hdr.dst_cid),
> >   			le32_to_cpu(pkt->hdr.dst_port));
> > -	vsock_addr_init(&vchild->remote_addr, le32_to_cpu(pkt->hdr.src_cid),
> > +	vsock_addr_init(&vchild->remote_addr, le64_to_cpu(pkt->hdr.src_cid),
> >   			le32_to_cpu(pkt->hdr.src_port));
> >   	vsock_insert_connected(vchild);
> > @@ -904,9 +904,9 @@ void virtio_transport_recv_pkt(struct virtio_vsock_pkt *pkt)
> >   	struct sock *sk;
> >   	bool space_available;
> > -	vsock_addr_init(&src, le32_to_cpu(pkt->hdr.src_cid),
> > +	vsock_addr_init(&src, le64_to_cpu(pkt->hdr.src_cid),
> >   			le32_to_cpu(pkt->hdr.src_port));
> > -	vsock_addr_init(&dst, le32_to_cpu(pkt->hdr.dst_cid),
> > +	vsock_addr_init(&dst, le64_to_cpu(pkt->hdr.dst_cid),
> >   			le32_to_cpu(pkt->hdr.dst_port));
> >   	trace_virtio_transport_recv_pkt(src.svm_cid, src.svm_port,
