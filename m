From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: [PATCH] ax25 & netrom fixes for 2.6
Date: Tue, 12 Aug 2003 19:46:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Cc: ralf@linux-mips.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-hams@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Hi,

These are the same changes I send earlier in two parts against 2.6.0-test1.
I remade the diff against 2.6.0-test3 as Stephen Hemminger's patch clashed
with mine (My patch already had the fix....)

Jeroen

changes:

	-fix waitqueue oops on interrupted socket call
	-add refcounting like struct sock for ax25_cb
	-skb allocation uses dev->hard_header_len instead off 
	 predicted worst case.
	-ax25_cb list uses hlists like struct sock
	-lock sk in ax25_find_listener
	-ax25_destroy_timer set from 10*HZ to 2*HZ (Tihomir Heidelberg)
	-lock sock when calling ax25_destroy_socket() (Tihomir Heidelberg)
	-Set ax25->sk to NULL when destroying sk (Tihomir Heidelberg)
	-Empty write_queue in ax25_destroy_socket() (Tihomir Heidelberg)
	-ax25_destroy_timer() doesn't share its timer with the heartbeat
	 timer
	-lock sock in ax25_destroy_timer()
	-return when destroying ax25 route (Ralf Baechle)

	-Add ax25_cb_put() calls to netrom
	-Initialize ax25_iface lists to NULL
	-unlock linkfail_lock in ax25_linkfail_release()
	-unlock listen_lock in ax25_listen_release()
	-unlock_listen_lock in ax25_listen_mine()
	-remove module_owner from nr_init()
	-Only release/register listener in nr_set_mac_address() if
	 interface is up.
	-Call nr_destroy_socket() with socket locked
	-Free write queue in nr_destroy_socket()
	-Add missing sock_[unlock/release] calls in netrom code
	-nr_destroy_tmer set from 10*HZ to 2*HZ
	-Fixed net_device refcounting to nr_dev_first() and nr_dev_get()
	-Added nr_node & nr_neigh refcounting
	-Use hlists for nr_node_list and nr_neigh_list
	-Added nr_node locking
	-Prevent race between freeing dev.priv and freeing dev
	-Don't free dev.name on module exit
	-Fix error return value from ax25_connect()
	-Missing unlock in ax25_register_sysctl()
	-nr_route_frame() makes a private copy of skb's instead of using
	 the one given, it also reserves head room using hard_header_len
	 from the device the packet goes out removing the need for
	 AX25_BPQ_HEADER_LEN
	-Make ax25_cb refcounting inlined or macro.
	-Additional locking in ax25

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=ISO-8859-1
Content-Disposition: attachment; filename="linux-2.6.0-test3.rxq3.diff"
Content-Transfer-Encoding: quoted-printable

diff -ru linux-2.6.0-test3/net/ax25/af_ax25.c linux-2.6.0-test1.rxq3/net/ax=
25/af_ax25.c=0A--- linux-2.6.0-test3/net/ax25/af_ax25.c	2003-08-09 06:41:26=
.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/af_ax25.c	2003-07-24=
 20:56:37.000000000 +0200=0A@@ -51,54 +51,25 @@=0A =0A =0A =0A-ax25_cb *ax2=
5_list;=0A+HLIST_HEAD(ax25_list);=0A spinlock_t ax25_list_lock =3D SPIN_LOC=
K_UNLOCKED;=0A =0A static struct proto_ops ax25_proto_ops;=0A =0A-/*=0A- *	=
Free an allocated ax25 control block. This is done to centralise=0A- *	the =
MOD count code.=0A- */=0A-void ax25_free_cb(ax25_cb *ax25)=0A-{=0A-	if (ax2=
5->digipeat !=3D NULL) {=0A-		kfree(ax25->digipeat);=0A-		ax25->digipeat =
=3D NULL;=0A-	}=0A-=0A-	kfree(ax25);=0A-}=0A-=0A static void ax25_free_sock=
(struct sock *sk)=0A {=0A-	ax25_free_cb(ax25_sk(sk));=0A+	ax25_cb_put(ax25_=
sk(sk));=0A }=0A =0A /*=0A  *	Socket removal during an interrupt is now saf=
e.=0A  */=0A-static void ax25_remove_socket(ax25_cb *ax25)=0A+static void a=
x25_cb_del(ax25_cb *ax25)=0A {=0A-	ax25_cb *s;=0A-=0A 	spin_lock_bh(&ax25_l=
ist_lock);=0A-	if ((s =3D ax25_list) =3D=3D ax25) {=0A-		ax25_list =3D s->n=
ext;=0A-		spin_unlock_bh(&ax25_list_lock);=0A-		return;=0A-	}=0A-=0A-	while=
 (s !=3D NULL && s->next !=3D NULL) {=0A-		if (s->next =3D=3D ax25) {=0A-		=
	s->next =3D ax25->next;=0A-			spin_unlock_bh(&ax25_list_lock);=0A-			retur=
n;=0A-		}=0A-=0A-		s =3D s->next;=0A-	}=0A+	hlist_del_init(&ax25->ax25_node=
);=0A 	spin_unlock_bh(&ax25_list_lock);=0A+	ax25_cb_put(ax25);=0A }=0A =0A =
/*=0A@@ -108,12 +79,13 @@=0A {=0A 	ax25_dev *ax25_dev;=0A 	ax25_cb *s;=0A+	=
struct hlist_node *node;=0A =0A 	if ((ax25_dev =3D ax25_dev_ax25dev(dev)) =
=3D=3D NULL)=0A 		return;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s=
 =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &a=
x25_list) {=0A 		if (s->ax25_dev =3D=3D ax25_dev) {=0A 			s->ax25_dev =3D N=
ULL;=0A 			ax25_disconnect(s, ENETUNREACH);=0A@@ -153,11 +125,11 @@=0A /*=
=0A  *	Add a socket to the bound sockets list.=0A  */=0A-void ax25_insert_s=
ocket(ax25_cb *ax25)=0A+void ax25_cb_add(ax25_cb *ax25)=0A {=0A 	spin_lock_=
bh(&ax25_list_lock);=0A-	ax25->next =3D ax25_list;=0A-	ax25_list  =3D ax25;=
=0A+	ax25_cb_hold(ax25);=0A+	hlist_add_head(&ax25->ax25_node, &ax25_list);=
=0A 	spin_unlock_bh(&ax25_list_lock);=0A }=0A =0A@@ -169,17 +141,18 @@=0A 	=
struct net_device *dev, int type)=0A {=0A 	ax25_cb *s;=0A+	struct hlist_nod=
e *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D ax25_list; s=
 !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_list) {=0A 		=
if ((s->iamdigi && !digi) || (!s->iamdigi && digi))=0A 			continue;=0A 		if=
 (s->sk && !ax25cmp(&s->source_addr, addr) &&=0A 		    s->sk->sk_type =3D=
=3D type && s->sk->sk_state =3D=3D TCP_LISTEN) {=0A 			/* If device is null=
 we match any device */=0A 			if (s->ax25_dev =3D=3D NULL || s->ax25_dev->d=
ev =3D=3D dev) {=0A+				sock_hold(s->sk);=0A 				spin_unlock_bh(&ax25_list_=
lock);=0A-=0A 				return s->sk;=0A 			}=0A 		}=0A@@ -197,9 +170,10 @@=0A {=
=0A 	struct sock *sk =3D NULL;=0A 	ax25_cb *s;=0A+	struct hlist_node *node;=
=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D ax25_list; s !=3D NU=
LL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_list) {=0A 		if (s->s=
k && !ax25cmp(&s->source_addr, my_addr) &&=0A 		    !ax25cmp(&s->dest_addr,=
 dest_addr) &&=0A 		    s->sk->sk_type =3D=3D type) {=0A@@ -223,9 +197,10 @=
@=0A 	ax25_digi *digi, struct net_device *dev)=0A {=0A 	ax25_cb *s;=0A+	str=
uct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D=
 ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_=
list) {=0A 		if (s->sk && s->sk->sk_type !=3D SOCK_SEQPACKET)=0A 			continu=
e;=0A 		if (s->ax25_dev =3D=3D NULL)=0A@@ -240,6 +215,7 @@=0A 				if (s->di=
gipeat !=3D NULL && s->digipeat->ndigi !=3D 0)=0A 					continue;=0A 			}=0A=
+			ax25_cb_hold(s);=0A 			spin_unlock_bh(&ax25_list_lock);=0A =0A 			retur=
n s;=0A@@ -257,9 +233,10 @@=0A {=0A 	struct sock *sk =3D NULL;=0A 	ax25_cb =
*s;=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-=
	for (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, n=
ode, &ax25_list) {=0A 		if (s->sk !=3D NULL && ax25cmp(&s->source_addr, add=
r) =3D=3D 0 &&=0A 		    s->sk->sk_type =3D=3D SOCK_RAW) {=0A 			sk =3D s->s=
k;=0A@@ -267,6 +244,7 @@=0A 			break;=0A 		}=0A 	}=0A+=0A 	spin_unlock_bh(&=
ax25_list_lock);=0A =0A 	return sk;=0A@@ -299,7 +277,16 @@=0A  */=0A static=
 void ax25_destroy_timer(unsigned long data)=0A {=0A-	ax25_destroy_socket((=
ax25_cb *)data);=0A+	ax25_cb *ax25=3D(ax25_cb *)data;=0A+	struct sock *sk;=
=0A+	=0A+	sk=3Dax25->sk;=0A+	=0A+	bh_lock_sock(sk);=0A+	sock_hold(sk);=0A+	=
ax25_destroy_socket(ax25);=0A+	bh_unlock_sock(sk);=0A+	sock_put(sk);=0A }=
=0A =0A /*=0A@@ -312,7 +299,7 @@=0A {=0A 	struct sk_buff *skb;=0A =0A-	ax25=
_remove_socket(ax25);=0A+	ax25_cb_del(ax25);=0A =0A 	ax25_stop_heartbeat(ax=
25);=0A 	ax25_stop_t1timer(ax25);=0A@@ -337,22 +324,27 @@=0A =0A 			kfree_s=
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
	ax25_cb_put(ax25);=0A 	}=0A }=0A =0A@@ -421,7 +413,7 @@=0A =0A   	case AX2=
5_N2:=0A   		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 31)=0A-  			return -EIN=
VAL;=0A+			return -EINVAL;=0A   		ax25->n2count =3D 0;=0A   		ax25->n2 =3D =
ax25_ctl.arg;=0A   		break;=0A@@ -448,7 +440,7 @@=0A   		return -EINVAL;=0A=
 	  }=0A =0A-	  return 0;=0A+	return 0;=0A }=0A =0A /*=0A@@ -507,6 +499,7 @=
@=0A 		return NULL;=0A =0A 	memset(ax25, 0x00, sizeof(*ax25));=0A+	atomic_s=
et(&ax25->refcount, 1);=0A =0A 	skb_queue_head_init(&ax25->write_queue);=0A=
 	skb_queue_head_init(&ax25->frag_queue);=0A@@ -655,6 +648,7 @@=0A 		   (so=
ck->state !=3D SS_UNCONNECTED ||=0A 		    sk->sk_state =3D=3D TCP_LISTEN)) =
{=0A 			res =3D -EADDRNOTAVAIL;=0A+			dev_put(dev);=0A 			break;=0A 		}=0A =
=0A@@ -877,7 +871,7 @@=0A 		break;=0A 	default:=0A 		sk_free(sk);=0A-		ax25=
_free_cb(ax25);=0A+		ax25_cb_put(ax25);=0A 		return NULL;=0A 	}=0A =0A@@ -9=
37,6 +931,7 @@=0A 	if (sk =3D=3D NULL)=0A 		return 0;=0A =0A+	sock_hold(sk)=
;=0A 	lock_sock(sk);=0A 	ax25 =3D ax25_sk(sk);=0A =0A@@ -944,13 +939,15 @@=
=0A 		switch (ax25->state) {=0A 		case AX25_STATE_0:=0A 			ax25_disconnect(=
ax25, 0);=0A-			goto drop;=0A+			ax25_destroy_socket(ax25);=0A+			break;=0A=
 =0A 		case AX25_STATE_1:=0A 		case AX25_STATE_2:=0A 			ax25_send_control(a=
x25, AX25_DISC, AX25_POLLON, AX25_COMMAND);=0A 			ax25_disconnect(ax25, 0);=
=0A-			goto drop;=0A+			ax25_destroy_socket(ax25);=0A+			break;=0A =0A 		ca=
se AX25_STATE_3:=0A 		case AX25_STATE_4:=0A@@ -993,16 +990,14 @@=0A 		sk->s=
k_shutdown |=3D SEND_SHUTDOWN;=0A 		sk->sk_state_change(sk);=0A 		sock_set_=
flag(sk, SOCK_DEAD);=0A-		goto drop;=0A+		ax25_destroy_socket(ax25);=0A 	}=
=0A =0A 	sock->sk   =3D NULL;=0A 	sk->sk_socket =3D NULL;	/* Not used, but =
we should do this */=0A 	release_sock(sk);=0A-	return 0;=0A- drop:=0A-	rele=
ase_sock(sk);=0A-	ax25_destroy_socket(ax25);=0A+	sock_put(sk);=0A+=0A 	retu=
rn 0;=0A }=0A =0A@@ -1077,7 +1072,7 @@=0A 		ax25_fillin_cb(ax25, ax25_dev);=
=0A =0A done:=0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_add(ax25);=0A 	sk->=
sk_zapped =3D 0;=0A =0A out:=0A@@ -1093,7 +1088,7 @@=0A 	int addr_len, int =
flags)=0A {=0A 	struct sock *sk =3D sock->sk;=0A-	ax25_cb *ax25 =3D ax25_sk=
(sk);=0A+	ax25_cb *ax25 =3D ax25_sk(sk), *ax25t;=0A 	struct full_sockaddr_a=
x25 *fsa =3D (struct full_sockaddr_ax25 *)uaddr;=0A 	ax25_digi *digi =3D NU=
LL;=0A 	int ct =3D 0, err =3D 0;=0A@@ -1199,7 +1194,7 @@=0A 			goto out;=0A=
 =0A 		ax25_fillin_cb(ax25, ax25->ax25_dev);=0A-		ax25_insert_socket(ax25);=
=0A+		ax25_cb_add(ax25);=0A 	} else {=0A 		if (ax25->ax25_dev =3D=3D NULL) =
{=0A 			err =3D -EHOSTUNREACH;=0A@@ -1208,11 +1203,12 @@=0A 	}=0A =0A 	if (=
sk->sk_type =3D=3D SOCK_SEQPACKET &&=0A-	    ax25_find_cb(&ax25->source_add=
r, &fsa->fsa_ax25.sax25_call, digi,=0A-		    	 ax25->ax25_dev->dev)) {=0A+	=
    (ax25t=3Dax25_find_cb(&ax25->source_addr, &fsa->fsa_ax25.sax25_call, di=
gi,=0A+		    	 ax25->ax25_dev->dev))) {=0A 		if (digi !=3D NULL)=0A 			kfre=
e(digi);=0A 		err =3D -EADDRINUSE;		/* Already such a connection */=0A+		ax=
25_cb_put(ax25t);=0A 		goto out;=0A 	}=0A =0A@@ -1273,6 +1269,8 @@=0A 				l=
ock_sock(sk);=0A 				continue;=0A 			}=0A+			current->state =3D TASK_RUNNIN=
G;=0A+			remove_wait_queue(sk->sk_sleep, &wait);=0A 			return -ERESTARTSYS;=
=0A 		}=0A 		current->state =3D TASK_RUNNING;=0A@@ -1288,10 +1286,11 @@=0A =
=0A 	sock->state =3D SS_CONNECTED;=0A =0A+	err=3D0;=0A out:=0A 	release_soc=
k(sk);=0A =0A-	return 0;=0A+	return err;=0A }=0A =0A =0A@@ -1331,15 +1330,1=
8 @@=0A 		if (skb)=0A 			break;=0A =0A-		current->state =3D TASK_INTERRUPTI=
BLE;=0A 		release_sock(sk);=0A+		current->state =3D TASK_INTERRUPTIBLE;=0A =
		if (flags & O_NONBLOCK)=0A 			return -EWOULDBLOCK;=0A 		if (!signal_pendi=
ng(tsk)) {=0A 			schedule();=0A+			current->state =3D TASK_RUNNING;=0A 			l=
ock_sock(sk);=0A 			continue;=0A 		}=0A+		current->state =3D TASK_RUNNING;=
=0A+		remove_wait_queue(sk->sk_sleep, &wait);=0A 		return -ERESTARTSYS;=0A =
	}=0A 	current->state =3D TASK_RUNNING;=0A@@ -1519,7 +1521,7 @@=0A 	SOCK_DE=
BUG(sk, "AX.25: sendto: building packet.\n");=0A =0A 	/* Assume the worst c=
ase */=0A-	size =3D len + 3 + ax25_addr_size(dp) + AX25_BPQ_HEADER_LEN;=0A+=
	size =3D len + ax25->ax25_dev->dev->hard_header_len;=0A =0A 	skb =3D sock_=
alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTWAIT, &err);=0A 	if (skb =
=3D=3D NULL)=0A@@ -1780,7 +1782,7 @@=0A =0A 		/* old structure? */=0A 		if =
(cmd =3D=3D SIOCAX25GETINFOOLD) {=0A-			static int warned;=0A+			static int=
 warned =3D 0;=0A 			if (!warned) {=0A 				printk(KERN_INFO "%s uses old SI=
OCAX25GETINFO\n",=0A 					current->comm);=0A@@ -1845,6 +1847,7 @@=0A 	int l=
en =3D 0;=0A 	off_t pos =3D 0;=0A 	off_t begin =3D 0;=0A+	struct hlist_node=
 *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A =0A@@ -1853,7 +1856,7 @@=
=0A 	 * magic dev src_addr dest_addr,digi1,digi2,.. st vs vr va t1 t1 t2 t2=
 t3 t3 idle idle n2 n2 rtt window paclen Snd-Q Rcv-Q inode=0A 	 */=0A =0A-	=
for (ax25 =3D ax25_list; ax25 !=3D NULL; ax25 =3D ax25->next) {=0A+	ax25_fo=
r_each(ax25, node, &ax25_list) {=0A 		len +=3D sprintf(buffer+len, "%8.8lx =
%s %s%s ",=0A 				(long) ax25,=0A 				ax25->ax25_dev =3D=3D NULL? "???" : a=
x25->ax25_dev->dev->name,=0A@@ -1882,10 +1885,12 @@=0A 			ax25->paclen);=0A=
 =0A 		if (ax25->sk !=3D NULL) {=0A+			bh_lock_sock(ax25->sk);=0A 			len +=
=3D sprintf(buffer + len, " %d %d %ld\n",=0A 				atomic_read(&ax25->sk->sk_=
wmem_alloc),=0A 				atomic_read(&ax25->sk->sk_rmem_alloc),=0A 				ax25->sk-=
>sk_socket !=3D NULL ? SOCK_INODE(ax25->sk->sk_socket)->i_ino : 0L);=0A+			=
bh_unlock_sock(ax25->sk);=0A 		} else {=0A 			len +=3D sprintf(buffer + len=
, " * * *\n");=0A 		}=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_ds_in.c li=
nux-2.6.0-test1.rxq3/net/ax25/ax25_ds_in.c=0A--- linux-2.6.0-test3/net/ax25=
/ax25_ds_in.c	2003-08-09 06:38:45.000000000 +0200=0A+++ linux-2.6.0-test1.r=
xq3/net/ax25/ax25_ds_in.c	2003-07-24 20:56:38.000000000 +0200=0A@@ -65,6 +6=
5,7 @@=0A 		ax25->state   =3D AX25_STATE_3;=0A 		ax25->n2count =3D 0;=0A 		=
if (ax25->sk !=3D NULL) {=0A+			bh_lock_sock(ax25->sk);=0A 			ax25->sk->sk_=
state =3D TCP_ESTABLISHED;=0A 			/*=0A 			 * For WAIT_SABM connections we w=
ill produce an accept=0A@@ -72,6 +73,7 @@=0A 			 */=0A 			if (!sock_flag(ax=
25->sk, SOCK_DEAD))=0A 				ax25->sk->sk_state_change(ax25->sk);=0A+			bh_un=
lock_sock(ax25->sk);=0A 		}=0A 		ax25_dama_on(ax25);=0A =0Adiff -ru linux-2=
.6.0-test3/net/ax25/ax25_ds_subr.c linux-2.6.0-test1.rxq3/net/ax25/ax25_ds_=
subr.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ds_subr.c	2003-08-09 06:41:32.=
000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/ax25_ds_subr.c	2003-0=
7-24 20:56:38.000000000 +0200=0A@@ -40,6 +40,7 @@=0A void ax25_ds_enquiry_r=
esponse(ax25_cb *ax25)=0A {=0A 	ax25_cb *ax25o;=0A+	struct hlist_node *node=
;=0A =0A 	/* Please note that neither DK4EG=B4s nor DG2FEF=B4s=0A 	 * DAMA =
spec mention the following behaviour as seen=0A@@ -80,7 +81,7 @@=0A 	ax25_d=
s_set_timer(ax25->ax25_dev);=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for=
 (ax25o =3D ax25_list; ax25o !=3D NULL; ax25o =3D ax25o->next) {=0A+	ax25_f=
or_each(ax25o, node, &ax25_list) {=0A 		if (ax25o =3D=3D ax25)=0A 			contin=
ue;=0A =0A@@ -160,9 +161,10 @@=0A {=0A 	ax25_cb *ax25;=0A 	int res =3D 0;=
=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	fo=
r (ax25 =3D ax25_list; ax25 !=3D NULL ; ax25 =3D ax25->next)=0A+	ax25_for_e=
ach(ax25, node, &ax25_list)=0A 		if (ax25->ax25_dev =3D=3D ax25_dev && (ax2=
5->condition & AX25_COND_DAMA_MODE) && ax25->state > AX25_STATE_1) {=0A 			=
res =3D 1;=0A 			break;=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_ds_timer=
.c linux-2.6.0-test1.rxq3/net/ax25/ax25_ds_timer.c=0A--- linux-2.6.0-test3/=
net/ax25/ax25_ds_timer.c	2003-08-09 06:41:26.000000000 +0200=0A+++ linux-2.=
6.0-test1.rxq3/net/ax25/ax25_ds_timer.c	2003-07-24 20:56:37.000000000 +0200=
=0A@@ -74,6 +74,7 @@=0A {=0A 	ax25_dev *ax25_dev =3D (struct ax25_dev *) ar=
g;=0A 	ax25_cb *ax25;=0A+	struct hlist_node *node;=0A =0A 	if (ax25_dev =3D=
=3D NULL || !ax25_dev->dama.slave)=0A 		return;			/* Yikes! */=0A@@ -84,7 +=
85,7 @@=0A 	}=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25=3Dax25_l=
ist; ax25 !=3D NULL; ax25 =3D ax25->next) {=0A+	ax25_for_each(ax25, node, &=
ax25_list) {=0A 		if (ax25->ax25_dev !=3D ax25_dev || !(ax25->condition & A=
X25_COND_DAMA_MODE))=0A 			continue;=0A =0A@@ -98,15 +99,26 @@=0A =0A void =
ax25_ds_heartbeat_expiry(ax25_cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk=
;=0A+=0A+	if (sk)=0A+		bh_lock_sock(sk);=0A+=0A 	switch (ax25->state) {=0A =
=0A 	case AX25_STATE_0:=0A 		/* Magic here: If we listen() and a new link d=
ies before it=0A 		   is accepted() it isn't 'dead' so doesn't get removed.=
 */=0A-		if (!ax25->sk || sock_flag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax=
25->sk->sk_state =3D=3D TCP_LISTEN &&=0A-		     sock_flag(ax25->sk, SOCK_DE=
AD))) {=0A-			ax25_destroy_socket(ax25);=0A+		if (!sk || sock_flag(sk, SOCK=
_DESTROY) ||=0A+		    (sk->sk_state =3D=3D TCP_LISTEN &&=0A+		     sock_fla=
g(sk, SOCK_DEAD))) {=0A+			if (sk) {=0A+				sock_hold(sk);=0A+				ax25_dest=
roy_socket(ax25);=0A+				sock_put(sk);=0A+				bh_unlock_sock(sk);=0A+			} e=
lse=0A+				ax25_destroy_socket(ax25);=0A 			return;=0A 		}=0A 		break;=0A@@=
 -115,9 +127,9 @@=0A 		/*=0A 		 * Check the state of the receive buffer.=0A=
 		 */=0A-		if (ax25->sk !=3D NULL) {=0A-			if (atomic_read(&ax25->sk->sk_r=
mem_alloc) <=0A-			    (ax25->sk->sk_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) =
{=0A+			if (atomic_read(&sk->sk_rmem_alloc) <=0A+			    (sk->sk_rcvbuf / 2)=
 &&=0A 			    (ax25->condition & AX25_COND_OWN_RX_BUSY)) {=0A 				ax25->con=
dition &=3D ~AX25_COND_OWN_RX_BUSY;=0A 				ax25->condition &=3D ~AX25_COND_=
ACK_PENDING;=0A@@ -127,6 +139,9 @@=0A 		break;=0A 	}=0A =0A+	if (sk)=0A+		b=
h_unlock_sock(sk);=0A+=0A 	ax25_start_heartbeat(ax25);=0A }=0A =0A@@ -157,6=
 +172,7 @@=0A 	ax25_stop_t3timer(ax25);=0A =0A 	if (ax25->sk !=3D NULL) {=
=0A+		bh_lock_sock(ax25->sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A=
 		ax25->sk->sk_err       =3D 0;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTD=
OWN;=0A@@ -164,6 +180,7 @@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 		=
	sock_set_flag(ax25->sk, SOCK_DEAD);=0A 		}=0A+		bh_lock_sock(ax25->sk);=0A=
 	}=0A }=0A =0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_iface.c linux-2.6.0=
-test1.rxq3/net/ax25/ax25_iface.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ifa=
ce.c	2003-08-09 06:42:13.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/a=
x25/ax25_iface.c	2003-07-24 20:56:37.000000000 +0200=0A@@ -33,20 +33,20 @@=
=0A 	struct protocol_struct *next;=0A 	unsigned int pid;=0A 	int (*func)(st=
ruct sk_buff *, ax25_cb *);=0A-} *protocol_list;=0A+} *protocol_list =3D NU=
LL;=0A static rwlock_t protocol_list_lock =3D RW_LOCK_UNLOCKED;=0A =0A stat=
ic struct linkfail_struct {=0A 	struct linkfail_struct *next;=0A 	void (*fu=
nc)(ax25_cb *, int);=0A-} *linkfail_list;=0A+} *linkfail_list =3D NULL;=0A =
static spinlock_t linkfail_lock =3D SPIN_LOCK_UNLOCKED;=0A =0A static struc=
t listen_struct {=0A 	struct listen_struct *next;=0A 	ax25_address  callsig=
n;=0A 	struct net_device *dev;=0A-} *listen_list;=0A+} *listen_list =3D NUL=
L;=0A static spinlock_t listen_lock =3D SPIN_LOCK_UNLOCKED;=0A =0A int ax25=
_protocol_register(unsigned int pid,=0A@@ -129,8 +129,10 @@=0A =0A 	spin_lo=
ck_bh(&linkfail_lock);=0A 	linkfail =3D linkfail_list;=0A-	if (linkfail =3D=
=3D NULL)=0A+	if (linkfail =3D=3D NULL) {=0A+		spin_unlock_bh(&linkfail_loc=
k);=0A 		return;=0A+	}=0A =0A 	if (linkfail->func =3D=3D func) {=0A 		linkf=
ail_list =3D linkfail->next;=0A@@ -180,8 +182,10 @@=0A =0A 	spin_lock_bh(&l=
isten_lock);=0A 	listen =3D listen_list;=0A-	if (listen =3D=3D NULL)=0A+	if=
 (listen =3D=3D NULL) {=0A+		spin_unlock_bh(&listen_lock);=0A 		return;=0A+=
	}=0A =0A 	if (ax25cmp(&listen->callsign, callsign) =3D=3D 0 && listen->dev=
 =3D=3D dev) {=0A 		listen_list =3D listen->next;=0A@@ -226,8 +230,10 @@=0A=
 =0A 	spin_lock_bh(&listen_lock);=0A 	for (listen =3D listen_list; listen !=
=3D NULL; listen =3D listen->next)=0A-		if (ax25cmp(&listen->callsign, call=
sign) =3D=3D 0 && (listen->dev =3D=3D dev || listen->dev =3D=3D NULL))=0A+	=
	if (ax25cmp(&listen->callsign, callsign) =3D=3D 0 && (listen->dev =3D=3D d=
ev || listen->dev =3D=3D NULL)) {=0A+			spin_unlock_bh(&listen_lock);=0A 		=
	return 1;=0A+	}=0A 	spin_unlock_bh(&listen_lock);=0A =0A 	return 0;=0Adiff=
 -ru linux-2.6.0-test3/net/ax25/ax25_in.c linux-2.6.0-test1.rxq3/net/ax25/a=
x25_in.c=0A--- linux-2.6.0-test3/net/ax25/ax25_in.c	2003-08-09 06:32:47.000=
000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/ax25_in.c	2003-07-24 20:=
56:36.000000000 +0200=0A@@ -147,6 +147,7 @@=0A 	}=0A =0A 	if (ax25->sk !=3D=
 NULL && ax25->ax25_dev->values[AX25_VALUES_CONMODE] =3D=3D 2) {=0A+		bh_lo=
ck_sock(ax25->sk);=0A 		if ((!ax25->pidincl && ax25->sk->sk_protocol =3D=3D=
 pid) ||=0A 		    ax25->pidincl) {=0A 			if (sock_queue_rcv_skb(ax25->sk, s=
kb) =3D=3D 0)=0A@@ -154,6 +155,7 @@=0A 			else=0A 				ax25->condition |=3D =
AX25_COND_OWN_RX_BUSY;=0A 		}=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A =0A 	=
return queued;=0A@@ -329,6 +331,7 @@=0A 		if (ax25_process_rx_frame(ax25, s=
kb, type, dama) =3D=3D 0)=0A 			kfree_skb(skb);=0A =0A+		ax25_cb_put(ax25);=
=0A 		return 0;=0A 	}=0A =0A@@ -357,11 +360,14 @@=0A 		sk =3D ax25_find_lis=
tener(next_digi, 1, dev, SOCK_SEQPACKET);=0A =0A 	if (sk !=3D NULL) {=0A+		=
bh_lock_sock(sk);=0A 		if (sk->sk_ack_backlog =3D=3D sk->sk_max_ack_backlog=
 ||=0A 		    (make =3D ax25_make_new(sk, ax25_dev)) =3D=3D NULL) {=0A 			if=
 (mine)=0A 				ax25_return_dm(dev, &src, &dest, &dp);=0A 			kfree_skb(skb);=
=0A+			bh_unlock_sock(sk);=0A+			sock_put(sk);=0A =0A 			return 0;=0A 		}=
=0A@@ -374,6 +380,8 @@=0A 		make->sk_pair  =3D sk;=0A =0A 		sk->sk_ack_back=
log++;=0A+		bh_unlock_sock(sk);=0A+		sock_put(sk);=0A 	} else {=0A 		if (!m=
ine) {=0A 			kfree_skb(skb);=0A@@ -429,7 +437,7 @@=0A =0A 	ax25->state =3D =
AX25_STATE_3;=0A =0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_add(ax25);=0A =
=0A 	ax25_start_heartbeat(ax25);=0A 	ax25_start_t3timer(ax25);=0Adiff -ru l=
inux-2.6.0-test3/net/ax25/ax25_ip.c linux-2.6.0-test1.rxq3/net/ax25/ax25_ip=
.c=0A--- linux-2.6.0-test3/net/ax25/ax25_ip.c	2003-08-09 06:34:43.000000000=
 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/ax25_ip.c	2003-07-24 20:56:37.=
000000000 +0200=0A@@ -107,6 +107,7 @@=0A 	ax25_address *src, *dst;=0A 	ax25=
_dev *ax25_dev;=0A 	ax25_route _route, *route =3D &_route;=0A+	ax25_cb *ax2=
5;=0A =0A 	dst =3D (ax25_address *)(bp + 1);=0A 	src =3D (ax25_address *)(b=
p + 8);=0A@@ -167,9 +168,14 @@=0A 			skb_pull(ourskb, AX25_HEADER_LEN - 1);=
	/* Keep PID */=0A 			ourskb->nh.raw =3D ourskb->data;=0A =0A-			ax25_send_=
frame(ourskb, ax25_dev->values[AX25_VALUES_PACLEN], &src_c,=0A-&dst_c, rout=
e->digipeat, dev);=0A-=0A+			ax25=3Dax25_send_frame(=0A+			    ourskb, =0A+=
			    ax25_dev->values[AX25_VALUES_PACLEN], =0A+			    &src_c,=0A+			    &=
dst_c, route->digipeat, dev);=0A+			if (ax25) {=0A+				ax25_cb_put(ax25);=
=0A+			}=0A 			goto put;=0A 		}=0A 	}=0Adiff -ru linux-2.6.0-test3/net/ax25=
/ax25_out.c linux-2.6.0-test1.rxq3/net/ax25/ax25_out.c=0A--- linux-2.6.0-te=
st3/net/ax25/ax25_out.c	2003-08-09 06:40:10.000000000 +0200=0A+++ linux-2.6=
.0-test1.rxq3/net/ax25/ax25_out.c	2003-07-24 20:56:38.000000000 +0200=0A@@ =
-71,7 +71,7 @@=0A =0A 	if (digi !=3D NULL) {=0A 		if ((ax25->digipeat =3D k=
malloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=3D NULL) {=0A-			ax25_free_cb(ax=
25);=0A+			ax25_cb_put(ax25);=0A 			return NULL;=0A 		}=0A 		memcpy(ax25->d=
igipeat, digi, sizeof(ax25_digi));=0A@@ -93,7 +93,7 @@=0A #endif=0A 	}=0A =
=0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_add(ax25);=0A =0A 	ax25->state =
=3D AX25_STATE_1;=0A =0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_route.c li=
nux-2.6.0-test1.rxq3/net/ax25/ax25_route.c=0A--- linux-2.6.0-test3/net/ax25=
/ax25_route.c	2003-08-09 06:38:41.000000000 +0200=0A+++ linux-2.6.0-test1.r=
xq3/net/ax25/ax25_route.c	2003-07-24 20:56:38.000000000 +0200=0A@@ -162,6 +=
162,7 @@=0A 		if (ax25_rt->digipeat !=3D NULL)=0A 			kfree(ax25_rt->digipea=
t);=0A 		kfree(ax25_rt);=0A+		return;=0A 	}=0A =0A 	/*=0A@@ -434,8 +435,11 =
@@=0A 		ax25_adjust_path(addr, ax25->digipeat);=0A 	}=0A =0A-	if (ax25->sk =
!=3D NULL)=0A+	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock(ax25->sk);=0A 		=
ax25->sk->sk_zapped =3D 0;=0A+		bh_unlock_sock(ax25->sk);=0A+	}=0A =0A put:=
=0A 	ax25_put_route(ax25_rt);=0Adiff -ru linux-2.6.0-test3/net/ax25/ax25_st=
d_in.c linux-2.6.0-test1.rxq3/net/ax25/ax25_std_in.c=0A--- linux-2.6.0-test=
3/net/ax25/ax25_std_in.c	2003-08-09 06:39:26.000000000 +0200=0A+++ linux-2.=
6.0-test1.rxq3/net/ax25/ax25_std_in.c	2003-07-24 20:56:37.000000000 +0200=
=0A@@ -73,10 +73,12 @@=0A 			ax25->state   =3D AX25_STATE_3;=0A 			ax25->n2=
count =3D 0;=0A 			if (ax25->sk !=3D NULL) {=0A+				bh_lock_sock(ax25->sk);=
=0A 				ax25->sk->sk_state =3D TCP_ESTABLISHED;=0A 				/* For WAIT_SABM con=
nections we will produce an accept ready socket here */=0A 				if (!sock_fl=
ag(ax25->sk, SOCK_DEAD))=0A 					ax25->sk->sk_state_change(ax25->sk);=0A+		=
		bh_unlock_sock(ax25->sk);=0A 			}=0A 		}=0A 		break;=0Adiff -ru linux-2.6=
.0-test3/net/ax25/ax25_std_timer.c linux-2.6.0-test1.rxq3/net/ax25/ax25_std=
_timer.c=0A--- linux-2.6.0-test3/net/ax25/ax25_std_timer.c	2003-08-09 06:34=
:03.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/ax25_std_timer.c	=
2003-07-24 20:56:37.000000000 +0200=0A@@ -33,14 +33,25 @@=0A =0A void ax25_=
std_heartbeat_expiry(ax25_cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk;=0A=
+	=0A+	if (sk)=0A+		bh_lock_sock(sk);=0A+=0A 	switch (ax25->state) {=0A 	ca=
se AX25_STATE_0:=0A 		/* Magic here: If we listen() and a new link dies bef=
ore it=0A 		   is accepted() it isn't 'dead' so doesn't get removed. */=0A-=
		if (!ax25->sk || sock_flag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax25->sk-=
>sk_state =3D=3D TCP_LISTEN &&=0A-		     sock_flag(ax25->sk, SOCK_DEAD))) {=
=0A-			ax25_destroy_socket(ax25);=0A+		if (!sk || sock_flag(sk, SOCK_DESTRO=
Y) ||=0A+		    (sk->sk_state =3D=3D TCP_LISTEN &&=0A+		     sock_flag(sk, S=
OCK_DEAD))) {=0A+			if (sk) {=0A+				sock_hold(sk);=0A+				ax25_destroy_soc=
ket(ax25);=0A+				bh_unlock_sock(sk);=0A+				sock_put(sk);=0A+			} else=0A+=
				ax25_destroy_socket(ax25);=0A 			return;=0A 		}=0A 		break;=0A@@ -50,9 =
+61,9 @@=0A 		/*=0A 		 * Check the state of the receive buffer.=0A 		 */=0A=
-		if (ax25->sk !=3D NULL) {=0A-			if (atomic_read(&ax25->sk->sk_rmem_alloc=
) <=0A-			    (ax25->sk->sk_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) {=0A+			i=
f (atomic_read(&sk->sk_rmem_alloc) <=0A+			    (sk->sk_rcvbuf / 2) &&=0A 		=
	    (ax25->condition & AX25_COND_OWN_RX_BUSY)) {=0A 				ax25->condition &=
=3D ~AX25_COND_OWN_RX_BUSY;=0A 				ax25->condition &=3D ~AX25_COND_ACK_PEND=
ING;=0A@@ -62,6 +73,9 @@=0A 		}=0A 	}=0A =0A+	if (sk)=0A+		bh_unlock_sock(s=
k);=0A+=0A 	ax25_start_heartbeat(ax25);=0A }=0A =0A@@ -94,6 +108,7 @@=0A 	a=
x25_stop_t3timer(ax25);=0A =0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock=
(ax25->sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_er=
r       =3D 0;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -101,6 +=
116,7 @@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 			sock_set_flag(ax2=
5->sk, SOCK_DEAD);=0A 		}=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A }=0A =0Ad=
iff -ru linux-2.6.0-test3/net/ax25/ax25_subr.c linux-2.6.0-test1.rxq3/net/a=
x25/ax25_subr.c=0A--- linux-2.6.0-test3/net/ax25/ax25_subr.c	2003-08-09 06:=
41:35.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/ax25_subr.c	200=
3-07-24 20:56:37.000000000 +0200=0A@@ -158,10 +158,10 @@=0A 	struct sk_buff=
 *skb;=0A 	unsigned char  *dptr;=0A =0A-	if ((skb =3D alloc_skb(AX25_BPQ_HE=
ADER_LEN + ax25_addr_size(ax25->digipeat) + 2, GFP_ATOMIC)) =3D=3D NULL)=0A=
+	if ((skb =3D alloc_skb(ax25->ax25_dev->dev->hard_header_len + 2, GFP_ATOM=
IC)) =3D=3D NULL)=0A 		return;=0A =0A-	skb_reserve(skb, AX25_BPQ_HEADER_LEN=
 + ax25_addr_size(ax25->digipeat));=0A+	skb_reserve(skb, ax25->ax25_dev->de=
v->hard_header_len);=0A =0A 	skb->nh.raw =3D skb->data;=0A =0A@@ -202,10 +2=
02,10 @@=0A 	if (dev =3D=3D NULL)=0A 		return;=0A =0A-	if ((skb =3D alloc_s=
kb(AX25_BPQ_HEADER_LEN + ax25_addr_size(digi) + 1, GFP_ATOMIC)) =3D=3D NULL=
)=0A+	if ((skb =3D alloc_skb(dev->hard_header_len + 1, GFP_ATOMIC)) =3D=3D =
NULL)=0A 		return;	/* Next SABM will get DM'd */=0A =0A-	skb_reserve(skb, A=
X25_BPQ_HEADER_LEN + ax25_addr_size(digi));=0A+	skb_reserve(skb, dev->hard_=
header_len);=0A 	skb->nh.raw =3D skb->data;=0A =0A 	ax25_digi_invert(digi, =
&retdigi);=0A@@ -282,6 +282,7 @@=0A 	ax25_link_failed(ax25, reason);=0A =0A=
 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock(ax25->sk);=0A 		ax25->sk->sk_=
state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_err       =3D reason;=0A 		ax25-=
>sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -289,5 +290,6 @@=0A 			ax25->sk->=
sk_state_change(ax25->sk);=0A 			sock_set_flag(ax25->sk, SOCK_DEAD);=0A 		}=
=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A }=0Adiff -ru linux-2.6.0-test3/net=
/ax25/ax25_timer.c linux-2.6.0-test1.rxq3/net/ax25/ax25_timer.c=0A--- linux=
-2.6.0-test3/net/ax25/ax25_timer.c	2003-08-09 06:38:16.000000000 +0200=0A++=
+ linux-2.6.0-test1.rxq3/net/ax25/ax25_timer.c	2003-07-24 20:56:38.00000000=
0 +0200=0A@@ -141,13 +141,10 @@=0A {=0A 	int proto =3D AX25_PROTO_STD_SIMPL=
EX;=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->s=
k;=0A =0A 	if (ax25->ax25_dev)=0A 		proto =3D ax25->ax25_dev->values[AX25_V=
ALUES_PROTOCOL];=0A =0A-	bh_lock_sock(sk);=0A-=0A 	switch (proto) {=0A 	cas=
e AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -163,15 +160=
,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A stat=
ic void ax25_t1timer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25 =3D=
 (ax25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_sock(s=
k);=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	case AX=
25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -185,15 +179,12 =
@@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A static v=
oid ax25_t2timer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25 =3D (ax=
25_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_sock(sk);=
=0A 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	case AX25_=
PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -207,15 +198,12 @@=
=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A static voi=
d ax25_t3timer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25 =3D (ax25=
_cb *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_sock(sk);=0A=
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	case AX25_PRO=
TO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -231,15 +219,12 @@=0A =
		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0A =0A static void ax=
25_idletimer_expiry(unsigned long param)=0A {=0A 	ax25_cb *ax25 =3D (ax25_c=
b *)param;=0A-	struct sock *sk =3D ax25->sk;=0A =0A-	bh_lock_sock(sk);=0A 	=
switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {=0A 	case AX25_PROTO=
_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DUPLEX:=0A@@ -255,5 +240,4 @@=0A 		br=
eak;=0A #endif=0A 	}=0A-	bh_unlock_sock(sk);=0A }=0Adiff -ru linux-2.6.0-te=
st3/net/ax25/sysctl_net_ax25.c linux-2.6.0-test1.rxq3/net/ax25/sysctl_net_a=
x25.c=0A--- linux-2.6.0-test3/net/ax25/sysctl_net_ax25.c	2003-08-09 06:41:2=
1.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net/ax25/sysctl_net_ax25.c	2=
003-07-24 20:56:37.000000000 +0200=0A@@ -12,20 +12,20 @@=0A #include <linux=
/spinlock.h>=0A #include <net/ax25.h>=0A =0A-static int min_ipdefmode[1],  =
  	max_ipdefmode[] =3D {1};=0A-static int min_axdefmode[1],            max_=
axdefmode[] =3D {1};=0A-static int min_backoff[1],		max_backoff[] =3D {2};=
=0A-static int min_conmode[1],		max_conmode[] =3D {2};=0A+static int min_ip=
defmode[] =3D {0},	max_ipdefmode[] =3D {1};=0A+static int min_axdefmode[] =
=3D {0},	max_axdefmode[] =3D {1};=0A+static int min_backoff[] =3D {0},		max=
_backoff[] =3D {2};=0A+static int min_conmode[] =3D {0},		max_conmode[] =3D=
 {2};=0A static int min_window[] =3D {1},		max_window[] =3D {7};=0A static =
int min_ewindow[] =3D {1},		max_ewindow[] =3D {63};=0A static int min_t1[] =
=3D {1},		max_t1[] =3D {30 * HZ};=0A static int min_t2[] =3D {1},		max_t2[]=
 =3D {20 * HZ};=0A-static int min_t3[1],   		max_t3[] =3D {3600 * HZ};=0A-s=
tatic int min_idle[1],  		max_idle[] =3D {65535 * HZ};=0A+static int min_t3=
[] =3D {0},		max_t3[] =3D {3600 * HZ};=0A+static int min_idle[] =3D {0},		m=
ax_idle[] =3D {65535 * HZ};=0A static int min_n2[] =3D {1},		max_n2[] =3D {=
31};=0A static int min_paclen[] =3D {1},		max_paclen[] =3D {512};=0A-static=
 int min_proto[1],		max_proto[] =3D {3};=0A-static int min_ds_timeout[1],  =
 	max_ds_timeout[] =3D {65535 * HZ};=0A+static int min_proto[] =3D {0},		ma=
x_proto[] =3D {3};=0A+static int min_ds_timeout[] =3D {0},	max_ds_timeout[]=
 =3D {65535 * HZ};=0A =0A static struct ctl_table_header *ax25_table_header=
;=0A =0A@@ -204,8 +204,10 @@=0A 	for (ax25_table_size =3D sizeof(ctl_table)=
, ax25_dev =3D ax25_dev_list; ax25_dev !=3D NULL; ax25_dev =3D ax25_dev->ne=
xt)=0A 		ax25_table_size +=3D sizeof(ctl_table);=0A =0A-	if ((ax25_table =
=3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL)=0A+	if ((ax25_table =
=3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL) {=0A+		spin_unlock_b=
h(&ax25_dev_lock);=0A 		return;=0A+	}=0A =0A 	memset(ax25_table, 0x00, ax25=
_table_size);=0A =0Adiff -ru linux-2.6.0-test3/net/netrom/af_netrom.c linux=
-2.6.0-test1.rxq3/net/netrom/af_netrom.c=0A--- linux-2.6.0-test3/net/netrom=
/af_netrom.c	2003-08-09 06:36:46.000000000 +0200=0A+++ linux-2.6.0-test1.rx=
q3/net/netrom/af_netrom.c	2003-07-24 20:56:55.000000000 +0200=0A@@ -147,8 +=
147,10 @@=0A 	spin_lock_bh(&nr_list_lock);=0A 	sk_for_each(s, node, &nr_lis=
t)=0A 		if (!ax25cmp(&nr_sk(s)->source_addr, addr) &&=0A-		    s->sk_state =
=3D=3D TCP_LISTEN)=0A+		    s->sk_state =3D=3D TCP_LISTEN) {=0A+		    	bh_l=
ock_sock(s);=0A 			goto found;=0A+		}=0A 	s =3D NULL;=0A found:=0A 	spin_un=
lock_bh(&nr_list_lock);=0A@@ -167,8 +169,10 @@=0A 	sk_for_each(s, node, &nr=
_list) {=0A 		nr_cb *nr =3D nr_sk(s);=0A 		=0A-		if (nr->my_index =3D=3D in=
dex && nr->my_id =3D=3D id)=0A+		if (nr->my_index =3D=3D index && nr->my_id=
 =3D=3D id) {=0A+			bh_lock_sock(s);=0A 			goto found;=0A+		}=0A 	}=0A 	s =
=3D NULL;=0A found:=0A@@ -190,8 +194,10 @@=0A 		nr_cb *nr =3D nr_sk(s);=0A =
		=0A 		if (nr->your_index =3D=3D index && nr->your_id =3D=3D id &&=0A-		  =
  !ax25cmp(&nr->dest_addr, dest))=0A+		    !ax25cmp(&nr->dest_addr, dest)) =
{=0A+		    	bh_lock_sock(s);=0A 			goto found;=0A+		}=0A 	}=0A 	s =3D NULL;=
=0A found:=0A@@ -206,14 +212,17 @@=0A {=0A 	unsigned short id =3D circuit;=
=0A 	unsigned char i, j;=0A+	struct sock *sk;=0A =0A 	for (;;) {=0A 		i =3D=
 id / 256;=0A 		j =3D id % 256;=0A =0A-		if (i !=3D 0 && j !=3D 0)=0A-			if=
 (nr_find_socket(i, j) =3D=3D NULL)=0A+		if (i !=3D 0 && j !=3D 0) {=0A+			=
if ((sk=3Dnr_find_socket(i, j)) =3D=3D NULL)=0A 				break;=0A+			bh_unlock_=
sock(sk);=0A+		}=0A =0A 		id++;=0A 	}=0A@@ -231,7 +240,12 @@=0A  */=0A stat=
ic void nr_destroy_timer(unsigned long data)=0A {=0A-	nr_destroy_socket((st=
ruct sock *)data);=0A+	struct sock *sk=3D(struct sock *)data;=0A+	bh_lock_s=
ock(sk);=0A+	sock_hold(sk);=0A+	nr_destroy_socket(sk);=0A+	bh_unlock_sock(s=
k);=0A+	sock_put(sk);=0A }=0A =0A /*=0A@@ -264,17 +278,20 @@=0A =0A 		kfree=
_skb(skb);=0A 	}=0A+	while ((skb =3D skb_dequeue(&sk->sk_write_queue)) !=3D=
 NULL) {=0A+		kfree_skb(skb);=0A+	}=0A =0A 	if (atomic_read(&sk->sk_wmem_al=
loc) ||=0A 	    atomic_read(&sk->sk_rmem_alloc)) {=0A 		/* Defer: outstandi=
ng buffers */=0A 		init_timer(&sk->sk_timer);=0A-		sk->sk_timer.expires  =
=3D jiffies + 10 * HZ;=0A+		sk->sk_timer.expires  =3D jiffies + 2 * HZ;=0A =
		sk->sk_timer.function =3D nr_destroy_timer;=0A 		sk->sk_timer.data     =
=3D (unsigned long)sk;=0A 		add_timer(&sk->sk_timer);=0A 	} else=0A-		sk_fr=
ee(sk);=0A+		sock_put(sk);=0A }=0A =0A /*=0A@@ -388,12 +405,15 @@=0A {=0A 	=
struct sock *sk =3D sock->sk;=0A =0A+	lock_sock(sk);=0A 	if (sk->sk_state !=
=3D TCP_LISTEN) {=0A 		memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);=0A =
		sk->sk_max_ack_backlog =3D backlog;=0A 		sk->sk_state           =3D TCP_L=
ISTEN;=0A+		release_sock(sk);=0A 		return 0;=0A 	}=0A+	release_sock(sk);=0A=
 =0A 	return -EOPNOTSUPP;=0A }=0A@@ -495,6 +515,7 @@=0A =0A 	if (sk =3D=3D =
NULL) return 0;=0A =0A+	lock_sock(sk);=0A 	nr =3D nr_sk(sk);=0A =0A 	switch=
 (nr->state) {=0A@@ -528,6 +549,7 @@=0A 	}=0A =0A 	sock->sk   =3D NULL;	=0A=
+	release_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -540,21 +562,26 @@=0A 	stru=
ct net_device *dev;=0A 	ax25_address *user, *source;=0A =0A-	if (!sk->sk_za=
pped)=0A+	lock_sock(sk);=0A+	if (!sk->sk_zapped) {=0A+		release_sock(sk);=
=0A 		return -EINVAL;=0A-=0A-	if (addr_len < sizeof(struct sockaddr_ax25) |=
| addr_len > sizeof(struct=0A-full_sockaddr_ax25))=0A+	}=0A+	if (addr_len <=
 sizeof(struct sockaddr_ax25) || addr_len > sizeof(struct full_sockaddr_ax2=
5)) {=0A+		release_sock(sk);=0A 		return -EINVAL;=0A-=0A-	if (addr_len < (a=
ddr->fsa_ax25.sax25_ndigis * sizeof(ax25_address) + sizeof(struct sockaddr_=
ax25)))=0A+	}=0A+	if (addr_len < (addr->fsa_ax25.sax25_ndigis * sizeof(ax25=
_address) + sizeof(struct sockaddr_ax25))) {=0A+		release_sock(sk);=0A 		re=
turn -EINVAL;=0A-=0A-	if (addr->fsa_ax25.sax25_family !=3D AF_NETROM)=0A+	}=
=0A+	if (addr->fsa_ax25.sax25_family !=3D AF_NETROM) {=0A+		release_sock(sk=
);=0A 		return -EINVAL;=0A-=0A+	}=0A 	if ((dev =3D nr_dev_get(&addr->fsa_ax=
25.sax25_call)) =3D=3D NULL) {=0A 		SOCK_DEBUG(sk, "NET/ROM: bind failed: i=
nvalid node callsign\n");=0A+		release_sock(sk);=0A 		return -EADDRNOTAVAIL=
;=0A 	}=0A =0A@@ -562,16 +589,22 @@=0A 	 * Only the super user can set an a=
rbitrary user callsign.=0A 	 */=0A 	if (addr->fsa_ax25.sax25_ndigis =3D=3D =
1) {=0A-		if (!capable(CAP_NET_BIND_SERVICE))=0A+		if (!capable(CAP_NET_BIN=
D_SERVICE)) {=0A+			dev_put(dev);=0A+			release_sock(sk);=0A 			return -EAC=
CES;=0A+		}=0A 		nr->user_addr   =3D addr->fsa_digipeater[0];=0A 		nr->sour=
ce_addr =3D addr->fsa_ax25.sax25_call;=0A 	} else {=0A 		source =3D &addr->=
fsa_ax25.sax25_call;=0A =0A 		if ((user =3D ax25_findbyuid(current->euid)) =
=3D=3D NULL) {=0A-			if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE))=
=0A+			if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE)) {=0A+				rele=
ase_sock(sk);=0A+				dev_put(dev);=0A 				return -EPERM;=0A+			}=0A 			user=
 =3D source;=0A 		}=0A =0A@@ -583,6 +616,8 @@=0A 	nr_insert_socket(sk);=0A =
=0A 	sk->sk_zapped =3D 0;=0A+	dev_put(dev);=0A+	release_sock(sk);=0A 	SOCK_=
DEBUG(sk, "NET/ROM: socket is bound\n");=0A 	return 0;=0A }=0A@@ -596,39 +6=
31,50 @@=0A 	ax25_address *user, *source =3D NULL;=0A 	struct net_device *d=
ev;=0A =0A+	lock_sock(sk);=0A 	if (sk->sk_state =3D=3D TCP_ESTABLISHED && s=
ock->state =3D=3D SS_CONNECTING) {=0A 		sock->state =3D SS_CONNECTED;=0A+		=
release_sock(sk);=0A 		return 0;	/* Connect completed during a ERESTARTSYS =
event */=0A 	}=0A =0A 	if (sk->sk_state =3D=3D TCP_CLOSE && sock->state =3D=
=3D SS_CONNECTING) {=0A 		sock->state =3D SS_UNCONNECTED;=0A+		release_sock=
(sk);=0A 		return -ECONNREFUSED;=0A 	}=0A =0A-	if (sk->sk_state =3D=3D TCP_=
ESTABLISHED)=0A+	if (sk->sk_state =3D=3D TCP_ESTABLISHED) {=0A+		release_so=
ck(sk);=0A 		return -EISCONN;	/* No reconnect on a seqpacket socket */=0A+	=
}=0A =0A 	sk->sk_state   =3D TCP_CLOSE;	=0A 	sock->state =3D SS_UNCONNECTED=
;=0A =0A-	if (addr_len !=3D sizeof(struct sockaddr_ax25) && addr_len !=3D s=
izeof(struct full_sockaddr_ax25))=0A+	if (addr_len !=3D sizeof(struct socka=
ddr_ax25) && addr_len !=3D sizeof(struct full_sockaddr_ax25)) {=0A+		releas=
e_sock(sk);=0A 		return -EINVAL;=0A-=0A-	if (addr->sax25_family !=3D AF_NET=
ROM)=0A+	}=0A+	if (addr->sax25_family !=3D AF_NETROM) {=0A+		release_sock(s=
k);=0A 		return -EINVAL;=0A-=0A+	}=0A 	if (sk->sk_zapped) {	/* Must bind fi=
rst - autobinding in this may or may not work */=0A 		sk->sk_zapped =3D 0;=
=0A =0A-		if ((dev =3D nr_dev_first()) =3D=3D NULL)=0A+		if ((dev =3D nr_de=
v_first()) =3D=3D NULL) {=0A+			release_sock(sk);=0A 			return -ENETUNREACH=
;=0A-=0A+		}=0A 		source =3D (ax25_address *)dev->dev_addr;=0A =0A 		if ((u=
ser =3D ax25_findbyuid(current->euid)) =3D=3D NULL) {=0A-			if (ax25_uid_po=
licy && !capable(CAP_NET_ADMIN))=0A+			if (ax25_uid_policy && !capable(CAP_=
NET_ADMIN)) {=0A+				dev_put(dev);=0A+				release_sock(sk);=0A 				return -=
EPERM;=0A+			}=0A 			user =3D source;=0A 		}=0A =0A@@ -636,12 +682,15 @@=0A=
 		nr->source_addr =3D *source;=0A 		nr->device      =3D dev;=0A =0A+		dev_=
put(dev);=0A 		nr_insert_socket(sk);		/* Finish the bind */=0A 	}=0A =0A 	n=
r->dest_addr =3D addr->sax25_call;=0A =0A+	release_sock(sk);=0A 	circuit =
=3D nr_find_next_circuit();=0A+	lock_sock(sk);=0A =0A 	nr->my_index =3D cir=
cuit / 256;=0A 	nr->my_id    =3D circuit % 256;=0A@@ -659,8 +708,10 @@=0A 	=
nr_start_heartbeat(sk);=0A =0A 	/* Now the loop */=0A-	if (sk->sk_state !=
=3D TCP_ESTABLISHED && (flags & O_NONBLOCK))=0A+	if (sk->sk_state !=3D TCP_=
ESTABLISHED && (flags & O_NONBLOCK)) {=0A+		release_sock(sk);=0A 		return -=
EINPROGRESS;=0A+	}=0A 		=0A 	/*=0A 	 * A Connect Ack with Choke or timeout =
or failed routing will go to=0A@@ -675,8 +726,10 @@=0A 			set_current_state=
(TASK_INTERRUPTIBLE);=0A 			if (sk->sk_state !=3D TCP_SYN_SENT)=0A 				brea=
k;=0A+			release_sock(sk);=0A 			if (!signal_pending(tsk)) {=0A 				schedul=
e();=0A+				lock_sock(sk);=0A 				continue;=0A 			}=0A 			return -ERESTARTS=
YS;=0A@@ -687,10 +740,12 @@=0A =0A 	if (sk->sk_state !=3D TCP_ESTABLISHED) =
{=0A 		sock->state =3D SS_UNCONNECTED;=0A+		release_sock(sk);=0A 		return s=
ock_error(sk);	/* Always set at this point */=0A 	}=0A =0A 	sock->state =3D=
 SS_CONNECTED;=0A+	release_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -753,6 +80=
8,7 @@=0A 	newsock->sk =3D newsk;=0A =0A out:=0A+	release_sock(sk);=0A 	ret=
urn err;=0A }=0A =0A@@ -763,9 +819,12 @@=0A 	struct sock *sk =3D sock->sk;=
=0A 	nr_cb *nr =3D nr_sk(sk);=0A =0A+	lock_sock(sk);=0A 	if (peer !=3D 0) {=
=0A-		if (sk->sk_state !=3D TCP_ESTABLISHED)=0A+		if (sk->sk_state !=3D TCP=
_ESTABLISHED) {=0A+			release_sock(sk);=0A 			return -ENOTCONN;=0A+		}=0A 	=
	sax->fsa_ax25.sax25_family =3D AF_NETROM;=0A 		sax->fsa_ax25.sax25_ndigis =
=3D 1;=0A 		sax->fsa_ax25.sax25_call   =3D nr->user_addr;=0A@@ -777,6 +836,=
7 @@=0A 		sax->fsa_ax25.sax25_call   =3D nr->source_addr;=0A 		*uaddr_len =
=3D sizeof(struct sockaddr_ax25);=0A 	}=0A+	release_sock(sk);=0A =0A 	retur=
n 0;=0A }=0A@@ -790,6 +850,7 @@=0A 	unsigned short circuit_index, circuit_i=
d;=0A 	unsigned short peer_circuit_index, peer_circuit_id;=0A 	unsigned sho=
rt frametype, flags, window, timeout;=0A+	int ret;=0A =0A 	skb->sk =3D NULL=
;		/* Initially we don't know who it's for */=0A =0A@@ -847,7 +908,9 @@=0A =
		else=0A 			nr_sk(sk)->bpqext =3D 0;=0A =0A-		return nr_process_rx_frame(s=
k, skb);=0A+		ret =3D nr_process_rx_frame(sk, skb);=0A+		bh_unlock_sock(sk)=
;=0A+		return ret;=0A 	}=0A =0A 	/*=0A@@ -877,6 +940,8 @@=0A 	if (!sk || sk=
->sk_ack_backlog =3D=3D sk->sk_max_ack_backlog ||=0A 	    (make =3D nr_make=
_new(sk)) =3D=3D NULL) {=0A 		nr_transmit_refusal(skb, 0);=0A+		if (sk)=0A+=
			bh_unlock_sock(sk);=0A 		return 0;=0A 	}=0A =0A@@ -894,7 +959,9 @@=0A 	n=
r_make->your_index  =3D circuit_index;=0A 	nr_make->your_id     =3D circuit=
_id;=0A =0A+	bh_unlock_sock(sk);=0A 	circuit =3D nr_find_next_circuit();=0A=
+	bh_lock_sock(sk);=0A =0A 	nr_make->my_index    =3D circuit / 256;=0A 	nr_=
make->my_id       =3D circuit % 256;=0A@@ -936,6 +1003,7 @@=0A 	if (!sock_f=
lag(sk, SOCK_DEAD))=0A 		sk->sk_data_ready(sk, skb->len);=0A =0A+	bh_unlock=
_sock(sk);=0A 	return 1;=0A }=0A =0A@@ -954,28 +1022,42 @@=0A 	if (msg->msg=
_flags & ~(MSG_DONTWAIT|MSG_EOR))=0A 		return -EINVAL;=0A =0A-	if (sk->sk_z=
apped)=0A-		return -EADDRNOTAVAIL;=0A+	lock_sock(sk);=0A+	if (sk->sk_zapped=
) {=0A+		err =3D -EADDRNOTAVAIL;=0A+		goto out;=0A+	}=0A =0A 	if (sk->sk_sh=
utdown & SEND_SHUTDOWN) {=0A 		send_sig(SIGPIPE, current, 0);=0A-		return -=
EPIPE;=0A+		err =3D -EPIPE;=0A+		goto out;=0A 	}=0A =0A-	if (nr->device =3D=
=3D NULL)=0A-		return -ENETUNREACH;=0A+	if (nr->device =3D=3D NULL) {=0A+		=
err =3D -ENETUNREACH;=0A+		goto out;=0A+	}=0A =0A 	if (usax) {=0A-		if (msg=
->msg_namelen < sizeof(sax))=0A-			return -EINVAL;=0A+		if (msg->msg_namele=
n < sizeof(sax)) {=0A+			err =3D -EINVAL;=0A+			goto out;=0A+		}=0A 		sax =
=3D *usax;=0A-		if (ax25cmp(&nr->dest_addr, &sax.sax25_call) !=3D 0)=0A-			=
return -EISCONN;=0A-		if (sax.sax25_family !=3D AF_NETROM)=0A-			return -EI=
NVAL;=0A+		if (ax25cmp(&nr->dest_addr, &sax.sax25_call) !=3D 0) {=0A+			err=
 =3D -EISCONN;=0A+			goto out;=0A+		}=0A+		if (sax.sax25_family !=3D AF_NET=
ROM) {=0A+			err =3D -EINVAL;=0A+			goto out;=0A+		}=0A 	} else {=0A-		if (=
sk->sk_state !=3D TCP_ESTABLISHED)=0A-			return -ENOTCONN;=0A+		if (sk->sk_=
state !=3D TCP_ESTABLISHED) {=0A+			err =3D -ENOTCONN;=0A+			goto out;=0A+	=
	}=0A 		sax.sax25_family =3D AF_NETROM;=0A 		sax.sax25_call   =3D nr->dest_=
addr;=0A 	}=0A@@ -984,10 +1066,10 @@=0A =0A 	/* Build a packet */=0A 	SOCK_=
DEBUG(sk, "NET/ROM: sendto: building packet.\n");=0A-	size =3D len + AX25_B=
PQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A=
+	size =3D len + NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A =0A 	if ((skb =3D so=
ck_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT, &err)) =3D=3D NU=
LL)=0A-		return err;=0A+		goto out;=0A =0A 	skb_reserve(skb, size - len);=
=0A =0A@@ -1022,12 +1104,16 @@=0A =0A 	if (sk->sk_state !=3D TCP_ESTABLISHE=
D) {=0A 		kfree_skb(skb);=0A-		return -ENOTCONN;=0A+		err =3D -ENOTCONN;=0A=
+		goto out;=0A 	}=0A =0A 	nr_output(sk, skb);	/* Shove it onto the queue *=
/=0A =0A-	return len;=0A+	err =3D len;=0A+out:=0A+	release_sock(sk);=0A+	re=
turn err;=0A }=0A =0A static int nr_recvmsg(struct kiocb *iocb, struct sock=
et *sock,=0A@@ -1044,12 +1130,17 @@=0A 	 * us! We do one quick check first =
though=0A 	 */=0A =0A-	if (sk->sk_state !=3D TCP_ESTABLISHED)=0A+	lock_sock=
(sk);=0A+	if (sk->sk_state !=3D TCP_ESTABLISHED) {=0A+		release_sock(sk);=
=0A 		return -ENOTCONN;=0A+	}=0A =0A 	/* Now we can treat all alike */=0A-	=
if ((skb =3D skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTW=
AIT, &er)) =3D=3D NULL)=0A+	if ((skb =3D skb_recv_datagram(sk, flags & ~MSG=
_DONTWAIT, flags & MSG_DONTWAIT, &er)) =3D=3D NULL) {=0A+		release_sock(sk)=
;=0A 		return er;=0A+	}=0A =0A 	skb->h.raw =3D skb->data;=0A 	copied     =
=3D skb->len;=0A@@ -1070,6 +1161,7 @@=0A =0A 	skb_free_datagram(sk, skb);=
=0A =0A+	release_sock(sk);=0A 	return copied;=0A }=0A =0A@@ -1077,13 +1169,=
16 @@=0A static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigne=
d long arg)=0A {=0A 	struct sock *sk =3D sock->sk;=0A+	int ret;=0A =0A+	loc=
k_sock(sk);=0A 	switch (cmd) {=0A 	case TIOCOUTQ: {=0A 		long amount;=0A 		=
amount =3D sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);=0A 		if (amount=
 < 0)=0A 			amount =3D 0;=0A+		release_sock(sk);=0A 		return put_user(amoun=
t, (int *)arg);=0A 	}=0A =0A@@ -1093,15 +1188,21 @@=0A 		/* These two are s=
afe on a single CPU system as only user tasks fiddle here */=0A 		if ((skb =
=3D skb_peek(&sk->sk_receive_queue)) !=3D NULL)=0A 			amount =3D skb->len;=
=0A+		release_sock(sk);=0A 		return put_user(amount, (int *)arg);=0A 	}=0A =
=0A 	case SIOCGSTAMP:=0A 		if (sk !=3D NULL) {=0A-			if (!sk->sk_stamp.tv_s=
ec)=0A+			if (!sk->sk_stamp.tv_sec) {=0A+				release_sock(sk);=0A 				retur=
n -ENOENT;=0A-			return copy_to_user((void *)arg, &sk->sk_stamp, sizeof(str=
uct timeval)) ? -EFAULT : 0;=0A+			}=0A+			ret =3D copy_to_user((void *)arg=
, &sk->sk_stamp, sizeof(struct timeval)) ? -EFAULT : 0;=0A+			release_sock(=
sk);=0A+			return ret;=0A 		}=0A+		release_sock(sk);=0A 		return -EINVAL;=
=0A =0A 	case SIOCGIFADDR:=0A@@ -1114,17 +1215,21 @@=0A 	case SIOCSIFNETMAS=
K:=0A 	case SIOCGIFMETRIC:=0A 	case SIOCSIFMETRIC:=0A+		release_sock(sk);=
=0A 		return -EINVAL;=0A =0A 	case SIOCADDRT:=0A 	case SIOCDELRT:=0A 	case =
SIOCNRDECOBS:=0A+		release_sock(sk);=0A 		if (!capable(CAP_NET_ADMIN)) retu=
rn -EPERM;=0A 		return nr_rt_ioctl(cmd, (void *)arg);=0A =0A 	default:=0A+	=
	release_sock(sk);=0A 		return dev_ioctl(cmd, (void *)arg);=0A 	}=0A+	relea=
se_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -1144,7 +1249,9 @@=0A 	len +=3D sp=
rintf(buffer, "user_addr dest_node src_node  dev    my  your  st  vs  vr  v=
a    t1     t2     t4      idle   n2  wnd Snd-Q Rcv-Q inode\n");=0A =0A 	sk=
_for_each(s, node, &nr_list) {=0A-		nr_cb *nr =3D nr_sk(s);=0A+		nr_cb *nr;=
=0A+		bh_lock_sock(s);=0A+		nr =3D nr_sk(s);=0A =0A 		if ((dev =3D nr->devi=
ce) =3D=3D NULL)=0A 			devname =3D "???";=0A@@ -1187,7 +1294,7 @@=0A 			len=
   =3D 0;=0A 			begin =3D pos;=0A 		}=0A-=0A+		bh_unlock_sock(s);=0A 		if (=
pos > offset + length)=0A 			break;=0A 	}=0A@@ -1256,6 +1363,7 @@=0A =0A 	f=
or (i =3D 0; i < nr_ndevs; i++) {=0A 		sprintf(dev_nr[i].name, "nr%d", i);=
=0A+		dev_nr[i].base_addr =3D i;=0A 		dev_nr[i].init =3D nr_init;=0A 		regi=
ster_netdev(&dev_nr[i]);=0A 	}=0A@@ -1300,23 +1408,23 @@=0A =0A 	nr_rt_free=
();=0A =0A-	ax25_protocol_release(AX25_P_NETROM);=0A+#ifdef CONFIG_SYSCTL=
=0A+	nr_unregister_sysctl();=0A+#endif=0A+=0A 	ax25_linkfail_release(nr_lin=
k_failed);=0A+	ax25_protocol_release(AX25_P_NETROM);=0A =0A 	unregister_net=
device_notifier(&nr_dev_notifier);=0A =0A-#ifdef CONFIG_SYSCTL=0A-	nr_unreg=
ister_sysctl();=0A-#endif=0A 	sock_unregister(PF_NETROM);=0A =0A 	for (i =
=3D 0; i < nr_ndevs; i++) {=0A 		if (dev_nr[i].priv !=3D NULL) {=0A+			unre=
gister_netdev(&dev_nr[i]);=0A 			kfree(dev_nr[i].priv);=0A 			dev_nr[i].pri=
v =3D NULL;=0A-			unregister_netdev(&dev_nr[i]);=0A 		}=0A-		kfree(dev_nr[i=
].name);=0A 	}=0A =0A 	kfree(dev_nr);=0Adiff -ru linux-2.6.0-test3/net/netr=
om/nr_dev.c linux-2.6.0-test1.rxq3/net/netrom/nr_dev.c=0A--- linux-2.6.0-te=
st3/net/netrom/nr_dev.c	2003-08-09 06:41:27.000000000 +0200=0A+++ linux-2.6=
.0-test1.rxq3/net/netrom/nr_dev.c	2003-07-24 20:56:54.000000000 +0200=0A@@ =
-159,11 +159,13 @@=0A {=0A 	struct sockaddr *sa =3D addr;=0A =0A-	ax25_list=
en_release((ax25_address *)dev->dev_addr, NULL);=0A+	if (dev->flags & IFF_U=
P)=0A+		ax25_listen_release((ax25_address *)dev->dev_addr, NULL);=0A =0A 	m=
emcpy(dev->dev_addr, sa->sa_data, dev->addr_len);=0A =0A-	ax25_listen_regis=
ter((ax25_address *)dev->dev_addr, NULL);=0A+	if (dev->flags & IFF_UP)=0A+	=
	ax25_listen_register((ax25_address *)dev->dev_addr, NULL);=0A =0A 	return =
0;=0A }=0A@@ -177,8 +179,8 @@=0A =0A static int nr_close(struct net_device =
*dev)=0A {=0A-	netif_stop_queue(dev);=0A 	ax25_listen_release((ax25_address=
 *)dev->dev_addr, NULL);=0A+	netif_stop_queue(dev);=0A 	return 0;=0A }=0A =
=0A@@ -197,16 +199,16 @@=0A =0A int nr_init(struct net_device *dev)=0A {=0A=
-	SET_MODULE_OWNER(dev);=0A 	dev->mtu		=3D NR_MAX_PACKET_SIZE;=0A 	dev->har=
d_start_xmit	=3D nr_xmit;=0A 	dev->open		=3D nr_open;=0A 	dev->stop		=3D nr=
_close;=0A =0A 	dev->hard_header	=3D nr_header;=0A-	dev->hard_header_len	=
=3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPO=
RT_LEN;=0A+	dev->hard_header_len	=3D NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A =
	dev->addr_len		=3D AX25_ADDR_LEN;=0A 	dev->type		=3D ARPHRD_NETROM;=0A+	de=
v->tx_queue_len	=3D 40;=0A 	dev->rebuild_header	=3D nr_rebuild_header;=0A 	=
dev->set_mac_address    =3D nr_set_mac_address;=0A =0Adiff -ru linux-2.6.0-=
test3/net/netrom/nr_in.c linux-2.6.0-test1.rxq3/net/netrom/nr_in.c=0A--- li=
nux-2.6.0-test3/net/netrom/nr_in.c	2003-08-09 06:34:46.000000000 +0200=0A++=
+ linux-2.6.0-test1.rxq3/net/netrom/nr_in.c	2003-07-24 20:56:55.000000000 +=
0200=0A@@ -74,6 +74,7 @@=0A static int nr_state1_machine(struct sock *sk, s=
truct sk_buff *skb,=0A 	int frametype)=0A {=0A+	bh_lock_sock(sk);=0A 	switc=
h (frametype) {=0A 	case NR_CONNACK: {=0A 		nr_cb *nr =3D nr_sk(sk);=0A@@ -=
102,6 +103,7 @@=0A 	default:=0A 		break;=0A 	}=0A+	bh_unlock_sock(sk);=0A =
=0A 	return 0;=0A }=0A@@ -114,6 +116,7 @@=0A static int nr_state2_machine(s=
truct sock *sk, struct sk_buff *skb,=0A 	int frametype)=0A {=0A+	bh_lock_so=
ck(sk);=0A 	switch (frametype) {=0A 	case NR_CONNACK | NR_CHOKE_FLAG:=0A 		=
nr_disconnect(sk, ECONNRESET);=0A@@ -129,6 +132,7 @@=0A 	default:=0A 		brea=
k;=0A 	}=0A+	bh_unlock_sock(sk);=0A =0A 	return 0;=0A }=0A@@ -150,6 +154,7 =
@@=0A 	nr =3D skb->data[18];=0A 	ns =3D skb->data[17];=0A =0A+	bh_lock_sock=
(sk);=0A 	switch (frametype) {=0A 	case NR_CONNREQ:=0A 		nr_write_internal(=
sk, NR_CONNACK);=0A@@ -260,6 +265,7 @@=0A 	default:=0A 		break;=0A 	}=0A+	b=
h_unlock_sock(sk);=0A =0A 	return queued;=0A }=0Adiff -ru linux-2.6.0-test3=
/net/netrom/nr_route.c linux-2.6.0-test1.rxq3/net/netrom/nr_route.c=0A--- l=
inux-2.6.0-test3/net/netrom/nr_route.c	2003-08-09 06:42:17.000000000 +0200=
=0A+++ linux-2.6.0-test1.rxq3/net/netrom/nr_route.c	2003-07-24 20:56:55.000=
000000 +0200=0A@@ -39,10 +39,45 @@=0A =0A static unsigned int nr_neigh_no =
=3D 1;=0A =0A-static struct nr_node  *nr_node_list;=0A-static spinlock_t nr=
_node_lock;=0A-static struct nr_neigh *nr_neigh_list;=0A-static spinlock_t =
nr_neigh_lock;=0A+HLIST_HEAD(nr_node_list);=0A+spinlock_t nr_node_list_lock=
 =3D SPIN_LOCK_UNLOCKED;=0A+HLIST_HEAD(nr_neigh_list);=0A+spinlock_t nr_nei=
gh_list_lock =3D SPIN_LOCK_UNLOCKED;=0A+=0A+struct nr_node *nr_node_get(ax2=
5_address *callsign)=0A+{=0A+	struct nr_node *found =3D NULL;=0A+	struct nr=
_node *nr_node;=0A+	struct hlist_node *node;=0A+=0A+	spin_lock_bh(&nr_node_=
list_lock);=0A+	nr_node_for_each(nr_node, node, &nr_node_list)=0A+		if (ax2=
5cmp(callsign, &nr_node->callsign) =3D=3D 0) {=0A+			nr_node_hold(nr_node);=
=0A+			found =3D nr_node;=0A+			break;=0A+		}=0A+	spin_unlock_bh(&nr_node_l=
ist_lock);=0A+	return found;=0A+}=0A+=0A+struct nr_neigh *nr_neigh_get_dev(=
ax25_address *callsign, struct net_device *dev)=0A+{=0A+	struct nr_neigh *f=
ound =3D NULL;=0A+	struct nr_neigh *nr_neigh;=0A+	struct hlist_node *node;=
=0A+=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	nr_neigh_for_each(nr_neigh,=
 node, &nr_neigh_list)=0A+		if (ax25cmp(callsign, &nr_neigh->callsign) =3D=
=3D 0 &&=0A+		    nr_neigh->dev =3D=3D dev) {=0A+			nr_neigh_hold(nr_neigh)=
;=0A+			found =3D nr_neigh;=0A+			break;=0A+		}=0A+	spin_unlock_bh(&nr_neig=
h_list_lock);=0A+	return found;=0A+}=0A =0A static void nr_remove_neigh(str=
uct nr_neigh *);=0A =0A@@ -57,17 +92,16 @@=0A 	struct nr_neigh *nr_neigh;=
=0A 	struct nr_route nr_route;=0A 	int i, found;=0A+	struct net_device *ode=
v;=0A =0A-	if (nr_dev_get(nr) !=3D NULL)	/* Can't add routes to ourself */=
=0A+	if ((odev=3Dnr_dev_get(nr)) !=3D NULL) {	/* Can't add routes to oursel=
f */=0A+		dev_put(odev);=0A 		return -EINVAL;=0A+	}=0A =0A-	for (nr_node =
=3D nr_node_list; nr_node !=3D NULL; nr_node =3D nr_node->next)=0A-		if (ax=
25cmp(nr, &nr_node->callsign) =3D=3D 0)=0A-			break;=0A+	nr_node =3D nr_nod=
e_get(nr);=0A =0A-	for (nr_neigh =3D nr_neigh_list; nr_neigh !=3D NULL; nr_=
neigh =3D nr_neigh->next)=0A-		if (ax25cmp(ax25, &nr_neigh->callsign) =3D=
=3D 0 && nr_neigh->dev =3D=3D dev)=0A-			break;=0A+	nr_neigh =3D nr_neigh_g=
et_dev(ax25, dev);=0A =0A 	/*=0A 	 * The L2 link to a neighbour has failed =
in the past=0A@@ -76,24 +110,36 @@=0A 	 * routes now (and not wait for a no=
de broadcast).=0A 	 */=0A 	if (nr_neigh !=3D NULL && nr_neigh->failed !=3D =
0 && quality =3D=3D 0) {=0A-		struct nr_node *node;=0A+		struct nr_node *nr=
_nodet;=0A+		struct hlist_node *node;=0A =0A-		for (node =3D nr_node_list; =
node !=3D NULL; node =3D node->next)=0A-			for (i =3D 0; i < node->count; i=
++)=0A-				if (node->routes[i].neighbour =3D=3D nr_neigh)=0A-					if (i < n=
ode->which)=0A-						node->which =3D i;=0A+		spin_lock_bh(&nr_node_list_loc=
k);=0A+		nr_node_for_each(nr_nodet, node, &nr_node_list) {=0A+			nr_node_lo=
ck(nr_nodet);=0A+			for (i =3D 0; i < nr_nodet->count; i++)=0A+				if (nr_n=
odet->routes[i].neighbour =3D=3D nr_neigh)=0A+					if (i < nr_nodet->which)=
=0A+						nr_nodet->which =3D i;=0A+			nr_node_unlock(nr_nodet);=0A+		}=0A+=
		spin_unlock_bh(&nr_node_list_lock);=0A 	}=0A =0A 	if (nr_neigh !=3D NULL)=
=0A 		nr_neigh->failed =3D 0;=0A =0A-	if (quality =3D=3D 0 && nr_neigh !=3D=
 NULL && nr_node !=3D NULL)=0A+	if (quality =3D=3D 0 && nr_neigh !=3D NULL =
&& nr_node !=3D NULL) {=0A+		nr_neigh_put(nr_neigh);=0A+		nr_node_put(nr_no=
de);=0A 		return 0;=0A+	}=0A =0A 	if (nr_neigh =3D=3D NULL) {=0A-		if ((nr_=
neigh =3D kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) =3D=3D NULL)=0A+		if ((nr=
_neigh =3D kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) =3D=3D NULL) {=0A+			if =
(nr_node)=0A+				nr_node_put(nr_node);=0A 			return -ENOMEM;=0A+		}=0A =0A =
		nr_neigh->callsign =3D *ax25;=0A 		nr_neigh->digipeat =3D NULL;=0A@@ -104=
,48 +150,58 @@=0A 		nr_neigh->count    =3D 0;=0A 		nr_neigh->number   =3D n=
r_neigh_no++;=0A 		nr_neigh->failed   =3D 0;=0A+		atomic_set(&nr_neigh->ref=
count, 1);=0A =0A 		if (ax25_digi !=3D NULL && ax25_digi->ndigi > 0) {=0A 	=
		if ((nr_neigh->digipeat =3D kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) =3D=
=3D NULL) {=0A 				kfree(nr_neigh);=0A+				if (nr_node)=0A+					nr_node_put=
(nr_node);=0A 				return -ENOMEM;=0A 			}=0A 			memcpy(nr_neigh->digipeat, =
ax25_digi,=0A 					sizeof(*ax25_digi));=0A 		}=0A =0A-		spin_lock_bh(&nr_ne=
igh_lock);=0A-		nr_neigh->next =3D nr_neigh_list;=0A-		nr_neigh_list  =3D n=
r_neigh;=0A-		spin_unlock_bh(&nr_neigh_lock);=0A+		spin_lock_bh(&nr_neigh_l=
ist_lock);=0A+		hlist_add_head(&nr_neigh->neigh_node, &nr_neigh_list);=0A+	=
	nr_neigh_hold(nr_neigh);=0A+		spin_unlock_bh(&nr_neigh_list_lock);=0A 	}=
=0A =0A 	if (quality !=3D 0 && ax25cmp(nr, ax25) =3D=3D 0 && !nr_neigh->loc=
ked)=0A 		nr_neigh->quality =3D quality;=0A =0A 	if (nr_node =3D=3D NULL) {=
=0A-		if ((nr_node =3D kmalloc(sizeof(*nr_node), GFP_ATOMIC)) =3D=3D NULL)=
=0A+		if ((nr_node =3D kmalloc(sizeof(*nr_node), GFP_ATOMIC)) =3D=3D NULL) =
{=0A+			if (nr_neigh)=0A+				nr_neigh_put(nr_neigh);=0A 			return -ENOMEM;=
=0A+		}=0A =0A 		nr_node->callsign =3D *nr;=0A 		strcpy(nr_node->mnemonic, =
mnemonic);=0A =0A 		nr_node->which =3D 0;=0A 		nr_node->count =3D 1;=0A+		a=
tomic_set(&nr_node->refcount, 1);=0A+		nr_node->node_lock =3D SPIN_LOCK_UNL=
OCKED;=0A =0A 		nr_node->routes[0].quality   =3D quality;=0A 		nr_node->rou=
tes[0].obs_count =3D obs_count;=0A 		nr_node->routes[0].neighbour =3D nr_ne=
igh;=0A =0A-		spin_lock_bh(&nr_node_lock);=0A-		nr_node->next =3D nr_node_l=
ist;=0A-		nr_node_list  =3D nr_node;=0A-		spin_unlock_bh(&nr_node_lock);=0A=
-=0A+		nr_neigh_hold(nr_neigh);=0A 		nr_neigh->count++;=0A =0A+		spin_lock_=
bh(&nr_node_list_lock);=0A+		hlist_add_head(&nr_node->node_node, &nr_node_l=
ist);=0A+		/* refcount initialized at 1 */=0A+		spin_unlock_bh(&nr_node_lis=
t_lock);=0A+=0A 		return 0;=0A 	}=0A+	nr_node_lock(nr_node);=0A =0A 	if (qu=
ality !=3D 0)=0A 		strcpy(nr_node->mnemonic, mnemonic);=0A@@ -171,11 +227,1=
3 @@=0A =0A 			nr_node->which++;=0A 			nr_node->count++;=0A+			nr_neigh_hol=
d(nr_neigh);=0A 			nr_neigh->count++;=0A 		} else {=0A 			/* It must be bet=
ter than the worst */=0A 			if (quality > nr_node->routes[2].quality) {=0A =
				nr_node->routes[2].neighbour->count--;=0A+				nr_neigh_put(nr_node->rou=
tes[2].neighbour);=0A =0A 				if (nr_node->routes[2].neighbour->count =3D=
=3D 0 && !nr_node->routes[2].neighbour->locked)=0A 					nr_remove_neigh(nr_=
node->routes[2].neighbour);=0A@@ -184,6 +242,7 @@=0A 				nr_node->routes[2]=
.obs_count =3D obs_count;=0A 				nr_node->routes[2].neighbour =3D nr_neigh;=
=0A =0A+				nr_neigh_hold(nr_neigh);=0A 				nr_neigh->count++;=0A 			}=0A 	=
	}=0A@@ -244,62 +303,42 @@=0A 		}=0A 	}=0A =0A+	nr_neigh_put(nr_neigh);=0A+=
	nr_node_unlock(nr_node);=0A+	nr_node_put(nr_node);=0A 	return 0;=0A }=0A =
=0A-static void nr_remove_node(struct nr_node *nr_node)=0A+static inline vo=
id __nr_remove_node(struct nr_node *nr_node)=0A {=0A-	struct nr_node *s;=0A=
-=0A-	spin_lock_bh(&nr_node_lock);=0A-	if ((s =3D nr_node_list) =3D=3D nr_n=
ode) {=0A-		nr_node_list =3D nr_node->next;=0A-		spin_unlock_bh(&nr_node_lo=
ck);=0A-		kfree(nr_node);=0A-		return;=0A-	}=0A-=0A-	while (s !=3D NULL && =
s->next !=3D NULL) {=0A-		if (s->next =3D=3D nr_node) {=0A-			s->next =3D n=
r_node->next;=0A-			spin_unlock_bh(&nr_node_lock);=0A-			kfree(nr_node);=0A=
-			return;=0A-		}=0A+	hlist_del_init(&nr_node->node_node);=0A+	nr_node_put=
(nr_node);=0A+}=0A =0A-		s =3D s->next;=0A-	}=0A+#define nr_remove_node_loc=
ked(__node) \=0A+	__nr_remove_node(__node)=0A =0A-	spin_unlock_bh(&nr_node_=
lock);=0A+static void nr_remove_node(struct nr_node *nr_node)=0A+{=0A+	spin=
_lock_bh(&nr_node_list_lock);=0A+	__nr_remove_node(nr_node);=0A+	spin_unloc=
k_bh(&nr_node_list_lock);=0A }=0A =0A-static void nr_remove_neigh(struct nr=
_neigh *nr_neigh)=0A+static inline void __nr_remove_neigh(struct nr_neigh *=
nr_neigh)=0A {=0A-	struct nr_neigh *s;=0A+	hlist_del_init(&nr_neigh->neigh_=
node);=0A+	nr_neigh_put(nr_neigh);=0A+}=0A =0A-	spin_lock_bh(&nr_neigh_lock=
);=0A-	if ((s =3D nr_neigh_list) =3D=3D nr_neigh) {=0A-		nr_neigh_list =3D =
nr_neigh->next;=0A-		spin_unlock_bh(&nr_neigh_lock);=0A-		if (nr_neigh->dig=
ipeat !=3D NULL)=0A-			kfree(nr_neigh->digipeat);=0A-		kfree(nr_neigh);=0A-=
		return;=0A-	}=0A+#define nr_remove_neigh_locked(__neigh) \=0A+	__nr_remov=
e_neigh(__neigh)=0A =0A-	while (s !=3D NULL && s->next !=3D NULL) {=0A-		if=
 (s->next =3D=3D nr_neigh) {=0A-			s->next =3D nr_neigh->next;=0A-			spin_u=
nlock_bh(&nr_neigh_lock);=0A-			if (nr_neigh->digipeat !=3D NULL)=0A-				kf=
ree(nr_neigh->digipeat);=0A-			kfree(nr_neigh);=0A-			return;=0A-		}=0A-=0A=
-		s =3D s->next;=0A-	}=0A-	spin_unlock_bh(&nr_neigh_lock);=0A+static void =
nr_remove_neigh(struct nr_neigh *nr_neigh)=0A+{=0A+	spin_lock_bh(&nr_neigh_=
list_lock);=0A+	__nr_remove_neigh(nr_neigh);=0A+	spin_unlock_bh(&nr_neigh_l=
ist_lock);=0A }=0A =0A /*=0A@@ -312,26 +351,27 @@=0A 	struct nr_neigh *nr_n=
eigh;=0A 	int i;=0A =0A-	for (nr_node =3D nr_node_list; nr_node !=3D NULL; =
nr_node =3D nr_node->next)=0A-		if (ax25cmp(callsign, &nr_node->callsign) =
=3D=3D 0)=0A-			break;=0A+	nr_node =3D nr_node_get(callsign);=0A =0A 	if (n=
r_node =3D=3D NULL)=0A 		return -EINVAL;=0A =0A-	for (nr_neigh =3D nr_neigh=
_list; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next)=0A-		if (ax25cmp(ne=
ighbour, &nr_neigh->callsign) =3D=3D 0 && nr_neigh->dev =3D=3D dev)=0A-			b=
reak;=0A+	nr_neigh =3D nr_neigh_get_dev(neighbour, dev);=0A =0A-	if (nr_nei=
gh =3D=3D NULL)=0A+	if (nr_neigh =3D=3D NULL) {=0A+		nr_node_put(nr_node);=
=0A 		return -EINVAL;=0A+	}=0A =0A+	nr_node_lock(nr_node);=0A 	for (i =3D 0=
; i < nr_node->count; i++) {=0A 		if (nr_node->routes[i].neighbour =3D=3D n=
r_neigh) {=0A 			nr_neigh->count--;=0A+			nr_neigh_put(nr_neigh);=0A =0A 		=
	if (nr_neigh->count =3D=3D 0 && !nr_neigh->locked)=0A 				nr_remove_neigh(=
nr_neigh);=0A+			nr_neigh_put(nr_neigh);=0A =0A 			nr_node->count--;=0A =0A=
@@ -346,11 +386,16 @@=0A 				case 2:=0A 					break;=0A 				}=0A+				nr_node=
_put(nr_node);=0A 			}=0A+			nr_node_unlock(nr_node);=0A =0A 			return 0;=
=0A 		}=0A 	}=0A+	nr_neigh_put(nr_neigh);=0A+	nr_node_unlock(nr_node);=0A+	=
nr_node_put(nr_node);=0A =0A 	return -EINVAL;=0A }=0A@@ -362,12 +407,12 @@=
=0A {=0A 	struct nr_neigh *nr_neigh;=0A =0A-	for (nr_neigh =3D nr_neigh_lis=
t; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next) {=0A-		if (ax25cmp(call=
sign, &nr_neigh->callsign) =3D=3D 0 && nr_neigh->dev =3D=3D dev) {=0A-			nr=
_neigh->quality =3D quality;=0A-			nr_neigh->locked  =3D 1;=0A-			return 0;=
=0A-		}=0A+	nr_neigh =3D nr_neigh_get_dev(callsign, dev);=0A+	if (nr_neigh)=
 {=0A+		nr_neigh->quality =3D quality;=0A+		nr_neigh->locked  =3D 1;=0A+		n=
r_neigh_put(nr_neigh);=0A+		return 0;=0A 	}=0A =0A 	if ((nr_neigh =3D kmall=
oc(sizeof(*nr_neigh), GFP_ATOMIC)) =3D=3D NULL)=0A@@ -382,6 +427,7 @@=0A 	n=
r_neigh->count    =3D 0;=0A 	nr_neigh->number   =3D nr_neigh_no++;=0A 	nr_n=
eigh->failed   =3D 0;=0A+	atomic_set(&nr_neigh->refcount, 1);=0A =0A 	if (a=
x25_digi !=3D NULL && ax25_digi->ndigi > 0) {=0A 		if ((nr_neigh->digipeat =
=3D kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) =3D=3D NULL) {=0A@@ -391,10 +4=
37,10 @@=0A 		memcpy(nr_neigh->digipeat, ax25_digi, sizeof(*ax25_digi));=0A=
 	}=0A =0A-	spin_lock_bh(&nr_neigh_lock);=0A-	nr_neigh->next =3D nr_neigh_l=
ist;=0A-	nr_neigh_list  =3D nr_neigh;=0A-	spin_unlock_bh(&nr_neigh_lock);=
=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	hlist_add_head(&nr_neigh->neigh=
_node, &nr_neigh_list);=0A+	/* refcount is initialized at 1 */=0A+	spin_unl=
ock_bh(&nr_neigh_list_lock);=0A =0A 	return 0;=0A }=0A@@ -407,9 +453,7 @@=
=0A {=0A 	struct nr_neigh *nr_neigh;=0A =0A-	for (nr_neigh =3D nr_neigh_lis=
t; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next)=0A-		if (ax25cmp(callsi=
gn, &nr_neigh->callsign) =3D=3D 0 && nr_neigh->dev =3D=3D dev)=0A-			break;=
=0A+	nr_neigh =3D nr_neigh_get_dev(callsign, dev);=0A =0A 	if (nr_neigh =3D=
=3D NULL) return -EINVAL;=0A =0A@@ -418,6 +462,7 @@=0A =0A 	if (nr_neigh->c=
ount =3D=3D 0)=0A 		nr_remove_neigh(nr_neigh);=0A+	nr_neigh_put(nr_neigh);=
=0A =0A 	return 0;=0A }=0A@@ -430,15 +475,13 @@=0A static int nr_dec_obs(vo=
id)=0A {=0A 	struct nr_neigh *nr_neigh;=0A-	struct nr_node  *s, *nr_node;=
=0A+	struct nr_node  *s;=0A+	struct hlist_node *node, *nodet;=0A 	int i;=0A=
 =0A-	nr_node =3D nr_node_list;=0A-=0A-	while (nr_node !=3D NULL) {=0A-		s =
      =3D nr_node;=0A-		nr_node =3D nr_node->next;=0A-=0A+	spin_lock_bh(&nr=
_node_list_lock);=0A+	nr_node_for_each_safe(s, node, nodet, &nr_node_list) =
{=0A+		nr_node_lock(s);=0A 		for (i =3D 0; i < s->count; i++) {=0A 			switc=
h (s->routes[i].obs_count) {=0A 			case 0:		/* A locked entry */=0A@@ -448,=
6 +491,7 @@=0A 				nr_neigh =3D s->routes[i].neighbour;=0A =0A 				nr_neigh=
->count--;=0A+				nr_neigh_put(nr_neigh);=0A =0A 				if (nr_neigh->count =
=3D=3D 0 && !nr_neigh->locked)=0A 					nr_remove_neigh(nr_neigh);=0A@@ -472=
,8 +516,10 @@=0A 		}=0A =0A 		if (s->count <=3D 0)=0A-			nr_remove_node(s);=
=0A+			nr_remove_node_locked(s);=0A+		nr_node_unlock(s);=0A 	}=0A+	spin_unl=
ock_bh(&nr_node_list_lock);=0A =0A 	return 0;=0A }=0A@@ -483,21 +529,17 @@=
=0A  */=0A void nr_rt_device_down(struct net_device *dev)=0A {=0A-	struct n=
r_neigh *s, *nr_neigh =3D nr_neigh_list;=0A-	struct nr_node  *t, *nr_node;=
=0A+	struct nr_neigh *s;=0A+	struct hlist_node *node, *nodet, *node2, *node=
2t;=0A+	struct nr_node  *t;=0A 	int i;=0A =0A-	while (nr_neigh !=3D NULL) {=
=0A-		s        =3D nr_neigh;=0A-		nr_neigh =3D nr_neigh->next;=0A-=0A+	spin=
_lock_bh(&nr_neigh_list_lock);=0A+	nr_neigh_for_each_safe(s, node, nodet, &=
nr_neigh_list) {=0A 		if (s->dev =3D=3D dev) {=0A-			nr_node =3D nr_node_li=
st;=0A-=0A-			while (nr_node !=3D NULL) {=0A-				t       =3D nr_node;=0A-		=
		nr_node =3D nr_node->next;=0A-=0A+			spin_lock_bh(&nr_node_list_lock);=0A=
+			nr_node_for_each_safe(t, node2, node2t, &nr_node_list) {=0A+				nr_node=
_lock(t);=0A 				for (i =3D 0; i < t->count; i++) {=0A 					if (t->routes[i=
].neighbour =3D=3D s) {=0A 						t->count--;=0A@@ -514,12 +556,15 @@=0A 			=
	}=0A =0A 				if (t->count <=3D 0)=0A-					nr_remove_node(t);=0A+					nr_re=
move_node_locked(t);=0A+				nr_node_unlock(t);=0A 			}=0A+			spin_unlock_bh=
(&nr_node_list_lock);=0A =0A-			nr_remove_neigh(s);=0A+			nr_remove_neigh_l=
ocked(s);=0A 		}=0A 	}=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A }=0A =0A=
 /*=0A@@ -553,6 +598,8 @@=0A 			if (first =3D=3D NULL || strncmp(dev->name,=
 first->name, 3) < 0)=0A 				first =3D dev;=0A 	}=0A+	if (first)=0A+		dev_h=
old(first);=0A 	read_unlock(&dev_base_lock);=0A =0A 	return first;=0A@@ -60=
3,6 +650,7 @@=0A {=0A 	struct nr_route_struct nr_route;=0A 	struct net_devi=
ce *dev;=0A+	int ret;=0A =0A 	switch (cmd) {=0A 	case SIOCADDRT:=0A@@ -610,=
23 +658,29 @@=0A 			return -EFAULT;=0A 		if ((dev =3D nr_ax25_dev_get(nr_ro=
ute.device)) =3D=3D NULL)=0A 			return -EINVAL;=0A-		if (nr_route.ndigis < =
0 || nr_route.ndigis > AX25_MAX_DIGIS)=0A+		if (nr_route.ndigis < 0 || nr_r=
oute.ndigis > AX25_MAX_DIGIS) {=0A+			dev_put(dev);=0A 			return -EINVAL;=
=0A+		}=0A 		switch (nr_route.type) {=0A 		case NETROM_NODE:=0A-			return n=
r_add_node(&nr_route.callsign,=0A+			ret =3D nr_add_node(&nr_route.callsign=
,=0A 				nr_route.mnemonic,=0A 				&nr_route.neighbour,=0A 				nr_call_to_d=
igi(nr_route.ndigis, nr_route.digipeaters),=0A 				dev, nr_route.quality,=
=0A 				nr_route.obs_count);=0A+			break;=0A 		case NETROM_NEIGH:=0A-			ret=
urn nr_add_neigh(&nr_route.callsign,=0A+			ret =3D nr_add_neigh(&nr_route.c=
allsign,=0A 				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters),=0A =
				dev, nr_route.quality);=0A+			break;=0A 		default:=0A-			return -EINVAL=
;=0A+			ret =3D -EINVAL;=0A 		}=0A+		dev_put(dev);=0A+		return ret;=0A =0A =
	case SIOCDELRT:=0A 		if (copy_from_user(&nr_route, arg, sizeof(struct nr_r=
oute_struct)))=0A@@ -635,14 +689,18 @@=0A 			return -EINVAL;=0A 		switch (n=
r_route.type) {=0A 		case NETROM_NODE:=0A-			return nr_del_node(&nr_route.c=
allsign,=0A+			ret =3D nr_del_node(&nr_route.callsign,=0A 				&nr_route.nei=
ghbour, dev);=0A+			break;=0A 		case NETROM_NEIGH:=0A-			return nr_del_neig=
h(&nr_route.callsign,=0A+			ret =3D nr_del_neigh(&nr_route.callsign,=0A 			=
	dev, nr_route.quality);=0A+			break;=0A 		default:=0A-			return -EINVAL;=
=0A+			ret =3D -EINVAL;=0A 		}=0A+		dev_put(dev);=0A+		return ret;=0A =0A 	=
case SIOCNRDECOBS:=0A 		return nr_dec_obs();=0A@@ -660,22 +718,36 @@=0A  */=
=0A void nr_link_failed(ax25_cb *ax25, int reason)=0A {=0A-	struct nr_neigh=
 *nr_neigh;=0A-	struct nr_node  *nr_node;=0A-=0A-	for (nr_neigh =3D nr_neig=
h_list; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next)=0A-		if (nr_neigh-=
>ax25 =3D=3D ax25)=0A+	struct nr_neigh *s, *nr_neigh =3D NULL;=0A+	struct h=
list_node *node;=0A+	struct nr_node  *nr_node =3D NULL;=0A+=0A+	spin_lock_b=
h(&nr_neigh_list_lock);=0A+	nr_neigh_for_each(s, node, &nr_neigh_list)=0A+	=
	if (s->ax25 =3D=3D ax25) {=0A+			nr_neigh_hold(s);=0A+			nr_neigh =3D s;=
=0A 			break;=0A+		}=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A =0A 	if (n=
r_neigh =3D=3D NULL) return;=0A =0A 	nr_neigh->ax25 =3D NULL;=0A+	ax25_cb_p=
ut(ax25);=0A =0A-	if (++nr_neigh->failed < sysctl_netrom_link_fails_count) =
return;=0A-=0A-	for (nr_node =3D nr_node_list; nr_node !=3D NULL; nr_node =
=3D nr_node->next)=0A+	if (++nr_neigh->failed < sysctl_netrom_link_fails_co=
unt) {=0A+		nr_neigh_put(nr_neigh);=0A+		return;=0A+	}=0A+	spin_lock_bh(&nr=
_node_list_lock);=0A+	nr_node_for_each(nr_node, node, &nr_node_list)=0A+		n=
r_node_lock(nr_node);=0A 		if (nr_node->which < nr_node->count && nr_node->=
routes[nr_node->which].neighbour =3D=3D nr_neigh)=0A 			nr_node->which++;=
=0A+		nr_node_unlock(nr_node);=0A+	spin_unlock_bh(&nr_node_list_lock);=0A+	=
nr_neigh_put(nr_neigh);=0A }=0A =0A /*=0A@@ -689,6 +761,9 @@=0A 	struct nr_=
node  *nr_node;=0A 	struct net_device *dev;=0A 	unsigned char *dptr;=0A+	ax=
25_cb *ax25s;=0A+	int ret;=0A+	struct sk_buff *skbn;=0A =0A =0A 	nr_src  =
=3D (ax25_address *)(skb->data + 0);=0A@@ -700,50 +775,84 @@=0A =0A 	if ((d=
ev =3D nr_dev_get(nr_dest)) !=3D NULL) {	/* Its for me */=0A 		if (ax25 =3D=
=3D NULL)			/* Its from me */=0A-			return nr_loopback_queue(skb);=0A+			re=
t =3D nr_loopback_queue(skb);=0A 		else=0A-			return nr_rx_frame(skb, dev);=
=0A+			ret =3D nr_rx_frame(skb, dev);=0A+		dev_put(dev);=0A+		return ret;=
=0A 	}=0A =0A 	if (!sysctl_netrom_routing_control && ax25 !=3D NULL)=0A 		r=
eturn 0;=0A =0A 	/* Its Time-To-Live has expired */=0A-	if (--skb->data[14]=
 =3D=3D 0)=0A+	if (skb->data[14] =3D=3D 1) {=0A 		return 0;=0A+	}=0A =0A-	f=
or (nr_node =3D nr_node_list; nr_node !=3D NULL; nr_node =3D nr_node->next)=
=0A-		if (ax25cmp(nr_dest, &nr_node->callsign) =3D=3D 0)=0A-			break;=0A+	n=
r_node =3D nr_node_get(nr_dest);=0A+	if (nr_node =3D=3D NULL)=0A+		return 0=
;=0A+	nr_node_lock(nr_node);=0A =0A-	if (nr_node =3D=3D NULL || nr_node->wh=
ich >=3D nr_node->count)=0A+	if (nr_node->which >=3D nr_node->count) {=0A+	=
	nr_node_unlock(nr_node);=0A+		nr_node_put(nr_node);=0A 		return 0;=0A+	}=
=0A =0A 	nr_neigh =3D nr_node->routes[nr_node->which].neighbour;=0A =0A-	if=
 ((dev =3D nr_dev_first()) =3D=3D NULL)=0A+	if ((dev =3D nr_dev_first()) =
=3D=3D NULL) {=0A+		nr_node_unlock(nr_node);=0A+		nr_node_put(nr_node);=0A+=
		return 0;=0A+	}=0A+=0A+	/* We are going to change the netrom headers so w=
e should get our=0A+	   own skb, we also did not know until now how much he=
ader space=0A+	   we had to reserve... - RXQ */=0A+	if ((skbn=3Dskb_copy_ex=
pand(skb, dev->hard_header_len, 0, GFP_ATOMIC)) =3D=3D NULL) {=0A+		nr_node=
_unlock(nr_node);=0A+		nr_node_put(nr_node);=0A+		dev_put(dev);=0A 		return=
 0;=0A+	}=0A+	kfree_skb(skb);=0A+	skb=3Dskbn;=0A+	skb->data[14]--;=0A =0A 	=
dptr  =3D skb_push(skb, 1);=0A 	*dptr =3D AX25_P_NETROM;=0A =0A-	nr_neigh->=
ax25 =3D ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh=
->callsign, nr_neigh->digipeat, nr_neigh->dev);=0A+	ax25s =3D ax25_send_fra=
me(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->=
digipeat, nr_neigh->dev);=0A+	if (nr_neigh->ax25 && ax25s) {=0A+		/* We wer=
e already holding this ax25_cb */=0A+		ax25_cb_put(ax25s);=0A+	}=0A+	nr_nei=
gh->ax25 =3D ax25s;=0A =0A-	return (nr_neigh->ax25 !=3D NULL);=0A+	dev_put(=
dev);=0A+	ret =3D (nr_neigh->ax25 !=3D NULL);=0A+	nr_node_unlock(nr_node);=
=0A+	nr_node_put(nr_node);=0A+	return ret;=0A }=0A =0A int nr_nodes_get_inf=
o(char *buffer, char **start, off_t offset, int length)=0A {=0A 	struct nr_=
node *nr_node;=0A+	struct hlist_node *node;=0A 	int len     =3D 0;=0A 	off_=
t pos   =3D 0;=0A 	off_t begin =3D 0;=0A 	int i;=0A =0A-	spin_lock_bh(&nr_n=
ode_lock);=0A+	spin_lock_bh(&nr_node_list_lock);=0A 	len +=3D sprintf(buffe=
r, "callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh\n")=
;=0A =0A-	for (nr_node =3D nr_node_list; nr_node !=3D NULL; nr_node =3D nr_=
node->next) {=0A+	nr_node_for_each(nr_node, node, &nr_node_list) {=0A+		nr_=
node_lock(nr_node);=0A 		len +=3D sprintf(buffer + len, "%-9s %-7s  %d %d",=
=0A 			ax2asc(&nr_node->callsign),=0A 			(nr_node->mnemonic[0] =3D=3D '\0')=
 ? "*" : nr_node->mnemonic,=0A@@ -756,6 +865,7 @@=0A 				nr_node->routes[i]=
.obs_count,=0A 				nr_node->routes[i].neighbour->number);=0A 		}=0A+		nr_no=
de_unlock(nr_node);=0A =0A 		len +=3D sprintf(buffer + len, "\n");=0A =0A@@=
 -769,7 +879,7 @@=0A 		if (pos > offset + length)=0A 			break;=0A 	}=0A-	sp=
in_unlock_bh(&nr_node_lock);=0A+	spin_unlock_bh(&nr_node_list_lock);=0A =0A=
 	*start =3D buffer + (offset - begin);=0A 	len   -=3D (offset - begin);=0A=
@@ -782,15 +892,16 @@=0A int nr_neigh_get_info(char *buffer, char **start, =
off_t offset, int length)=0A {=0A 	struct nr_neigh *nr_neigh;=0A+	struct hl=
ist_node *node;=0A 	int len     =3D 0;=0A 	off_t pos   =3D 0;=0A 	off_t beg=
in =3D 0;=0A 	int i;=0A =0A-	spin_lock_bh(&nr_neigh_lock);=0A+	spin_lock_bh=
(&nr_neigh_list_lock);=0A 	len +=3D sprintf(buffer, "addr  callsign  dev  q=
ual lock count failed digipeaters\n");=0A =0A-	for (nr_neigh =3D nr_neigh_l=
ist; nr_neigh !=3D NULL; nr_neigh =3D nr_neigh->next) {=0A+	nr_neigh_for_ea=
ch(nr_neigh, node, &nr_neigh_list) {=0A 		len +=3D sprintf(buffer + len, "%=
05d %-9s %-4s  %3d    %d   %3d    %3d",=0A 			nr_neigh->number,=0A 			ax2as=
c(&nr_neigh->callsign),=0A@@ -818,7 +929,7 @@=0A 			break;=0A 	}=0A =0A-	sp=
in_unlock_bh(&nr_neigh_lock);=0A+	spin_unlock_bh(&nr_neigh_list_lock);=0A =
=0A 	*start =3D buffer + (offset - begin);=0A 	len   -=3D (offset - begin);=
=0A@@ -833,20 +944,24 @@=0A  */=0A void __exit nr_rt_free(void)=0A {=0A-	st=
ruct nr_neigh *s, *nr_neigh =3D nr_neigh_list;=0A-	struct nr_node  *t, *nr_=
node  =3D nr_node_list;=0A-=0A-	while (nr_node !=3D NULL) {=0A-		t       =
=3D nr_node;=0A-		nr_node =3D nr_node->next;=0A-=0A-		nr_remove_node(t);=0A=
-	}=0A-=0A-	while (nr_neigh !=3D NULL) {=0A-		s        =3D nr_neigh;=0A-		n=
r_neigh =3D nr_neigh->next;=0A-=0A-		nr_remove_neigh(s);=0A+	struct nr_neig=
h *s =3D NULL;=0A+	struct nr_node  *t =3D NULL;=0A+	struct hlist_node *node=
, *nodet;=0A+=0A+	spin_lock_bh(&nr_neigh_list_lock);=0A+	spin_lock_bh(&nr_n=
ode_list_lock);=0A+	nr_node_for_each_safe(t, node, nodet, &nr_node_list) {=
=0A+		nr_node_lock(t);=0A+		nr_remove_node_locked(t);=0A+		nr_node_unlock(t=
);=0A+	}=0A+	nr_neigh_for_each_safe(s, node, nodet, &nr_neigh_list) {=0A+		=
while(s->count) {=0A+			s->count--;=0A+			nr_neigh_put(s);=0A+		}=0A+		nr_r=
emove_neigh_locked(s);=0A 	}=0A+	spin_unlock_bh(&nr_node_list_lock);=0A+	sp=
in_unlock_bh(&nr_neigh_list_lock);=0A }=0Adiff -ru linux-2.6.0-test3/net/ne=
trom/nr_subr.c linux-2.6.0-test1.rxq3/net/netrom/nr_subr.c=0A--- linux-2.6.=
0-test3/net/netrom/nr_subr.c	2003-08-09 06:42:56.000000000 +0200=0A+++ linu=
x-2.6.0-test1.rxq3/net/netrom/nr_subr.c	2003-07-24 20:56:54.000000000 +0200=
=0A@@ -127,7 +127,7 @@=0A 	unsigned char  *dptr;=0A 	int len, timeout;=0A =
=0A-	len =3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + N=
R_TRANSPORT_LEN;=0A+	len =3D NR_NETWORK_LEN + NR_TRANSPORT_LEN;=0A =0A 	swi=
tch (frametype & 0x0F) {=0A 	case NR_CONNREQ:=0A@@ -151,7 +151,7 @@=0A 	/*=
=0A 	 *	Space for AX.25 and NET/ROM network header=0A 	 */=0A-	skb_reserve(=
skb, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN);=0A+	skb_r=
eserve(skb, NR_NETWORK_LEN);=0A =0A 	dptr =3D skb_put(skb, skb_tailroom(skb=
));=0A =0A@@ -219,12 +219,12 @@=0A 	unsigned char *dptr;=0A 	int len;=0A =
=0A-	len =3D AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + N=
R_TRANSPORT_LEN + 1;=0A+	len =3D NR_NETWORK_LEN + NR_TRANSPORT_LEN + 1;=0A =
=0A 	if ((skbn =3D alloc_skb(len, GFP_ATOMIC)) =3D=3D NULL)=0A 		return;=0A=
 =0A-	skb_reserve(skbn, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN);=0A+	skb=
_reserve(skbn, 0);=0A =0A 	dptr =3D skb_put(skbn, NR_NETWORK_LEN + NR_TRANS=
PORT_LEN);=0A =0Adiff -ru linux-2.6.0-test3/net/netrom/nr_timer.c linux-2.6=
.0-test1.rxq3/net/netrom/nr_timer.c=0A--- linux-2.6.0-test3/net/netrom/nr_t=
imer.c	2003-08-09 06:38:56.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/net=
/netrom/nr_timer.c	2003-07-24 20:56:55.000000000 +0200=0A@@ -143,7 +143,10 =
@@=0A 		   is accepted() it isn't 'dead' so doesn't get removed. */=0A 		if=
 (sock_flag(sk, SOCK_DESTROY) ||=0A 		    (sk->sk_state =3D=3D TCP_LISTEN &=
& sock_flag(sk, SOCK_DEAD))) {=0A+			sock_hold(sk);=0A 			nr_destroy_socket=
(sk);=0A+			bh_unlock_sock(sk);=0A+			sock_put(sk);=0A 			return;=0A 		}=0A=
 		break;=0A@@ -227,6 +230,7 @@=0A 	case NR_STATE_1:=0A 		if (nr->n2count =
=3D=3D nr->n2) {=0A 			nr_disconnect(sk, ETIMEDOUT);=0A+			bh_unlock_sock(s=
k);=0A 			return;=0A 		} else {=0A 			nr->n2count++;=0A@@ -237,6 +241,7 @@=
=0A 	case NR_STATE_2:=0A 		if (nr->n2count =3D=3D nr->n2) {=0A 			nr_discon=
nect(sk, ETIMEDOUT);=0A+			bh_unlock_sock(sk);=0A 			return;=0A 		} else {=
=0A 			nr->n2count++;=0A@@ -247,6 +252,7 @@=0A 	case NR_STATE_3:=0A 		if (n=
r->n2count =3D=3D nr->n2) {=0A 			nr_disconnect(sk, ETIMEDOUT);=0A+			bh_un=
lock_sock(sk);=0A 			return;=0A 		} else {=0A 			nr->n2count++;=0Adiff -ru =
linux-2.6.0-test3/net/netrom/sysctl_net_netrom.c linux-2.6.0-test1.rxq3/net=
/netrom/sysctl_net_netrom.c=0A--- linux-2.6.0-test3/net/netrom/sysctl_net_n=
etrom.c	2003-08-09 06:33:21.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/ne=
t/netrom/sysctl_net_netrom.c	2003-07-24 20:56:54.000000000 +0200=0A@@ -15,9=
 +15,9 @@=0A /*=0A  *	Values taken from NET/ROM documentation.=0A  */=0A-st=
atic int min_quality[1],       max_quality[] =3D {255};=0A-static int min_o=
bs[1],           max_obs[]     =3D {255};=0A-static int min_ttl[1],        =
   max_ttl[]     =3D {255};=0A+static int min_quality[] =3D {0}, max_qualit=
y[] =3D {255};=0A+static int min_obs[]     =3D {0}, max_obs[]     =3D {255}=
;=0A+static int min_ttl[]     =3D {0}, max_ttl[]     =3D {255};=0A static i=
nt min_t1[]      =3D {5 * HZ};=0A static int max_t1[]      =3D {600 * HZ};=
=0A static int min_n2[]      =3D {2}, max_n2[]      =3D {127};=0A@@ -28,7 +=
28,7 @@=0A static int min_window[]  =3D {1}, max_window[]  =3D {127};=0A st=
atic int min_idle[]    =3D {0 * HZ};=0A static int max_idle[]    =3D {65535=
 * HZ};=0A-static int min_route[1],        max_route[]   =3D {1};=0A+static=
 int min_route[]   =3D {0}, max_route[]   =3D {1};=0A static int min_fails[=
]   =3D {1}, max_fails[]   =3D {10};=0A =0A static struct ctl_table_header =
*nr_table_header;=0A--- linux-2.6.0-test3/include/net/ax25.h	2003-08-09 06:=
38:16.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/include/net/ax25.h	2003-=
07-24 21:01:59.000000000 +0200=0A@@ -10,6 +10,7 @@=0A #include <linux/ax25.=
h>=0A #include <linux/spinlock.h>=0A #include <linux/timer.h>=0A+#include <=
linux/list.h>=0A #include <asm/atomic.h>=0A =0A #define	AX25_T1CLAMPLO  		1=
=0A@@ -180,7 +181,7 @@=0A } ax25_dev;=0A =0A typedef struct ax25_cb {=0A-	s=
truct ax25_cb		*next;=0A+	struct hlist_node	ax25_node;=0A 	ax25_address		so=
urce_addr, dest_addr;=0A 	ax25_digi		*digipeat;=0A 	ax25_dev		*ax25_dev;=0A=
@@ -197,17 +198,32 @@=0A 	struct sk_buff_head	ack_queue;=0A 	struct sk_buff=
_head	frag_queue;=0A 	unsigned char		window;=0A-	struct timer_list	timer;=
=0A+	struct timer_list	timer, dtimer;=0A 	struct sock		*sk;		/* Backlink to=
 socket */=0A+	atomic_t		refcount;=0A } ax25_cb;=0A =0A #define ax25_sk(__s=
k) ((ax25_cb *)(__sk)->sk_protinfo)=0A =0A+#define ax25_for_each(__ax25, no=
de, list) \=0A+	hlist_for_each_entry(__ax25, node, list, ax25_node)=0A+=0A+=
#define ax25_cb_hold(__ax25) \=0A+	atomic_inc(&((__ax25)->refcount))=0A+=0A=
+static __inline__ void ax25_cb_put(ax25_cb *ax25)=0A+{=0A+	if (atomic_dec_=
and_test(&ax25->refcount)) {=0A+		if (ax25->digipeat)=0A+			kfree(ax25->dig=
ipeat);=0A+		kfree(ax25);=0A+	}=0A+}=0A+=0A /* af_ax25.c */=0A-extern ax25_=
cb *ax25_list;=0A+extern struct hlist_head ax25_list;=0A extern spinlock_t =
ax25_list_lock;=0A-extern void ax25_free_cb(ax25_cb *);=0A-extern void ax25=
_insert_socket(ax25_cb *);=0A+extern void ax25_cb_add(ax25_cb *);=0A struct=
 sock *ax25_find_listener(ax25_address *, int, struct net_device *, int);=
=0A struct sock *ax25_get_socket(ax25_address *, ax25_address *, int);=0A e=
xtern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *, st=
ruct net_device *);=0A--- linux-2.6.0-test3/include/net/netrom.h	2003-08-09=
 06:37:18.000000000 +0200=0A+++ linux-2.6.0-test1.rxq3/include/net/netrom.h=
	2003-07-24 21:01:59.000000000 +0200=0A@@ -7,6 +7,7 @@=0A #ifndef _NETROM_H=
=0A #define _NETROM_H =0A #include <linux/netrom.h>=0A+#include <linux/list=
.h>=0A =0A #define	NR_NETWORK_LEN			15=0A #define	NR_TRANSPORT_LEN		5=0A@@ =
-77,16 +78,17 @@=0A #define nr_sk(__sk) ((nr_cb *)(__sk)->sk_protinfo)=0A =
=0A struct nr_neigh {=0A-	struct nr_neigh *next;=0A-	ax25_address    callsi=
gn;=0A-	ax25_digi       *digipeat;=0A-	ax25_cb		*ax25;=0A-	struct net_devic=
e   *dev;=0A-	unsigned char   quality;=0A-	unsigned char   locked;=0A-	unsi=
gned short  count;=0A-	unsigned int    number;=0A-	unsigned char	failed;=0A=
+	struct hlist_node	neigh_node;=0A+	ax25_address		callsign;=0A+	ax25_digi		=
*digipeat;=0A+	ax25_cb			*ax25;=0A+	struct net_device	*dev;=0A+	unsigned ch=
ar		quality;=0A+	unsigned char		locked;=0A+	unsigned short		count;=0A+	unsi=
gned int		number;=0A+	unsigned char		failed;=0A+	atomic_t		refcount;=0A };=
=0A =0A struct nr_route {=0A@@ -96,14 +98,74 @@=0A };=0A =0A struct nr_node=
 {=0A-	struct nr_node  *next;=0A-	ax25_address    callsign;=0A-	char		mnemo=
nic[7];=0A-	unsigned char   which;=0A-	unsigned char   count;=0A-	struct nr=
_route routes[3];=0A+	struct hlist_node	node_node;=0A+	ax25_address		callsi=
gn;=0A+	char			mnemonic[7];=0A+	unsigned char		which;=0A+	unsigned char		co=
unt;=0A+	struct nr_route		routes[3];=0A+	atomic_t		refcount;=0A+	spinlock_t=
		node_lock;=0A };=0A =0A+/************************************************=
*********************=0A+ *	nr_node & nr_neigh lists, refcounting and locki=
ng=0A+ ********************************************************************=
*/=0A+=0A+extern struct hlist_head nr_node_list;=0A+extern struct hlist_hea=
d nr_neigh_list;=0A+=0A+#define nr_node_hold(__nr_node) \=0A+	atomic_inc(&(=
(__nr_node)->refcount))=0A+=0A+static __inline__ void nr_node_put(struct nr=
_node *nr_node)=0A+{=0A+	if (atomic_dec_and_test(&nr_node->refcount)) {=0A+=
		kfree(nr_node);=0A+	}=0A+}=0A+=0A+#define nr_neigh_hold(__nr_neigh) \=0A+=
	atomic_inc(&((__nr_neigh)->refcount))=0A+=0A+static __inline__ void nr_nei=
gh_put(struct nr_neigh *nr_neigh)=0A+{=0A+	if (atomic_dec_and_test(&nr_neig=
h->refcount)) {=0A+		if (nr_neigh->digipeat !=3D NULL)=0A+			kfree(nr_neigh=
->digipeat);=0A+		kfree(nr_neigh);=0A+	}=0A+}=0A+=0A+/* nr_node_lock and nr=
_node_unlock also hold/put the node's refcounter.=0A+ */=0A+static __inline=
__ void nr_node_lock(struct nr_node *nr_node)=0A+{=0A+	nr_node_hold(nr_node=
);=0A+	spin_lock_bh(&nr_node->node_lock);=0A+}=0A+=0A+static __inline__ voi=
d nr_node_unlock(struct nr_node *nr_node)=0A+{=0A+	spin_unlock_bh(&nr_node-=
>node_lock);=0A+	nr_node_put(nr_node);=0A+}=0A+=0A+#define nr_neigh_for_eac=
h(__nr_neigh, node, list) \=0A+	hlist_for_each_entry(__nr_neigh, node, list=
, neigh_node)=0A+=0A+#define nr_neigh_for_each_safe(__nr_neigh, node, node2=
, list) \=0A+	hlist_for_each_entry_safe(__nr_neigh, node, node2, list, neig=
h_node)=0A+=0A+#define nr_node_for_each(__nr_node, node, list) \=0A+	hlist_=
for_each_entry(__nr_node, node, list, node_node)=0A+=0A+#define nr_node_for=
_each_safe(__nr_node, node, node2, list) \=0A+	hlist_for_each_entry_safe(__=
nr_node, node, node2, list, node_node)=0A+=0A+=0A+/************************=
*********************************************/=0A+=0A /* af_netrom.c */=0A =
extern int  sysctl_netrom_default_path_quality;=0A extern int  sysctl_netro=
m_obsolescence_count_initialiser;=0A
--AWniW0JNca5xppdA--
