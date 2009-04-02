From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: [PATCH] TX_RING and packet mmap
Date: Thu, 02 Apr 2009 21:48:38 +0200
Message-ID: <1238701718.5669.26.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:50890 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765689AbZDBTj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 15:39:59 -0400
Received: from smtp1-g21.free.fr (localhost [127.0.0.1])
	by smtp1-g21.free.fr (Postfix) with ESMTP id 2AE6C940193
	for <netdev@vger.kernel.org>; Thu,  2 Apr 2009 21:39:50 +0200 (CEST)
Received: from [192.168.0.12] (gol06-1-82-242-162-120.fbx.proxad.net [82.242.162.120])
	by smtp1-g21.free.fr (Postfix) with ESMTP id C7B949401CD
	for <netdev@vger.kernel.org>; Thu,  2 Apr 2009 21:39:47 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Johann Baudy <johann.baudy@gnu-log.net>

New packet socket feature that makes packet socket more efficient for t=
ransmission.
- It reduces number of system call through a PACKET_TX_RING mechanism, =
based on PACKET_RX_RING (Circular buffer allocated in kernel space whic=
h is mmapped from user space).
- It minimizes CPU copy using fragmented SKB (almost zero copy).

Signed-off-by: Johann Baudy <johann.baudy@gnu-log.net>

--

As I start to receive few mails from people that are now using this fea=
ture, I would like to discuss with you if it is possible to integrate t=
his patch in the kernel under CONFIG_PACKET_MMAP feature flag.
More details (example of using, patch 2.4,2.6 ...) can be found at:  ht=
tp://wiki.ipxwarzone.com/index.php5?title=3DLinux_packet_mmap
This feature is based on PACKET_RX_RING mechanism. I've implemented a p=
arallel mechanism for TX that can send multiple packets to device in on=
e system call thanks to mmapped memory.
It uses skb destructor and mmapped memory (status flag) to indicate use=
r that packet has been sent and buffer is now free for new sending.=20
It also adds some abstraction functions/structures to prevent code redu=
ndancy.

 Documentation/networking/packet_mmap.txt |  139 +++++++-
 include/linux/if_packet.h                |    2 +
 net/packet/af_packet.c                   |  561 ++++++++++++++++++++++=
++------
 3 files changed, 579 insertions(+), 123 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/n=
etworking/packet_mmap.txt
index 07c53d5..43e4a49 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -4,16 +4,18 @@
=20
 This file documents the CONFIG_PACKET_MMAP option available with the P=
ACKET
 socket interface on 2.4 and 2.6 kernels. This type of sockets is used =
for=20
-capture network traffic with utilities like tcpdump or any other that =
uses=20
-the libpcap library.=20
-
-You can find the latest version of this document at
+capture network traffic with utilities like tcpdump or any other that =
needs
+raw access to network interface.
=20
+You can find the latest version of this document at:
     http://pusa.uv.es/~ulisses/packet_mmap/
=20
-Please send me your comments to
+Howto can be found at:
+    http://wiki.gnu-log.net (packet_mmap)
=20
+Please send your comments to
     Ulisses Alonso Camar=F3 <uaca@i.hate.spam.alumni.uv.es>
+    Johann Baudy <johann.baudy@gnu-log.net>
=20
 ----------------------------------------------------------------------=
---------
 + Why use PACKET_MMAP
@@ -25,19 +27,24 @@ to capture each packet, it requires two if you want=
 to get packet's
 timestamp (like libpcap always does).
=20
 In the other hand PACKET_MMAP is very efficient. PACKET_MMAP provides =
a size=20
-configurable circular buffer mapped in user space. This way reading pa=
ckets just=20
-needs to wait for them, most of the time there is no need to issue a s=
ingle=20
-system call. By using a shared buffer between the kernel and the user=20
-also has the benefit of minimizing packet copies.
-
-It's fine to use PACKET_MMAP to improve the performance of the capture=
 process,=20
-but it isn't everything. At least, if you are capturing at high speeds=
 (this=20
-is relative to the cpu speed), you should check if the device driver o=
f your=20
-network interface card supports some sort of interrupt load mitigation=
 or=20
-(even better) if it supports NAPI, also make sure it is enabled.
+configurable circular buffer mapped in user space that can be used to =
either
+send or receive packets. This way reading packets just needs to wait f=
or them,
+most of the time there is no need to issue a single system call. Conce=
rning
+transmission, multiple packets can be sent through one system call to =
get the
+highest bandwidth.
+By using a shared buffer between the kernel and the user also has the =
benefit
+of minimizing packet copies.
+
+It's fine to use PACKET_MMAP to improve the performance of the capture=
 and
+transmission process, but it isn't everything. At least, if you are ca=
pturing
+at high speeds (this is relative to the cpu speed), you should check i=
f the
+device driver of your network interface card supports some sort of int=
errupt
+load mitigation or (even better) if it supports NAPI, also make sure i=
t is
+enabled. For transmission, check the MTU (Maximum Transmission Unit) u=
sed and
+supported by devices of your network.
=20
 ----------------------------------------------------------------------=
----------
-+ How to use CONFIG_PACKET_MMAP
++ How to use CONFIG_PACKET_MMAP to improve capture process
 ----------------------------------------------------------------------=
----------
=20
 From the user standpoint, you should use the higher level libpcap libr=
ary, which
@@ -57,7 +64,7 @@ the low level details or want to improve libpcap by i=
ncluding PACKET_MMAP
 support.
=20
 ----------------------------------------------------------------------=
----------
-+ How to use CONFIG_PACKET_MMAP directly
++ How to use CONFIG_PACKET_MMAP directly to improve capture process
 ----------------------------------------------------------------------=
----------
=20
 From the system calls stand point, the use of PACKET_MMAP involves
@@ -66,6 +73,7 @@ the following process:
=20
 [setup]     socket() -------> creation of the capture socket
             setsockopt() ---> allocation of the circular buffer (ring)
+                              option: PACKET_RX_RING
             mmap() ---------> mapping of the allocated buffer to the
                               user process
=20
@@ -97,13 +105,75 @@ also the mapping of the circular buffer in the use=
r process and
 the use of this buffer.
=20
 ----------------------------------------------------------------------=
----------
++ How to use CONFIG_PACKET_MMAP directly to improve transmission proce=
ss
+----------------------------------------------------------------------=
----------
+Transmission process is similar to capture as shown below.
+
+[setup]          socket() -------> creation of the transmission socket
+                 setsockopt() ---> allocation of the circular buffer (=
ring)
+                                   option: PACKET_TX_RING
+                 bind() ---------> bind transmission socket with a net=
work interface
+                 mmap() ---------> mapping of the allocated buffer to =
the
+                                   user process
+
+[transmission]   poll() ---------> wait for free packets (optional)
+                 send() ---------> send all packets that are set as re=
ady in
+                                   the ring
+                                   The flag MSG_DONTWAIT can be used t=
o return
+                                   before end of transfer.
+
+[shutdown]  close() --------> destruction of the transmission socket a=
nd
+                              deallocation of all associated resources=
=2E
+
+Binding the socket to your network interface is mandatory (with zero c=
opy) to
+know the header size of frames used in the circular buffer.
+
+As capture, each frame contains two parts:
+
+ --------------------
+| struct tpacket_hdr | Header. It contains the status of
+|                    | of this frame
+|--------------------|
+| data buffer        |
+.                    .  Data that will be sent over the network interf=
ace.
+.                    .
+ --------------------
+
+ bind() associates the socket to your network interface thanks to
+ sll_ifindex parameter of struct sockaddr_ll.
+
+ Initialization example:
+
+ struct sockaddr_ll my_addr;
+ struct ifreq s_ifr;
+ ...
+
+ strncpy (s_ifr.ifr_name, "eth0", sizeof(s_ifr.ifr_name));
+
+ /* get interface index of eth0 */
+ ioctl(this->socket, SIOCGIFINDEX, &s_ifr);
+
+ /* fill sockaddr_ll struct to prepare binding */
+ my_addr.sll_family =3D AF_PACKET;
+ my_addr.sll_protocol =3D ETH_P_ALL;
+ my_addr.sll_ifindex =3D  s_ifr.ifr_ifindex;
+
+ /* bind socket to eth0 */
+ bind(this->socket, (struct sockaddr *)&my_addr, sizeof(struct sockadd=
r_ll));
+
+ A complete tutorial is available at: http://wiki.gnu-log.net/
+
+----------------------------------------------------------------------=
----------
 + PACKET_MMAP settings
 ----------------------------------------------------------------------=
----------
=20
=20
 To setup PACKET_MMAP from user level code is done with a call like
=20
+ - Capture process
      setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req, sizeof(=
req))
+ - Transmission process
+     setsockopt(fd, SOL_PACKET, PACKET_TX_RING, (void *) &req, sizeof(=
req))
=20
 The most significant argument in the previous call is the req paramete=
r,=20
 this parameter must to have the following structure:
@@ -117,11 +187,11 @@ this parameter must to have the following structu=
re:
     };
=20
 This structure is defined in /usr/include/linux/if_packet.h and establ=
ishes a=20
-circular buffer (ring) of unswappable memory mapped in the capture pro=
cess.=20
+circular buffer (ring) of unswappable memory.
 Being mapped in the capture process allows reading the captured frames=
 and=20
 related meta-information like timestamps without requiring a system ca=
ll.
=20
-Captured frames are grouped in blocks. Each block is a physically cont=
iguous=20
+Frames are grouped in blocks. Each block is a physically contiguous
 region of memory and holds tp_block_size/tp_frame_size frames. The tot=
al number=20
 of blocks is tp_block_nr. Note that tp_frame_nr is a redundant paramet=
er because
=20
@@ -336,6 +406,7 @@ struct tpacket_hdr). If this field is 0 means that =
the frame is ready
 to be used for the kernel, If not, there is a frame the user can read=20
 and the following flags apply:
=20
++++ Capture process:
      from include/linux/if_packet.h
=20
      #define TP_STATUS_COPY          2=20
@@ -391,6 +462,36 @@ packets are in the ring:
 It doesn't incur in a race condition to first check the status value a=
nd=20
 then poll for frames.
=20
+
+++ Transmission process
+Those defines are also used for transmission:
+
+     #define TP_STATUS_KERNEL        0 // Frame is available
+     #define TP_STATUS_USER          1 // Frame will be sent on next s=
end()
+     #define TP_STATUS_COPY          2 // Frame is currently in transm=
ission
+
+First, the kernel initializes all frames to TP_STATUS_KERNEL. To send =
a packet,
+the user fills a data buffer of an available frame, sets tp_len to cur=
rent
+data buffer size and sets its status field to TP_STATUS_USER. This can=
 be done
+on multiple frames. Once the user is ready to transmit, it calls send(=
).
+Then all buffers with status equal to TP_STATUS_USER are forwarded to =
the
+network device. The kernel updates each status of sent frames with
+TP_STATUS_COPY until the end of transfer.
+At the end of each transfer, buffer status returns to TP_STATUS_KERNEL=
=2E
+
+    header->tp_len =3D in_i_size;
+    header->tp_status =3D TP_STATUS_USER;
+    retval =3D send(this->socket, NULL, 0, 0);
+
+The user can also use poll() to check if a buffer is available:
+(status =3D=3D TP_STATUS_KERNEL)
+
+    struct pollfd pfd;
+    pfd.fd =3D fd;
+    pfd.revents =3D 0;
+    pfd.events =3D POLLOUT;
+    retval =3D poll(&pfd, 1, timeout);
+
 ----------------------------------------------------------------------=
----------
 + THANKS
 ----------------------------------------------------------------------=
----------
diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 18db066..a5d2f9a 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -46,6 +46,8 @@ struct sockaddr_ll
 #define PACKET_VERSION			10
 #define PACKET_HDRLEN			11
 #define PACKET_RESERVE			12
+#define PACKET_TX_RING			13
+#define PACKET_LOSS			14
=20
 struct tpacket_stats
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1fc4a78..e239696 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -157,7 +157,25 @@ struct packet_mreq_max
 };
=20
 #ifdef CONFIG_PACKET_MMAP
-static int packet_set_ring(struct sock *sk, struct tpacket_req *req, i=
nt closing);
+static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
+		int closing, int tx_ring);
+
+struct packet_ring_buffer {
+	char *			*pg_vec;
+	unsigned int		head;
+	unsigned int		frames_per_block;
+	unsigned int		frame_size;
+	unsigned int		frame_max;
+
+	unsigned int		pg_vec_order;
+	unsigned int		pg_vec_pages;
+	unsigned int		pg_vec_len;
+
+	atomic_t		pending;
+};
+
+struct packet_sock;
+static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 #endif
=20
 static void packet_flush_mclist(struct sock *sk);
@@ -167,11 +185,8 @@ struct packet_sock {
 	struct sock		sk;
 	struct tpacket_stats	stats;
 #ifdef CONFIG_PACKET_MMAP
-	char *			*pg_vec;
-	unsigned int		head;
-	unsigned int            frames_per_block;
-	unsigned int		frame_size;
-	unsigned int		frame_max;
+	struct packet_ring_buffer	rx_ring;
+	struct packet_ring_buffer	tx_ring;
 	int			copy_thresh;
 #endif
 	struct packet_type	prot_hook;
@@ -185,12 +200,10 @@ struct packet_sock {
 	struct packet_mclist	*mclist;
 #ifdef CONFIG_PACKET_MMAP
 	atomic_t		mapped;
-	unsigned int            pg_vec_order;
-	unsigned int		pg_vec_pages;
-	unsigned int		pg_vec_len;
 	enum tpacket_versions	tp_version;
 	unsigned int		tp_hdrlen;
 	unsigned int		tp_reserve;
+	unsigned int		tp_loss:1;
 #endif
 };
=20
@@ -206,36 +219,33 @@ struct packet_skb_cb {
=20
 #ifdef CONFIG_PACKET_MMAP
=20
-static void *packet_lookup_frame(struct packet_sock *po, unsigned int =
position,
-				 int status)
+static void __packet_set_status(struct packet_sock *po, void *frame, i=
nt status)
 {
-	unsigned int pg_vec_pos, frame_offset;
 	union {
 		struct tpacket_hdr *h1;
 		struct tpacket2_hdr *h2;
 		void *raw;
 	} h;
=20
-	pg_vec_pos =3D position / po->frames_per_block;
-	frame_offset =3D position % po->frames_per_block;
-
-	h.raw =3D po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size);
+	h.raw =3D frame;
 	switch (po->tp_version) {
 	case TPACKET_V1:
-		if (status !=3D (h.h1->tp_status ? TP_STATUS_USER :
-						TP_STATUS_KERNEL))
-			return NULL;
+		h.h1->tp_status =3D status;
+		flush_dcache_page(virt_to_page(&h.h1->tp_status));
 		break;
 	case TPACKET_V2:
-		if (status !=3D (h.h2->tp_status ? TP_STATUS_USER :
-						TP_STATUS_KERNEL))
-			return NULL;
+		h.h2->tp_status =3D status;
+		flush_dcache_page(virt_to_page(&h.h2->tp_status));
 		break;
+	default:
+		printk(KERN_ERR "TPACKET version not supported\n");
+		BUG();
 	}
-	return h.raw;
+=09
+	smp_wmb();
 }
=20
-static void __packet_set_status(struct packet_sock *po, void *frame, i=
nt status)
+static int __packet_get_status(struct packet_sock *po, void *frame)
 {
 	union {
 		struct tpacket_hdr *h1;
@@ -243,16 +253,73 @@ static void __packet_set_status(struct packet_soc=
k *po, void *frame, int status)
 		void *raw;
 	} h;
=20
+	smp_rmb();
+
 	h.raw =3D frame;
 	switch (po->tp_version) {
 	case TPACKET_V1:
-		h.h1->tp_status =3D status;
-		break;
+		flush_dcache_page(virt_to_page(&h.h1->tp_status));
+		return h.h1->tp_status;
 	case TPACKET_V2:
-		h.h2->tp_status =3D status;
-		break;
+		flush_dcache_page(virt_to_page(&h.h2->tp_status));
+		return h.h2->tp_status;
+	default:
+		printk(KERN_ERR "TPACKET version not supported\n");
+		BUG();
+		return 0;
 	}
 }
+
+static void *packet_lookup_frame(struct packet_sock *po,
+		struct packet_ring_buffer *rb,
+		unsigned int position,
+		int status)
+{
+	unsigned int pg_vec_pos, frame_offset;
+	union {
+		struct tpacket_hdr *h1;
+		struct tpacket2_hdr *h2;
+		void *raw;
+	} h;
+
+	pg_vec_pos =3D position / rb->frames_per_block;
+	frame_offset =3D position % rb->frames_per_block;
+
+	h.raw =3D rb->pg_vec[pg_vec_pos] + (frame_offset * rb->frame_size);
+
+	if( status !=3D __packet_get_status(po, h.raw) )
+		return NULL;
+
+	return h.raw;
+}
+
+static inline void *packet_current_rx_frame(struct packet_sock *po, in=
t status)
+{
+	return packet_lookup_frame(po, &po->rx_ring, po->rx_ring.head, status=
);
+}
+
+static inline void *packet_current_tx_frame(struct packet_sock *po, in=
t status)
+{
+	return packet_lookup_frame(po, &po->tx_ring, po->tx_ring.head, status=
);
+}
+
+static inline void *packet_previous_rx_frame(struct packet_sock *po, i=
nt status)
+{
+	unsigned int previous =3D po->rx_ring.head ? po->rx_ring.head - 1 : p=
o->rx_ring.frame_max;
+	return packet_lookup_frame(po, &po->rx_ring, previous, status);
+}
+
+static inline void *packet_previous_tx_frame(struct packet_sock *po, i=
nt status)
+{
+	unsigned int previous =3D po->tx_ring.head ? po->tx_ring.head - 1 : p=
o->tx_ring.frame_max;
+	return packet_lookup_frame(po, &po->tx_ring, previous, status);
+}
+
+static inline void packet_increment_head(struct packet_ring_buffer *bu=
ff)
+{
+	buff->head =3D buff->head !=3D buff->frame_max ? buff->head+1 : 0;
+}
+
 #endif
=20
 static inline struct packet_sock *pkt_sk(struct sock *sk)
@@ -648,7 +715,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct =
net_device *dev, struct packe
 		macoff =3D netoff - maclen;
 	}
=20
-	if (macoff + snaplen > po->frame_size) {
+	if (macoff + snaplen > po->rx_ring.frame_size) {
 		if (po->copy_thresh &&
 		    atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
 		    (unsigned)sk->sk_rcvbuf) {
@@ -661,16 +728,16 @@ static int tpacket_rcv(struct sk_buff *skb, struc=
t net_device *dev, struct packe
 			if (copy_skb)
 				skb_set_owner_r(copy_skb, sk);
 		}
-		snaplen =3D po->frame_size - macoff;
+		snaplen =3D po->rx_ring.frame_size - macoff;
 		if ((int)snaplen < 0)
 			snaplen =3D 0;
 	}
=20
 	spin_lock(&sk->sk_receive_queue.lock);
-	h.raw =3D packet_lookup_frame(po, po->head, TP_STATUS_KERNEL);
+	h.raw =3D packet_current_rx_frame(po, TP_STATUS_KERNEL);
 	if (!h.raw)
 		goto ring_is_full;
-	po->head =3D po->head !=3D po->frame_max ? po->head+1 : 0;
+	packet_increment_head(&po->rx_ring);
 	po->stats.tp_packets++;
 	if (copy_skb) {
 		status |=3D TP_STATUS_COPY;
@@ -727,7 +794,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct =
net_device *dev, struct packe
=20
 	__packet_set_status(po, h.raw, status);
 	smp_mb();
-
 	{
 		struct page *p_start, *p_end;
 		u8 *h_end =3D h.raw + macoff + snaplen - 1;
@@ -761,10 +827,238 @@ ring_is_full:
 	goto drop_n_restore;
 }
=20
-#endif
+static void tpacket_destruct_skb(struct sk_buff *skb)
+{
+	struct packet_sock *po =3D pkt_sk(skb->sk);
+	void * ph;
+=09
+	BUG_ON(skb =3D=3D NULL);
+=09
+	if (likely(po->tx_ring.pg_vec)) {
+		ph =3D packet_lookup_frame(po, &po->tx_ring, skb->mark, TP_STATUS_CO=
PY);
+		BUG_ON(atomic_read(&po->tx_ring.pending) =3D=3D 0);
+		atomic_dec(&po->tx_ring.pending);
+		__packet_set_status(po, ph, TP_STATUS_KERNEL);
+	}
+=09
+	sock_wfree(skb);
+}
+
+static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff * s=
kb, void * frame,
+		struct net_device *dev, int size_max, __be16 proto,
+		unsigned char * addr)
+{
+	union {
+		struct tpacket_hdr *h1;
+		struct tpacket2_hdr *h2;
+		void *raw;
+	} ph;
+	int to_write, offset, len, tp_len, nr_frags, len_max;
+	struct socket *sock =3D po->sk.sk_socket;
+	struct page *page;
+	void *data;
+	int err;
=20
+	ph.raw =3D frame;
=20
-static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
+	skb->protocol =3D proto;
+	skb->dev =3D dev;
+	skb->priority =3D po->sk.sk_priority;
+	skb->mark =3D po->tx_ring.head;
+
+	switch(po->tp_version) {
+	case TPACKET_V2:
+		tp_len =3D ph.h2->tp_len;
+		break;
+	default:
+		tp_len =3D ph.h1->tp_len;
+		break;
+	}
+	if (unlikely(tp_len > size_max)) {
+		printk(KERN_ERR "packet size is too long (%d > %d)\n",
+				tp_len, size_max);
+		return -EMSGSIZE;
+	}
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reset_network_header(skb);
+
+	data =3D ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
+	to_write =3D tp_len;
+
+	if (sock->type =3D=3D SOCK_DGRAM) {
+		err =3D dev_hard_header(skb, dev, ntohs(proto), addr,
+				NULL, tp_len);
+		if (unlikely(err < 0))
+			return -EINVAL;
+	} else if (dev->hard_header_len ) {
+		/* net device doesn't like empty head */
+		if(unlikely(tp_len <=3D dev->hard_header_len)) {
+			printk(KERN_ERR "packet size is too short "
+					"(%d < %d)\n", tp_len,
+					dev->hard_header_len);
+			return -EINVAL;
+		}
+
+		skb_push(skb, dev->hard_header_len);
+		err =3D skb_store_bits(skb, 0, data,
+				dev->hard_header_len);
+		if (unlikely(err))
+			return err;
+
+		data +=3D dev->hard_header_len;
+		to_write -=3D dev->hard_header_len;
+	}
+
+	err =3D -EFAULT;
+	page =3D virt_to_page(data);
+	offset =3D offset_in_page(data);
+	len_max =3D PAGE_SIZE - offset;
+	len =3D ((to_write > len_max) ? len_max : to_write);
+
+	skb->data_len =3D to_write;
+	skb->len +=3D to_write;
+	skb->truesize +=3D to_write;
+	atomic_add(to_write, &po->sk.sk_wmem_alloc);
+
+	while ( likely(to_write) ) {
+		nr_frags =3D skb_shinfo(skb)->nr_frags;
+
+		if(unlikely(nr_frags >=3D MAX_SKB_FRAGS)) {
+			printk(KERN_ERR "Packet exceed the number "
+					"of skb frags(%lu)\n",
+					MAX_SKB_FRAGS);
+			return -EFAULT;
+		}
+
+		flush_dcache_page(page);
+		get_page(page);
+		skb_fill_page_desc(skb,
+				nr_frags,
+				page++, offset, len);
+		to_write -=3D len;
+		offset =3D 0;
+		len_max =3D PAGE_SIZE;
+		len =3D ((to_write > len_max) ? len_max : to_write);
+	}
+
+	return tp_len;
+}
+
+static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
+{
+	struct socket *sock;
+	struct sk_buff *skb;
+	struct net_device *dev;
+	__be16 proto;
+	int ifindex, err, reserve =3D 0;
+	void * ph;
+	struct sockaddr_ll *saddr=3D(struct sockaddr_ll *)msg->msg_name;
+	int tp_len, size_max;
+	unsigned char *addr;
+	int len_sum =3D 0;
+	int status =3D 0;
+
+	sock =3D po->sk.sk_socket;
+
+	mutex_lock(&po->pg_vec_lock);
+
+	err =3D -EBUSY;
+	if (saddr =3D=3D NULL) {
+		ifindex	=3D po->ifindex;
+		proto	=3D po->num;
+		addr	=3D NULL;
+	} else {
+		err =3D -EINVAL;
+		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
+			goto out;
+		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_=
ll, sll_addr)))
+			goto out;
+		ifindex	=3D saddr->sll_ifindex;
+		proto	=3D saddr->sll_protocol;
+		addr	=3D saddr->sll_addr;
+	}
+
+	dev =3D dev_get_by_index(sock_net(&po->sk), ifindex);
+	err =3D -ENXIO;
+	if (unlikely(dev =3D=3D NULL))
+		goto out;
+
+	reserve =3D dev->hard_header_len;
+
+	err =3D -ENETDOWN;
+	if (unlikely(!(dev->flags & IFF_UP)))
+		goto out_put;
+
+	size_max =3D po->tx_ring.frame_size - sizeof(struct skb_shared_info)
+		- po->tp_hdrlen - LL_ALLOCATED_SPACE(dev) - sizeof(struct sockaddr_l=
l);
+
+	if (size_max > dev->mtu + reserve)
+		size_max =3D dev->mtu + reserve;
+
+	do
+	{
+		ph =3D packet_current_tx_frame(po, TP_STATUS_USER);
+		if(unlikely(ph =3D=3D NULL)) {
+			schedule();
+			continue;
+		}
+
+		status =3D TP_STATUS_USER;
+		skb =3D sock_alloc_send_skb(&po->sk, LL_ALLOCATED_SPACE(dev) + sizeo=
f(struct sockaddr_ll),
+				0, &err);
+		if (unlikely(skb =3D=3D NULL))
+			goto out_status;
+
+		tp_len =3D tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
+				addr);
+		if(unlikely(tp_len < 0)) {
+			if(po->tp_loss) {
+				__packet_set_status(po, ph, TP_STATUS_KERNEL);
+				packet_increment_head(&po->tx_ring);
+				kfree_skb(skb);
+				continue;
+			} else {
+				status =3D TP_STATUS_LOSING;
+				err =3D tp_len;
+				goto out_status;
+			}
+		}
+
+		skb->destructor =3D tpacket_destruct_skb;
+		__packet_set_status(po, ph, TP_STATUS_COPY);
+		atomic_inc(&po->tx_ring.pending);
+
+		status =3D TP_STATUS_USER;
+		err =3D dev_queue_xmit(skb);
+		if (unlikely(err > 0 && (err =3D net_xmit_errno(err)) !=3D 0))
+			goto out_xmit;
+		packet_increment_head(&po->tx_ring);
+		len_sum +=3D tp_len;
+	}
+	while(likely(((ph !=3D NULL)
+			|| ((!(msg->msg_flags & MSG_DONTWAIT))
+				 && (atomic_read(&po->tx_ring.pending))))
+		    ));
+
+	err =3D len_sum;
+	goto out_put;
+
+out_xmit:
+	skb->destructor =3D sock_wfree;
+	atomic_dec(&po->tx_ring.pending);
+out_status:
+	__packet_set_status(po, ph, status);
+	kfree_skb(skb);
+out_put:
+	dev_put(dev);
+out:
+	mutex_unlock(&po->pg_vec_lock);
+	return err;
+}
+#endif
+
+static int packet_snd(struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk =3D sock->sk;
@@ -855,6 +1149,19 @@ out:
 	return err;
 }
=20
+static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *msg, size_t len)
+{
+#ifdef CONFIG_PACKET_MMAP
+	struct sock *sk =3D sock->sk;
+	struct packet_sock *po =3D pkt_sk(sk);
+	if (po->tx_ring.pg_vec)
+		return tpacket_snd(po, msg);
+	else
+#endif
+		return packet_snd(sock, msg, len);
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -894,10 +1201,15 @@ static int packet_release(struct socket *sock)
 	packet_flush_mclist(sk);
=20
 #ifdef CONFIG_PACKET_MMAP
-	if (po->pg_vec) {
+	{
 		struct tpacket_req req;
 		memset(&req, 0, sizeof(req));
-		packet_set_ring(sk, &req, 1);
+
+		if (po->rx_ring.pg_vec)
+			packet_set_ring(sk, &req, 1, 0);
+
+		if (po->tx_ring.pg_vec)
+			packet_set_ring(sk, &req, 1, 1);
 	}
 #endif
=20
@@ -1416,6 +1728,7 @@ packet_setsockopt(struct socket *sock, int level,=
 int optname, char __user *optv
=20
 #ifdef CONFIG_PACKET_MMAP
 	case PACKET_RX_RING:
+	case PACKET_TX_RING:
 	{
 		struct tpacket_req req;
=20
@@ -1423,7 +1736,7 @@ packet_setsockopt(struct socket *sock, int level,=
 int optname, char __user *optv
 			return -EINVAL;
 		if (copy_from_user(&req,optval,sizeof(req)))
 			return -EFAULT;
-		return packet_set_ring(sk, &req, 0);
+		return packet_set_ring(sk, &req, 0, optname =3D=3D PACKET_TX_RING);
 	}
 	case PACKET_COPY_THRESH:
 	{
@@ -1443,7 +1756,7 @@ packet_setsockopt(struct socket *sock, int level,=
 int optname, char __user *optv
=20
 		if (optlen !=3D sizeof(val))
 			return -EINVAL;
-		if (po->pg_vec)
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
 			return -EBUSY;
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
@@ -1462,13 +1775,26 @@ packet_setsockopt(struct socket *sock, int leve=
l, int optname, char __user *optv
=20
 		if (optlen !=3D sizeof(val))
 			return -EINVAL;
-		if (po->pg_vec)
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
 			return -EBUSY;
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
 		po->tp_reserve =3D val;
 		return 0;
 	}
+	case PACKET_LOSS:
+	{
+		unsigned int val;
+
+		if (optlen !=3D sizeof(val))
+			return -EINVAL;
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
+			return -EBUSY;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+		po->tp_loss =3D !!val;
+		return 0;
+	}
 #endif
 	case PACKET_AUXDATA:
 	{
@@ -1574,6 +1900,12 @@ static int packet_getsockopt(struct socket *sock=
, int level, int optname,
 		val =3D po->tp_reserve;
 		data =3D &val;
 		break;
+	case PACKET_LOSS:
+		if (len > sizeof(unsigned int))
+			len =3D sizeof(unsigned int);
+		val =3D po->tp_loss;
+		data =3D &val;
+		break;
 #endif
 	default:
 		return -ENOPROTOOPT;
@@ -1706,13 +2038,17 @@ static unsigned int packet_poll(struct file * f=
ile, struct socket *sock,
 	unsigned int mask =3D datagram_poll(file, sock, wait);
=20
 	spin_lock_bh(&sk->sk_receive_queue.lock);
-	if (po->pg_vec) {
-		unsigned last =3D po->head ? po->head-1 : po->frame_max;
-
-		if (packet_lookup_frame(po, last, TP_STATUS_USER))
+	if (po->rx_ring.pg_vec) {
+		if (packet_previous_rx_frame(po, TP_STATUS_USER))
 			mask |=3D POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
+	spin_lock_bh(&sk->sk_write_queue.lock);
+	if (po->tx_ring.pg_vec) {
+		if (packet_current_tx_frame(po, TP_STATUS_KERNEL))
+			mask |=3D POLLOUT | POLLWRNORM;
+	}
+	spin_unlock_bh(&sk->sk_write_queue.lock);
 	return mask;
 }
=20
@@ -1788,21 +2124,32 @@ out_free_pgvec:
 	goto out;
 }
=20
-static int packet_set_ring(struct sock *sk, struct tpacket_req *req, i=
nt closing)
+static int packet_set_ring(struct sock *sk, struct tpacket_req *req, i=
nt closing, int tx_ring)
 {
 	char **pg_vec =3D NULL;
 	struct packet_sock *po =3D pkt_sk(sk);
 	int was_running, order =3D 0;
+	struct packet_ring_buffer *rb;
+	struct sk_buff_head *rb_queue;
 	__be16 num;
-	int err =3D 0;
+	int err;
=20
-	if (req->tp_block_nr) {
-		int i;
+	rb =3D tx_ring ? &po->tx_ring : &po->rx_ring;
+	rb_queue =3D tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
=20
-		/* Sanity tests and some calculations */
+	err =3D -EBUSY;
+	if(!closing) {
+		if (atomic_read(&po->mapped))
+			goto out;
+		if (atomic_read(&rb->pending))
+			goto out;
+	}
=20
-		if (unlikely(po->pg_vec))
-			return -EBUSY;
+	if (req->tp_block_nr) {
+		/* Sanity tests and some calculations */
+		err =3D -EBUSY;
+		if (unlikely(rb->pg_vec))
+			goto out;
=20
 		switch (po->tp_version) {
 		case TPACKET_V1:
@@ -1813,42 +2160,35 @@ static int packet_set_ring(struct sock *sk, str=
uct tpacket_req *req, int closing
 			break;
 		}
=20
+		err =3D -EINVAL;
 		if (unlikely((int)req->tp_block_size <=3D 0))
-			return -EINVAL;
+			goto out;
 		if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
-			return -EINVAL;
+			goto out;
 		if (unlikely(req->tp_frame_size < po->tp_hdrlen +
-						  po->tp_reserve))
-			return -EINVAL;
+					po->tp_reserve))
+			goto out;
 		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
-			return -EINVAL;
+			goto out;
=20
-		po->frames_per_block =3D req->tp_block_size/req->tp_frame_size;
-		if (unlikely(po->frames_per_block <=3D 0))
-			return -EINVAL;
-		if (unlikely((po->frames_per_block * req->tp_block_nr) !=3D
-			     req->tp_frame_nr))
-			return -EINVAL;
+		rb->frames_per_block =3D req->tp_block_size/req->tp_frame_size;
+		if (unlikely(rb->frames_per_block <=3D 0))
+			goto out;
+		if (unlikely((rb->frames_per_block * req->tp_block_nr) !=3D
+					req->tp_frame_nr))
+			goto out;
=20
 		err =3D -ENOMEM;
 		order =3D get_order(req->tp_block_size);
 		pg_vec =3D alloc_pg_vec(req, order);
 		if (unlikely(!pg_vec))
 			goto out;
-
-		for (i =3D 0; i < req->tp_block_nr; i++) {
-			void *ptr =3D pg_vec[i];
-			int k;
-
-			for (k =3D 0; k < po->frames_per_block; k++) {
-				__packet_set_status(po, ptr, TP_STATUS_KERNEL);
-				ptr +=3D req->tp_frame_size;
-			}
-		}
-		/* Done */
-	} else {
+	}
+	/* Done */
+	else {
+		err =3D -EINVAL;
 		if (unlikely(req->tp_frame_nr))
-			return -EINVAL;
+			goto out;
 	}
=20
 	lock_sock(sk);
@@ -1872,20 +2212,19 @@ static int packet_set_ring(struct sock *sk, str=
uct tpacket_req *req, int closing
 	if (closing || atomic_read(&po->mapped) =3D=3D 0) {
 		err =3D 0;
 #define XC(a, b) ({ __typeof__ ((a)) __t; __t =3D (a); (a) =3D (b); __=
t; })
-
-		spin_lock_bh(&sk->sk_receive_queue.lock);
-		pg_vec =3D XC(po->pg_vec, pg_vec);
-		po->frame_max =3D (req->tp_frame_nr - 1);
-		po->head =3D 0;
-		po->frame_size =3D req->tp_frame_size;
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
-
-		order =3D XC(po->pg_vec_order, order);
-		req->tp_block_nr =3D XC(po->pg_vec_len, req->tp_block_nr);
-
-		po->pg_vec_pages =3D req->tp_block_size/PAGE_SIZE;
-		po->prot_hook.func =3D po->pg_vec ? tpacket_rcv : packet_rcv;
-		skb_queue_purge(&sk->sk_receive_queue);
+		spin_lock_bh(&rb_queue->lock);
+		pg_vec =3D XC(rb->pg_vec, pg_vec);
+		rb->frame_max =3D (req->tp_frame_nr - 1);
+		rb->head =3D 0;
+		rb->frame_size =3D req->tp_frame_size;
+		spin_unlock_bh(&rb_queue->lock);
+
+		order =3D XC(rb->pg_vec_order, order);
+		req->tp_block_nr =3D XC(rb->pg_vec_len, req->tp_block_nr);
+
+		rb->pg_vec_pages =3D req->tp_block_size/PAGE_SIZE;
+		po->prot_hook.func =3D (po->rx_ring.pg_vec) ? tpacket_rcv : packet_r=
cv;
+		skb_queue_purge(rb_queue);
 #undef XC
 		if (atomic_read(&po->mapped))
 			printk(KERN_DEBUG "packet_mmap: vma is busy: %d\n", atomic_read(&po=
->mapped));
@@ -1913,7 +2252,8 @@ static int packet_mmap(struct file *file, struct =
socket *sock, struct vm_area_st
 {
 	struct sock *sk =3D sock->sk;
 	struct packet_sock *po =3D pkt_sk(sk);
-	unsigned long size;
+	unsigned long size, expected_size;
+	struct packet_ring_buffer *rb;
 	unsigned long start;
 	int err =3D -EINVAL;
 	int i;
@@ -1921,26 +2261,39 @@ static int packet_mmap(struct file *file, struc=
t socket *sock, struct vm_area_st
 	if (vma->vm_pgoff)
 		return -EINVAL;
=20
-	size =3D vma->vm_end - vma->vm_start;
-
 	mutex_lock(&po->pg_vec_lock);
-	if (po->pg_vec =3D=3D NULL)
+
+	expected_size =3D 0;
+	for(rb =3D &po->rx_ring; rb <=3D &po->tx_ring; rb++) {
+		if (rb->pg_vec)
+			expected_size +=3D rb->pg_vec_len * rb->pg_vec_pages * PAGE_SIZE;
+	}
+
+	if (expected_size =3D=3D 0)
 		goto out;
-	if (size !=3D po->pg_vec_len*po->pg_vec_pages*PAGE_SIZE)
+
+	size =3D vma->vm_end - vma->vm_start;
+	if (size !=3D expected_size)
 		goto out;
=20
 	start =3D vma->vm_start;
-	for (i =3D 0; i < po->pg_vec_len; i++) {
-		struct page *page =3D virt_to_page(po->pg_vec[i]);
-		int pg_num;
-
-		for (pg_num =3D 0; pg_num < po->pg_vec_pages; pg_num++, page++) {
-			err =3D vm_insert_page(vma, start, page);
-			if (unlikely(err))
-				goto out;
-			start +=3D PAGE_SIZE;
+	for(rb =3D &po->rx_ring; rb <=3D &po->tx_ring; rb++) {
+		if (rb->pg_vec =3D=3D NULL)
+			continue;
+
+		for (i =3D 0; i < rb->pg_vec_len; i++) {
+			struct page *page =3D virt_to_page(rb->pg_vec[i]);
+			int pg_num;
+
+			for (pg_num =3D 0; pg_num < rb->pg_vec_pages; pg_num++, page++) {
+				err =3D vm_insert_page(vma, start, page);
+				if (unlikely(err))
+					goto out;
+				start +=3D PAGE_SIZE;
+			}
 		}
-	}
+	}=09
+=09
 	atomic_inc(&po->mapped);
 	vma->vm_ops =3D &packet_mmap_ops;
 	err =3D 0;


