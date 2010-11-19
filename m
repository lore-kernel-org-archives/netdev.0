From: Tom Herbert <therbert@google.com>
Subject: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 12:04:31 -0800
Message-ID: <AANLkTi=WF2hAGAufv_Anc=b=Fm2WOpOMOv1UrDRvaTHp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:52730 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab0KSUEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 15:04:36 -0500
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oAJK4Zjf005754
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 12:04:35 -0800
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by hpaq3.eem.corp.google.com with ESMTP id oAJK4XMj015030
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 12:04:34 -0800
Received: by pzk35 with SMTP id 35so1369552pzk.35
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 12:04:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a project I'm contemplating.=A0 If you have any comments or can
point me to prior work in this area that would be appreciated.

It seems like should be fairly straight forward to extend the mmap
packet ring mechanisms to be used for arbitrary sockets (like TCP,
UDP, etc.). The idea is that we create a ring buffer for a socket
which is mmap'ed to share between user and kernel. =A0This can be done
for both transmit and receive side, and is basically modeled as a
consumer/producer queue. =A0There are semantic differences between
stream and datagram sockets that need to be considered, but I don't
think anything here is untenable.

The expected benefits of this are:

TX:
=A0- Zero copy transmit (which is already supported by vmsplice(), but
this might be simpler)
=A0- One system call needed on transmit which can cover multiple
datagrams or what would have been multiple writes (the call is just to
kick kernel to start sending)

RX:
=A0- Zero system calls needed to do receive (determining data ready is
accomplished by polling)
=A0- Immediate data placement in kernel available all the time,
including OOO placement
=A0- Potential for true zero copy on receive with device support (like
per flow queues, UDP queues)

The userland use of this for TCP might look something like:

struct mmap_sock_hdr {,
=A0 =A0__u32 prod_ptr;
=A0 =A0__u32 consumer_ptr;
};

int s;
struct mmap_sock_hdr *tx, *rx;
void *tx_base, *rx_base;

struct s_mmap_req {
=A0 =A0size_t size;
} mmap_req;

s =3D socket(AF_INET, SOCKET_STREAM, 0);

/* Set up ring buffer on socket and mmap into user space for TX */
size =3D 1 >> 19 - sizeof (struct mmap_sock_hdr);
mmap_req.size =A0=3D size;
setsockopt(s, SOL_SOCKET, TX_RING, (char *)&mmap_req,
sizeof(s_mmap_req));
tx =3D mmap(0, size, PROT_READ|PROT_WRITE, MAP_SHARED, s, 0);
tx_base =3D (void *)tx[1];

/* Now do same thing for RX */
size =3D 1 >> 19 - sizeof (struct mmap_sock_hdr);
mmap_req.size =A0=3D size;
setsockopt(s, SOL_SOCKET, RX_RING, (char *)&mmap_req,
sizeof(s_mmap_req));
rx =3D mmap(0, size, PROT_READ|PROT_WRITE, MAP_SHARED, s, 0);
rx_base =3D (void *)rx[1];

bind(s, ...) /* Normal bind */
connect(s, ...) /* Normal connect */

/* Transmit */

/* Application fills some of the available buffer (up to consumer point=
er) */
for (i =3D 0; i < 10000; i++)
=A0 =A0tx_base[prod_ptr + i] =3D i % 256;

/* Advance producer pointer */
prod_ptr +=3D 10000;

send(s, NULL, 0); /* Tells stack to send new data indicated by prod
pointer, just a trigger */

/* Polling for POLLOUT should work as expected */

/*********** Receive */

while (1) {
=A0 =A0poll(fds);
=A0 =A0if (s has POLLIN set) {
=A0 =A0 =A0 =A0Process data from rx_base[rx->consume_ptr] to
rx_base[rx->prod_ptr], modulo size of buffer of course
=A0 =A0 =A0 =A0rx->consume_ptr =3D rx->prod_ptr; =A0 =A0/* Gives back b=
uffer space
to the kernel */
=A0 }
}
