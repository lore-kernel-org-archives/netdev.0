From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 4/5] net/x25: push BKL usage into x25_proto
Date: Thu, 12 Nov 2009 16:18:42 +1100
Message-ID: <d45a3acc0911112118j256136b7i99acf3fd7a7aacaa@mail.gmail.com>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
	 <1257431850-20874-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Henner Eisen <eis@baty.hanse.de>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-x25-owner@vger.kernel.org>
In-Reply-To: <1257431850-20874-5-git-send-email-arnd@arndb.de>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46or anyone who looking at the next step, be aware there is an existin=
g
bug in this area.

With single threaded x.25 processes and light X.25 traffic over time
'dead sockets' hang around. They sometimes have negative values in the
inode field and all the timers are timed out. When they exist rmmod
x25 will crash the system, even though lsmod shows 0 usage if all x.25
programs are shutdown.

# cat /proc/net/x25/socket
dest_addr  src_addr   dev   lci st vs vr va   t  t2 t21 t22 t23 Snd-Q
Rcv-Q inode
0505xxxxxxxxx 0505xxxxxxxxx x25tap0 000  0  0  0  0   0   3 200 180
180     0     0 6198164303842135440
0505xxxxxxxxx 0505xxxxxxxxx x25tap0 000  0  0  0  0   0   3 200 180
180     0     0 111073138
They can be reproduced faster with threaded client/server test
programs doing connect/disconnect. No time to look further at the
moment, but I can help test.


On Fri, Nov 6, 2009 at 1:37 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The x25 driver uses lock_kernel() implicitly through
> its proto_ops wrapper. The makes the usage explicit
> in order to get rid of that wrapper and to better document
> the usage of the BKL.
>
> The next step should be to get rid of the usage of the BKL
> in x25 entirely, which requires understanding what data
> structures need serialized accesses.
>
> Cc: Henner Eisen <eis@baty.hanse.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: linux-x25@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> =A0net/x25/af_x25.c | =A0 71 ++++++++++++++++++++++++++++++++++++++++=
+++++--------
> =A01 files changed, 60 insertions(+), 11 deletions(-)
>
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index 7fa9c7a..a7a4bc2 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -415,6 +415,7 @@ static int x25_setsockopt(struct socket *sock, in=
t level, int optname,
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0int rc =3D -ENOPROTOOPT;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (level !=3D SOL_X25 || optname !=3D X25_QBITINCL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -429,6 +430,7 @@ static int x25_setsockopt(struct socket *sock, in=
t level, int optname,
> =A0 =A0 =A0 =A0x25_sk(sk)->qbitincl =3D !!opt;
> =A0 =A0 =A0 =A0rc =3D 0;
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -438,6 +440,7 @@ static int x25_getsockopt(struct socket *sock, in=
t level, int optname,
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0int val, len, rc =3D -ENOPROTOOPT;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (level !=3D SOL_X25 || optname !=3D X25_QBITINCL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -458,6 +461,7 @@ static int x25_getsockopt(struct socket *sock, in=
t level, int optname,
> =A0 =A0 =A0 =A0val =3D x25_sk(sk)->qbitincl;
> =A0 =A0 =A0 =A0rc =3D copy_to_user(optval, &val, len) ? -EFAULT : 0;
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -466,12 +470,14 @@ static int x25_listen(struct socket *sock, int =
backlog)
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0int rc =3D -EOPNOTSUPP;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (sk->sk_state !=3D TCP_LISTEN) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(&x25_sk(sk)->dest_addr, 0, X25_=
ADDR_LEN);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_max_ack_backlog =3D backlog;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_state =A0 =A0 =A0 =A0 =A0 =3D T=
CP_LISTEN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D 0;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 unlock_kernel();
>
> =A0 =A0 =A0 =A0return rc;
> =A0}
> @@ -597,6 +603,7 @@ static int x25_release(struct socket *sock)
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct x25_sock *x25;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (!sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -627,6 +634,7 @@ static int x25_release(struct socket *sock)
>
> =A0 =A0 =A0 =A0sock_orphan(sk);
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -634,18 +642,23 @@ static int x25_bind(struct socket *sock, struct=
 sockaddr *uaddr, int addr_len)
> =A0{
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct sockaddr_x25 *addr =3D (struct sockaddr_x25 *)u=
addr;
> + =A0 =A0 =A0 int rc =3D 0;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (!sock_flag(sk, SOCK_ZAPPED) ||
> =A0 =A0 =A0 =A0 =A0 =A0addr_len !=3D sizeof(struct sockaddr_x25) ||
> - =A0 =A0 =A0 =A0 =A0 addr->sx25_family !=3D AF_X25)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 addr->sx25_family !=3D AF_X25) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0x25_sk(sk)->source_addr =3D addr->sx25_addr;
> =A0 =A0 =A0 =A0x25_insert_socket(sk);
> =A0 =A0 =A0 =A0sock_reset_flag(sk, SOCK_ZAPPED);
> =A0 =A0 =A0 =A0SOCK_DEBUG(sk, "x25_bind: socket is bound\n");
> -
> - =A0 =A0 =A0 return 0;
> +out:
> + =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 return rc;
> =A0}
>
> =A0static int x25_wait_for_connection_establishment(struct sock *sk)
> @@ -686,6 +699,7 @@ static int x25_connect(struct socket *sock, struc=
t sockaddr *uaddr,
> =A0 =A0 =A0 =A0struct x25_route *rt;
> =A0 =A0 =A0 =A0int rc =3D 0;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0lock_sock(sk);
> =A0 =A0 =A0 =A0if (sk->sk_state =3D=3D TCP_ESTABLISHED && sock->state=
 =3D=3D SS_CONNECTING) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock->state =3D SS_CONNECTED;
> @@ -763,6 +777,7 @@ out_put_route:
> =A0 =A0 =A0 =A0x25_route_put(rt);
> =A0out:
> =A0 =A0 =A0 =A0release_sock(sk);
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -802,6 +817,7 @@ static int x25_accept(struct socket *sock, struct=
 socket *newsock, int flags)
> =A0 =A0 =A0 =A0struct sk_buff *skb;
> =A0 =A0 =A0 =A0int rc =3D -EINVAL;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (!sk || sk->sk_state !=3D TCP_LISTEN)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -829,6 +845,7 @@ static int x25_accept(struct socket *sock, struct=
 socket *newsock, int flags)
> =A0out2:
> =A0 =A0 =A0 =A0release_sock(sk);
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -838,10 +855,14 @@ static int x25_getname(struct socket *sock, str=
uct sockaddr *uaddr,
> =A0 =A0 =A0 =A0struct sockaddr_x25 *sx25 =3D (struct sockaddr_x25 *)u=
addr;
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct x25_sock *x25 =3D x25_sk(sk);
> + =A0 =A0 =A0 int rc =3D 0;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (peer) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_state !=3D TCP_ESTABLISHED)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOTCONN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_state !=3D TCP_ESTABLISHED) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -ENOTCONN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sx25->sx25_addr =3D x25->dest_addr;
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sx25->sx25_addr =3D x25->source_addr;
> @@ -849,7 +870,21 @@ static int x25_getname(struct socket *sock, stru=
ct sockaddr *uaddr,
> =A0 =A0 =A0 =A0sx25->sx25_family =3D AF_X25;
> =A0 =A0 =A0 =A0*uaddr_len =3D sizeof(*sx25);
>
> - =A0 =A0 =A0 return 0;
> +out:
> + =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 return rc;
> +}
> +
> +static unsigned int x25_datagram_poll(struct file *file, struct sock=
et *sock,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0poll_table *wait=
)
> +{
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 lock_kernel();
> + =A0 =A0 =A0 rc =3D datagram_poll(file, sock, wait);
> + =A0 =A0 =A0 unlock_kernel();
> +
> + =A0 =A0 =A0 return rc;
> =A0}
>
> =A0int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
> @@ -1002,6 +1037,7 @@ static int x25_sendmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0size_t size;
> =A0 =A0 =A0 =A0int qbit =3D 0, rc =3D -EINVAL;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_OOB|MSG_EOR|MS=
G_CMSG_COMPAT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -1166,6 +1202,7 @@ static int x25_sendmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0release_sock(sk);
> =A0 =A0 =A0 =A0rc =3D len;
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0out_kfree_skb:
> =A0 =A0 =A0 =A0kfree_skb(skb);
> @@ -1186,6 +1223,7 @@ static int x25_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0unsigned char *asmptr;
> =A0 =A0 =A0 =A0int rc =3D -ENOTCONN;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * This works for seqpacket too. The receiver has orde=
red the queue for
> =A0 =A0 =A0 =A0 * us! We do one quick check first though
> @@ -1259,6 +1297,7 @@ static int x25_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0out_free_dgram:
> =A0 =A0 =A0 =A0skb_free_datagram(sk, skb);
> =A0out:
> + =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -1270,6 +1309,7 @@ static int x25_ioctl(struct socket *sock, unsig=
ned int cmd, unsigned long arg)
> =A0 =A0 =A0 =A0void __user *argp =3D (void __user *)arg;
> =A0 =A0 =A0 =A0int rc;
>
> + =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0switch (cmd) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case TIOCOUTQ: {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int amount =3D sk->sk_=
sndbuf - sk_wmem_alloc_get(sk);
> @@ -1472,6 +1512,7 @@ static int x25_ioctl(struct socket *sock, unsig=
ned int cmd, unsigned long arg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -ENOIOCTLCMD;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 unlock_kernel();
>
> =A0 =A0 =A0 =A0return rc;
> =A0}
> @@ -1542,15 +1583,19 @@ static int compat_x25_ioctl(struct socket *so=
ck, unsigned int cmd,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCGSTAMP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D compat_sock_get=
_timestamp(sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0(struct timeval __user*)argp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCGSTAMPNS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D compat_sock_get=
_timestampns(sk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0(struct timespec __user*)argp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCGIFADDR:
> =A0 =A0 =A0 =A0case SIOCSIFADDR:
> @@ -1569,16 +1614,22 @@ static int compat_x25_ioctl(struct socket *so=
ck, unsigned int cmd,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EPERM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!capable(CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D x25_route_ioctl(cmd, argp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCX25GSUBSCRIP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D compat_x25_subscr_ioctl(cmd, ar=
gp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCX25SSUBSCRIP:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EPERM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!capable(CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D compat_x25_subscr_ioctl(cmd, ar=
gp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case SIOCX25GFACILITIES:
> =A0 =A0 =A0 =A0case SIOCX25SFACILITIES:
> @@ -1600,7 +1651,7 @@ static int compat_x25_ioctl(struct socket *sock=
, unsigned int cmd,
> =A0}
> =A0#endif
>
> -static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) =3D {
> +static const struct proto_ops x25_proto_ops =3D {
> =A0 =A0 =A0 =A0.family =3D =A0 =A0 =A0 AF_X25,
> =A0 =A0 =A0 =A0.owner =3D =A0 =A0 =A0 =A0THIS_MODULE,
> =A0 =A0 =A0 =A0.release =3D =A0 =A0 =A0x25_release,
> @@ -1609,7 +1660,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(x=
25_proto_ops) =3D {
> =A0 =A0 =A0 =A0.socketpair =3D =A0 sock_no_socketpair,
> =A0 =A0 =A0 =A0.accept =3D =A0 =A0 =A0 x25_accept,
> =A0 =A0 =A0 =A0.getname =3D =A0 =A0 =A0x25_getname,
> - =A0 =A0 =A0 .poll =3D =A0 =A0 =A0 =A0 datagram_poll,
> + =A0 =A0 =A0 .poll =3D =A0 =A0 =A0 =A0 x25_datagram_poll,
> =A0 =A0 =A0 =A0.ioctl =3D =A0 =A0 =A0 =A0x25_ioctl,
> =A0#ifdef CONFIG_COMPAT
> =A0 =A0 =A0 =A0.compat_ioctl =3D compat_x25_ioctl,
> @@ -1624,8 +1675,6 @@ static const struct proto_ops SOCKOPS_WRAPPED(x=
25_proto_ops) =3D {
> =A0 =A0 =A0 =A0.sendpage =3D =A0 =A0 sock_no_sendpage,
> =A0};
>
> -SOCKOPS_WRAP(x25_proto, AF_X25);
> -
> =A0static struct packet_type x25_packet_type __read_mostly =3D {
> =A0 =A0 =A0 =A0.type =3D cpu_to_be16(ETH_P_X25),
> =A0 =A0 =A0 =A0.func =3D x25_lapb_receive_frame,
> --
> 1.6.3.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
