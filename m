From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [PATCH] Convert ax25 to seq_file
Date: Wed, 13 Aug 2003 17:34:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813173446.A2604@jeroen.pe1rxq.ampr.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org> <20030812135655.7334887b.shemminger@osdl.org> <20030812230951.E28977@jeroen.pe1rxq.ampr.org> <20030812153901.6e700dcb.shemminger@osdl.org> <20030813010301.K28977@jeroen.pe1rxq.ampr.org> <20030812172151.7de0c950.shemminger@osdl.org> <20030813031159.6c6c9629.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <shemminger@osdl.org>, linux-hams@vger.kernel.org,
   ralf@linux-mips.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S . Miller" <davem@redhat.com>
In-Reply-To: <20030813031159.6c6c9629.davem@redhat.com>; from davem@redhat.com on Wed, Aug 13, 2003 at 12:11:59 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

On 2003.08.13 12:11:59 +0200 David S. Miller wrote:
> I have a bazillion different ax.25 patches in my inbox now,
> some should be applied and others not, and this is hard to
> determine with all the activity.
> 
> Can someone send me a coherent set of patches to apply once
> all the issues have been worked out?

This is my last patch (rxq4) plus Stephen's last three (dev locking,
setsockopt, seq_file)

Jeroen

p.s. Which protocol is a good example of non-linear skb usage? Most still
seem to use skb_linearize() and the skb documentation is somewhat outdated.

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=ISO-8859-1
Content-Disposition: attachment; filename="linux-2.6.0-test3.ax25.diff"
Content-Transfer-Encoding: quoted-printable

Only in linux-2.6.0-test3.rxq/net/ax25: .af_ax25.o.cmd=0AOnly in linux-2.6.=
0-test3.rxq/net/ax25: .ax25.ko.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25=
: .ax25.mod.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .ax25.o.cmd=0AO=
nly in linux-2.6.0-test3.rxq/net/ax25: .ax25_addr.o.cmd=0AOnly in linux-2.6=
.0-test3.rxq/net/ax25: .ax25_dev.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/=
ax25: .ax25_iface.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .ax25_in.=
o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .ax25_ip.o.cmd=0AOnly in li=
nux-2.6.0-test3.rxq/net/ax25: .ax25_out.o.cmd=0AOnly in linux-2.6.0-test3.r=
xq/net/ax25: .ax25_route.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .a=
x25_std_in.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .ax25_std_subr.o=
.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .ax25_std_timer.o.cmd=0AOnly=
 in linux-2.6.0-test3.rxq/net/ax25: .ax25_subr.o.cmd=0AOnly in linux-2.6.0-=
test3.rxq/net/ax25: .ax25_timer.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/a=
x25: .ax25_uid.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .built-in.o.=
cmd=0AOnly in linux-2.6.0-test3.rxq/net/ax25: .sysctl_net_ax25.o.cmd=0Adiff=
 -ru linux-2.6.0-test3/net/ax25/af_ax25.c linux-2.6.0-test3.rxq/net/ax25/af=
_ax25.c=0A--- linux-2.6.0-test3/net/ax25/af_ax25.c	2003-08-09 06:41:26.0000=
00000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25/af_ax25.c	2003-08-13 00:29=
:48.000000000 +0200=0A@@ -51,54 +51,27 @@=0A =0A =0A =0A-ax25_cb *ax25_list=
;=0A+HLIST_HEAD(ax25_list);=0A spinlock_t ax25_list_lock =3D SPIN_LOCK_UNLO=
CKED;=0A =0A static struct proto_ops ax25_proto_ops;=0A =0A-/*=0A- *	Free a=
n allocated ax25 control block. This is done to centralise=0A- *	the MOD co=
unt code.=0A- */=0A-void ax25_free_cb(ax25_cb *ax25)=0A-{=0A-	if (ax25->dig=
ipeat !=3D NULL) {=0A-		kfree(ax25->digipeat);=0A-		ax25->digipeat =3D NULL=
;=0A-	}=0A-=0A-	kfree(ax25);=0A-}=0A-=0A static void ax25_free_sock(struct =
sock *sk)=0A {=0A-	ax25_free_cb(ax25_sk(sk));=0A+	ax25_cb_put(ax25_sk(sk));=
=0A }=0A =0A /*=0A  *	Socket removal during an interrupt is now safe.=0A  *=
/=0A-static void ax25_remove_socket(ax25_cb *ax25)=0A+static void ax25_cb_d=
el(ax25_cb *ax25)=0A {=0A-	ax25_cb *s;=0A-=0A-	spin_lock_bh(&ax25_list_lock=
);=0A-	if ((s =3D ax25_list) =3D=3D ax25) {=0A-		ax25_list =3D s->next;=0A+=
	if (!hlist_unhashed(&ax25->ax25_node)) {=0A+		spin_lock_bh(&ax25_list_lock=
);=0A+		hlist_del_init(&ax25->ax25_node);=0A 		spin_unlock_bh(&ax25_list_lo=
ck);=0A-		return;=0A-	}=0A-=0A-	while (s !=3D NULL && s->next !=3D NULL) {=
=0A-		if (s->next =3D=3D ax25) {=0A-			s->next =3D ax25->next;=0A-			spin_u=
nlock_bh(&ax25_list_lock);=0A-			return;=0A-		}=0A-=0A-		s =3D s->next;=0A+=
		ax25_cb_put(ax25);=0A 	}=0A-	spin_unlock_bh(&ax25_list_lock);=0A }=0A =0A=
 /*=0A@@ -108,12 +81,13 @@=0A {=0A 	ax25_dev *ax25_dev;=0A 	ax25_cb *s;=0A+=
	struct hlist_node *node;=0A =0A 	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =
=3D=3D NULL)=0A 		return;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s=
 =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &a=
x25_list) {=0A 		if (s->ax25_dev =3D=3D ax25_dev) {=0A 			s->ax25_dev =3D N=
ULL;=0A 			ax25_disconnect(s, ENETUNREACH);=0A@@ -153,11 +127,11 @@=0A /*=
=0A  *	Add a socket to the bound sockets list.=0A  */=0A-void ax25_insert_s=
ocket(ax25_cb *ax25)=0A+void ax25_cb_add(ax25_cb *ax25)=0A {=0A 	spin_lock_=
bh(&ax25_list_lock);=0A-	ax25->next =3D ax25_list;=0A-	ax25_list  =3D ax25;=
=0A+	ax25_cb_hold(ax25);=0A+	hlist_add_head(&ax25->ax25_node, &ax25_list);=
=0A 	spin_unlock_bh(&ax25_list_lock);=0A }=0A =0A@@ -169,17 +143,18 @@=0A 	=
struct net_device *dev, int type)=0A {=0A 	ax25_cb *s;=0A+	struct hlist_nod=
e *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D ax25_list; s=
 !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_list) {=0A 		=
if ((s->iamdigi && !digi) || (!s->iamdigi && digi))=0A 			continue;=0A 		if=
 (s->sk && !ax25cmp(&s->source_addr, addr) &&=0A 		    s->sk->sk_type =3D=
=3D type && s->sk->sk_state =3D=3D TCP_LISTEN) {=0A 			/* If device is null=
 we match any device */=0A 			if (s->ax25_dev =3D=3D NULL || s->ax25_dev->d=
ev =3D=3D dev) {=0A+				sock_hold(s->sk);=0A 				spin_unlock_bh(&ax25_list_=
lock);=0A-=0A 				return s->sk;=0A 			}=0A 		}=0A@@ -197,9 +172,10 @@=0A {=
=0A 	struct sock *sk =3D NULL;=0A 	ax25_cb *s;=0A+	struct hlist_node *node;=
=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D ax25_list; s !=3D NU=
LL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_list) {=0A 		if (s->s=
k && !ax25cmp(&s->source_addr, my_addr) &&=0A 		    !ax25cmp(&s->dest_addr,=
 dest_addr) &&=0A 		    s->sk->sk_type =3D=3D type) {=0A@@ -223,9 +199,10 @=
@=0A 	ax25_digi *digi, struct net_device *dev)=0A {=0A 	ax25_cb *s;=0A+	str=
uct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D=
 ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_=
list) {=0A 		if (s->sk && s->sk->sk_type !=3D SOCK_SEQPACKET)=0A 			continu=
e;=0A 		if (s->ax25_dev =3D=3D NULL)=0A@@ -240,6 +217,7 @@=0A 				if (s->di=
gipeat !=3D NULL && s->digipeat->ndigi !=3D 0)=0A 					continue;=0A 			}=0A=
+			ax25_cb_hold(s);=0A 			spin_unlock_bh(&ax25_list_lock);=0A =0A 			retur=
n s;=0A@@ -257,9 +235,10 @@=0A {=0A 	struct sock *sk =3D NULL;=0A 	ax25_cb =
*s;=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-=
	for (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, n=
ode, &ax25_list) {=0A 		if (s->sk !=3D NULL && ax25cmp(&s->source_addr, add=
r) =3D=3D 0 &&=0A 		    s->sk->sk_type =3D=3D SOCK_RAW) {=0A 			sk =3D s->s=
k;=0A@@ -267,6 +246,7 @@=0A 			break;=0A 		}=0A 	}=0A+=0A 	spin_unlock_bh(&=
ax25_list_lock);=0A =0A 	return sk;=0A@@ -299,7 +279,16 @@=0A  */=0A static=
 void ax25_destroy_timer(unsigned long data)=0A {=0A-	ax25_destroy_socket((=
ax25_cb *)data);=0A+	ax25_cb *ax25=3D(ax25_cb *)data;=0A+	struct sock *sk;=
=0A+	=0A+	sk=3Dax25->sk;=0A+	=0A+	bh_lock_sock(sk);=0A+	sock_hold(sk);=0A+	=
ax25_destroy_socket(ax25);=0A+	bh_unlock_sock(sk);=0A+	sock_put(sk);=0A }=
=0A =0A /*=0A@@ -312,7 +301,7 @@=0A {=0A 	struct sk_buff *skb;=0A =0A-	ax25=
_remove_socket(ax25);=0A+	ax25_cb_del(ax25);=0A =0A 	ax25_stop_heartbeat(ax=
25);=0A 	ax25_stop_t1timer(ax25);=0A@@ -337,22 +326,27 @@=0A =0A 			kfree_s=
kb(skb);=0A 		}=0A+		while ((skb =3D skb_dequeue(&ax25->sk->sk_write_queue)=
) !=3D NULL) {=0A+			kfree_skb(skb);=0A+		}=0A 	}=0A =0A 	if (ax25->sk !=3D=
 NULL) {=0A 		if (atomic_read(&ax25->sk->sk_wmem_alloc) ||=0A 		    atomic_=
read(&ax25->sk->sk_rmem_alloc)) {=0A 			/* Defer: outstanding buffers */=0A=
-			init_timer(&ax25->timer);=0A-			ax25->timer.expires  =3D jiffies + 10 *=
 HZ;=0A-			ax25->timer.function =3D ax25_destroy_timer;=0A-			ax25->timer.d=
ata     =3D (unsigned long)ax25;=0A-			add_timer(&ax25->timer);=0A+			init_=
timer(&ax25->dtimer);=0A+			ax25->dtimer.expires  =3D jiffies + 2 * HZ;=0A+=
			ax25->dtimer.function =3D ax25_destroy_timer;=0A+			ax25->dtimer.data   =
  =3D (unsigned long)ax25;=0A+			add_timer(&ax25->dtimer);=0A 		} else {=0A=
-			sock_put(ax25->sk);=0A+			struct sock *sk=3Dax25->sk;=0A+			ax25->sk=3D=
NULL;=0A+			sock_put(sk);=0A 		}=0A 	} else {=0A-		ax25_free_cb(ax25);=0A+	=
	ax25_cb_put(ax25);=0A 	}=0A }=0A =0A@@ -421,7 +415,7 @@=0A =0A   	case AX2=
5_N2:=0A   		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 31)=0A-  			return -EIN=
VAL;=0A+			return -EINVAL;=0A   		ax25->n2count =3D 0;=0A   		ax25->n2 =3D =
ax25_ctl.arg;=0A   		break;=0A@@ -448,7 +442,7 @@=0A   		return -EINVAL;=0A=
 	  }=0A =0A-	  return 0;=0A+	return 0;=0A }=0A =0A /*=0A@@ -507,6 +501,7 @=
@=0A 		return NULL;=0A =0A 	memset(ax25, 0x00, sizeof(*ax25));=0A+	atomic_s=
et(&ax25->refcount, 1);=0A =0A 	skb_queue_head_init(&ax25->write_queue);=0A=
 	skb_queue_head_init(&ax25->frag_queue);=0A@@ -655,6 +650,7 @@=0A 		   (so=
ck->state !=3D SS_UNCONNECTED ||=0A 		    sk->sk_state =3D=3D TCP_LISTEN)) =
{=0A 			res =3D -EADDRNOTAVAIL;=0A+			dev_put(dev);=0A 			break;=0A 		}=0A =
=0A@@ -877,7 +873,7 @@=0A 		break;=0A 	default:=0A 		sk_free(sk);=0A-		ax25=
_free_cb(ax25);=0A+		ax25_cb_put(ax25);=0A 		return NULL;=0A 	}=0A =0A@@ -9=
37,6 +933,7 @@=0A 	if (sk =3D=3D NULL)=0A 		return 0;=0A =0A+	sock_hold(sk)=
;=0A 	lock_sock(sk);=0A 	ax25 =3D ax25_sk(sk);=0A =0A@@ -944,13 +941,15 @@=
=0A 		switch (ax25->state) {=0A 		case AX25_STATE_0:=0A 			ax25_disconnect(=
ax25, 0);=0A-			goto drop;=0A+			ax25_destroy_socket(ax25);=0A+			break;=0A=
 =0A 		case AX25_STATE_1:=0A 		case AX25_STATE_2:=0A 			ax25_send_control(a=
x25, AX25_DISC, AX25_POLLON, AX25_COMMAND);=0A 			ax25_disconnect(ax25, 0);=
=0A-			goto drop;=0A+			ax25_destroy_socket(ax25);=0A+			break;=0A =0A 		ca=
se AX25_STATE_3:=0A 		case AX25_STATE_4:=0A@@ -993,16 +992,14 @@=0A 		sk->s=
k_shutdown |=3D SEND_SHUTDOWN;=0A 		sk->sk_state_change(sk);=0A 		sock_set_=
flag(sk, SOCK_DEAD);=0A-		goto drop;=0A+		ax25_destroy_socket(ax25);=0A 	}=
=0A =0A 	sock->sk   =3D NULL;=0A 	sk->sk_socket =3D NULL;	/* Not used, but =
we should do this */=0A 	release_sock(sk);=0A-	return 0;=0A- drop:=0A-	rele=
ase_sock(sk);=0A-	ax25_destroy_socket(ax25);=0A+	sock_put(sk);=0A+=0A 	retu=
rn 0;=0A }=0A =0A@@ -1077,7 +1074,7 @@=0A 		ax25_fillin_cb(ax25, ax25_dev);=
=0A =0A done:=0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_add(ax25);=0A 	sk->=
sk_zapped =3D 0;=0A =0A out:=0A@@ -1093,7 +1090,7 @@=0A 	int addr_len, int =
flags)=0A {=0A 	struct sock *sk =3D sock->sk;=0A-	ax25_cb *ax25 =3D ax25_sk=
(sk);=0A+	ax25_cb *ax25 =3D ax25_sk(sk), *ax25t;=0A 	struct full_sockaddr_a=
x25 *fsa =3D (struct full_sockaddr_ax25 *)uaddr;=0A 	ax25_digi *digi =3D NU=
LL;=0A 	int ct =3D 0, err =3D 0;=0A@@ -1199,7 +1196,7 @@=0A 			goto out;=0A=
 =0A 		ax25_fillin_cb(ax25, ax25->ax25_dev);=0A-		ax25_insert_socket(ax25);=
=0A+		ax25_cb_add(ax25);=0A 	} else {=0A 		if (ax25->ax25_dev =3D=3D NULL) =
{=0A 			err =3D -EHOSTUNREACH;=0A@@ -1208,11 +1205,12 @@=0A 	}=0A =0A 	if (=
sk->sk_type =3D=3D SOCK_SEQPACKET &&=0A-	    ax25_find_cb(&ax25->source_add=
r, &fsa->fsa_ax25.sax25_call, digi,=0A-		    	 ax25->ax25_dev->dev)) {=0A+	=
    (ax25t=3Dax25_find_cb(&ax25->source_addr, &fsa->fsa_ax25.sax25_call, di=
gi,=0A+		    	 ax25->ax25_dev->dev))) {=0A 		if (digi !=3D NULL)=0A 			kfre=
e(digi);=0A 		err =3D -EADDRINUSE;		/* Already such a connection */=0A+		ax=
25_cb_put(ax25t);=0A 		goto out;=0A 	}=0A =0A@@ -1273,6 +1271,8 @@=0A 				l=
ock_sock(sk);=0A 				continue;=0A 			}=0A+			current->state =3D TASK_RUNNIN=
G;=0A+			remove_wait_queue(sk->sk_sleep, &wait);=0A 			return -ERESTARTSYS;=
=0A 		}=0A 		current->state =3D TASK_RUNNING;=0A@@ -1288,10 +1288,11 @@=0A =
=0A 	sock->state =3D SS_CONNECTED;=0A =0A+	err=3D0;=0A out:=0A 	release_soc=
k(sk);=0A =0A-	return 0;=0A+	return err;=0A }=0A =0A =0A@@ -1331,15 +1332,1=
8 @@=0A 		if (skb)=0A 			break;=0A =0A-		current->state =3D TASK_INTERRUPTI=
BLE;=0A 		release_sock(sk);=0A+		current->state =3D TASK_INTERRUPTIBLE;=0A =
		if (flags & O_NONBLOCK)=0A 			return -EWOULDBLOCK;=0A 		if (!signal_pendi=
ng(tsk)) {=0A 			schedule();=0A+			current->state =3D TASK_RUNNING;=0A 			l=
ock_sock(sk);=0A 			continue;=0A 		}=0A+		current->state =3D TASK_RUNNING;=
=0A+		remove_wait_queue(sk->sk_sleep, &wait);=0A 		return -ERESTARTSYS;=0A =
	}=0A 	current->state =3D TASK_RUNNING;=0A@@ -1519,7 +1523,7 @@=0A 	SOCK_DE=
BUG(sk, "AX.25: sendto: building packet.\n");=0A =0A 	/* Assume the worst c=
ase */=0A-	size =3D len + 3 + ax25_addr_size(dp) + AX25_BPQ_HEADER_LEN;=0A+=
	size =3D len + ax25->ax25_dev->dev->hard_header_len;=0A =0A 	skb =3D sock_=
alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTWAIT, &err);=0A 	if (skb =
=3D=3D NULL)=0A@@ -1780,7 +1784,7 @@=0A =0A 		/* old structure? */=0A 		if =
(cmd =3D=3D SIOCAX25GETINFOOLD) {=0A-			static int warned;=0A+			static int=
 warned =3D 0;=0A 			if (!warned) {=0A 				printk(KERN_INFO "%s uses old SI=
OCAX25GETINFO\n",=0A 					current->comm);=0A@@ -1845,6 +1849,7 @@=0A 	int l=
en =3D 0;=0A 	off_t pos =3D 0;=0A 	off_t begin =3D 0;=0A+	struct hlist_node=
 *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A =0A@@ -1853,7 +1858,7 @@=
=0A 	 * magic dev src_addr dest_addr,digi1,digi2,.. st vs vr va t1 t1 t2 t2=
 t3 t3 idle idle n2 n2 rtt window paclen Snd-Q Rcv-Q inode=0A 	 */=0A =0A-	=
for (ax25 =3D ax25_list; ax25 !=3D NULL; ax25 =3D ax25->next) {=0A+	ax25_fo=
r_each(ax25, node, &ax25_list) {=0A 		len +=3D sprintf(buffer+len, "%8.8lx =
%s %s%s ",=0A 				(long) ax25,=0A 				ax25->ax25_dev =3D=3D NULL? "???" : a=
x25->ax25_dev->dev->name,=0A@@ -1882,10 +1887,12 @@=0A 			ax25->paclen);=0A=
 =0A 		if (ax25->sk !=3D NULL) {=0A+			bh_lock_sock(ax25->sk);=0A 			len +=
=3D sprintf(buffer + len, " %d %d %ld\n",=0A 				atomic_read(&ax25->sk->sk_=
wmem_alloc),=0A 				atomic_read(&ax25->sk->sk_rmem_alloc),=0A 				ax25->sk-=
>sk_socket !=3D NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino : 0L);=0A+			=
bh_unlock_sock(ax25->sk);=0A 		} else {=0A 			len +=3D sprintf(buffer + len=
, " * * *\n");=0A 		}=0AOnly in linux-2.6.0-test3.rxq/net/ax25: af_ax25.o=
=0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25.ko=0AOnly in linux-2.6.0-te=
st3.rxq/net/ax25: ax25.mod.c=0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25=
.mod.o=0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25.o=0AOnly in linux-2.6=
.0-test3.rxq/net/ax25: ax25_addr.o=0AOnly in linux-2.6.0-test3.rxq/net/ax25=
: ax25_dev.o=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_ds_in.c linux-2.6.0=
-test3.rxq/net/ax25/ax25_ds_in.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ds_i=
n.c	2003-08-09 06:38:45.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax2=
5/ax25_ds_in.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -65,6 +65,7 @@=0A 	=
	ax25->state   =3D AX25_STATE_3;=0A 		ax25->n2count =3D 0;=0A 		if (ax25->s=
k !=3D NULL) {=0A+			bh_lock_sock(ax25->sk);=0A 			ax25->sk->sk_state =3D T=
CP_ESTABLISHED;=0A 			/*=0A 			 * For WAIT_SABM connections we will produce=
 an accept=0A@@ -72,6 +73,7 @@=0A 			 */=0A 			if (!sock_flag(ax25->sk, SOC=
K_DEAD))=0A 				ax25->sk->sk_state_change(ax25->sk);=0A+			bh_unlock_sock(a=
x25->sk);=0A 		}=0A 		ax25_dama_on(ax25);=0A =0Adiff -ru linux-2.6.0-test3/=
net/ax25/ax25_ds_subr.c linux-2.6.0-test3.rxq/net/ax25/ax25_ds_subr.c=0A---=
 linux-2.6.0-test3/net/ax25/ax25_ds_subr.c	2003-08-09 06:41:32.000000000 +0=
200=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_ds_subr.c	2003-08-12 23:40:35=
.000000000 +0200=0A@@ -40,6 +40,7 @@=0A void ax25_ds_enquiry_response(ax25_=
cb *ax25)=0A {=0A 	ax25_cb *ax25o;=0A+	struct hlist_node *node;=0A =0A 	/* =
Please note that neither DK4EG=B4s nor DG2FEF=B4s=0A 	 * DAMA spec mention =
the following behaviour as seen=0A@@ -80,7 +81,7 @@=0A 	ax25_ds_set_timer(a=
x25->ax25_dev);=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25o =3D a=
x25_list; ax25o !=3D NULL; ax25o =3D ax25o->next) {=0A+	ax25_for_each(ax25o=
, node, &ax25_list) {=0A 		if (ax25o =3D=3D ax25)=0A 			continue;=0A =0A@@ =
-160,9 +161,10 @@=0A {=0A 	ax25_cb *ax25;=0A 	int res =3D 0;=0A+	struct hli=
st_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25 =3D ax2=
5_list; ax25 !=3D NULL ; ax25 =3D ax25->next)=0A+	ax25_for_each(ax25, node,=
 &ax25_list)=0A 		if (ax25->ax25_dev =3D=3D ax25_dev && (ax25->condition & =
AX25_COND_DAMA_MODE) && ax25->state > AX25_STATE_1) {=0A 			res =3D 1;=0A 	=
		break;=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_ds_timer.c linux-2.6.0-=
test3.rxq/net/ax25/ax25_ds_timer.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ds=
_timer.c	2003-08-09 06:41:26.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/ne=
t/ax25/ax25_ds_timer.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -74,6 +74,7=
 @@=0A {=0A 	ax25_dev *ax25_dev =3D (struct ax25_dev *) arg;=0A 	ax25_cb *a=
x25;=0A+	struct hlist_node *node;=0A =0A 	if (ax25_dev =3D=3D NULL || !ax25=
_dev->dama.slave)=0A 		return;			/* Yikes! */=0A@@ -84,7 +85,7 @@=0A 	}=0A =
=0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25=3Dax25_list; ax25 !=3D NU=
LL; ax25 =3D ax25->next) {=0A+	ax25_for_each(ax25, node, &ax25_list) {=0A 	=
	if (ax25->ax25_dev !=3D ax25_dev || !(ax25->condition & AX25_COND_DAMA_MOD=
E))=0A 			continue;=0A =0A@@ -98,15 +99,26 @@=0A =0A void ax25_ds_heartbeat=
_expiry(ax25_cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk;=0A+=0A+	if (sk)=
=0A+		bh_lock_sock(sk);=0A+=0A 	switch (ax25->state) {=0A =0A 	case AX25_ST=
ATE_0:=0A 		/* Magic here: If we listen() and a new link dies before it=0A =
		   is accepted() it isn't 'dead' so doesn't get removed. */=0A-		if (!ax2=
5->sk || sock_flag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax25->sk->sk_state =
=3D=3D TCP_LISTEN &&=0A-		     sock_flag(ax25->sk, SOCK_DEAD))) {=0A-			ax2=
5_destroy_socket(ax25);=0A+		if (!sk || sock_flag(sk, SOCK_DESTROY) ||=0A+	=
	    (sk->sk_state =3D=3D TCP_LISTEN &&=0A+		     sock_flag(sk, SOCK_DEAD))=
) {=0A+			if (sk) {=0A+				sock_hold(sk);=0A+				ax25_destroy_socket(ax25);=
=0A+				sock_put(sk);=0A+				bh_unlock_sock(sk);=0A+			} else=0A+				ax25_d=
estroy_socket(ax25);=0A 			return;=0A 		}=0A 		break;=0A@@ -115,9 +127,9 @@=
=0A 		/*=0A 		 * Check the state of the receive buffer.=0A 		 */=0A-		if (a=
x25->sk !=3D NULL) {=0A-			if (atomic_read(&ax25->sk->sk_rmem_alloc) <=0A-	=
		    (ax25->sk->sk_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) {=0A+			if (atomi=
c_read(&sk->sk_rmem_alloc) <=0A+			    (sk->sk_rcvbuf / 2) &&=0A 			    (ax=
25->condition & AX25_COND_OWN_RX_BUSY)) {=0A 				ax25->condition &=3D ~AX25=
_COND_OWN_RX_BUSY;=0A 				ax25->condition &=3D ~AX25_COND_ACK_PENDING;=0A@@=
 -127,6 +139,9 @@=0A 		break;=0A 	}=0A =0A+	if (sk)=0A+		bh_unlock_sock(sk)=
;=0A+=0A 	ax25_start_heartbeat(ax25);=0A }=0A =0A@@ -157,6 +172,7 @@=0A 	ax=
25_stop_t3timer(ax25);=0A =0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock(=
ax25->sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_err=
       =3D 0;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -164,6 +1=
80,7 @@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 			sock_set_flag(ax25=
->sk, SOCK_DEAD);=0A 		}=0A+		bh_lock_sock(ax25->sk);=0A 	}=0A }=0A =0Adiff=
 -ru linux-2.6.0-test3/net/ax25/ax25_iface.c linux-2.6.0-test3.rxq/net/ax25=
/ax25_iface.c=0A--- linux-2.6.0-test3/net/ax25/ax25_iface.c	2003-08-09 06:4=
2:13.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_iface.c	2003=
-08-12 23:40:35.000000000 +0200=0A@@ -33,20 +33,20 @@=0A 	struct protocol_s=
truct *next;=0A 	unsigned int pid;=0A 	int (*func)(struct sk_buff *, ax25_c=
b *);=0A-} *protocol_list;=0A+} *protocol_list =3D NULL;=0A static rwlock_t=
 protocol_list_lock =3D RW_LOCK_UNLOCKED;=0A =0A static struct linkfail_str=
uct {=0A 	struct linkfail_struct *next;=0A 	void (*func)(ax25_cb *, int);=
=0A-} *linkfail_list;=0A+} *linkfail_list =3D NULL;=0A static spinlock_t li=
nkfail_lock =3D SPIN_LOCK_UNLOCKED;=0A =0A static struct listen_struct {=0A=
 	struct listen_struct *next;=0A 	ax25_address  callsign;=0A 	struct net_de=
vice *dev;=0A-} *listen_list;=0A+} *listen_list =3D NULL;=0A static spinloc=
k_t listen_lock =3D SPIN_LOCK_UNLOCKED;=0A =0A int ax25_protocol_register(u=
nsigned int pid,=0A@@ -129,8 +129,10 @@=0A =0A 	spin_lock_bh(&linkfail_lock=
);=0A 	linkfail =3D linkfail_list;=0A-	if (linkfail =3D=3D NULL)=0A+	if (li=
nkfail =3D=3D NULL) {=0A+		spin_unlock_bh(&linkfail_lock);=0A 		return;=0A+=
	}=0A =0A 	if (linkfail->func =3D=3D func) {=0A 		linkfail_list =3D linkfai=
l->next;=0A@@ -180,8 +182,10 @@=0A =0A 	spin_lock_bh(&listen_lock);=0A 	lis=
ten =3D listen_list;=0A-	if (listen =3D=3D NULL)=0A+	if (listen =3D=3D NULL=
) {=0A+		spin_unlock_bh(&listen_lock);=0A 		return;=0A+	}=0A =0A 	if (ax25c=
mp(&listen->callsign, callsign) =3D=3D 0 && listen->dev =3D=3D dev) {=0A 		=
listen_list =3D listen->next;=0A@@ -226,8 +230,10 @@=0A =0A 	spin_lock_bh(&=
listen_lock);=0A 	for (listen =3D listen_list; listen !=3D NULL; listen =3D=
 listen->next)=0A-		if (ax25cmp(&listen->callsign, callsign) =3D=3D 0 && (l=
isten->dev =3D=3D dev || listen->dev =3D=3D NULL))=0A+		if (ax25cmp(&listen=
->callsign, callsign) =3D=3D 0 && (listen->dev =3D=3D dev || listen->dev =
=3D=3D NULL)) {=0A+			spin_unlock_bh(&listen_lock);=0A 			return 1;=0A+	}=
=0A 	spin_unlock_bh(&listen_lock);=0A =0A 	return 0;=0AOnly in linux-2.6.0-=
test3.rxq/net/ax25: ax25_iface.o=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25=
_in.c linux-2.6.0-test3.rxq/net/ax25/ax25_in.c=0A--- linux-2.6.0-test3/net/=
ax25/ax25_in.c	2003-08-09 06:32:47.000000000 +0200=0A+++ linux-2.6.0-test3.=
rxq/net/ax25/ax25_in.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -147,6 +147=
,7 @@=0A 	}=0A =0A 	if (ax25->sk !=3D NULL && ax25->ax25_dev->values[AX25_V=
ALUES_CONMODE] =3D=3D 2) {=0A+		bh_lock_sock(ax25->sk);=0A 		if ((!ax25->pi=
dincl && ax25->sk->sk_protocol =3D=3D pid) ||=0A 		    ax25->pidincl) {=0A =
			if (sock_queue_rcv_skb(ax25->sk, skb) =3D=3D 0)=0A@@ -154,6 +155,7 @@=0A=
 			else=0A 				ax25->condition |=3D AX25_COND_OWN_RX_BUSY;=0A 		}=0A+		bh_=
unlock_sock(ax25->sk);=0A 	}=0A =0A 	return queued;=0A@@ -329,6 +331,7 @@=
=0A 		if (ax25_process_rx_frame(ax25, skb, type, dama) =3D=3D 0)=0A 			kfre=
e_skb(skb);=0A =0A+		ax25_cb_put(ax25);=0A 		return 0;=0A 	}=0A =0A@@ -357,=
11 +360,14 @@=0A 		sk =3D ax25_find_listener(next_digi, 1, dev, SOCK_SEQPAC=
KET);=0A =0A 	if (sk !=3D NULL) {=0A+		bh_lock_sock(sk);=0A 		if (sk->sk_ac=
k_backlog =3D=3D sk->sk_max_ack_backlog ||=0A 		    (make =3D ax25_make_new=
(sk, ax25_dev)) =3D=3D NULL) {=0A 			if (mine)=0A 				ax25_return_dm(dev, &=
src, &dest, &dp);=0A 			kfree_skb(skb);=0A+			bh_unlock_sock(sk);=0A+			soc=
k_put(sk);=0A =0A 			return 0;=0A 		}=0A@@ -374,6 +380,8 @@=0A 		make->sk_p=
air  =3D sk;=0A =0A 		sk->sk_ack_backlog++;=0A+		bh_unlock_sock(sk);=0A+		s=
ock_put(sk);=0A 	} else {=0A 		if (!mine) {=0A 			kfree_skb(skb);=0A@@ -429=
,7 +437,7 @@=0A =0A 	ax25->state =3D AX25_STATE_3;=0A =0A-	ax25_insert_sock=
et(ax25);=0A+	ax25_cb_add(ax25);=0A =0A 	ax25_start_heartbeat(ax25);=0A 	ax=
25_start_t3timer(ax25);=0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25_in.o=
=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_ip.c linux-2.6.0-test3.rxq/net/=
ax25/ax25_ip.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ip.c	2003-08-09 06:34:=
43.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_ip.c	2003-08-1=
2 23:40:35.000000000 +0200=0A@@ -107,6 +107,7 @@=0A 	ax25_address *src, *ds=
t;=0A 	ax25_dev *ax25_dev;=0A 	ax25_route _route, *route =3D &_route;=0A+	a=
x25_cb *ax25;=0A =0A 	dst =3D (ax25_address *)(bp + 1);=0A 	src =3D (ax25_a=
ddress *)(bp + 8);=0A@@ -167,9 +168,14 @@=0A 			skb_pull(ourskb, AX25_HEADE=
R_LEN - 1);	/* Keep PID */=0A 			ourskb->nh.raw =3D ourskb->data;=0A =0A-		=
	ax25_send_frame(ourskb, ax25_dev->values[AX25_VALUES_PACLEN], &src_c,=0A-&=
dst_c, route->digipeat, dev);=0A-=0A+			ax25=3Dax25_send_frame(=0A+			    o=
urskb, =0A+			    ax25_dev->values[AX25_VALUES_PACLEN], =0A+			    &src_c,=
=0A+			    &dst_c, route->digipeat, dev);=0A+			if (ax25) {=0A+				ax25_cb_=
put(ax25);=0A+			}=0A 			goto put;=0A 		}=0A 	}=0AOnly in linux-2.6.0-test3=
.rxq/net/ax25: ax25_ip.o=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_out.c l=
inux-2.6.0-test3.rxq/net/ax25/ax25_out.c=0A--- linux-2.6.0-test3/net/ax25/a=
x25_out.c	2003-08-09 06:40:10.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/n=
et/ax25/ax25_out.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -71,7 +71,7 @@=
=0A =0A 	if (digi !=3D NULL) {=0A 		if ((ax25->digipeat =3D kmalloc(sizeof(=
ax25_digi), GFP_ATOMIC)) =3D=3D NULL) {=0A-			ax25_free_cb(ax25);=0A+			ax2=
5_cb_put(ax25);=0A 			return NULL;=0A 		}=0A 		memcpy(ax25->digipeat, digi,=
 sizeof(ax25_digi));=0A@@ -93,7 +93,7 @@=0A #endif=0A 	}=0A =0A-	ax25_inser=
t_socket(ax25);=0A+	ax25_cb_add(ax25);=0A =0A 	ax25->state =3D AX25_STATE_1=
;=0A =0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25_out.o=0Adiff -ru linux=
-2.6.0-test3/net/ax25/ax25_route.c linux-2.6.0-test3.rxq/net/ax25/ax25_rout=
e.c=0A--- linux-2.6.0-test3/net/ax25/ax25_route.c	2003-08-09 06:38:41.00000=
0000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_route.c	2003-08-12 23:=
40:35.000000000 +0200=0A@@ -162,6 +162,7 @@=0A 		if (ax25_rt->digipeat !=3D=
 NULL)=0A 			kfree(ax25_rt->digipeat);=0A 		kfree(ax25_rt);=0A+		return;=0A=
 	}=0A =0A 	/*=0A@@ -434,8 +435,11 @@=0A 		ax25_adjust_path(addr, ax25->dig=
ipeat);=0A 	}=0A =0A-	if (ax25->sk !=3D NULL)=0A+	if (ax25->sk !=3D NULL) {=
=0A+		bh_lock_sock(ax25->sk);=0A 		ax25->sk->sk_zapped =3D 0;=0A+		bh_unloc=
k_sock(ax25->sk);=0A+	}=0A =0A put:=0A 	ax25_put_route(ax25_rt);=0AOnly in =
linux-2.6.0-test3.rxq/net/ax25: ax25_route.o=0Adiff -ru linux-2.6.0-test3/n=
et/ax25/ax25_std_in.c linux-2.6.0-test3.rxq/net/ax25/ax25_std_in.c=0A--- li=
nux-2.6.0-test3/net/ax25/ax25_std_in.c	2003-08-09 06:39:26.000000000 +0200=
=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_std_in.c	2003-08-12 23:40:35.000=
000000 +0200=0A@@ -73,10 +73,12 @@=0A 			ax25->state   =3D AX25_STATE_3;=0A=
 			ax25->n2count =3D 0;=0A 			if (ax25->sk !=3D NULL) {=0A+				bh_lock_soc=
k(ax25->sk);=0A 				ax25->sk->sk_state =3D TCP_ESTABLISHED;=0A 				/* For W=
AIT_SABM connections we will produce an accept ready socket here */=0A 				=
if (!sock_flag(ax25->sk, SOCK_DEAD))=0A 					ax25->sk->sk_state_change(ax25=
->sk);=0A+				bh_unlock_sock(ax25->sk);=0A 			}=0A 		}=0A 		break;=0AOnly i=
n linux-2.6.0-test3.rxq/net/ax25: ax25_std_in.o=0AOnly in linux-2.6.0-test3=
.rxq/net/ax25: ax25_std_subr.o=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_s=
td_timer.c linux-2.6.0-test3.rxq/net/ax25/ax25_std_timer.c=0A--- linux-2.6.=
0-test3/net/ax25/ax25_std_timer.c	2003-08-09 06:34:03.000000000 +0200=0A+++=
 linux-2.6.0-test3.rxq/net/ax25/ax25_std_timer.c	2003-08-12 23:40:35.000000=
000 +0200=0A@@ -33,14 +33,25 @@=0A =0A void ax25_std_heartbeat_expiry(ax25_=
cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk;=0A+	=0A+	if (sk)=0A+		bh_loc=
k_sock(sk);=0A+=0A 	switch (ax25->state) {=0A 	case AX25_STATE_0:=0A 		/* M=
agic here: If we listen() and a new link dies before it=0A 		   is accepted=
() it isn't 'dead' so doesn't get removed. */=0A-		if (!ax25->sk || sock_fl=
ag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax25->sk->sk_state =3D=3D TCP_LISTE=
N &&=0A-		     sock_flag(ax25->sk, SOCK_DEAD))) {=0A-			ax25_destroy_socket=
(ax25);=0A+		if (!sk || sock_flag(sk, SOCK_DESTROY) ||=0A+		    (sk->sk_sta=
te =3D=3D TCP_LISTEN &&=0A+		     sock_flag(sk, SOCK_DEAD))) {=0A+			if (sk=
) {=0A+				sock_hold(sk);=0A+				ax25_destroy_socket(ax25);=0A+				bh_unloc=
k_sock(sk);=0A+				sock_put(sk);=0A+			} else=0A+				ax25_destroy_socket(ax=
25);=0A 			return;=0A 		}=0A 		break;=0A@@ -50,9 +61,9 @@=0A 		/*=0A 		 * C=
heck the state of the receive buffer.=0A 		 */=0A-		if (ax25->sk !=3D NULL)=
 {=0A-			if (atomic_read(&ax25->sk->sk_rmem_alloc) <=0A-			    (ax25->sk->s=
k_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) {=0A+			if (atomic_read(&sk->sk_rme=
m_alloc) <=0A+			    (sk->sk_rcvbuf / 2) &&=0A 			    (ax25->condition & AX=
25_COND_OWN_RX_BUSY)) {=0A 				ax25->condition &=3D ~AX25_COND_OWN_RX_BUSY;=
=0A 				ax25->condition &=3D ~AX25_COND_ACK_PENDING;=0A@@ -62,6 +73,9 @@=0A=
 		}=0A 	}=0A =0A+	if (sk)=0A+		bh_unlock_sock(sk);=0A+=0A 	ax25_start_hear=
tbeat(ax25);=0A }=0A =0A@@ -94,6 +108,7 @@=0A 	ax25_stop_t3timer(ax25);=0A =
=0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock(ax25->sk);=0A 		ax25->sk->=
sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_err       =3D 0;=0A 		ax25->s=
k->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -101,6 +116,7 @@=0A 			ax25->sk->sk=
_state_change(ax25->sk);=0A 			sock_set_flag(ax25->sk, SOCK_DEAD);=0A 		}=
=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A }=0A =0AOnly in linux-2.6.0-test3.=
rxq/net/ax25: ax25_std_timer.o=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_s=
ubr.c linux-2.6.0-test3.rxq/net/ax25/ax25_subr.c=0A--- linux-2.6.0-test3/ne=
t/ax25/ax25_subr.c	2003-08-09 06:41:35.000000000 +0200=0A+++ linux-2.6.0-te=
st3.rxq/net/ax25/ax25_subr.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -158,=
10 +158,10 @@=0A 	struct sk_buff *skb;=0A 	unsigned char  *dptr;=0A =0A-	if=
 ((skb =3D alloc_skb(AX25_BPQ_HEADER_LEN + ax25_addr_size(ax25->digipeat) +=
 2, GFP_ATOMIC)) =3D=3D NULL)=0A+	if ((skb =3D alloc_skb(ax25->ax25_dev->de=
v->hard_header_len + 2, GFP_ATOMIC)) =3D=3D NULL)=0A 		return;=0A =0A-	skb_=
reserve(skb, AX25_BPQ_HEADER_LEN + ax25_addr_size(ax25->digipeat));=0A+	skb=
_reserve(skb, ax25->ax25_dev->dev->hard_header_len);=0A =0A 	skb->nh.raw =
=3D skb->data;=0A =0A@@ -202,10 +202,10 @@=0A 	if (dev =3D=3D NULL)=0A 		re=
turn;=0A =0A-	if ((skb =3D alloc_skb(AX25_BPQ_HEADER_LEN + ax25_addr_size(d=
igi) + 1, GFP_ATOMIC)) =3D=3D NULL)=0A+	if ((skb =3D alloc_skb(dev->hard_he=
ader_len + 1, GFP_ATOMIC)) =3D=3D NULL)=0A 		return;	/* Next SABM will get =
DM'd */=0A =0A-	skb_reserve(skb, AX25_BPQ_HEADER_LEN + ax25_addr_size(digi)=
);=0A+	skb_reserve(skb, dev->hard_header_len);=0A 	skb->nh.raw =3D skb->dat=
a;=0A =0A 	ax25_digi_invert(digi, &retdigi);=0A@@ -282,6 +282,7 @@=0A 	ax25=
_link_failed(ax25, reason);=0A =0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_=
sock(ax25->sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->s=
k_err       =3D reason;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@=
 -289,5 +290,6 @@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 			sock_set=
_flag(ax25->sk, SOCK_DEAD);=0A 		}=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A =
}=0AOnly in linux-2.6.0-test3.rxq/net/ax25: ax25_subr.o=0Adiff -ru linux-2.=
6.0-test3/net/ax25/ax25_timer.c linux-2.6.0-test3.rxq/net/ax25/ax25_timer.c=
=0A--- linux-2.6.0-test3/net/ax25/ax25_timer.c	2003-08-09 06:38:16.00000000=
0 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25/ax25_timer.c	2003-08-12 23:40:=
35.000000000 +0200=0A@@ -141,13 +141,10 @@=0A {=0A 	int proto =3D AX25_PROT=
O_STD_SIMPLEX;=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =
=3D ax25->sk;=0A =0A 	if (ax25->ax25_dev)=0A 		proto =3D ax25->ax25_dev->va=
lues[AX25_VALUES_PROTOCOL];=0A =0A-	bh_lock_sock(sk);=0A-=0A 	switch (proto=
) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -=
163,15 +160,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=
=0A =0A static void ax25_t1timer_expiry(unsigned long param)=0A {=0A 	ax25_=
cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh=
_lock_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=
=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -185=
,15 +179,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =
=0A static void ax25_t2timer_expiry(unsigned long param)=0A {=0A 	ax25_cb *=
ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_loc=
k_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A =
	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -207,15 =
+198,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A =
static void ax25_t3timer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25=
 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_so=
ck(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	cas=
e AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -231,15 +219=
,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A stat=
ic void ax25_idletimer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25 =
=3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_soc=
k(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	case=
 AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -255,5 +240,4=
 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0AOnly in linu=
x-2.6.0-test3.rxq/net/ax25: ax25_timer.o=0AOnly in linux-2.6.0-test3.rxq/ne=
t/ax25: ax25_uid.o=0AOnly in linux-2.6.0-test3.rxq/net/ax25: built-in.o=0Ad=
iff -ru linux-2.6.0-test3/net/ax25/sysctl_net_ax25.c linux-2.6.0-test3.rxq/=
net/ax25/sysctl_net_ax25.c=0A--- linux-2.6.0-test3/net/ax25/sysctl_net_ax25=
.c	2003-08-09 06:41:21.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/ax25=
/sysctl_net_ax25.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -12,20 +12,20 @=
@=0A #include <linux/spinlock.h>=0A #include <net/ax25.h>=0A =0A-static int=
 min_ipdefmode[1],    	max_ipdefmode[] =3D {1};=0A-static int min_axdefmode=
[1],            max_axdefmode[] =3D {1};=0A-static int min_backoff[1],		max=
_backoff[] =3D {2};=0A-static int min_conmode[1],		max_conmode[] =3D {2};=
=0A+static int min_ipdefmode[] =3D {0},	max_ipdefmode[] =3D {1};=0A+static =
int min_axdefmode[] =3D {0},	max_axdefmode[] =3D {1};=0A+static int min_bac=
koff[] =3D {0},		max_backoff[] =3D {2};=0A+static int min_conmode[] =3D {0}=
,		max_conmode[] =3D {2};=0A static int min_window[] =3D {1},		max_window[]=
 =3D {7};=0A static int min_ewindow[] =3D {1},		max_ewindow[] =3D {63};=0A =
static int min_t1[] =3D {1},		max_t1[] =3D {30 * HZ};=0A static int min_t2[=
] =3D {1},		max_t2[] =3D {20 * HZ};=0A-static int min_t3[1],   		max_t3[] =
=3D {3600 * HZ};=0A-static int min_idle[1],  		max_idle[] =3D {65535 * HZ};=
=0A+static int min_t3[] =3D {0},		max_t3[] =3D {3600 * HZ};=0A+static int m=
in_idle[] =3D {0},		max_idle[] =3D {65535 * HZ};=0A static int min_n2[] =3D=
 {1},		max_n2[] =3D {31};=0A static int min_paclen[] =3D {1},		max_paclen[]=
 =3D {512};=0A-static int min_proto[1],		max_proto[] =3D {3};=0A-static int=
 min_ds_timeout[1],   	max_ds_timeout[] =3D {65535 * HZ};=0A+static int min=
_proto[] =3D {0},		max_proto[] =3D {3};=0A+static int min_ds_timeout[] =3D =
{0},	max_ds_timeout[] =3D {65535 * HZ};=0A =0A static struct ctl_table_head=
er *ax25_table_header;=0A =0A@@ -204,8 +204,10 @@=0A 	for (ax25_table_size =
=3D sizeof(ctl_table), ax25_dev =3D ax25_dev_list; ax25_dev !=3D NULL; ax25=
_dev =3D ax25_dev->next)=0A 		ax25_table_size +=3D sizeof(ctl_table);=0A =
=0A-	if ((ax25_table =3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL)=
=0A+	if ((ax25_table =3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL)=
 {=0A+		spin_unlock_bh(&ax25_dev_lock);=0A 		return;=0A+	}=0A =0A 	memset(a=
x25_table, 0x00, ax25_table_size);=0A =0AOnly in linux-2.6.0-test3.rxq/net/=
ax25: sysctl_net_ax25.o=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .af_net=
rom.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .built-in.o.cmd=0AOnl=
y in linux-2.6.0-test3.rxq/net/netrom: .netrom.ko.cmd=0AOnly in linux-2.6.0=
-test3.rxq/net/netrom: .netrom.mod.o.cmd=0AOnly in linux-2.6.0-test3.rxq/ne=
t/netrom: .netrom.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .nr_dev=
.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .nr_in.o.cmd=0AOnly in l=
inux-2.6.0-test3.rxq/net/netrom: .nr_loopback.o.cmd=0AOnly in linux-2.6.0-t=
est3.rxq/net/netrom: .nr_out.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/netr=
om: .nr_route.o.cmd=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .nr_subr.o.=
cmd=0AOnly in linux-2.6.0-test3.rxq/net/netrom: .nr_timer.o.cmd=0AOnly in l=
inux-2.6.0-test3.rxq/net/netrom: .sysctl_net_netrom.o.cmd=0Adiff -ru linux-=
2.6.0-test3/net/netrom/af_netrom.c linux-2.6.0-test3.rxq/net/netrom/af_netr=
om.c=0A--- linux-2.6.0-test3/net/netrom/af_netrom.c	2003-08-09 06:36:46.000=
000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/netrom/af_netrom.c	2003-08-12 =
23:40:35.000000000 +0200=0A@@ -147,8 +147,10 @@=0A 	spin_lock_bh(&nr_list_l=
ock);=0A 	sk_for_each(s, node, &nr_list)=0A 		if (!ax25cmp(&nr_sk(s)->sourc=
e_addr, addr) &&=0A-		    s->sk_state =3D=3D TCP_LISTEN)=0A+		    s->sk_sta=
te =3D=3D TCP_LISTEN) {=0A+		    	bh_lock_sock(s);=0A 			goto found;=0A+		}=
=0A 	s =3D NULL;=0A found:=0A 	spin_unlock_bh(&nr_list_lock);=0A@@ -167,8 +=
169,10 @@=0A 	sk_for_each(s, node, &nr_list) {=0A 		nr_cb *nr =3D nr_sk(s);=
=0A 		=0A-		if (nr->my_index =3D=3D index && nr->my_id =3D=3D id)=0A+		if (=
nr->my_index =3D=3D index && nr->my_id =3D=3D id) {=0A+			bh_lock_sock(s);=
=0A 			goto found;=0A+		}=0A 	}=0A 	s =3D NULL;=0A found:=0A@@ -190,8 +194,=
10 @@=0A 		nr_cb *nr =3D nr_sk(s);=0A 		=0A 		if (nr->your_index =3D=3D ind=
ex && nr->your_id =3D=3D id &&=0A-		    !ax25cmp(&nr->dest_addr, dest))=0A+=
		    !ax25cmp(&nr->dest_addr, dest)) {=0A+		    	bh_lock_sock(s);=0A 			go=
to found;=0A+		}=0A 	}=0A 	s =3D NULL;=0A found:=0A@@ -206,14 +212,17 @@=0A=
 {=0A 	unsigned short id =3D circuit;=0A 	unsigned char i, j;=0A+	struct so=
ck *sk;=0A =0A 	for (;;) {=0A 		i =3D id / 256;=0A 		j =3D id % 256;=0A =0A=
-		if (i !=3D 0 && j !=3D 0)=0A-			if (nr_find_socket(i, j) =3D=3D NULL)=0A=
+		if (i !=3D 0 && j !=3D 0) {=0A+			if ((sk=3Dnr_find_socket(i, j)) =3D=3D=
 NULL)=0A 				break;=0A+			bh_unlock_sock(sk);=0A+		}=0A =0A 		id++;=0A 	}=
=0A@@ -231,7 +240,12 @@=0A  */=0A static void nr_destroy_timer(unsigned lon=
g data)=0A {=0A-	nr_destroy_socket((struct sock *)data);=0A+	struct sock *s=
k=3D(struct sock *)data;=0A+	bh_lock_sock(sk);=0A+	sock_hold(sk);=0A+	nr_de=
stroy_socket(sk);=0A+	bh_unlock_sock(sk);=0A+	sock_put(sk);=0A }=0A =0A /*=
=0A@@ -264,17 +278,20 @@=0A =0A 		kfree_skb(skb);=0A 	}=0A+	while ((skb =3D=
 skb_dequeue(&sk->sk_write_queue)) !=3D NULL) {=0A+		kfree_skb(skb);=0A+	}=
=0A =0A 	if (atomic_read(&sk->sk_wmem_alloc) ||=0A 	    atomic_read(&sk->sk=
_rmem_alloc)) {=0A 		/* Defer: outstanding buffers */=0A 		init_timer(&sk->=
sk_timer);=0A-		sk->sk_timer.expires  =3D jiffies + 10 * HZ;=0A+		sk->sk_ti=
mer.expires  =3D jiffies + 2 * HZ;=0A 		sk->sk_timer.function =3D nr_destro=
y_timer;=0A 		sk->sk_timer.data     =3D (unsigned long)sk;=0A 		add_timer(&=
sk->sk_timer);=0A 	} else=0A-		sk_free(sk);=0A+		sock_put(sk);=0A }=0A =0A =
/*=0A@@ -388,12 +405,15 @@=0A {=0A 	struct sock *sk =3D sock->sk;=0A =0A+	l=
ock_sock(sk);=0A 	if (sk->sk_state !=3D TCP_LISTEN) {=0A 		memset(&nr_sk(sk=
)->user_addr, 0, AX25_ADDR_LEN);=0A 		sk->sk_max_ack_backlog =3D backlog;=
=0A 		sk->sk_state           =3D TCP_LISTEN;=0A+		release_sock(sk);=0A 		re=
turn 0;=0A 	}=0A+	release_sock(sk);=0A =0A 	return -EOPNOTSUPP;=0A }=0A@@ -=
495,6 +515,7 @@=0A =0A 	if (sk =3D=3D NULL) return 0;=0A =0A+	lock_sock(sk)=
;=0A 	nr =3D nr_sk(sk);=0A =0A 	switch (nr->state) {=0A@@ -528,6 +549,7 @@=
=0A 	}=0A =0A 	sock->sk   =3D NULL;	=0A+	release_sock(sk);=0A =0A 	return 0=
;=0A }=0A@@ -540,21 +562,26 @@=0A 	struct net_device *dev;=0A 	ax25_address=
 *user, *source;=0A =0A-	if (!sk->sk_zapped)=0A+	lock_sock(sk);=0A+	if (!sk=
->sk_zapped) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=0A-	if (addr=
_len < sizeof(struct sockaddr_ax25) || addr_len > sizeof(struct=0A-full_soc=
kaddr_ax25))=0A+	}=0A+	if (addr_len < sizeof(struct sockaddr_ax25) || addr_=
len > sizeof(struct full_sockaddr_ax25)) {=0A+		release_sock(sk);=0A 		retu=
rn -EINVAL;=0A-=0A-	if (addr_len < (addr->fsa_ax25.sax25_ndigis * sizeof(ax=
25_address) + sizeof(struct sockaddr_ax25)))=0A+	}=0A+	if (addr_len < (addr=
->fsa_ax25.sax25_ndigis * sizeof(ax25_address) + sizeof(struct sockaddr_ax2=
5))) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=0A-	if (addr->fsa_ax=
25.sax25_family !=3D AF_NETROM)=0A+	}=0A+	if (addr->fsa_ax25.sax25_family !=
=3D AF_NETROM) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=0A+	}=0A 	=
if ((dev =3D nr_dev_get(&addr->fsa_ax25.sax25_call)) =3D=3D NULL) {=0A 		SO=
CK_DEBUG(sk, "NET/ROM: bind failed: invalid node callsign\n");=0A+		release=
_sock(sk);=0A 		return -EADDRNOTAVAIL;=0A 	}=0A =0A@@ -562,16 +589,22 @@=0A=
 	 * Only the super user can set an arbitrary user callsign.=0A 	 */=0A 	if=
 (addr->fsa_ax25.sax25_ndigis =3D=3D 1) {=0A-		if (!capable(CAP_NET_BIND_SE=
RVICE))=0A+		if (!capable(CAP_NET_BIND_SERVICE)) {=0A+			dev_put(dev);=0A+	=
		release_sock(sk);=0A 			return -EACCES;=0A+		}=0A 		nr->user_addr   =3D a=
ddr->fsa_digipeater[0];=0A 		nr->source_addr =3D addr->fsa_ax25.sax25_call;=
=0A 	} else {=0A 		source =3D &addr->fsa_ax25.sax25_call;=0A =0A 		if ((use=
r =3D ax25_findbyuid(current->euid)) =3D=3D NULL) {=0A-			if (ax25_uid_poli=
cy && !capable(CAP_NET_BIND_SERVICE))=0A+			if (ax25_uid_policy && !capable=
(CAP_NET_BIND_SERVICE)) {=0A+				release_sock(sk);=0A+				dev_put(dev);=0A =
				return -EPERM;=0A+			}=0A 			user =3D source;=0A 		}=0A =0A@@ -583,6 +6=
16,8 @@=0A 	nr_insert_socket(sk);=0A =0A 	sk->sk_zapped =3D 0;=0A+	dev_put(=
dev);=0A+	release_sock(sk);=0A 	SOCK_DEBUG(sk, "NET/ROM: socket is bound\n"=
);=0A 	return 0;=0A }=0A@@ -596,39 +631,50 @@=0A 	ax25_address *user, *sour=
ce =3D NULL;=0A 	struct net_device *dev;=0A =0A+	lock_sock(sk);=0A 	if (sk-=
>sk_state =3D=3D TCP_ESTABLISHED && sock->state =3D=3D SS_CONNECTING) {=0A =
		sock->state =3D SS_CONNECTED;=0A+		release_sock(sk);=0A 		return 0;	/* Co=
nnect completed during a ERESTARTSYS event */=0A 	}=0A =0A 	if (sk->sk_stat=
e =3D=3D TCP_CLOSE && sock->state =3D=3D SS_CONNECTING) {=0A 		sock->state =
=3D SS_UNCONNECTED;=0A+		release_sock(sk);=0A 		return -ECONNREFUSED;=0A 	}=
=0A =0A-	if (sk->sk_state =3D=3D TCP_ESTABLISHED)=0A+	if (sk->sk_state =3D=
=3D TCP_ESTABLISHED) {=0A+		release_sock(sk);=0A 		return -EISCONN;	/* No r=
econnect on a seqpacket socket */=0A+	}=0A =0A 	sk->sk_state   =3D TCP_CLOS=
E;	=0A 	sock->state =3D SS_UNCONNECTED;=0A =0A-	if (addr_len !=3D sizeof(st=
ruct sockaddr_ax25) && addr_len !=3D sizeof(struct full_sockaddr_ax25))=0A+=
	if (addr_len !=3D sizeof(struct sockaddr_ax25) && addr_len !=3D sizeof(str=
uct full_sockaddr_ax25)) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=
=0A-	if (addr->sax25_family !=3D AF_NETROM)=0A+	}=0A+	if (addr->sax25_famil=
y !=3D AF_NETROM) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=0A+	}=
=0A 	if (sk->sk_zapped) {	/* Must bind first - autobinding in this may or m=
ay not work */=0A 		sk->sk_zapped =3D 0;=0A =0A-		if ((dev =3D nr_dev_first=
()) =3D=3D NULL)=0A+		if ((dev =3D nr_dev_first()) =3D=3D NULL) {=0A+			rel=
ease_sock(sk);=0A 			return -ENETUNREACH;=0A-=0A+		}=0A 		source =3D (ax25_=
address *)dev->dev_addr;=0A =0A 		if ((user =3D ax25_findbyuid(current->eui=
d)) =3D=3D NULL) {=0A-			if (ax25_uid_policy && !capable(CAP_NET_ADMIN))=0A=
+			if (ax25_uid_policy && !capable(CAP_NET_ADMIN)) {=0A+				dev_put(dev);=
=0A+				release_sock(sk);=0A 				return -EPERM;=0A+			}=0A 			user =3D sour=
ce;=0A 		}=0A =0A@@ -636,12 +682,15 @@=0A 		nr->source_addr =3D *source;=0A=
 		nr->device      =3D dev;=0A =0A+		dev_put(dev);=0A 		nr_insert_socket(sk=
);		/* Finish the bind */=0A 	}=0A =0A 	nr->dest_addr =3D addr->sax25_call;=
=0A =0A+	release_sock(sk);=0A 	circuit =3D nr_find_next_circuit();=0A+	lock=
_sock(sk);=0A =0A 	nr->my_index =3D circuit / 256;=0A 	nr->my_id    =3D cir=
cuit % 256;=0A@@ -659,8 +708,10 @@=0A 	nr_start_heartbeat(sk);=0A =0A 	/* N=
ow the loop */=0A-	if (sk->sk_state !=3D TCP_ESTABLISHED && (flags & O_NONB=
LOCK))=0A+	if (sk->sk_state !=3D TCP_ESTABLISHED && (flags & O_NONBLOCK)) {=
=0A+		release_sock(sk);=0A 		return -EINPROGRESS;=0A+	}=0A 		=0A 	/*=0A 	 *=
 A Connect Ack with Choke or timeout or failed routing will go to=0A@@ -675=
,8 +726,10 @@=0A 			set_current_state(TASK_INTERRUPTIBLE);=0A 			if (sk->sk=
_state !=3D TCP_SYN_SENT)=0A 				break;=0A+			release_sock(sk);=0A 			if (!=
signal_pending(tsk)) {=0A 				schedule();=0A+				lock_sock(sk);=0A 				cont=
inue;=0A 			}=0A 			return -ERESTARTSYS;=0A@@ -687,10 +740,12 @@=0A =0A 	if=
 (sk->sk_state !=3D TCP_ESTABLISHED) {=0A 		sock->state =3D SS_UNCONNECTED;=
=0A+		release_sock(sk);=0A 		return sock_error(sk);	/* Always set at this p=
oint */=0A 	}=0A =0A 	sock->state =3D SS_CONNECTED;=0A+	release_sock(sk);=
=0A =0A 	return 0;=0A }=0A@@ -753,6 +808,7 @@=0A 	newsock->sk =3D newsk;=0A=
 =0A out:=0A+	release_sock(sk);=0A 	return err;=0A }=0A =0A@@ -763,9 +819,1=
2 @@=0A 	struct sock *sk =3D sock->sk;=0A 	nr_cb *nr =3D nr_sk(sk);=0A =0A+=
	lock_sock(sk);=0A 	if (peer !=3D 0) {=0A-		if (sk->sk_state !=3D TCP_ESTAB=
LISHED)=0A+		if (sk->sk_state !=3D TCP_ESTABLISHED) {=0A+			release_sock(sk=
);=0A 			return -ENOTCONN;=0A+		}=0A 		sax->fsa_ax25.sax25_family =3D AF_NE=
TROM;=0A 		sax->fsa_ax25.sax25_ndigis =3D 1;=0A 		sax->fsa_ax25.sax25_call =
  =3D nr->user_addr;=0A@@ -777,6 +836,7 @@=0A 		sax->fsa_ax25.sax25_call   =
=3D nr->source_addr;=0A 		*uaddr_len =3D sizeof(struct sockaddr_ax25);=0A 	=
}=0A+	release_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -790,6 +850,7 @@=0A 	un=
signed short circuit_index, circuit_id;=0A 	unsigned short peer_circuit_ind=
ex, peer_circuit_id;=0A 	unsigned short frametype, flags, window, timeout;=
=0A+	int ret;=0A =0A 	skb->sk =3D NULL;		/* Initially we don't know who it'=
s for */=0A =0A@@ -847,7 +908,9 @@=0A 		else=0A 			nr_sk(sk)->bpqext =3D 0;=
=0A =0A-		return nr_process_rx_frame(sk, skb);=0A+		ret =3D nr_process_rx_f=
rame(sk, skb);=0A+		bh_unlock_sock(sk);=0A+		return ret;=0A 	}=0A =0A 	/*=
=0A@@ -877,6 +940,8 @@=0A 	if (!sk || sk->sk_ack_backlog =3D=3D sk->sk_max_=
ack_backlog ||=0A 	    (make =3D nr_make_new(sk)) =3D=3D NULL) {=0A 		nr_tr=
ansmit_refusal(skb, 0);=0A+		if (sk)=0A+			bh_unlock_sock(sk);=0A 		return =
0;=0A 	}=0A =0A@@ -894,7 +959,9 @@=0A 	nr_make->your_index  =3D circuit_ind=
ex;=0A 	nr_make->your_id     =3D circuit_id;=0A =0A+	bh_unlock_sock(sk);=0A=
 	circuit =3D nr_find_next_circuit();=0A+	bh_lock_sock(sk);=0A =0A 	nr_make=
->my_index    =3D circuit / 256;=0A 	nr_make->my_id       =3D circuit % 256=
;=0A@@ -936,6 +1003,7 @@=0A 	if (!sock_flag(sk, SOCK_DEAD))=0A 		sk->sk_dat=
a_ready(sk, skb->len);=0A =0A+	bh_unlock_sock(sk);=0A 	return 1;=0A }=0A =
=0A@@ -954,28 +1022,42 @@=0A 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR))=
=0A 		return -EINVAL;=0A =0A-	if (sk->sk_zapped)=0A-		return -EADDRNOTAVAIL=
;=0A+	lock_sock(sk);=0A+	if (sk->sk_zapped) {=0A+		err =3D -EADDRNOTAVAIL;=
=0A+		goto out;=0A+	}=0A =0A 	if (sk->sk_shutdown & SEND_SHUTDOWN) {=0A 		s=
end_sig(SIGPIPE, current, 0);=0A-		return -EPIPE;=0A+		err =3D -EPIPE;=0A+	=
	goto out;=0A 	}=0A =0A-	if (nr->device =3D=3D NULL)=0A-		return -ENETUNREA=
CH;=0A+	if (nr->device =3D=3D NULL) {=0A+		err =3D -ENETUNREACH;=0A+		goto =
out;=0A+	}=0A =0A 	if (usax) {=0A-		if (msg->msg_namelen < sizeof(sax))=0A-=
			return -EINVAL;=0A+		if (msg->msg_namelen < sizeof(sax)) {=0A+			err =3D=
 -EINVAL;=0A+			goto out;=0A+		}=0A 		sax =3D *usax;=0A-		if (ax25cmp(&nr->=
dest_addr, &sax.sax25_call) !=3D 0)=0A-			return -EISCONN;=0A-		if (sax.sax=
25_family !=3D AF_NETROM)=0A-			return -EINVAL;=0A+		if (ax25cmp(&nr->dest_=
addr, &sax.sax25_call) !=3D 0) {=0A+			err =3D -EISCONN;=0A+			goto out;=0A=
+		}=0A+		if (sax.sax25_family !=3D AF_NETROM) {=0A+			err =3D -EINVAL;=0A+=
			goto out;=0A+		}=0A 	} else {=0A-		if (sk->sk_state !=3D TCP_ESTABLISHED=
)=0A-			return -ENOTCONN;=0A+		if (sk->sk_state !=3D TCP_ESTABLISHED) {=0A+=
			err =3D -ENOTCONN;=0A+			goto out;=0A+		}=0A 		sax.sax25_family =3D AF_N=
ETROM;=0A 		sax.sax25_call   =3D nr->dest_addr;=0A 	}=0A@@ -984,10 +1066,10=
 @@=0A =0A 	/* Build a packet */=0A 	SOCK_DEBUG(sk, "NET/ROM: sendto: build=
ing packet.\n");=0A-	size =3D len + AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_L=
EN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A+	size =3D len + NR_NETWORK_LEN +=
 NR_TRANSPORT_LEN;=0A =0A 	if ((skb =3D sock_alloc_send_skb(sk, size, msg->=
msg_flags & MSG_DONTWAIT, &err)) =3D=3D NULL)=0A-		return err;=0A+		goto ou=
t;=0A =0A 	skb_reserve(skb, size - len);=0A =0A@@ -1022,12 +1104,16 @@=0A =
=0A 	if (sk->sk_state !=3D TCP_ESTABLISHED) {=0A 		kfree_skb(skb);=0A-		ret=
urn -ENOTCONN;=0A+		err =3D -ENOTCONN;=0A+		goto out;=0A 	}=0A =0A 	nr_outp=
ut(sk, skb);	/* Shove it onto the queue */=0A =0A-	return len;=0A+	err =3D =
len;=0A+out:=0A+	release_sock(sk);=0A+	return err;=0A }=0A =0A static int n=
r_recvmsg(struct kiocb *iocb, struct socket *sock,=0A@@ -1044,12 +1130,17 @=
@=0A 	 * us! We do one quick check first though=0A 	 */=0A =0A-	if (sk->sk_=
state !=3D TCP_ESTABLISHED)=0A+	lock_sock(sk);=0A+	if (sk->sk_state !=3D TC=
P_ESTABLISHED) {=0A+		release_sock(sk);=0A 		return -ENOTCONN;=0A+	}=0A =0A=
 	/* Now we can treat all alike */=0A-	if ((skb =3D skb_recv_datagram(sk, f=
lags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er)) =3D=3D NULL)=0A+	if ((skb=
 =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er=
)) =3D=3D NULL) {=0A+		release_sock(sk);=0A 		return er;=0A+	}=0A =0A 	skb-=
>h.raw =3D skb->data;=0A 	copied     =3D skb->len;=0A@@ -1070,6 +1161,7 @@=
=0A =0A 	skb_free_datagram(sk, skb);=0A =0A+	release_sock(sk);=0A 	return c=
opied;=0A }=0A =0A@@ -1077,13 +1169,16 @@=0A static int nr_ioctl(struct soc=
ket *sock, unsigned int cmd, unsigned long arg)=0A {=0A 	struct sock *sk =
=3D sock->sk;=0A+	int ret;=0A =0A+	lock_sock(sk);=0A 	switch (cmd) {=0A 	ca=
se TIOCOUTQ: {=0A 		long amount;=0A 		amount =3D sk->sk_sndbuf - atomic_rea=
d(&sk->sk_wmem_alloc);=0A 		if (amount < 0)=0A 			amount =3D 0;=0A+		releas=
e_sock(sk);=0A 		return put_user(amount, (int *)arg);=0A 	}=0A =0A@@ -1093,=
15 +1188,21 @@=0A 		/* These two are safe on a single CPU system as only us=
er tasks fiddle here */=0A 		if ((skb =3D skb_peek(&sk->sk_receive_queue)) =
!=3D NULL)=0A 			amount =3D skb->len;=0A+		release_sock(sk);=0A 		return pu=
t_user(amount, (int *)arg);=0A 	}=0A =0A 	case SIOCGSTAMP:=0A 		if (sk !=3D=
 NULL) {=0A-			if (!sk->sk_stamp.tv_sec)=0A+			if (!sk->sk_stamp.tv_sec) {=
=0A+				release_sock(sk);=0A 				return -ENOENT;=0A-			return copy_to_user(=
(void *)arg, &sk->sk_stamp, sizeof(struct timeval)) ? -EFAULT : 0;=0A+			}=
=0A+			ret =3D copy_to_user((void *)arg, &sk->sk_stamp, sizeof(struct timev=
al)) ? -EFAULT : 0;=0A+			release_sock(sk);=0A+			return ret;=0A 		}=0A+		r=
elease_sock(sk);=0A 		return -EINVAL;=0A =0A 	case SIOCGIFADDR:=0A@@ -1114,=
17 +1215,21 @@=0A 	case SIOCSIFNETMASK:=0A 	case SIOCGIFMETRIC:=0A 	case SI=
OCSIFMETRIC:=0A+		release_sock(sk);=0A 		return -EINVAL;=0A =0A 	case SIOCA=
DDRT:=0A 	case SIOCDELRT:=0A 	case SIOCNRDECOBS:=0A+		release_sock(sk);=0A =
		if (!capable(CAP_NET_ADMIN)) return -EPERM;=0A 		return nr_rt_ioctl(cmd, =
(void *)arg);=0A =0A 	default:=0A+		release_sock(sk);=0A 		return dev_ioctl=
(cmd, (void *)arg);=0A 	}=0A+	release_sock(sk);=0A =0A 	return 0;=0A }=0A@@=
 -1144,7 +1249,9 @@=0A 	len +=3D sprintf(buffer, "user_addr dest_node src_n=
ode  dev    my  your  st  vs  vr  va    t1     t2     t4      idle   n2  wn=
d Snd-Q Rcv-Q inode\n");=0A =0A 	sk_for_each(s, node, &nr_list) {=0A-		nr_c=
b *nr =3D nr_sk(s);=0A+		nr_cb *nr;=0A+		bh_lock_sock(s);=0A+		nr =3D nr_sk=
(s);=0A =0A 		if ((dev =3D nr->device) =3D=3D NULL)=0A 			devname =3D "???"=
;=0A@@ -1187,7 +1294,7 @@=0A 			len   =3D 0;=0A 			begin =3D pos;=0A 		}=0A=
-=0A+		bh_unlock_sock(s);=0A 		if (pos > offset + length)=0A 			break;=0A 	=
}=0A@@ -1256,6 +1363,7 @@=0A =0A 	for (i =3D 0; i < nr_ndevs; i++) {=0A 		s=
printf(dev_nr[i].name, "nr%d", i);=0A+		dev_nr[i].base_addr =3D i;=0A 		dev=
_nr[i].init =3D nr_init;=0A 		register_netdev(&dev_nr[i]);=0A 	}=0A@@ -1300=
,23 +1408,23 @@=0A =0A 	nr_rt_free();=0A =0A-	ax25_protocol_release(AX25_P_=
NETROM);=0A+#ifdef CONFIG_SYSCTL=0A+	nr_unregister_sysctl();=0A+#endif=0A+=
=0A 	ax25_linkfail_release(nr_link_failed);=0A+	ax25_protocol_release(AX25_=
P_NETROM);=0A =0A 	unregister_netdevice_notifier(&nr_dev_notifier);=0A =0A-=
#ifdef CONFIG_SYSCTL=0A-	nr_unregister_sysctl();=0A-#endif=0A 	sock_unregis=
ter(PF_NETROM);=0A =0A 	for (i =3D 0; i < nr_ndevs; i++) {=0A 		if (dev_nr[=
i].priv !=3D NULL) {=0A+			unregister_netdev(&dev_nr[i]);=0A 			kfree(dev_n=
r[i].priv);=0A 			dev_nr[i].priv =3D NULL;=0A-			unregister_netdev(&dev_nr[=
i]);=0A 		}=0A-		kfree(dev_nr[i].name);=0A 	}=0A =0A 	kfree(dev_nr);=0AOnly=
 in linux-2.6.0-test3.rxq/net/netrom: af_netrom.o=0AOnly in linux-2.6.0-tes=
t3.rxq/net/netrom: built-in.o=0AOnly in linux-2.6.0-test3.rxq/net/netrom: n=
etrom.ko=0AOnly in linux-2.6.0-test3.rxq/net/netrom: netrom.mod.c=0AOnly in=
 linux-2.6.0-test3.rxq/net/netrom: netrom.mod.o=0AOnly in linux-2.6.0-test3=
.rxq/net/netrom: netrom.o=0Adiff -ru linux-2.6.0-test3/net/netrom/nr_dev.c =
linux-2.6.0-test3.rxq/net/netrom/nr_dev.c=0A--- linux-2.6.0-test3/net/netro=
m/nr_dev.c	2003-08-09 06:41:27.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/=
net/netrom/nr_dev.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -159,11 +159,1=
3 @@=0A {=0A 	struct sockaddr *sa =3D addr;=0A =0A-	ax25_listen_release((ax=
25_address *)dev->dev_addr, NULL);=0A+	if (dev->flags & IFF_UP)=0A+		ax25_l=
isten_release((ax25_address *)dev->dev_addr, NULL);=0A =0A 	memcpy(dev->dev=
_addr, sa->sa_data, dev->addr_len);=0A =0A-	ax25_listen_register((ax25_addr=
ess *)dev->dev_addr, NULL);=0A+	if (dev->flags & IFF_UP)=0A+		ax25_listen_r=
egister((ax25_address *)dev->dev_addr, NULL);=0A =0A 	return 0;=0A }=0A@@ -=
177,8 +179,8 @@=0A =0A static int nr_close(struct net_device *dev)=0A {=0A-=
	netif_stop_queue(dev);=0A 	ax25_listen_release((ax25_address *)dev->dev_ad=
dr, NULL);=0A+	netif_stop_queue(dev);=0A 	return 0;=0A }=0A =0A@@ -197,16 +=
199,16 @@=0A =0A int nr_init(struct net_device *dev)=0A {=0A-	SET_MODULE_OW=
NER(dev);=0A 	dev->mtu		=3D NR_MAX_PACKET_SIZE;=0A 	dev->hard_start_xmit	=
=3D nr_xmit;=0A 	dev->open		=3D nr_open;=0A 	dev->stop		=3D nr_close;=0A =
=0A 	dev->hard_header	=3D nr_header;=0A-	dev->hard_header_len	=3D AX25_BPQ_=
HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A+	d=
ev->hard_header_len	=3D NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A 	dev->addr_le=
n		=3D AX25_ADDR_LEN;=0A 	dev->type		=3D ARPHRD_NETROM;=0A+	dev->tx_queue_l=
en	=3D 40;=0A 	dev->rebuild_header	=3D nr_rebuild_header;=0A 	dev->set_mac_=
address    =3D nr_set_mac_address;=0A =0AOnly in linux-2.6.0-test3.rxq/net/=
netrom: nr_dev.o=0Adiff -ru linux-2.6.0-test3/net/netrom/nr_in.c linux-2.6.=
0-test3.rxq/net/netrom/nr_in.c=0A--- linux-2.6.0-test3/net/netrom/nr_in.c	2=
003-08-09 06:34:46.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/netrom/n=
r_in.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -74,6 +74,7 @@=0A static in=
t nr_state1_machine(struct sock *sk, struct sk_buff *skb,=0A 	int frametype=
)=0A {=0A+	bh_lock_sock(sk);=0A 	switch (frametype) {=0A 	case NR_CONNACK: =
{=0A 		nr_cb *nr =3D nr_sk(sk);=0A@@ -102,6 +103,7 @@=0A 	default:=0A 		bre=
ak;=0A 	}=0A+	bh_unlock_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -114,6 +116,7=
 @@=0A static int nr_state2_machine(struct sock *sk, struct sk_buff *skb,=
=0A 	int frametype)=0A {=0A+	bh_lock_sock(sk);=0A 	switch (frametype) {=0A =
	case NR_CONNACK | NR_CHOKE_FLAG:=0A 		nr_disconnect(sk, ECONNRESET);=0A@@ =
-129,6 +132,7 @@=0A 	default:=0A 		break;=0A 	}=0A+	bh_unlock_sock(sk);=0A =
=0A 	return 0;=0A }=0A@@ -150,6 +154,7 @@=0A 	nr =3D skb->data[18];=0A 	ns =
=3D skb->data[17];=0A =0A+	bh_lock_sock(sk);=0A 	switch (frametype) {=0A 	c=
ase NR_CONNREQ:=0A 		nr_write_internal(sk, NR_CONNACK);=0A@@ -260,6 +265,7 =
@@=0A 	default:=0A 		break;=0A 	}=0A+	bh_unlock_sock(sk);=0A =0A 	return qu=
eued;=0A }=0AOnly in linux-2.6.0-test3.rxq/net/netrom: nr_in.o=0AOnly in li=
nux-2.6.0-test3.rxq/net/netrom: nr_loopback.o=0AOnly in linux-2.6.0-test3.r=
xq/net/netrom: nr_out.o=0Adiff -ru linux-2.6.0-test3/net/netrom/nr_route.c =
linux-2.6.0-test3.rxq/net/netrom/nr_route.c=0A--- linux-2.6.0-test3/net/net=
rom/nr_route.c	2003-08-09 06:42:17.000000000 +0200=0A+++ linux-2.6.0-test3.=
rxq/net/netrom/nr_route.c	2003-08-12 23:40:35.000000000 +0200=0A@@ -39,10 +=
39,45 @@=0A =0A static unsigned int nr_neigh_no =3D 1;=0A =0A-static struct=
 nr_node  *nr_node_list;=0A-static spinlock_t nr_node_lock;=0A-static struc=
t nr_neigh *nr_neigh_list;=0A-static spinlock_t nr_neigh_lock;=0A+HLIST_HEA=
D(nr_node_list);=0A+spinlock_t nr_node_list_lock =3D SPIN_LOCK_UNLOCKED;=0A=
+HLIST_HEAD(nr_neigh_list);=0A+spinlock_t nr_neigh_list_lock =3D SPIN_LOCK_=
UNLOCKED;=0A+=0A+struct nr_node *nr_node_get(ax25_address *callsign)=0A+{=
=0A+	struct nr_node *found =3D NULL;=0A+	struct nr_node *nr_node;=0A+	struc=
t hlist_node *node;=0A+=0A+	spin_lock_bh(&nr_node_list_lock);=0A+	nr_node_f=
or_each(nr_node, node, &nr_node_list)=0A+		if (ax25cmp(callsign, &nr_node->=
callsign) =3D=3D 0) {=0A+			nr_node_hold(nr_node);=0A+			found =3D nr_node;=
=0A+			break;=0A+		}=0A+	spin_unlock_bh(&nr_node_list_lock);=0A+	return fou=
nd;=0A+}=0A+=0A+struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign, s=
truct net_device *dev)=0A+{=0A+	struct nr_neigh *found =3D NULL;=0A+	struct=
 nr_neigh *nr_neigh;=0A+	struct hlist_node *node;=0A+=0A+	spin_lock_bh(&nr_=
neigh_list_lock);=0A+	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list)=0A+=
		if (ax25cmp(callsign, &nr_neigh->callsign) =3D=3D 0 &&=0A+		    nr_neigh-=
>dev =3D=3D dev) {=0A+			nr_neigh_hold(nr_neigh);=0A+			found =3D nr_neigh;=
=0A+			break;=0A+		}=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A+	return fo=
und;=0A+}=0A =0A static void nr_remove_neigh(struct nr_neigh *);=0A =0A@@ -=
57,17 +92,16 @@=0A 	struct nr_neigh *nr_neigh;=0A 	struct nr_route nr_route=
;=0A 	int i, found;=0A+	struct net_device *odev;=0A =0A-	if (nr_dev_get(nr)=
 !=3D NULL)	/* Can't add routes to ourself */=0A+	if ((odev=3Dnr_dev_get(nr=
)) !=3D NULL) {	/* Can't add routes to ourself */=0A+		dev_put(odev);=0A 		=
return -EINVAL;=0A+	}=0A =0A-	for (nr_node =3D nr_node_list; nr_node !=3D N=
ULL; nr_node =3D nr_node->next)=0A-		if (ax25cmp(nr, &nr_node->callsign) =
=3D=3D 0)=0A-			break;=0A+	nr_node =3D nr_node_get(nr);=0A =0A-	for (nr_nei=
gh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next)=0A-	=
	if (ax25cmp(ax25, &nr_neigh->callsign) =3D=3D 0 && nr_neigh->dev =3D=3D de=
v)=0A-			break;=0A+	nr_neigh =3D nr_neigh_get_dev(ax25, dev);=0A =0A 	/*=0A=
 	 * The L2 link to a neighbour has failed in the past=0A@@ -76,24 +110,36 =
@@=0A 	 * routes now (and not wait for a node broadcast).=0A 	 */=0A 	if (n=
r_neigh !=3D NULL && nr_neigh->failed !=3D 0 && quality =3D=3D 0) {=0A-		st=
ruct nr_node *node;=0A+		struct nr_node *nr_nodet;=0A+		struct hlist_node *=
node;=0A =0A-		for (node =3D nr_node_list; node !=3D NULL; node =3D node->n=
ext)=0A-			for (i =3D 0; i < node->count; i++)=0A-				if (node->routes[i].n=
eighbour =3D=3D nr_neigh)=0A-					if (i < node->which)=0A-						node->which=
 =3D i;=0A+		spin_lock_bh(&nr_node_list_lock);=0A+		nr_node_for_each(nr_nod=
et, node, &nr_node_list) {=0A+			nr_node_lock(nr_nodet);=0A+			for (i =3D 0=
; i < nr_nodet->count; i++)=0A+				if (nr_nodet->routes[i].neighbour =3D=3D=
 nr_neigh)=0A+					if (i < nr_nodet->which)=0A+						nr_nodet->which =3D i;=
=0A+			nr_node_unlock(nr_nodet);=0A+		}=0A+		spin_unlock_bh(&nr_node_list_l=
ock);=0A 	}=0A =0A 	if (nr_neigh !=3D NULL)=0A 		nr_neigh->failed =3D 0;=0A=
 =0A-	if (quality =3D=3D 0 && nr_neigh !=3D NULL && nr_node !=3D NULL)=0A+	=
if (quality =3D=3D 0 && nr_neigh !=3D NULL && nr_node !=3D NULL) {=0A+		nr_=
neigh_put(nr_neigh);=0A+		nr_node_put(nr_node);=0A 		return 0;=0A+	}=0A =0A=
 	if (nr_neigh =3D=3D NULL) {=0A-		if ((nr_neigh =3D kmalloc(sizeof(*nr_nei=
gh), GFP_ATOMIC)) =3D=3D NULL)=0A+		if ((nr_neigh =3D kmalloc(sizeof(*nr_ne=
igh), GFP_ATOMIC)) =3D=3D NULL) {=0A+			if (nr_node)=0A+				nr_node_put(nr_=
node);=0A 			return -ENOMEM;=0A+		}=0A =0A 		nr_neigh->callsign =3D *ax25;=
=0A 		nr_neigh->digipeat =3D NULL;=0A@@ -104,48 +150,58 @@=0A 		nr_neigh->c=
ount    =3D 0;=0A 		nr_neigh->number   =3D nr_neigh_no++;=0A 		nr_neigh->fa=
iled   =3D 0;=0A+		atomic_set(&nr_neigh->refcount, 1);=0A =0A 		if (ax25_di=
gi !=3D NULL && ax25_digi->ndigi > 0) {=0A 			if ((nr_neigh->digipeat =3D k=
malloc(sizeof(*ax25_digi), GFP_KERNEL)) =3D=3D NULL) {=0A 				kfree(nr_neig=
h);=0A+				if (nr_node)=0A+					nr_node_put(nr_node);=0A 				return -ENOMEM=
;=0A 			}=0A 			memcpy(nr_neigh->digipeat, ax25_digi,=0A 					sizeof(*ax25_=
digi));=0A 		}=0A =0A-		spin_lock_bh(&nr_neigh_lock);=0A-		nr_neigh->next =
=3D nr_neigh_list;=0A-		nr_neigh_list  =3D nr_neigh;=0A-		spin_unlock_bh(&n=
r_neigh_lock);=0A+		spin_lock_bh(&nr_neigh_list_lock);=0A+		hlist_add_head(=
&nr_neigh->neigh_node, &nr_neigh_list);=0A+		nr_neigh_hold(nr_neigh);=0A+		=
spin_unlock_bh(&nr_neigh_list_lock);=0A 	}=0A =0A 	if (quality !=3D 0 && ax=
25cmp(nr, ax25) =3D=3D 0 && !nr_neigh->locked)=0A 		nr_neigh->quality =3D q=
uality;=0A =0A 	if (nr_node =3D=3D NULL) {=0A-		if ((nr_node =3D kmalloc(si=
zeof(*nr_node), GFP_ATOMIC)) =3D=3D NULL)=0A+		if ((nr_node =3D kmalloc(siz=
eof(*nr_node), GFP_ATOMIC)) =3D=3D NULL) {=0A+			if (nr_neigh)=0A+				nr_ne=
igh_put(nr_neigh);=0A 			return -ENOMEM;=0A+		}=0A =0A 		nr_node->callsign =
=3D *nr;=0A 		strcpy(nr_node->mnemonic, mnemonic);=0A =0A 		nr_node->which =
=3D 0;=0A 		nr_node->count =3D 1;=0A+		atomic_set(&nr_node->refcount, 1);=
=0A+		nr_node->node_lock =3D SPIN_LOCK_UNLOCKED;=0A =0A 		nr_node->routes[0=
].quality   =3D quality;=0A 		nr_node->routes[0].obs_count =3D obs_count;=
=0A 		nr_node->routes[0].neighbour =3D nr_neigh;=0A =0A-		spin_lock_bh(&nr_=
node_lock);=0A-		nr_node->next =3D nr_node_list;=0A-		nr_node_list  =3D nr_=
node;=0A-		spin_unlock_bh(&nr_node_lock);=0A-=0A+		nr_neigh_hold(nr_neigh);=
=0A 		nr_neigh->count++;=0A =0A+		spin_lock_bh(&nr_node_list_lock);=0A+		hl=
ist_add_head(&nr_node->node_node, &nr_node_list);=0A+		/* refcount initiali=
zed at 1 */=0A+		spin_unlock_bh(&nr_node_list_lock);=0A+=0A 		return 0;=0A =
	}=0A+	nr_node_lock(nr_node);=0A =0A 	if (quality !=3D 0)=0A 		strcpy(nr_no=
de->mnemonic, mnemonic);=0A@@ -171,11 +227,13 @@=0A =0A 			nr_node->which++=
;=0A 			nr_node->count++;=0A+			nr_neigh_hold(nr_neigh);=0A 			nr_neigh->co=
unt++;=0A 		} else {=0A 			/* It must be better than the worst */=0A 			if =
(quality > nr_node->routes[2].quality) {=0A 				nr_node->routes[2].neighbou=
r->count--;=0A+				nr_neigh_put(nr_node->routes[2].neighbour);=0A =0A 				i=
f (nr_node->routes[2].neighbour->count =3D=3D 0 && !nr_node->routes[2].neig=
hbour->locked)=0A 					nr_remove_neigh(nr_node->routes[2].neighbour);=0A@@ =
-184,6 +242,7 @@=0A 				nr_node->routes[2].obs_count =3D obs_count;=0A 				=
nr_node->routes[2].neighbour =3D nr_neigh;=0A =0A+				nr_neigh_hold(nr_neig=
h);=0A 				nr_neigh->count++;=0A 			}=0A 		}=0A@@ -244,62 +303,42 @@=0A 		}=
=0A 	}=0A =0A+	nr_neigh_put(nr_neigh);=0A+	nr_node_unlock(nr_node);=0A+	nr_=
node_put(nr_node);=0A 	return 0;=0A }=0A =0A-static void nr_remove_node(str=
uct nr_node *nr_node)=0A+static inline void __nr_remove_node(struct nr_node=
 *nr_node)=0A {=0A-	struct nr_node *s;=0A-=0A-	spin_lock_bh(&nr_node_lock);=
=0A-	if ((s =3D nr_node_list) =3D=3D nr_node) {=0A-		nr_node_list =3D nr_no=
de->next;=0A-		spin_unlock_bh(&nr_node_lock);=0A-		kfree(nr_node);=0A-		ret=
urn;=0A-	}=0A-=0A-	while (s !=3D NULL && s->next !=3D NULL) {=0A-		if (s->n=
ext =3D=3D nr_node) {=0A-			s->next =3D nr_node->next;=0A-			spin_unlock_bh=
(&nr_node_lock);=0A-			kfree(nr_node);=0A-			return;=0A-		}=0A+	hlist_del_i=
nit(&nr_node->node_node);=0A+	nr_node_put(nr_node);=0A+}=0A =0A-		s =3D s->=
next;=0A-	}=0A+#define nr_remove_node_locked(__node) \=0A+	__nr_remove_node=
(__node)=0A =0A-	spin_unlock_bh(&nr_node_lock);=0A+static void nr_remove_no=
de(struct nr_node *nr_node)=0A+{=0A+	spin_lock_bh(&nr_node_list_lock);=0A+	=
__nr_remove_node(nr_node);=0A+	spin_unlock_bh(&nr_node_list_lock);=0A }=0A =
=0A-static void nr_remove_neigh(struct nr_neigh *nr_neigh)=0A+static inline=
 void __nr_remove_neigh(struct nr_neigh *nr_neigh)=0A {=0A-	struct nr_neigh=
 *s;=0A+	hlist_del_init(&nr_neigh->neigh_node);=0A+	nr_neigh_put(nr_neigh);=
=0A+}=0A =0A-	spin_lock_bh(&nr_neigh_lock);=0A-	if ((s =3D nr_neigh_list) =
=3D=3D nr_neigh) {=0A-		nr_neigh_list =3D nr_neigh->next;=0A-		spin_unlock_=
bh(&nr_neigh_lock);=0A-		if (nr_neigh->digipeat !=3D NULL)=0A-			kfree(nr_n=
eigh->digipeat);=0A-		kfree(nr_neigh);=0A-		return;=0A-	}=0A+#define nr_rem=
ove_neigh_locked(__neigh) \=0A+	__nr_remove_neigh(__neigh)=0A =0A-	while (s=
 !=3D NULL && s->next !=3D NULL) {=0A-		if (s->next =3D=3D nr_neigh) {=0A-	=
		s->next =3D nr_neigh->next;=0A-			spin_unlock_bh(&nr_neigh_lock);=0A-			i=
f (nr_neigh->digipeat !=3D NULL)=0A-				kfree(nr_neigh->digipeat);=0A-			kf=
ree(nr_neigh);=0A-			return;=0A-		}=0A-=0A-		s =3D s->next;=0A-	}=0A-	spin_=
unlock_bh(&nr_neigh_lock);=0A+static void nr_remove_neigh(struct nr_neigh *=
nr_neigh)=0A+{=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	__nr_remove_neigh=
(nr_neigh);=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A }=0A =0A /*=0A@@ -3=
12,26 +351,27 @@=0A 	struct nr_neigh *nr_neigh;=0A 	int i;=0A =0A-	for (nr_=
node =3D nr_node_list; nr_node !=3D NULL; nr_node =3D nr_node->next)=0A-		i=
f (ax25cmp(callsign, &nr_node->callsign) =3D=3D 0)=0A-			break;=0A+	nr_node=
 =3D nr_node_get(callsign);=0A =0A 	if (nr_node =3D=3D NULL)=0A 		return -E=
INVAL;=0A =0A-	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neig=
h =3D nr_neigh->next)=0A-		if (ax25cmp(neighbour, &nr_neigh->callsign) =3D=
=3D 0 && nr_neigh->dev =3D=3D dev)=0A-			break;=0A+	nr_neigh =3D nr_neigh_g=
et_dev(neighbour, dev);=0A =0A-	if (nr_neigh =3D=3D NULL)=0A+	if (nr_neigh =
=3D=3D NULL) {=0A+		nr_node_put(nr_node);=0A 		return -EINVAL;=0A+	}=0A =0A=
+	nr_node_lock(nr_node);=0A 	for (i =3D 0; i < nr_node->count; i++) {=0A 		=
if (nr_node->routes[i].neighbour =3D=3D nr_neigh) {=0A 			nr_neigh->count--=
;=0A+			nr_neigh_put(nr_neigh);=0A =0A 			if (nr_neigh->count =3D=3D 0 && !=
nr_neigh->locked)=0A 				nr_remove_neigh(nr_neigh);=0A+			nr_neigh_put(nr_n=
eigh);=0A =0A 			nr_node->count--;=0A =0A@@ -346,11 +386,16 @@=0A 				case =
2:=0A 					break;=0A 				}=0A+				nr_node_put(nr_node);=0A 			}=0A+			nr_no=
de_unlock(nr_node);=0A =0A 			return 0;=0A 		}=0A 	}=0A+	nr_neigh_put(nr_ne=
igh);=0A+	nr_node_unlock(nr_node);=0A+	nr_node_put(nr_node);=0A =0A 	return=
 -EINVAL;=0A }=0A@@ -362,12 +407,12 @@=0A {=0A 	struct nr_neigh *nr_neigh;=
=0A =0A-	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neigh =3D =
nr_neigh->next) {=0A-		if (ax25cmp(callsign, &nr_neigh->callsign) =3D=3D 0 =
&& nr_neigh->dev =3D=3D dev) {=0A-			nr_neigh->quality =3D quality;=0A-			n=
r_neigh->locked  =3D 1;=0A-			return 0;=0A-		}=0A+	nr_neigh =3D nr_neigh_ge=
t_dev(callsign, dev);=0A+	if (nr_neigh) {=0A+		nr_neigh->quality =3D qualit=
y;=0A+		nr_neigh->locked  =3D 1;=0A+		nr_neigh_put(nr_neigh);=0A+		return 0=
;=0A 	}=0A =0A 	if ((nr_neigh =3D kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) =
=3D=3D NULL)=0A@@ -382,6 +427,7 @@=0A 	nr_neigh->count    =3D 0;=0A 	nr_nei=
gh->number   =3D nr_neigh_no++;=0A 	nr_neigh->failed   =3D 0;=0A+	atomic_se=
t(&nr_neigh->refcount, 1);=0A =0A 	if (ax25_digi !=3D NULL && ax25_digi->nd=
igi > 0) {=0A 		if ((nr_neigh->digipeat =3D kmalloc(sizeof(*ax25_digi), GFP=
_KERNEL)) =3D=3D NULL) {=0A@@ -391,10 +437,10 @@=0A 		memcpy(nr_neigh->digi=
peat, ax25_digi, sizeof(*ax25_digi));=0A 	}=0A =0A-	spin_lock_bh(&nr_neigh_=
lock);=0A-	nr_neigh->next =3D nr_neigh_list;=0A-	nr_neigh_list  =3D nr_neig=
h;=0A-	spin_unlock_bh(&nr_neigh_lock);=0A+	spin_lock_bh(&nr_neigh_list_lock=
);=0A+	hlist_add_head(&nr_neigh->neigh_node, &nr_neigh_list);=0A+	/* refcou=
nt is initialized at 1 */=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A =0A 	=
return 0;=0A }=0A@@ -407,9 +453,7 @@=0A {=0A 	struct nr_neigh *nr_neigh;=0A=
 =0A-	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neigh =3D nr_=
neigh->next)=0A-		if (ax25cmp(callsign, &nr_neigh->callsign) =3D=3D 0 && nr=
_neigh->dev =3D=3D dev)=0A-			break;=0A+	nr_neigh =3D nr_neigh_get_dev(call=
sign, dev);=0A =0A 	if (nr_neigh =3D=3D NULL) return -EINVAL;=0A =0A@@ -418=
,6 +462,7 @@=0A =0A 	if (nr_neigh->count =3D=3D 0)=0A 		nr_remove_neigh(nr_=
neigh);=0A+	nr_neigh_put(nr_neigh);=0A =0A 	return 0;=0A }=0A@@ -430,15 +47=
5,13 @@=0A static int nr_dec_obs(void)=0A {=0A 	struct nr_neigh *nr_neigh;=
=0A-	struct nr_node  *s, *nr_node;=0A+	struct nr_node  *s;=0A+	struct hlist=
_node *node, *nodet;=0A 	int i;=0A =0A-	nr_node =3D nr_node_list;=0A-=0A-	w=
hile (nr_node !=3D NULL) {=0A-		s       =3D nr_node;=0A-		nr_node =3D nr_no=
de->next;=0A-=0A+	spin_lock_bh(&nr_node_list_lock);=0A+	nr_node_for_each_sa=
fe(s, node, nodet, &nr_node_list) {=0A+		nr_node_lock(s);=0A 		for (i =3D 0=
; i < s->count; i++) {=0A 			switch (s->routes[i].obs_count) {=0A 			case 0=
:		/* A locked entry */=0A@@ -448,6 +491,7 @@=0A 				nr_neigh =3D s->routes=
[i].neighbour;=0A =0A 				nr_neigh->count--;=0A+				nr_neigh_put(nr_neigh);=
=0A =0A 				if (nr_neigh->count =3D=3D 0 && !nr_neigh->locked)=0A 					nr_r=
emove_neigh(nr_neigh);=0A@@ -472,8 +516,10 @@=0A 		}=0A =0A 		if (s->count =
<=3D 0)=0A-			nr_remove_node(s);=0A+			nr_remove_node_locked(s);=0A+		nr_no=
de_unlock(s);=0A 	}=0A+	spin_unlock_bh(&nr_node_list_lock);=0A =0A 	return =
0;=0A }=0A@@ -483,21 +529,17 @@=0A  */=0A void nr_rt_device_down(struct net=
_device *dev)=0A {=0A-	struct nr_neigh *s, *nr_neigh =3D nr_neigh_list;=0A-=
	struct nr_node  *t, *nr_node;=0A+	struct nr_neigh *s;=0A+	struct hlist_nod=
e *node, *nodet, *node2, *node2t;=0A+	struct nr_node  *t;=0A 	int i;=0A =0A=
-	while (nr_neigh !=3D NULL) {=0A-		s        =3D nr_neigh;=0A-		nr_neigh =
=3D nr_neigh->next;=0A-=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	nr_neigh=
_for_each_safe(s, node, nodet, &nr_neigh_list) {=0A 		if (s->dev =3D=3D dev=
) {=0A-			nr_node =3D nr_node_list;=0A-=0A-			while (nr_node !=3D NULL) {=
=0A-				t       =3D nr_node;=0A-				nr_node =3D nr_node->next;=0A-=0A+			sp=
in_lock_bh(&nr_node_list_lock);=0A+			nr_node_for_each_safe(t, node2, node2=
t, &nr_node_list) {=0A+				nr_node_lock(t);=0A 				for (i =3D 0; i < t->cou=
nt; i++) {=0A 					if (t->routes[i].neighbour =3D=3D s) {=0A 						t->count=
--;=0A@@ -514,12 +556,15 @@=0A 				}=0A =0A 				if (t->count <=3D 0)=0A-			=
		nr_remove_node(t);=0A+					nr_remove_node_locked(t);=0A+				nr_node_unloc=
k(t);=0A 			}=0A+			spin_unlock_bh(&nr_node_list_lock);=0A =0A-			nr_remove=
_neigh(s);=0A+			nr_remove_neigh_locked(s);=0A 		}=0A 	}=0A+	spin_unlock_bh=
(&nr_neigh_list_lock);=0A }=0A =0A /*=0A@@ -553,6 +598,8 @@=0A 			if (first=
 =3D=3D NULL || strncmp(dev->name, first->name, 3) < 0)=0A 				first =3D de=
v;=0A 	}=0A+	if (first)=0A+		dev_hold(first);=0A 	read_unlock(&dev_base_loc=
k);=0A =0A 	return first;=0A@@ -603,6 +650,7 @@=0A {=0A 	struct nr_route_st=
ruct nr_route;=0A 	struct net_device *dev;=0A+	int ret;=0A =0A 	switch (cmd=
) {=0A 	case SIOCADDRT:=0A@@ -610,23 +658,29 @@=0A 			return -EFAULT;=0A 		=
if ((dev =3D nr_ax25_dev_get(nr_route.device)) =3D=3D NULL)=0A 			return -E=
INVAL;=0A-		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS)=0A=
+		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {=0A+			dev=
_put(dev);=0A 			return -EINVAL;=0A+		}=0A 		switch (nr_route.type) {=0A 		=
case NETROM_NODE:=0A-			return nr_add_node(&nr_route.callsign,=0A+			ret =
=3D nr_add_node(&nr_route.callsign,=0A 				nr_route.mnemonic,=0A 				&nr_ro=
ute.neighbour,=0A 				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters=
),=0A 				dev, nr_route.quality,=0A 				nr_route.obs_count);=0A+			break;=
=0A 		case NETROM_NEIGH:=0A-			return nr_add_neigh(&nr_route.callsign,=0A+	=
		ret =3D nr_add_neigh(&nr_route.callsign,=0A 				nr_call_to_digi(nr_route.=
ndigis, nr_route.digipeaters),=0A 				dev, nr_route.quality);=0A+			break;=
=0A 		default:=0A-			return -EINVAL;=0A+			ret =3D -EINVAL;=0A 		}=0A+		dev=
_put(dev);=0A+		return ret;=0A =0A 	case SIOCDELRT:=0A 		if (copy_from_user=
(&nr_route, arg, sizeof(struct nr_route_struct)))=0A@@ -635,14 +689,18 @@=
=0A 			return -EINVAL;=0A 		switch (nr_route.type) {=0A 		case NETROM_NODE:=
=0A-			return nr_del_node(&nr_route.callsign,=0A+			ret =3D nr_del_node(&nr=
_route.callsign,=0A 				&nr_route.neighbour, dev);=0A+			break;=0A 		case N=
ETROM_NEIGH:=0A-			return nr_del_neigh(&nr_route.callsign,=0A+			ret =3D nr=
_del_neigh(&nr_route.callsign,=0A 				dev, nr_route.quality);=0A+			break;=
=0A 		default:=0A-			return -EINVAL;=0A+			ret =3D -EINVAL;=0A 		}=0A+		dev=
_put(dev);=0A+		return ret;=0A =0A 	case SIOCNRDECOBS:=0A 		return nr_dec_o=
bs();=0A@@ -660,22 +718,36 @@=0A  */=0A void nr_link_failed(ax25_cb *ax25, =
int reason)=0A {=0A-	struct nr_neigh *nr_neigh;=0A-	struct nr_node  *nr_nod=
e;=0A-=0A-	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neigh =
=3D nr_neigh->next)=0A-		if (nr_neigh->ax25 =3D=3D ax25)=0A+	struct nr_neig=
h *s, *nr_neigh =3D NULL;=0A+	struct hlist_node *node;=0A+	struct nr_node  =
*nr_node =3D NULL;=0A+=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	nr_neigh_=
for_each(s, node, &nr_neigh_list)=0A+		if (s->ax25 =3D=3D ax25) {=0A+			nr_=
neigh_hold(s);=0A+			nr_neigh =3D s;=0A 			break;=0A+		}=0A+	spin_unlock_bh=
(&nr_neigh_list_lock);=0A =0A 	if (nr_neigh =3D=3D NULL) return;=0A =0A 	nr=
_neigh->ax25 =3D NULL;=0A+	ax25_cb_put(ax25);=0A =0A-	if (++nr_neigh->faile=
d < sysctl_netrom_link_fails_count) return;=0A-=0A-	for (nr_node =3D nr_nod=
e_list; nr_node !=3D NULL; nr_node =3D nr_node->next)=0A+	if (++nr_neigh->f=
ailed < sysctl_netrom_link_fails_count) {=0A+		nr_neigh_put(nr_neigh);=0A+	=
	return;=0A+	}=0A+	spin_lock_bh(&nr_node_list_lock);=0A+	nr_node_for_each(n=
r_node, node, &nr_node_list)=0A+		nr_node_lock(nr_node);=0A 		if (nr_node->=
which < nr_node->count && nr_node->routes[nr_node->which].neighbour =3D=3D =
nr_neigh)=0A 			nr_node->which++;=0A+		nr_node_unlock(nr_node);=0A+	spin_un=
lock_bh(&nr_node_list_lock);=0A+	nr_neigh_put(nr_neigh);=0A }=0A =0A /*=0A@=
@ -689,6 +761,9 @@=0A 	struct nr_node  *nr_node;=0A 	struct net_device *dev=
;=0A 	unsigned char *dptr;=0A+	ax25_cb *ax25s;=0A+	int ret;=0A+	struct sk_b=
uff *skbn;=0A =0A =0A 	nr_src  =3D (ax25_address *)(skb->data + 0);=0A@@ -7=
00,50 +775,84 @@=0A =0A 	if ((dev =3D nr_dev_get(nr_dest)) !=3D NULL) {	/* =
Its for me */=0A 		if (ax25 =3D=3D NULL)			/* Its from me */=0A-			return n=
r_loopback_queue(skb);=0A+			ret =3D nr_loopback_queue(skb);=0A 		else=0A-	=
		return nr_rx_frame(skb, dev);=0A+			ret =3D nr_rx_frame(skb, dev);=0A+		d=
ev_put(dev);=0A+		return ret;=0A 	}=0A =0A 	if (!sysctl_netrom_routing_cont=
rol && ax25 !=3D NULL)=0A 		return 0;=0A =0A 	/* Its Time-To-Live has expir=
ed */=0A-	if (--skb->data[14] =3D=3D 0)=0A+	if (skb->data[14] =3D=3D 1) {=
=0A 		return 0;=0A+	}=0A =0A-	for (nr_node =3D nr_node_list; nr_node !=3D N=
ULL; nr_node =3D nr_node->next)=0A-		if (ax25cmp(nr_dest, &nr_node->callsig=
n) =3D=3D 0)=0A-			break;=0A+	nr_node =3D nr_node_get(nr_dest);=0A+	if (nr_=
node =3D=3D NULL)=0A+		return 0;=0A+	nr_node_lock(nr_node);=0A =0A-	if (nr_=
node =3D=3D NULL || nr_node->which >=3D nr_node->count)=0A+	if (nr_node->wh=
ich >=3D nr_node->count) {=0A+		nr_node_unlock(nr_node);=0A+		nr_node_put(n=
r_node);=0A 		return 0;=0A+	}=0A =0A 	nr_neigh =3D nr_node->routes[nr_node-=
>which].neighbour;=0A =0A-	if ((dev =3D nr_dev_first()) =3D=3D NULL)=0A+	if=
 ((dev =3D nr_dev_first()) =3D=3D NULL) {=0A+		nr_node_unlock(nr_node);=0A+=
		nr_node_put(nr_node);=0A+		return 0;=0A+	}=0A+=0A+	/* We are going to cha=
nge the netrom headers so we should get our=0A+	   own skb, we also did not=
 know until now how much header space=0A+	   we had to reserve... - RXQ */=
=0A+	if ((skbn=3Dskb_copy_expand(skb, dev->hard_header_len, 0, GFP_ATOMIC))=
 =3D=3D NULL) {=0A+		nr_node_unlock(nr_node);=0A+		nr_node_put(nr_node);=0A=
+		dev_put(dev);=0A 		return 0;=0A+	}=0A+	kfree_skb(skb);=0A+	skb=3Dskbn;=
=0A+	skb->data[14]--;=0A =0A 	dptr  =3D skb_push(skb, 1);=0A 	*dptr =3D AX2=
5_P_NETROM;=0A =0A-	nr_neigh->ax25 =3D ax25_send_frame(skb, 256, (ax25_addr=
ess *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev=
);=0A+	ax25s =3D ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &=
nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);=0A+	if (nr_neigh->a=
x25 && ax25s) {=0A+		/* We were already holding this ax25_cb */=0A+		ax25_c=
b_put(ax25s);=0A+	}=0A+	nr_neigh->ax25 =3D ax25s;=0A =0A-	return (nr_neigh-=
>ax25 !=3D NULL);=0A+	dev_put(dev);=0A+	ret =3D (nr_neigh->ax25 !=3D NULL);=
=0A+	nr_node_unlock(nr_node);=0A+	nr_node_put(nr_node);=0A+	return ret;=0A =
}=0A =0A int nr_nodes_get_info(char *buffer, char **start, off_t offset, in=
t length)=0A {=0A 	struct nr_node *nr_node;=0A+	struct hlist_node *node;=0A=
 	int len     =3D 0;=0A 	off_t pos   =3D 0;=0A 	off_t begin =3D 0;=0A 	int =
i;=0A =0A-	spin_lock_bh(&nr_node_lock);=0A+	spin_lock_bh(&nr_node_list_lock=
);=0A 	len +=3D sprintf(buffer, "callsign  mnemonic w n qual obs neigh qual=
 obs neigh qual obs neigh\n");=0A =0A-	for (nr_node =3D nr_node_list; nr_no=
de !=3D NULL; nr_node =3D nr_node->next) {=0A+	nr_node_for_each(nr_node, no=
de, &nr_node_list) {=0A+		nr_node_lock(nr_node);=0A 		len +=3D sprintf(buff=
er + len, "%-9s %-7s  %d %d",=0A 			ax2asc(&nr_node->callsign),=0A 			(nr_n=
ode->mnemonic[0] =3D=3D '\0') ? "*" : nr_node->mnemonic,=0A@@ -756,6 +865,7=
 @@=0A 				nr_node->routes[i].obs_count,=0A 				nr_node->routes[i].neighbou=
r->number);=0A 		}=0A+		nr_node_unlock(nr_node);=0A =0A 		len +=3D sprintf(=
buffer + len, "\n");=0A =0A@@ -769,7 +879,7 @@=0A 		if (pos > offset + leng=
th)=0A 			break;=0A 	}=0A-	spin_unlock_bh(&nr_node_lock);=0A+	spin_unlock_b=
h(&nr_node_list_lock);=0A =0A 	*start =3D buffer + (offset - begin);=0A 	le=
n   -=3D (offset - begin);=0A@@ -782,15 +892,16 @@=0A int nr_neigh_get_info=
(char *buffer, char **start, off_t offset, int length)=0A {=0A 	struct nr_n=
eigh *nr_neigh;=0A+	struct hlist_node *node;=0A 	int len     =3D 0;=0A 	off=
_t pos   =3D 0;=0A 	off_t begin =3D 0;=0A 	int i;=0A =0A-	spin_lock_bh(&nr_=
neigh_lock);=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A 	len +=3D sprintf(bu=
ffer, "addr  callsign  dev  qual lock count failed digipeaters\n");=0A =0A-=
	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh=
->next) {=0A+	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list) {=0A 		len =
+=3D sprintf(buffer + len, "%05d %-9s %-4s  %3d    %d   %3d    %3d",=0A 			=
nr_neigh->number,=0A 			ax2asc(&nr_neigh->callsign),=0A@@ -818,7 +929,7 @@=
=0A 			break;=0A 	}=0A =0A-	spin_unlock_bh(&nr_neigh_lock);=0A+	spin_unlock=
_bh(&nr_neigh_list_lock);=0A =0A 	*start =3D buffer + (offset - begin);=0A =
	len   -=3D (offset - begin);=0A@@ -833,20 +944,24 @@=0A  */=0A void __exit=
 nr_rt_free(void)=0A {=0A-	struct nr_neigh *s, *nr_neigh =3D nr_neigh_list;=
=0A-	struct nr_node  *t, *nr_node  =3D nr_node_list;=0A-=0A-	while (nr_node=
 !=3D NULL) {=0A-		t       =3D nr_node;=0A-		nr_node =3D nr_node->next;=0A-=
=0A-		nr_remove_node(t);=0A-	}=0A-=0A-	while (nr_neigh !=3D NULL) {=0A-		s =
       =3D nr_neigh;=0A-		nr_neigh =3D nr_neigh->next;=0A-=0A-		nr_remove_n=
eigh(s);=0A+	struct nr_neigh *s =3D NULL;=0A+	struct nr_node  *t =3D NULL;=
=0A+	struct hlist_node *node, *nodet;=0A+=0A+	spin_lock_bh(&nr_neigh_list_l=
ock);=0A+	spin_lock_bh(&nr_node_list_lock);=0A+	nr_node_for_each_safe(t, no=
de, nodet, &nr_node_list) {=0A+		nr_node_lock(t);=0A+		nr_remove_node_locke=
d(t);=0A+		nr_node_unlock(t);=0A+	}=0A+	nr_neigh_for_each_safe(s, node, nod=
et, &nr_neigh_list) {=0A+		while(s->count) {=0A+			s->count--;=0A+			nr_nei=
gh_put(s);=0A+		}=0A+		nr_remove_neigh_locked(s);=0A 	}=0A+	spin_unlock_bh(=
&nr_node_list_lock);=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A }=0AOnly i=
n linux-2.6.0-test3.rxq/net/netrom: nr_route.o=0Adiff -ru linux-2.6.0-test3=
/net/netrom/nr_subr.c linux-2.6.0-test3.rxq/net/netrom/nr_subr.c=0A--- linu=
x-2.6.0-test3/net/netrom/nr_subr.c	2003-08-09 06:42:56.000000000 +0200=0A++=
+ linux-2.6.0-test3.rxq/net/netrom/nr_subr.c	2003-08-12 23:40:35.000000000 =
+0200=0A@@ -127,7 +127,7 @@=0A 	unsigned char  *dptr;=0A 	int len, timeout;=
=0A =0A-	len =3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN=
 + NR_TRANSPORT_LEN;=0A+	len =3D NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A =0A =
	switch (frametype & 0x0F) {=0A 	case NR_CONNREQ:=0A@@ -151,7 +151,7 @@=0A =
	/*=0A 	 *	Space for AX.25 and NET/ROM network header=0A 	 */=0A-	skb_reser=
ve(skb, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN);=0A+	sk=
b_reserve(skb, NR_NETWORK_LEN);=0A =0A 	dptr =3D skb_put(skb, skb_tailroom(=
skb));=0A =0A@@ -219,12 +219,12 @@=0A 	unsigned char *dptr;=0A 	int len;=0A=
 =0A-	len =3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + =
NR_TRANSPORT_LEN + 1;=0A+	len =3D NR_NETWORK_LEN + NR_TRANSPORT_LEN + 1;=0A=
 =0A 	if ((skbn =3D alloc_skb(len, GFP_ATOMIC)) =3D=3D NULL)=0A 		return;=
=0A =0A-	skb_reserve(skbn, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN);=0A+	=
skb_reserve(skbn, 0);=0A =0A 	dptr =3D skb_put(skbn, NR_NETWORK_LEN + NR_TR=
ANSPORT_LEN);=0A =0AOnly in linux-2.6.0-test3.rxq/net/netrom: nr_subr.o=0Ad=
iff -ru linux-2.6.0-test3/net/netrom/nr_timer.c linux-2.6.0-test3.rxq/net/n=
etrom/nr_timer.c=0A--- linux-2.6.0-test3/net/netrom/nr_timer.c	2003-08-09 0=
6:38:56.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/net/netrom/nr_timer.c	2=
003-08-12 23:40:35.000000000 +0200=0A@@ -143,7 +143,10 @@=0A 		   is accept=
ed() it isn't 'dead' so doesn't get removed. */=0A 		if (sock_flag(sk, SOCK=
_DESTROY) ||=0A 		    (sk->sk_state =3D=3D TCP_LISTEN && sock_flag(sk, SOCK=
_DEAD))) {=0A+			sock_hold(sk);=0A 			nr_destroy_socket(sk);=0A+			bh_unloc=
k_sock(sk);=0A+			sock_put(sk);=0A 			return;=0A 		}=0A 		break;=0A@@ -227,=
6 +230,7 @@=0A 	case NR_STATE_1:=0A 		if (nr->n2count =3D=3D nr->n2) {=0A 	=
		nr_disconnect(sk, ETIMEDOUT);=0A+			bh_unlock_sock(sk);=0A 			return;=0A =
		} else {=0A 			nr->n2count++;=0A@@ -237,6 +241,7 @@=0A 	case NR_STATE_2:=
=0A 		if (nr->n2count =3D=3D nr->n2) {=0A 			nr_disconnect(sk, ETIMEDOUT);=
=0A+			bh_unlock_sock(sk);=0A 			return;=0A 		} else {=0A 			nr->n2count++;=
=0A@@ -247,6 +252,7 @@=0A 	case NR_STATE_3:=0A 		if (nr->n2count =3D=3D nr-=
>n2) {=0A 			nr_disconnect(sk, ETIMEDOUT);=0A+			bh_unlock_sock(sk);=0A 			=
return;=0A 		} else {=0A 			nr->n2count++;=0AOnly in linux-2.6.0-test3.rxq/=
net/netrom: nr_timer.o=0Adiff -ru linux-2.6.0-test3/net/netrom/sysctl_net_n=
etrom.c linux-2.6.0-test3.rxq/net/netrom/sysctl_net_netrom.c=0A--- linux-2.=
6.0-test3/net/netrom/sysctl_net_netrom.c	2003-08-09 06:33:21.000000000 +020=
0=0A+++ linux-2.6.0-test3.rxq/net/netrom/sysctl_net_netrom.c	2003-08-12 23:=
40:35.000000000 +0200=0A@@ -15,9 +15,9 @@=0A /*=0A  *	Values taken from NET=
/ROM documentation.=0A  */=0A-static int min_quality[1],       max_quality[=
] =3D {255};=0A-static int min_obs[1],           max_obs[]     =3D {255};=
=0A-static int min_ttl[1],           max_ttl[]     =3D {255};=0A+static int=
 min_quality[] =3D {0}, max_quality[] =3D {255};=0A+static int min_obs[]   =
  =3D {0}, max_obs[]     =3D {255};=0A+static int min_ttl[]     =3D {0}, ma=
x_ttl[]     =3D {255};=0A static int min_t1[]      =3D {5 * HZ};=0A static =
int max_t1[]      =3D {600 * HZ};=0A static int min_n2[]      =3D {2}, max_=
n2[]      =3D {127};=0A@@ -28,7 +28,7 @@=0A static int min_window[]  =3D {1=
}, max_window[]  =3D {127};=0A static int min_idle[]    =3D {0 * HZ};=0A st=
atic int max_idle[]    =3D {65535 * HZ};=0A-static int min_route[1],       =
 max_route[]   =3D {1};=0A+static int min_route[]   =3D {0}, max_route[]   =
=3D {1};=0A static int min_fails[]   =3D {1}, max_fails[]   =3D {10};=0A =
=0A static struct ctl_table_header *nr_table_header;=0AOnly in linux-2.6.0-=
test3.rxq/net/netrom: sysctl_net_netrom.o=0A--- linux-2.6.0-test3/include/n=
et/ax25.h	2003-08-09 06:38:16.000000000 +0200=0A+++ linux-2.6.0-test3.rxq/i=
nclude/net/ax25.h	2003-08-12 23:40:35.000000000 +0200=0A@@ -10,6 +10,7 @@=
=0A #include <linux/ax25.h>=0A #include <linux/spinlock.h>=0A #include <lin=
ux/timer.h>=0A+#include <linux/list.h>=0A #include <asm/atomic.h>=0A =0A #d=
efine	AX25_T1CLAMPLO  		1=0A@@ -180,7 +181,7 @@=0A } ax25_dev;=0A =0A typed=
ef struct ax25_cb {=0A-	struct ax25_cb		*next;=0A+	struct hlist_node	ax25_n=
ode;=0A 	ax25_address		source_addr, dest_addr;=0A 	ax25_digi		*digipeat;=0A=
 	ax25_dev		*ax25_dev;=0A@@ -197,17 +198,32 @@=0A 	struct sk_buff_head	ack_=
queue;=0A 	struct sk_buff_head	frag_queue;=0A 	unsigned char		window;=0A-	s=
truct timer_list	timer;=0A+	struct timer_list	timer, dtimer;=0A 	struct soc=
k		*sk;		/* Backlink to socket */=0A+	atomic_t		refcount;=0A } ax25_cb;=0A =
=0A #define ax25_sk(__sk) ((ax25_cb *)(__sk)->sk_protinfo)=0A =0A+#define a=
x25_for_each(__ax25, node, list) \=0A+	hlist_for_each_entry(__ax25, node, l=
ist, ax25_node)=0A+=0A+#define ax25_cb_hold(__ax25) \=0A+	atomic_inc(&((__a=
x25)->refcount))=0A+=0A+static __inline__ void ax25_cb_put(ax25_cb *ax25)=
=0A+{=0A+	if (atomic_dec_and_test(&ax25->refcount)) {=0A+		if (ax25->digipe=
at)=0A+			kfree(ax25->digipeat);=0A+		kfree(ax25);=0A+	}=0A+}=0A+=0A /* af_=
ax25.c */=0A-extern ax25_cb *ax25_list;=0A+extern struct hlist_head ax25_li=
st;=0A extern spinlock_t ax25_list_lock;=0A-extern void ax25_free_cb(ax25_c=
b *);=0A-extern void ax25_insert_socket(ax25_cb *);=0A+extern void ax25_cb_=
add(ax25_cb *);=0A struct sock *ax25_find_listener(ax25_address *, int, str=
uct net_device *, int);=0A struct sock *ax25_get_socket(ax25_address *, ax2=
5_address *, int);=0A extern ax25_cb *ax25_find_cb(ax25_address *, ax25_add=
ress *, ax25_digi *, struct net_device *);=0A--- linux-2.6.0-test3/include/=
net/netrom.h	2003-08-09 06:37:18.000000000 +0200=0A+++ linux-2.6.0-test3.rx=
q/include/net/netrom.h	2003-08-12 23:40:35.000000000 +0200=0A@@ -7,6 +7,7 @=
@=0A #ifndef _NETROM_H=0A #define _NETROM_H =0A #include <linux/netrom.h>=
=0A+#include <linux/list.h>=0A =0A #define	NR_NETWORK_LEN			15=0A #define	N=
R_TRANSPORT_LEN		5=0A@@ -77,16 +78,17 @@=0A #define nr_sk(__sk) ((nr_cb *)(=
__sk)->sk_protinfo)=0A =0A struct nr_neigh {=0A-	struct nr_neigh *next;=0A-=
	ax25_address    callsign;=0A-	ax25_digi       *digipeat;=0A-	ax25_cb		*ax2=
5;=0A-	struct net_device   *dev;=0A-	unsigned char   quality;=0A-	unsigned =
char   locked;=0A-	unsigned short  count;=0A-	unsigned int    number;=0A-	u=
nsigned char	failed;=0A+	struct hlist_node	neigh_node;=0A+	ax25_address		ca=
llsign;=0A+	ax25_digi		*digipeat;=0A+	ax25_cb			*ax25;=0A+	struct net_devic=
e	*dev;=0A+	unsigned char		quality;=0A+	unsigned char		locked;=0A+	unsigned=
 short		count;=0A+	unsigned int		number;=0A+	unsigned char		failed;=0A+	ato=
mic_t		refcount;=0A };=0A =0A struct nr_route {=0A@@ -96,14 +98,74 @@=0A };=
=0A =0A struct nr_node {=0A-	struct nr_node  *next;=0A-	ax25_address    cal=
lsign;=0A-	char		mnemonic[7];=0A-	unsigned char   which;=0A-	unsigned char =
  count;=0A-	struct nr_route routes[3];=0A+	struct hlist_node	node_node;=0A=
+	ax25_address		callsign;=0A+	char			mnemonic[7];=0A+	unsigned char		which;=
=0A+	unsigned char		count;=0A+	struct nr_route		routes[3];=0A+	atomic_t		re=
fcount;=0A+	spinlock_t		node_lock;=0A };=0A =0A+/**************************=
*******************************************=0A+ *	nr_node & nr_neigh lists,=
 refcounting and locking=0A+ **********************************************=
***********************/=0A+=0A+extern struct hlist_head nr_node_list;=0A+e=
xtern struct hlist_head nr_neigh_list;=0A+=0A+#define nr_node_hold(__nr_nod=
e) \=0A+	atomic_inc(&((__nr_node)->refcount))=0A+=0A+static __inline__ void=
 nr_node_put(struct nr_node *nr_node)=0A+{=0A+	if (atomic_dec_and_test(&nr_=
node->refcount)) {=0A+		kfree(nr_node);=0A+	}=0A+}=0A+=0A+#define nr_neigh_=
hold(__nr_neigh) \=0A+	atomic_inc(&((__nr_neigh)->refcount))=0A+=0A+static =
__inline__ void nr_neigh_put(struct nr_neigh *nr_neigh)=0A+{=0A+	if (atomic=
_dec_and_test(&nr_neigh->refcount)) {=0A+		if (nr_neigh->digipeat !=3D NULL=
)=0A+			kfree(nr_neigh->digipeat);=0A+		kfree(nr_neigh);=0A+	}=0A+}=0A+=0A+=
/* nr_node_lock and nr_node_unlock also hold/put the node's refcounter.=0A+=
 */=0A+static __inline__ void nr_node_lock(struct nr_node *nr_node)=0A+{=0A=
+	nr_node_hold(nr_node);=0A+	spin_lock_bh(&nr_node->node_lock);=0A+}=0A+=0A=
+static __inline__ void nr_node_unlock(struct nr_node *nr_node)=0A+{=0A+	sp=
in_unlock_bh(&nr_node->node_lock);=0A+	nr_node_put(nr_node);=0A+}=0A+=0A+#d=
efine nr_neigh_for_each(__nr_neigh, node, list) \=0A+	hlist_for_each_entry(=
__nr_neigh, node, list, neigh_node)=0A+=0A+#define nr_neigh_for_each_safe(_=
_nr_neigh, node, node2, list) \=0A+	hlist_for_each_entry_safe(__nr_neigh, n=
ode, node2, list, neigh_node)=0A+=0A+#define nr_node_for_each(__nr_node, no=
de, list) \=0A+	hlist_for_each_entry(__nr_node, node, list, node_node)=0A+=
=0A+#define nr_node_for_each_safe(__nr_node, node, node2, list) \=0A+	hlist=
_for_each_entry_safe(__nr_node, node, node2, list, node_node)=0A+=0A+=0A+/*=
********************************************************************/=0A+=
=0A /* af_netrom.c */=0A extern int  sysctl_netrom_default_path_quality;=0A=
 extern int  sysctl_netrom_obsolescence_count_initialiser;=0Adiff -Nru a/ne=
t/ax25/ax25_dev.c b/net/ax25/ax25_dev.c=0A--- a/net/ax25/ax25_dev.c	Tue Aug=
 12 16:45:51 2003=0A+++ b/net/ax25/ax25_dev.c	Tue Aug 12 16:45:51 2003=0A@@=
 -67,6 +67,7 @@=0A =0A 	dev->ax25_ptr     =3D ax25_dev;=0A 	ax25_dev->dev  =
   =3D dev;=0A+	dev_hold(dev);=0A 	ax25_dev->forward =3D NULL;=0A =0A 	ax25=
_dev->values[AX25_VALUES_IPDEFMODE] =3D AX25_DEF_IPDEFMODE;=0A@@ -121,6 +12=
2,7 @@=0A 	if ((s =3D ax25_dev_list) =3D=3D ax25_dev) {=0A 		ax25_dev_list =
=3D s->next;=0A 		spin_unlock_bh(&ax25_dev_lock);=0A+		dev_put(dev);=0A 		k=
free(ax25_dev);=0A 		ax25_register_sysctl();=0A 		return;=0A@@ -131,6 +133,=
7 @@=0A 			s->next =3D ax25_dev->next;=0A 			spin_unlock_bh(&ax25_dev_lock)=
;=0A 			kfree(ax25_dev);=0A+			dev_put(dev);=0A 			ax25_register_sysctl();=
=0A 			return;=0A 		}=0A--- ax25/net/ax25/af_ax25.c	2003-08-12 17:08:42.025=
816088 -0700=0A+++ linux-2.5-net/net/ax25/af_ax25.c	2003-08-12 16:47:07.802=
057749=0A-0700=0A 		if (optlen > IFNAMSIZ)=0A 			optlen=3DIFNAMSIZ;=0A 		if=
 (copy_from_user(devname, optval, optlen)) {=0A-		res =3D -EFAULT;=0A+			re=
s =3D -EFAULT;=0A 			break;=0A 		}=0A =0A@@ -650,12 +650,14 @@ static int a=
x25_setsockopt(struct socket=0A 		   (sock->state !=3D SS_UNCONNECTED ||=0A=
 		    sk->sk_state =3D=3D TCP_LISTEN)) {=0A 			res =3D -EADDRNOTAVAIL;=0A-=
			dev_put(dev);=0A-			break;=0A 		}=0A =0A-		ax25->ax25_dev =3D ax25_dev_a=
x25dev(dev);=0A-		ax25_fillin_cb(ax25, ax25->ax25_dev);=0A+		else if ((ax25=
->ax25_dev =3D ax25_dev_ax25dev(dev)) =3D=3D NULL)=0A+			res =3D -EINVAL;=
=0A+		else =0A+			ax25_fillin_cb(ax25, ax25->ax25_dev);=0A+=0A+		dev_put(de=
v);=0A 		break;=0A =0A 	default:=0Adiff -Nru a/include/net/ax25.h b/include=
/net/ax25.h=0A--- a/include/net/ax25.h	Tue Aug 12 17:16:52 2003=0A+++ b/inc=
lude/net/ax25.h	Tue Aug 12 17:16:52 2003=0A@@ -314,7 +314,7 @@=0A /* ax25_r=
oute.c */=0A extern void ax25_rt_device_down(struct net_device *);=0A exter=
n int  ax25_rt_ioctl(unsigned int, void *);=0A-extern int  ax25_rt_get_info=
(char *, char **, off_t, int);=0A+extern struct file_operations ax25_route_=
fops;=0A extern int  ax25_rt_autobind(ax25_cb *, ax25_address *);=0A extern=
 ax25_route *ax25_rt_find_route(ax25_route *, ax25_address *,=0A 	struct ne=
t_device *);=0A@@ -373,7 +373,7 @@=0A extern int  ax25_uid_policy;=0A exter=
n ax25_address *ax25_findbyuid(uid_t);=0A extern int  ax25_uid_ioctl(int, s=
truct sockaddr_ax25 *);=0A-extern int  ax25_uid_get_info(char *, char **, o=
ff_t, int);=0A+extern struct file_operations ax25_uid_fops;=0A extern void =
ax25_uid_free(void);=0A =0A /* sysctl_net_ax25.c */=0Adiff -Nru a/net/ax25/=
af_ax25.c b/net/ax25/af_ax25.c=0A--- a/net/ax25/af_ax25.c	Tue Aug 12 17:16:=
52 2003=0A+++ b/net/ax25/af_ax25.c	Tue Aug 12 17:16:52 2003=0A@@ -1844,81 +=
1844,107 @@=0A 	return res;=0A }=0A =0A-static int ax25_get_info(char *buff=
er, char **start, off_t offset, int=0Alength)=0A+#ifdef CONFIG_PROC_FS=0A+=
=0A+static void *ax25_info_start(struct seq_file *seq, loff_t *pos)=0A {=0A=
-	ax25_cb *ax25;=0A-	int k;=0A-	int len =3D 0;=0A-	off_t pos =3D 0;=0A-	off=
_t begin =3D 0;=0A+	struct ax25_cb *ax25;=0A 	struct hlist_node *node;=0A+	=
int i =3D 0;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A+	ax25_for_each(ax25,=
 node, &ax25_list) {=0A+		if (i =3D=3D *pos)=0A+			return ax25;=0A+		++i;=
=0A+	}=0A+	return NULL;=0A+}=0A+=0A+static void *ax25_info_next(struct seq_=
file *seq, void *v, loff_t *pos)=0A+{=0A+	++*pos;=0A+=0A+	return hlist_entr=
y( ((struct ax25_cb *)v)->ax25_node.next,=0A+			    struct ax25_cb, ax25_no=
de);=0A+}=0A+	=0A+static void ax25_info_stop(struct seq_file *seq, void *v)=
=0A+{=0A+	spin_unlock_bh(&ax25_list_lock);=0A+}=0A+=0A+static int ax25_info=
_show(struct seq_file *seq, void *v)=0A+{=0A+	ax25_cb *ax25 =3D v;=0A+	int =
k;=0A+=0A =0A 	/*=0A 	 * New format:=0A 	 * magic dev src_addr dest_addr,di=
gi1,digi2,.. st vs vr va t1 t1=0At2 t2 t3 t3 idle idle n2 n2 rtt window pac=
len Snd-Q Rcv-Q inode=0A 	 */=0A =0A-	ax25_for_each(ax25, node, &ax25_list)=
 {=0A-		len +=3D sprintf(buffer+len, "%8.8lx %s %s%s ",=0A-				(long) ax25,=
=0A-				ax25->ax25_dev =3D=3D NULL? "???" : ax25->ax25_dev->dev->name,=0A-	=
			ax2asc(&ax25->source_addr),=0A-				ax25->iamdigi? "*":"");=0A-=0A-		len =
+=3D sprintf(buffer+len, "%s", ax2asc(&ax25->dest_addr));=0A-=0A-		for (k=
=3D0; (ax25->digipeat !=3D NULL) && (k <=0Aax25->digipeat->ndigi); k++) {=
=0A-			len +=3D sprintf(buffer+len, ",%s%s",=0A-					ax2asc(&ax25->digipeat=
->calls[k]),=0A-					ax25->digipeat->repeated[k]? "*":"");=0A-		}=0A-=0A-		=
len +=3D sprintf(buffer+len, " %d %d %d %d %lu %lu %lu %lu=0A%lu %lu %lu %l=
u %d %d %lu %d %d",=0A-			ax25->state,=0A-			ax25->vs, ax25->vr, ax25->va,=
=0A-			ax25_display_timer(&ax25->t1timer) / HZ, ax25->t1=0A/ HZ,=0A-			ax25=
_display_timer(&ax25->t2timer) / HZ, ax25->t2=0A/ HZ,=0A-			ax25_display_ti=
mer(&ax25->t3timer) / HZ, ax25->t3=0A/ HZ,=0A-			ax25_display_timer(&ax25->=
idletimer) / (60 * HZ),=0A-			ax25->idle / (60 * HZ),=0A-			ax25->n2count, =
ax25->n2,=0A-			ax25->rtt / HZ,=0A-			ax25->window,=0A-			ax25->paclen);=0A=
-=0A-		if (ax25->sk !=3D NULL) {=0A-			bh_lock_sock(ax25->sk);=0A-			len +=
=3D sprintf(buffer + len, " %d %d %ld\n",=0A-				atomic_read(&ax25->sk->sk_=
wmem_alloc),=0A-				atomic_read(&ax25->sk->sk_rmem_alloc),=0A-				ax25->sk-=
>sk_socket !=3D NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino=0A: 0L);=0A-	=
		bh_unlock_sock(ax25->sk);=0A-		} else {=0A-			len +=3D sprintf(buffer + l=
en, " * * *\n");=0A-		}=0A-=0A-		pos =3D begin + len;=0A-=0A-		if (pos < of=
fset) {=0A-			len   =3D 0;=0A-			begin =3D pos;=0A-		}=0A+	seq_printf(seq, =
"%8.8lx %s %s%s ",=0A+		   (long) ax25,=0A+		   ax25->ax25_dev =3D=3D NULL?=
 "???" :=0Aax25->ax25_dev->dev->name,=0A+		   ax2asc(&ax25->source_addr),=
=0A+		   ax25->iamdigi? "*":"");=0A+	seq_printf(seq, "%s", ax2asc(&ax25->de=
st_addr));=0A+=0A+	for (k=3D0; (ax25->digipeat !=3D NULL) && (k < ax25->dig=
ipeat->ndigi);=0Ak++) {=0A+		seq_printf(seq, ",%s%s",=0A+			   ax2asc(&ax25=
->digipeat->calls[k]),=0A+			   ax25->digipeat->repeated[k]? "*":"");=0A+	}=
=0A =0A-		if (pos > offset + length)=0A-			break;=0A+	seq_printf(seq, " %d =
%d %d %d %lu %lu %lu %lu %lu %lu %lu %lu %d=0A%d %lu %d %d",=0A+		   ax25->=
state,=0A+		   ax25->vs, ax25->vr, ax25->va,=0A+		   ax25_display_timer(&ax=
25->t1timer) / HZ, ax25->t1 / HZ,=0A+		   ax25_display_timer(&ax25->t2timer=
) / HZ, ax25->t2 / HZ,=0A+		   ax25_display_timer(&ax25->t3timer) / HZ, ax2=
5->t3 / HZ,=0A+		   ax25_display_timer(&ax25->idletimer) / (60 * HZ),=0A+		=
   ax25->idle / (60 * HZ),=0A+		   ax25->n2count, ax25->n2,=0A+		   ax25->r=
tt / HZ,=0A+		   ax25->window,=0A+		   ax25->paclen);=0A+=0A+	if (ax25->sk =
!=3D NULL) {=0A+		bh_lock_sock(ax25->sk);=0A+		seq_printf(seq," %d %d %ld\n=
",=0A+			   atomic_read(&ax25->sk->sk_wmem_alloc),=0A+			   atomic_read(&ax=
25->sk->sk_rmem_alloc),=0A+			   ax25->sk->sk_socket !=3D NULL ? SOCK_INODE=
(ax25->sk->sk_socket)->i_ino=0A: 0L);=0A+		bh_unlock_sock(ax25->sk);=0A+	} =
else {=0A+		seq_puts(seq, " * * *\n");=0A 	}=0A+	return 0;=0A+}=0A =0A-	spi=
n_unlock_bh(&ax25_list_lock);=0A+static struct seq_operations ax25_info_seq=
ops =3D {=0A+	.start =3D ax25_info_start,=0A+	.next =3D ax25_info_next,=0A+=
	.stop =3D ax25_info_stop,=0A+	.show =3D ax25_info_show,=0A+};=0A =0A-	*sta=
rt =3D buffer + (offset - begin);=0A-	len   -=3D (offset - begin);=0A+stati=
c int ax25_info_open(struct inode *inode, struct file *file)=0A+{=0A+	retur=
n seq_open(file, &ax25_info_seqops);=0A+}=0A =0A-	if (len > length) len =3D=
 length;=0A+struct file_operations ax25_info_fops =3D {=0A+	.owner =3D THIS=
_MODULE,=0A+	.open =3D ax25_info_open,=0A+	.read =3D seq_read,=0A+	.llseek =
=3D seq_lseek,=0A+	.release =3D seq_release,=0A+};=0A =0A-	return(len);=0A-=
}=0A+#endif=0A =0A static struct net_proto_family ax25_family_ops =3D {=0A =
	.family =3D	PF_AX25,=0A@@ -1988,9 +2014,9 @@=0A 	register_netdevice_notifi=
er(&ax25_dev_notifier);=0A 	ax25_register_sysctl();=0A =0A-	proc_net_create=
("ax25_route", 0, ax25_rt_get_info);=0A-	proc_net_create("ax25", 0, ax25_ge=
t_info);=0A-	proc_net_create("ax25_calls", 0, ax25_uid_get_info);=0A+	proc_=
net_fops_create("ax25_route", S_IRUGO, &ax25_route_fops);=0A+	proc_net_fops=
_create("ax25", S_IRUGO, &ax25_info_fops);=0A+	proc_net_fops_create("ax25_c=
alls", S_IRUGO, &ax25_uid_fops);=0A =0A 	printk(banner);=0A 	return 0;=0Adi=
ff -Nru a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c=0A--- a/net/ax25/ax=
25_route.c	Tue Aug 12 17:16:52 2003=0A+++ b/net/ax25/ax25_route.c	Tue Aug 1=
2 17:16:52 2003=0A@@ -34,6 +34,7 @@=0A #include <linux/mm.h>=0A #include <l=
inux/interrupt.h>=0A #include <linux/init.h>=0A+#include <linux/seq_file.h>=
=0A =0A static ax25_route *ax25_route_list;=0A static rwlock_t ax25_route_l=
ock =3D RW_LOCK_UNLOCKED;=0A@@ -278,66 +279,100 @@=0A 	}=0A }=0A =0A-int ax=
25_rt_get_info(char *buffer, char **start, off_t offset, int length)=0A-{=
=0A-	ax25_route *ax25_rt;=0A-	int len     =3D 0;=0A-	off_t pos   =3D 0;=0A-=
	off_t begin =3D 0;=0A-	char *callsign;=0A-	int i;=0A+#ifdef CONFIG_PROC_FS=
=0A =0A-	read_lock(&ax25_route_lock);=0A+#define AX25_PROC_START	((void *)1=
)=0A =0A-	len +=3D sprintf(buffer, "callsign  dev  mode digipeaters\n");=0A=
+static void *ax25_rt_seq_start(struct seq_file *seq, loff_t *pos)=0A+{=0A+=
	struct ax25_route *ax25_rt;=0A+	int i =3D 1;=0A+ =0A+ 	read_lock(&ax25_rou=
te_lock);=0A+	if (*pos =3D=3D 0)=0A+		return AX25_PROC_START;=0A =0A 	for (=
ax25_rt =3D ax25_route_list; ax25_rt !=3D NULL; ax25_rt =3D=0Aax25_rt->next=
) {=0A+		if (i =3D=3D *pos)=0A+			return ax25_rt;=0A+		++i;=0A+	}=0A+=0A+	r=
eturn NULL;=0A+}=0A+=0A+static void *ax25_rt_seq_next(struct seq_file *seq,=
 void *v, loff_t *pos)=0A+{=0A+	++*pos;=0A+	return (v =3D=3D AX25_PROC_STAR=
T) ? ax25_route_list : =0A+		((struct ax25_route *) v)->next;=0A+}=0A+=0A+s=
tatic void ax25_rt_seq_stop(struct seq_file *seq, void *v)=0A+{=0A+	read_un=
lock(&ax25_route_lock);=0A+}=0A+=0A+static int ax25_rt_seq_show(struct seq_=
file *seq, void *v)=0A+{=0A+	if (v =3D=3D AX25_PROC_START)=0A+		seq_puts(se=
q, "callsign  dev  mode digipeaters\n");=0A+	else {=0A+		struct ax25_route =
*ax25_rt =3D v;=0A+		const char *callsign;=0A+		int i;=0A+=0A 		if (ax25cmp=
(&ax25_rt->callsign, &null_ax25_address) =3D=3D 0)=0A 			callsign =3D "defa=
ult";=0A 		else=0A 			callsign =3D ax2asc(&ax25_rt->callsign);=0A-		len +=
=3D sprintf(buffer + len, "%-9s %-4s",=0A+=0A+		seq_printf(seq, "%-9s %-4s"=
,=0A 			callsign,=0A 			ax25_rt->dev ? ax25_rt->dev->name : "???");=0A =0A =
		switch (ax25_rt->ip_mode) {=0A 		case 'V':=0A-			len +=3D sprintf(buffer =
+ len, "   vc");=0A+			seq_puts(seq, "   vc");=0A 			break;=0A 		case 'D':=
=0A-			len +=3D sprintf(buffer + len, "   dg");=0A+			seq_puts(seq, "   dg"=
);=0A 			break;=0A 		default:=0A-			len +=3D sprintf(buffer + len, "    *")=
;=0A+			seq_puts(seq, "    *");=0A 			break;=0A 		}=0A =0A 		if (ax25_rt->d=
igipeat !=3D NULL)=0A 			for (i =3D 0; i < ax25_rt->digipeat->ndigi; i++)=
=0A-				len +=3D sprintf(buffer + len, " %s",=0Aax2asc(&ax25_rt->digipeat->=
calls[i]));=0A-=0A-		len +=3D sprintf(buffer + len, "\n");=0A+				seq_print=
f(seq, " %s", ax2asc(&ax25_rt->digipeat->calls[i]));=0A =0A-		pos =3D begin=
 + len;=0A-=0A-		if (pos < offset) {=0A-			len   =3D 0;=0A-			begin =3D pos=
;=0A-		}=0A-=0A-		if (pos > offset + length)=0A-			break;=0A+		seq_puts(seq=
, "\n");=0A 	}=0A-	read_unlock(&ax25_route_lock);=0A-=0A-	*start =3D buffer=
 + (offset - begin);=0A-	len   -=3D (offset - begin);=0A+	return 0;=0A+}=0A=
 =0A-	if (len > length)=0A-		len =3D length;=0A+static struct seq_operation=
s ax25_rt_seqops =3D {=0A+	.start =3D ax25_rt_seq_start,=0A+	.next =3D ax25=
_rt_seq_next,=0A+	.stop =3D ax25_rt_seq_stop,=0A+	.show =3D ax25_rt_seq_sho=
w,=0A+};=0A =0A-	return len;=0A+static int ax25_rt_info_open(struct inode *=
inode, struct file *file)=0A+{=0A+	return seq_open(file, &ax25_rt_seqops);=
=0A }=0A+=0A+struct file_operations ax25_route_fops =3D {=0A+	.owner =3D TH=
IS_MODULE,=0A+	.open =3D ax25_rt_info_open,=0A+	.read =3D seq_read,=0A+	.ll=
seek =3D seq_lseek,=0A+	.release =3D seq_release,=0A+};=0A+=0A+#endif=0A =
=0A /*=0A  *	Find AX.25 route=0Adiff -Nru a/net/ax25/ax25_uid.c b/net/ax25/=
ax25_uid.c=0A--- a/net/ax25/ax25_uid.c	Tue Aug 12 17:16:52 2003=0A+++ b/net=
/ax25/ax25_uid.c	Tue Aug 12 17:16:52 2003=0A@@ -30,6 +30,7 @@=0A #include <=
linux/interrupt.h>=0A #include <linux/notifier.h>=0A #include <linux/proc_f=
s.h>=0A+#include <linux/seq_file.h>=0A #include <linux/stat.h>=0A #include =
<linux/netfilter.h>=0A #include <linux/sysctl.h>=0A@@ -141,39 +142,73 @@=0A=
 	return -EINVAL;	/*NOTREACHED */=0A }=0A =0A-int ax25_uid_get_info(char *b=
uffer, char **start, off_t offset, int=0Alength)=0A+#ifdef CONFIG_PROC_FS=
=0A+=0A+#define AX25_PROC_START	((void *)1)=0A+=0A+static void *ax25_uid_se=
q_start(struct seq_file *seq, loff_t *pos)=0A {=0A-	ax25_uid_assoc *pt;=0A-=
	int len     =3D 0;=0A-	off_t pos   =3D 0;=0A-	off_t begin =3D 0;=0A+	struc=
t ax25_uid_assoc *pt;=0A+	int i =3D 1;=0A =0A 	read_lock(&ax25_uid_lock);=
=0A-	len +=3D sprintf(buffer, "Policy: %d\n", ax25_uid_policy);=0A+	if (*po=
s =3D=3D 0)=0A+		return AX25_PROC_START;=0A =0A 	for (pt =3D ax25_uid_list;=
 pt !=3D NULL; pt =3D pt->next) {=0A-		len +=3D sprintf(buffer + len, "%6d =
%s\n", pt->uid,=0Aax2asc(&pt->call));=0A-=0A-		pos =3D begin + len;=0A+		if=
 (i =3D=3D *pos)=0A+			return pt;=0A+		++i;=0A+	}=0A+	return NULL;=0A+}=0A =
=0A-		if (pos < offset) {=0A-			len =3D 0;=0A-			begin =3D pos;=0A-		}=0A+s=
tatic void *ax25_uid_seq_next(struct seq_file *seq, void *v, loff_t *pos)=
=0A+{=0A+	++*pos;=0A+	return (v =3D=3D AX25_PROC_START) ? ax25_uid_list : =
=0A+		((struct ax25_uid_assoc *) v)->next;=0A+}=0A =0A-		if (pos > offset +=
 length)=0A-			break;=0A-	}=0A+static void ax25_uid_seq_stop(struct seq_fil=
e *seq, void *v)=0A+{=0A 	read_unlock(&ax25_uid_lock);=0A+}=0A+=0A+static i=
nt ax25_uid_seq_show(struct seq_file *seq, void *v)=0A+{=0A+	if (v =3D=3D A=
X25_PROC_START)=0A+		seq_printf(seq, "Policy: %d\n", ax25_uid_policy);=0A+	=
else {=0A+		struct ax25_uid_assoc *pt =3D v;=0A+		=0A =0A-	*start =3D buffe=
r + (offset - begin);=0A-	len   -=3D offset - begin;=0A+		seq_printf(seq, "=
%6d %s\n", pt->uid, ax2asc(&pt->call));=0A+	}=0A+	return 0;=0A+}=0A =0A-	if=
 (len > length)=0A-		len =3D length;=0A+static struct seq_operations ax25_u=
id_seqops =3D {=0A+	.start =3D ax25_uid_seq_start,=0A+	.next =3D ax25_uid_s=
eq_next,=0A+	.stop =3D ax25_uid_seq_stop,=0A+	.show =3D ax25_uid_seq_show,=
=0A+};=0A =0A-	return len;=0A+static int ax25_uid_info_open(struct inode *i=
node, struct file *file)=0A+{=0A+	return seq_open(file, &ax25_uid_seqops);=
=0A }=0A+=0A+struct file_operations ax25_uid_fops =3D {=0A+	.owner =3D THIS=
_MODULE,=0A+	.open =3D ax25_uid_info_open,=0A+	.read =3D seq_read,=0A+	.lls=
eek =3D seq_lseek,=0A+	.release =3D seq_release,=0A+};=0A+=0A+#endif=0A =0A=
 /*=0A  *	Free all memory associated with UID/Callsign structures.=0A
--AWniW0JNca5xppdA--
