From: "Johann Baudy" <johaahn@gmail.com>
Subject: Packet mmap: TX RING and zero copy
Date: Tue, 2 Sep 2008 20:27:36 +0200
Message-ID: <7e0dd21a0809021127n35cd38d7m98be5ee5d7158788@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?ISO-8859-1?Q?Ulisses_Alonso_Camar=F3?=" <uaca@alumni.uv.es>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:35256 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbYIBS1i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 14:27:38 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2379606rvb.1
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 11:27:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'm currently working on an embedded project (based on Linux kernel)
that needs a high throughput using gigabit Ethernet controller and
"small" cpu.
I've made lot of tests, playing with jumbo frames, raw sockets, ...
I've never exceeded ~25Mbytes/s. So I've decided to analyze deeply the
packet socket transmission process.

The main blocking point was the memcpy_fromiovec() function that is
located in the packet_sendmsg() of af_packet.c.
It was consuming all my CPU resources to copy data from user space to
socket buffer.
Then I've started to work on a hack that makes this transfer possible
without any memcpys.

Mainly, the hack is the implementation of two "features":

    *  Sending packet through a circular buffer between user and
kernel space that minimizes the number of system calls. (Feature
actually implemented for capture process, libpcap ..).
       To sum up the user process :
        - initialize a raw socket
        - allocate N buffers into kernel space through a setsockopt() (=
TX ring),
        - mmap() the allocated memory,
        - fill M buffers with custom data, and update status of filled
buffers to ready (header of buffer: struct tpacket_hdr contains a
status field: TP_STATUS_KERNEL means free, TP_STATUS_USER means ready
to be sent, TP_STATUS_COPY means transmission ongoing)
        - call send() procedure. The kernel will then send all buffers
set with TP_STATUS_USER. Status is set to TP_STATUS_COPY during
transfer and TP_STATUS_KERNEL when done.

    *  Zero copy mode.  CONFIG_PACKET_MMAP_ZERO_COPY feature flag
skips CPU copy between the circular buffer and the socket buffer
allocated during send.
       To send packet without zero copy, if my understanding is
correct, first we allocate a socket buffer with sock_alloc_send_skb(),
then we copy content of data into the socket buffer, finally we give
this sk_buff to the network card. With zero copy, the trick is to
bypass the data copy by substituting data pointers of allocated
sk_buff for data pointers of our circular buffer.
       This way network devices use our circular buffer instead of
socket buffer concerning data.
       And to prevent the kernel from crashing during skb data release
(shinfo+data release), we restore the whole previous content of
sk_buff inside the destructor callback.

I'm aware that this suggestion is really far from a real solution,
mainly due to this hard substitution.
But, I would like to get as much criticism as possible in order to
start a discussion with experts about a conceivable way to mix
zero-copy, sk_buff management and packet socket.
Which is perhaps impossible with current network kernel flow ...

PS: I've reached 85Mbytes/s with TX RING and zero-copy

Thanks in advance for your advices,
Johann Baudy

diff --git a/Documentation/networking/packet_mmap.txt
b/Documentation/networking/packet_mmap.txt
index db0cd51..0cfb835 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -4,16 +4,17 @@

 This file documents the CONFIG_PACKET_MMAP option available with the P=
ACKET
 socket interface on 2.4 and 2.6 kernels. This type of sockets is used =
for
-capture network traffic with utilities like tcpdump or any other that =
uses
-the libpcap library.
+capture network traffic with utilities like tcpdump or any other that =
needs
+raw acces to network interface.

 You can find the latest version of this document at

-    http://pusa.uv.es/~ulisses/packet_mmap/
+    http://pusa.uv.es/~ulisses/packet_mmap/ (down ?)

 Please send me your comments to

     Ulisses Alonso Camar=F3 <uaca@i.hate.spam.alumni.uv.es>
+    Johann Baudy <johann.baudy@gnu-log.net> (TX RING - Zero Copy)

 ----------------------------------------------------------------------=
---------
 + Why use PACKET_MMAP
@@ -25,19 +26,25 @@ to capture each packet, it requires two if you
want to get packet's
 timestamp (like libpcap always does).

 In the other hand PACKET_MMAP is very efficient. PACKET_MMAP provides =
a size
-configurable circular buffer mapped in user space. This way reading
packets just
-needs to wait for them, most of the time there is no need to issue a s=
ingle
-system call. By using a shared buffer between the kernel and the user
-also has the benefit of minimizing packet copies.
-
-It's fine to use PACKET_MMAP to improve the performance of the
capture process,
-but it isn't everything. At least, if you are capturing at high speeds=
 (this
-is relative to the cpu speed), you should check if the device driver o=
f your
-network interface card supports some sort of interrupt load mitigation=
 or
-(even better) if it supports NAPI, also make sure it is enabled.
+configurable circular buffer mapped in user space that can be used to =
either
+send or receive packets. This way reading packets just needs to wait f=
or them,
+most of the time there is no need to issue a single system call. For
transmission,
+multiple packets can be sent in one sytem call and outgoing data buffe=
rs can be
+zero-copied to get the highest bandwidth (with PACKET_MMAP_ZERO_COPY).
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
+supported by devices of your network. Especially if you are using DMA.
+(cf Jumbo frame)

 ----------------------------------------------------------------------=
----------
-+ How to use CONFIG_PACKET_MMAP
++ How to use CONFIG_PACKET_MMAP to improve capture process
 ----------------------------------------------------------------------=
----------

 From the user standpoint, you should use the higher level libpcap
library, which
@@ -56,8 +63,9 @@ The rest of this document is intended for people who
want to understand
 the low level details or want to improve libpcap by including PACKET_M=
MAP
 support.

+
 ----------------------------------------------------------------------=
----------
-+ How to use CONFIG_PACKET_MMAP directly
++ How to use CONFIG_PACKET_MMAP directly to improve capture porcess
 ----------------------------------------------------------------------=
----------

 From the system calls stand point, the use of PACKET_MMAP involves
@@ -66,6 +74,7 @@ the following process:

 [setup]     socket() -------> creation of the capture socket
             setsockopt() ---> allocation of the circular buffer (ring)
+                              option: PACKET_RX_RING
             mmap() ---------> mapping of the allocated buffer to the
                               user process

@@ -97,14 +106,95 @@ also the mapping of the circular buffer in the
user process and
 the use of this buffer.

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
+                 bind() ---------> bind transmission socket with a
network interface
+                 getsockopt() ---> get the circular buffer header size
+                                   option: PACKET_TX_RING_HEADER_SIZE
+                 mmap() ---------> mapping of the allocated buffer to =
the
+                                   user process
+
+[transmission]   poll() ---------> wait for free packets (optional)
+                 send() ---------> send all packets that are set as re=
ady in
+                                   the ring
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
+Each frame contains five parts:
+
+ -------------------
+| struct tpacket    | Header. It contains the status of
+|                   | of this frame
+|-------------------|
+| struct skbuff     | (Zero copy only) Save of allocated socket buffer
+|                   | descriptor.
+|-------------------|
+| network interface | (Zero copy only) size =3D LL_RESERVED_SPACE(dev)
+| reserved space    |
+|-------------------|
+| data buffer       |
+.                   .  Data that will be sent over the network interfa=
ce.
+.                   .
+|-------------------|
+| network interface | (Zero copy only) size =3D LL_ALLOCATED_SPACE(dev=
)
+| reserved space    |                         - LL_RESERVED_SPACE(dev)
+ -------------------
+
+ Network interface reserved spaces may differ between devices that
why user must
+ ask header size to the kernel after bind() call.
+
+ bind() associates the socket to your network interface thanks to
+ sll_ifindex parameter of struct sockaddr_ll.
+
+ getsockopt(PACKET_TX_RING_HEADER_SIZE) returns an offset that must be
+ added to each frame pointer to get the start pointer of the data buff=
er.
+
+ int i_header_size;
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
+ /* get header size */
+ getsockopt(this->socket, SOL_PACKET, PACKET_TX_RING_HEADER_SIZE,
+            (void*)&i_header_size,&opt_len);
+
+ A complete tutorial is available at: http://wiki.gnu-log.net/
+
+----------------------------------------------------------------------=
----------
 + PACKET_MMAP settings
 ----------------------------------------------------------------------=
----------


 To setup PACKET_MMAP from user level code is done with a call like

+ - Capture process
      setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req, sizeof(=
req))

+ - Transmission process
+     setsockopt(fd, SOL_PACKET, PACKET_TX_RING, (void *) &req, sizeof(=
req))
+
 The most significant argument in the previous call is the req paramete=
r,
 this parameter must to have the following structure:

@@ -117,11 +207,11 @@ this parameter must to have the following structu=
re:
     };

 This structure is defined in /usr/include/linux/if_packet.h and establ=
ishes a
-circular buffer (ring) of unswappable memory mapped in the capture pro=
cess.
+circular buffer (ring) of unswappable memory.
 Being mapped in the capture process allows reading the captured frames=
 and
 related meta-information like timestamps without requiring a system ca=
ll.

-Captured frames are grouped in blocks. Each block is a physically cont=
iguous
+Frames are grouped in blocks. Each block is a physically contiguous
 region of memory and holds tp_block_size/tp_frame_size frames. The
total number
 of blocks is tp_block_nr. Note that tp_frame_nr is a redundant
parameter because

@@ -336,13 +426,13 @@ struct tpacket_hdr). If this field is 0 means
that the frame is ready
 to be used for the kernel, If not, there is a frame the user can read
 and the following flags apply:

-     from include/linux/if_packet.h
+++ Capture process:

+from include/linux/if_packet.h
      #define TP_STATUS_COPY          2
      #define TP_STATUS_LOSING        4
      #define TP_STATUS_CSUMNOTREADY  8

-
 TP_STATUS_COPY        : This flag indicates that the frame (and associ=
ated
                         meta information) has been truncated because i=
t's
                         larger than tp_frame_size. This packet can be
@@ -388,8 +478,38 @@ packets are in the ring:
     if (status =3D=3D TP_STATUS_KERNEL)
         retval =3D poll(&pfd, 1, timeout);

-It doesn't incur in a race condition to first check the status value a=
nd
-then poll for frames.
+
+++ Transmission process
+Those defines are also used for transmission:
+
+     #define TP_STATUS_KERNEL        0 // Frame is available
+     #define TP_STATUS_USER          1 // Frame will be sent on next s=
end()
+     #define TP_STATUS_COPY          2 // Frame is currently in transm=
ission
+     #define TP_STATUS_LOSING        4 // Indicate a transmission erro=
r
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
+TP_STATUS_COPY until the end of transfer (if zero copy is used, otherw=
ise
+end of socket buffer copy).
+At the end, all statuses return to TP_STATUS_KERNEL.
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
diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index ad09609..a79cd89 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -43,6 +43,8 @@ struct sockaddr_ll
 #define PACKET_COPY_THRESH		7
 #define PACKET_AUXDATA			8
 #define PACKET_ORIGDEV			9
+#define PACKET_TX_RING			10
+#define PACKET_TX_RING_HEADER_SIZE	11

 struct tpacket_stats
 {
@@ -79,6 +81,11 @@ struct tpacket_hdr
 #define TPACKET_ALIGN(x)	(((x)+TPACKET_ALIGNMENT-1)&~(TPACKET_ALIGNMEN=
T-1))
 #define TPACKET_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket_hdr)) +
sizeof(struct sockaddr_ll))

+/* packet ring modes */
+#define TPACKET_MODE_NONE 0
+#define TPACKET_MODE_RX 1
+#define TPACKET_MODE_TX 2
+
 /*
    Frame structure:

diff --git a/net/packet/Kconfig b/net/packet/Kconfig
index 34ff93f..2c74568 100644
--- a/net/packet/Kconfig
+++ b/net/packet/Kconfig
@@ -16,7 +16,7 @@ config PACKET
 	  If unsure, say Y.

 config PACKET_MMAP
-	bool "Packet socket: mmapped IO"
+	bool "mmapped IO"
 	depends on PACKET
 	help
 	  If you say Y here, the Packet protocol driver will use an IO
@@ -24,3 +24,12 @@ config PACKET_MMAP

 	  If unsure, say N.

+config PACKET_MMAP_ZERO_COPY
+	bool "zero-copy TX"
+	depends on PACKET_MMAP
+	help
+	  If you say Y here, the Packet protocol driver will fill socket buff=
er
+	  descriptors with TX ring buffer addresses. This mechanism that resu=
lts
+	  in faster communication.
+
+	  If unsure, say N.
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..45367dc 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -158,7 +158,9 @@ struct packet_mreq_max
 };

 #ifdef CONFIG_PACKET_MMAP
-static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
int closing);
+static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
int closing, int mode);
+static int tpacket_snd(struct socket *sock,
+											struct msghdr *msg, size_t len);
 #endif

 static void packet_flush_mclist(struct sock *sk);
@@ -173,7 +175,9 @@ struct packet_sock {
 	unsigned int            frames_per_block;
 	unsigned int		frame_size;
 	unsigned int		frame_max;
+	unsigned int		header_size;
 	int			copy_thresh;
+	int		mode;
 #endif
 	struct packet_type	prot_hook;
 	spinlock_t		bind_lock;
@@ -692,10 +696,209 @@ ring_is_full:
 	goto drop_n_restore;
 }

+/*
+ * TX ring skb destructor.
+ * This function is called when skb is freed.
+ * */
+#ifdef CONFIG_PACKET_MMAP_ZERO_COPY
+void tpacket_skb_destructor (struct sk_buff *skb)
+{
+	struct tpacket_hdr *header =3D (struct tpacket_hdr*) skb->head;
+	struct sk_buff * skb_copy;
+
+	/* calculate old skb pointer */
+	skb_copy =3D ((void*) header + sizeof(struct tpacket_hdr));
+
+	/* restore previous skb header (before substitution) */
+	memcpy(skb, skb_copy, sizeof(struct sk_buff));
+
+	/* execute previous destructor */
+	if(skb->destructor)
+		skb->destructor(skb);
+
+	/* check status of buffer */
+	BUG_ON(header->tp_status !=3D TP_STATUS_COPY);
+	header->tp_status =3D TP_STATUS_KERNEL;
+
+	return;
+}
 #endif

+/*
+ * TX Ring packet send function
+ * */
+static int tpacket_snd(struct socket *sock,
+											struct msghdr *msg, size_t len)
+{
+	struct sock *sk =3D sock->sk;
+	struct sockaddr_ll *saddr=3D(struct sockaddr_ll *)msg->msg_name;
+	struct packet_sock *po =3D pkt_sk(sk);
+	struct net_device *dev;
+	int err, reserve=3D0,  len_sum=3D0, ifindex, i;
+	struct sk_buff * skb, * skb_copy;
+	unsigned char *addr;
+	__be16 proto;
+
+	/*
+	 *	Get and verify the address.
+	 */
+	if (saddr =3D=3D NULL) {
+		ifindex	=3D po->ifindex;
+		proto	=3D po->num;
+		addr =3D NULL;
+	} else {
+		err =3D -EINVAL;
+		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
+			goto out;
+		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct
sockaddr_ll, sll_addr)))
+			goto out;
+		ifindex	=3D saddr->sll_ifindex;
+		proto	=3D saddr->sll_protocol;
+		addr	=3D saddr->sll_addr;
+	}

-static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
+	/* get device by index */
+	dev =3D dev_get_by_index(sock_net(sk), ifindex);
+	err =3D -ENXIO;
+	if (dev =3D=3D NULL)
+		goto out_put;
+	if (sock->type =3D=3D SOCK_RAW)
+		reserve =3D dev->hard_header_len;
+
+	/* check if header size of device has changed since bind */
+	/* bind() call is mandatory as user must know where data must be writ=
ten.
+	 * it fills header_size setting of current socket
+	 * and allows getsockopt(PACKET_TX_RING_HEADER_SIZE) call */
+	err =3D -EINVAL;
+#ifdef CONFIG_PACKET_MMAP_ZERO_COPY
+	if(po->header_size !=3D LL_RESERVED_SPACE(dev) + sizeof(struct
tpacket_hdr) + sizeof(struct sk_buff))
+#else
+	if(po->header_size !=3D sizeof(struct tpacket_hdr))
+#endif
+		goto out_put;
+
+	/* check interface up */
+	err =3D -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto out_put;
+
+	/* loop on all frames */
+	for (i =3D 0; i <=3D po->frame_max; i++) {
+		struct tpacket_hdr *header =3D packet_lookup_frame(po, i);
+		int size_max =3D po->frame_size - sizeof(struct skb_shared_info) -
sizeof(struct tpacket_hdr) - LL_ALLOCATED_SPACE(dev);
+
+		if(header->tp_status =3D=3D TP_STATUS_USER) {
+			/* mark header as tx ongoing */
+			header->tp_status =3D TP_STATUS_COPY;
+
+			/* check packet size */
+			err =3D -EMSGSIZE;
+			if (header->tp_len > dev->mtu+reserve)
+				goto out_put;
+			if(header->tp_len > size_max)
+				goto out_put;
+
+#ifdef CONFIG_PACKET_MMAP_ZERO_COPY
+			err =3D -ENOMEM;
+			/* allocate skb header */
+			skb =3D sock_alloc_send_skb(sk,
+																0,
+																msg->msg_flags & MSG_DONTWAIT,
+																&err);
+			if (skb=3D=3DNULL)
+				goto out_put;
+
+			err =3D -EINVAL;
+			if (sock->type =3D=3D SOCK_DGRAM &&
+				dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len) < 0)
+				goto out_free;
+
+			/* clone current skb */
+			skb_copy =3D ((void*) header + sizeof(struct tpacket_hdr));
+			memcpy(skb_copy, skb, sizeof(struct sk_buff));
+
+			/* substitute skb data with Tx ring pointers */
+			skb->head =3D (void*)header;
+			skb->data =3D (void*)skb->head;
+			skb->end =3D (void*)header + po->frame_size - sizeof(struct skb_sha=
red_info);
+			skb->truesize =3D po->frame_size;
+			skb_reset_tail_pointer(skb);
+
+			/* make sure we've copied shinfo properly into ring buffer */
+			memcpy(skb_shinfo(skb), skb_shinfo(skb_copy), sizeof(struct
skb_shared_info));
+
+			err =3D -ENOSPC;
+			/* check buffer size */
+			if(skb_tailroom(skb) < header->tp_len)
+				goto out_free;
+
+			/* put data into skb */
+			skb_reserve(skb, po->header_size);
+			skb_put(skb, header->tp_len);
+			skb_reset_network_header(skb);
+			skb_reset_transport_header(skb);
+
+			/* store destructor call back to update tpacket header status */
+			skb->destructor =3D tpacket_skb_destructor;
+#else
+			err =3D -ENOMEM;
+			/* allocate skb header */
+			skb =3D sock_alloc_send_skb(sk,
+																header->tp_len + LL_ALLOCATED_SPACE(dev),
+																msg->msg_flags & MSG_DONTWAIT,
+																&err);
+			if (skb=3D=3DNULL)
+				goto out_put;
+
+			/* reserve device header */
+			skb_reserve(skb, LL_RESERVED_SPACE(dev));
+			skb_put(skb,header->tp_len);
+			skb_shinfo(skb)->frag_list=3D0;
+			skb_shinfo(skb)->nr_frags=3D0;
+
+			/* copy all data from TX ring buffer to skb */
+			err =3D skb_store_bits(skb, 0, (void*)header + po->header_size,
header->tp_len);
+			if( err )
+				goto out_free;
+
+#endif
+
+			/* fill skb with proto, device and priority */
+			skb->protocol =3D proto;
+			skb->dev =3D dev;
+			skb->priority =3D sk->sk_priority;
+
+
+			/* now send it */
+			err =3D dev_queue_xmit(skb);
+			if (err > 0 && (err =3D net_xmit_errno(err)) !=3D 0)
+				goto out_free;
+
+#ifndef CONFIG_PACKET_MMAP_ZERO_COPY
+			/* reset flag of buffer as data has been copied into skb */
+			header->tp_status =3D TP_STATUS_KERNEL;
+#endif
+			len_sum +=3D skb->len;
+		}
+	}
+	dev_put(dev);
+
+	return(len_sum);
+
+out_free:
+	kfree_skb(skb);
+out_put:
+	if (dev)
+		dev_put(dev);
+out:
+	return err;
+}
+#endif
+
+/*
+ * Normal packet send function
+ * */
+static int packet_snd(struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk =3D sock->sk;
@@ -705,14 +908,13 @@ static int packet_sendmsg(struct kiocb *iocb,
struct socket *sock,
 	__be16 proto;
 	unsigned char *addr;
 	int ifindex, err, reserve =3D 0;
+	struct packet_sock *po =3D pkt_sk(sk);

 	/*
 	 *	Get and verify the address.
 	 */

 	if (saddr =3D=3D NULL) {
-		struct packet_sock *po =3D pkt_sk(sk);
-
 		ifindex	=3D po->ifindex;
 		proto	=3D po->num;
 		addr	=3D NULL;
@@ -786,6 +988,23 @@ out:
 	return err;
 }

+static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
+													struct msghdr *msg, size_t len)
+{
+	struct sock *sk =3D sock->sk;
+	struct packet_sock *po =3D pkt_sk(sk);
+	//printk("tpacket TX sendmsg\n");
+
+	/* check if tx ring mode enabled */
+#ifdef CONFIG_PACKET_MMAP
+	if (po->mode =3D=3D TPACKET_MODE_TX)
+		return tpacket_snd(sock, msg, len);
+	else
+#endif
+		return packet_snd(sock, msg, len);
+
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -827,7 +1046,7 @@ static int packet_release(struct socket *sock)
 	if (po->pg_vec) {
 		struct tpacket_req req;
 		memset(&req, 0, sizeof(req));
-		packet_set_ring(sk, &req, 1);
+		packet_set_ring(sk, &req, 1, TPACKET_MODE_NONE);
 	}
 #endif

@@ -875,7 +1094,11 @@ static int packet_do_bind(struct sock *sk,
struct net_device *dev, __be16 protoc
 	po->prot_hook.dev =3D dev;

 	po->ifindex =3D dev ? dev->ifindex : 0;
-
+#ifdef CONFIG_PACKET_MMAP_ZERO_COPY
+	po->header_size =3D dev ? (LL_RESERVED_SPACE(dev) + sizeof(struct
tpacket_hdr) + sizeof(struct sk_buff)) : 0;
+#else
+	po->header_size =3D sizeof(struct tpacket_hdr);
+#endif
 	if (protocol =3D=3D 0)
 		goto out_unlock;

@@ -1015,6 +1238,12 @@ static int packet_create(struct net *net,
struct socket *sock, int protocol)
 		po->running =3D 1;
 	}

+#ifdef CONFIG_PACKET_MMAP
+	po->mode =3D TPACKET_MODE_NONE;
+	po->header_size =3D 0;
+#endif
+
+
 	write_lock_bh(&net->packet.sklist_lock);
 	sk_add_node(sk, &net->packet.sklist);
 	write_unlock_bh(&net->packet.sklist_lock);
@@ -1344,7 +1573,19 @@ packet_setsockopt(struct socket *sock, int
level, int optname, char __user *optv
 			return -EINVAL;
 		if (copy_from_user(&req,optval,sizeof(req)))
 			return -EFAULT;
-		return packet_set_ring(sk, &req, 0);
+				/* store packet mode */
+				return packet_set_ring(sk, &req, 0, TPACKET_MODE_RX);
+			}
+		case PACKET_TX_RING:
+			{
+				struct tpacket_req req;
+
+				if (optlen<sizeof(req))
+					return -EINVAL;
+				if (copy_from_user(&req,optval,sizeof(req)))
+					return -EFAULT;
+				/* store packet mode */
+				return packet_set_ring(sk, &req, 0, TPACKET_MODE_TX);
 	}
 	case PACKET_COPY_THRESH:
 	{
@@ -1408,6 +1649,17 @@ static int packet_getsockopt(struct socket
*sock, int level, int optname,
 		return -EINVAL;

 	switch(optname)	{
+#ifdef CONFIG_PACKET_MMAP
+		case PACKET_TX_RING_HEADER_SIZE:
+			if (len > sizeof(int))
+				len =3D sizeof(int);
+			val =3D po->header_size;
+			/* header_size should differ from 0 if device has been bind */
+			if (unlikely(val =3D=3D 0))
+				return -EACCES;
+			data =3D &val;
+			break;
+#endif
 	case PACKET_STATISTICS:
 		if (len > sizeof(struct tpacket_stats))
 			len =3D sizeof(struct tpacket_stats);
@@ -1562,7 +1814,10 @@ static unsigned int packet_poll(struct file *
file, struct socket *sock,
 	struct sock *sk =3D sock->sk;
 	struct packet_sock *po =3D pkt_sk(sk);
 	unsigned int mask =3D datagram_poll(file, sock, wait);
+	int i;

+	/* RX RING - waiting for packet */
+	if(po->mode =3D=3D TPACKET_MODE_RX) {
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->pg_vec) {
 		unsigned last =3D po->head ? po->head-1 : po->frame_max;
@@ -1574,6 +1829,21 @@ static unsigned int packet_poll(struct file *
file, struct socket *sock,
 			mask |=3D POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
+	}
+	/* TX RING - waiting for free buffer */
+	else if(po->mode =3D=3D TPACKET_MODE_TX) {
+		if(mask & POLLOUT) {
+			mask &=3D ~POLLOUT;
+			for (i =3D 0; i < po->frame_max; i++) {
+				struct tpacket_hdr *header =3D packet_lookup_frame(po, i);
+				if(header->tp_status =3D=3D TP_STATUS_KERNEL)
+				{
+					mask |=3D POLLOUT;
+					break;
+				}
+			}
+		}
+	}
 	return mask;
 }

@@ -1649,7 +1919,7 @@ out_free_pgvec:
 	goto out;
 }

-static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
int closing)
+	static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
int closing ,int mode)
 {
 	char **pg_vec =3D NULL;
 	struct packet_sock *po =3D pkt_sk(sk);
@@ -1657,6 +1927,9 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req, int closing
 	__be16 num;
 	int err =3D 0;

+		/* saving ring mode */
+		po->mode =3D mode;
+
 	if (req->tp_block_nr) {
 		int i;

@@ -1736,7 +2009,7 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req, int closing
 		req->tp_block_nr =3D XC(po->pg_vec_len, req->tp_block_nr);

 		po->pg_vec_pages =3D req->tp_block_size/PAGE_SIZE;
-		po->prot_hook.func =3D po->pg_vec ? tpacket_rcv : packet_rcv;
+		po->prot_hook.func =3D (po->pg_vec && (po->mode =3D=3D TPACKET_MODE_=
RX))
? tpacket_rcv : packet_rcv;
 		skb_queue_purge(&sk->sk_receive_queue);
 #undef XC
 		if (atomic_read(&po->mapped))
