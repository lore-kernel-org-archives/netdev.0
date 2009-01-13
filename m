From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 00:38:32 +0100
Message-ID: <496D25F8.2080505@cosmosbay.com>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE> <20090113123702.ad29cd13.akpm@linux-foundation.org> <496D2078.9080302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Volker.Lendecke@SerNet.DE, linux-kernel@vger.kernel.org,
	Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54600 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbZAMXiy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:38:54 -0500
In-Reply-To: <496D2078.9080302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Andrew Morton a =E9crit :
>> (cc's added)
>>
>> On Thu, 8 Jan 2009 11:13:51 +0100
>> Volker Lendecke <Volker.Lendecke@SerNet.DE> wrote:
>>
>>> Hi!
>>>
>>> While implementing splice support in Samba for better
>>> performance I found it blocking when trying to pull data off
>>> tcp into a pipe when the recvq was full. Attached find a
>>> test program that shows this behaviour, on another host I
>>> started
>>>
>>> netcat 192.168.19.10 4711 < /dev/zero
>>>
>>> vlendec@lenny:~$ uname -a
>>> Linux lenny 2.6.28-06857-g5cbd04a #7 Wed Jan 7 10:10:42 CET 2009 x8=
6_64 =3D GNU/Linux
>>> vlendec@lenny:~$ gcc -o splicetest /host/home/vlendec/splicetest.c =
-O3 -Wall
>>> vlendec@lenny:~$ ./splicetest out 65536 &
>>> [1] 697
>>> vlendec@lenny:~$ strace -p 697
>>> Process 697 attached - interrupt to quit
>>> splice(0x3, 0, 0x5, 0, 0x56a0, 0x1)     =3D 22176
>>> splice(0x7, 0, 0x4, 0, 0x10000, 0x1^C <unfinished ...>
>=20
> Volker, your splice() is a blocking one, from tcp socket to a pipe ?
>=20
> If no other thread is reading the pipe, then you might block forever
> in splice_to_pipe() as soon pipe is full (16 pages).
>=20
> As pages are not necessarly full (each skb will use at least one page=
, even if=20
> its length is small), it is not really possible to use splice() like =
this.
>=20
> In your case, only safe way with current kernel would be to call spli=
ce()
> asking for no more than 16 bytes, that would be really insane for you=
r needs.
>=20
> You may prefer a non blocking mode, at least when calling splice_to_p=
ipe()
>=20
> Maybe SPLICE_F_NONBLOCK splice() flag should only apply on pipe side.
> tcp_splice_read() should not use this flag to select a blocking/nonbl=
oking
> mode on the source socket, but underlying file flag.
>=20
> This way, your program could let socket in blocking mode, yet call sp=
lice()
> with SPLICE_F_NONBLOCK flag to not block on pipe.
>=20

This patch, coupled with the previous one from Willy Tarreau=20
(tcp: splice as many packets as possible at once)
gives expected result.

[PATCH] net: splice() from tcp to socket should take into account O_NON=
BLOCK

Instead of using SPLICE_F_NONBLOCK to select a non blocking mode both o=
n
source tcp socket and pipe destination, we use the underlying file flag=
 (O_NONBLOCK)
for selecting a non blocking socket.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/linux/net.h b/include/linux/net.h
index 4515efa..10e38d1 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -185,7 +185,7 @@ struct proto_ops {
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
 				      int offset, size_t size, int flags);
-	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
+	ssize_t 	(*splice_read)(struct file *file,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flag=
s);
 };
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 218235d..e8e7f80 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -309,7 +309,7 @@ extern int			tcp_twsk_unique(struct sock *sk,
=20
 extern void			tcp_twsk_destructor(struct sock *sk);
=20
-extern ssize_t			tcp_splice_read(struct socket *sk, loff_t *ppos,
+extern ssize_t			tcp_splice_read(struct file *file, loff_t *ppos,
 					        struct pipe_inode_info *pipe, size_t len, unsigned int fl=
ags);
=20
 static inline void tcp_dec_quickack_mode(struct sock *sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ce572f9..c777d88 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -548,10 +548,11 @@ static int __tcp_splice_read(struct sock *sk, str=
uct tcp_splice_state *tss)
  *    Will read pages from given socket and fill them into a pipe.
  *
  **/
-ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
+ssize_t tcp_splice_read(struct file *file, loff_t *ppos,
 			struct pipe_inode_info *pipe, size_t len,
 			unsigned int flags)
 {
+	struct socket *sock =3D file->private_data;
 	struct sock *sk =3D sock->sk;
 	struct tcp_splice_state tss =3D {
 		.pipe =3D pipe,
@@ -572,7 +573,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t=
 *ppos,
=20
 	lock_sock(sk);
=20
-	timeo =3D sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	timeo =3D sock_rcvtimeo(sk, file->f_flags & O_NONBLOCK);
 	while (tss.len) {
 		ret =3D __tcp_splice_read(sk, &tss);
 		if (ret < 0)

