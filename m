From: "john ye" <johny@asimco.com.cn>
Subject: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing tcp socket be atomic
Date: Wed, 3 Feb 2010 17:12:33 +0800
Message-ID: <474C17045AA24E3F8519EE76BAB47439@JOHNYE1>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312;
	format=flowed	reply-type=original
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>, <jmorris@namei.org>, <kaber@coreworks.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Subject: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing tcp =
socket be atomic
from: John Ye <johny@asimco.com.cn>

Writing tcp socket is not atomic in current kernel. When a socket is wr=
itten by
multi-processes or threads,the other end will read interleaved garbage =
data.

This simple patch is to resolve this issue, to make the stream socket w=
riting
be atomic under certain data size limit.

Similar to file system pipe ( with a max atomic write limit ), an atomi=
c
socket can be written by multi processes or threads.

But it=A1=AFs more than pipe. The pipe can only be used by multi proces=
ses in a
local system, the atomic stream socket can be used remotely to send dat=
a
among machines without user level locking involved.

How to test this patch:
1) apply the patch to kernel and modules, reboot from the new patched k=
ernel
2) #define TCP_ATOMIC 20 in your test.c (TCP_ATOMIC is defined as 20 in=
 kernel)
3) create a tcp socket, set the atomic option.
for example:
        int val =3D 512;
        int len =3D 4;
        if(setsockopt(s, IPPROTO_TCP, TCP_ATOMIC, &val, len) =3D=3D -1)=
 {
                perror("setsockopt");
                return -1 ;
        }
will set the atomic max data size to 512 bytes

to get the current atomic size for socket s,
        val =3D 0;
        len =3D 4;
        if(getsockopt(s, IPPROTO_TCP, TCP_ATOMIC, &val, &len) =3D=3D -1=
) {
                perror("setsockopt");
                return -1 ;
        }


4) Then, connect to a tcp server, fork a child process.
let both main process and child process write() or send() its own data =
block to the server.
=46rom the server, the received data bytes will be interleaved if no TC=
P_ATOMIC is set.
(I have a testing c code ready)

Signed-off-by: John Ye (Seeker) johny@asimco.com.cn

---


--- linux/net/ipv4/tcp.c        2008-12-05 09:48:57.000000000 +0800
+++ linux/net/ipv4/tcp.c        2010-02-03 15:15:11.000000000 +0800
@@ -822,6 +822,7 @@
        int mss_now, size_goal;
        int err, copied;
        long timeo;
+       int atomic;     /* is atomic write? johnye. Feb 2, 2010 */

        lock_sock(sk);
        TCP_CHECK_TIMER(sk);
@@ -849,6 +850,11 @@
        if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
                goto do_error;

+
+        /* for multi-seg data or too big chunk, no atomic. johnye. */
+       atomic =3D tp->atomic_size;
+        if(iovlen > 1 || iov->iov_len > atomic) atomic =3D 0;
+
        while (--iovlen >=3D 0) {
                int seglen =3D iov->iov_len;
                unsigned char __user *from =3D iov->iov_base;
@@ -889,14 +895,28 @@
                        if (copy > seglen)
                                copy =3D seglen;

+                       /* if atomic write. johnye */
+                       if (atomic)
+                               copy =3D seglen;
+
                        /* Where to copy to? */
                        if (skb_tailroom(skb) > 0) {
                                /* We have some space in skb head. Supe=
rb! */
-                               if (copy > skb_tailroom(skb))
+                               /* consider atomic write, johnye */
+                               if (copy > skb_tailroom(skb)) {
+                                       if(atomic)
+                                           goto skb_page_start;       =
 /* q mark yet, johnye */
+
                                        copy =3D skb_tailroom(skb);
+                               }
                                if ((err =3D skb_add_data(skb, from, co=
py)) !=3D 0)
                                        goto do_fault;
-                       } else {
+
+                               goto skb_page_done;
+                       //} else {
+                       }
+                       skb_page_start:
+                       {
                                int merge =3D 0;
                                int i =3D skb_shinfo(skb)->nr_frags;
                                struct page *page =3D TCP_PAGE(sk);
@@ -925,8 +945,17 @@
                                } else
                                        off =3D 0;

-                               if (copy > PAGE_SIZE - off)
-                                       copy =3D PAGE_SIZE - off;
+                               /* consider atomic write, johnye */
+                               if (copy > PAGE_SIZE - off) {
+                                       if (atomic && page) {
+                                                put_page(page);
+                                                TCP_PAGE(sk) =3D page =
=3D NULL;
+                                                off =3D 0;
+                                               merge =3D 0;
+                                       } else {
+                                               copy =3D PAGE_SIZE - of=
f;
+                                       }
+                               }

                                if (!sk_wmem_schedule(sk, copy))
                                        goto wait_for_memory;
@@ -968,6 +997,7 @@

                                TCP_OFF(sk) =3D off + copy;
                        }
+                       skb_page_done:

                        if (!copied)
                                TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG=
_PSH;
@@ -2019,6 +2049,16 @@
        lock_sock(sk);

        switch (optname) {
+
+       /* set the atomic write max size. johnye */
+        case TCP_ATOMIC:
+               if(val > 1024) {
+                       err =3D -EINVAL;
+                       break;
+               }
+               tp->atomic_size =3D val;
+               break;
+
        case TCP_MAXSEG:
                /* Values greater than interface MTU won't take effect.=
 However
                 * at the point when this call is done we typically don=
't yet
@@ -2276,6 +2316,12 @@
                return -EINVAL;

        switch (optname) {
+
+       /* get the atomic write max size. johnye */
+       case TCP_ATOMIC:
+               val =3D tp->atomic_size;
+               break;
+
        case TCP_MAXSEG:
                val =3D tp->mss_cache;
                if (!val && ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_L=
ISTEN)))
--- linux/include/linux/tcp.h   2008-10-10 06:13:53.000000000 +0800
+++ linux/include/linux/tcp.h   2010-02-03 13:54:55.000000000 +0800
@@ -97,6 +97,8 @@
 #define TCP_CONGESTION         13      /* Congestion control algorithm=
 */
 #define TCP_MD5SIG             14      /* TCP MD5 Signature (RFC2385) =
*/

+#define        TCP_ATOMIC              20      /* atomic TCP socket wr=
itting */
+
 #define TCPI_OPT_TIMESTAMPS    1
 #define TCPI_OPT_SACK          2
 #define TCPI_OPT_WSCALE                4
@@ -411,6 +413,7 @@
 #endif

        int                     linger2;
+       u32                     atomic_size;    /* for atomic tcp socke=
t write, johnye. Feb 2, 2010 */
 };

 static inline struct tcp_sock *tcp_sk(const struct sock *sk)


---=20
