From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: [PATCH] ax25 changes
Date: Wed, 20 Aug 2003 20:45:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820204518.C5568@jeroen.pe1rxq.ampr.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org> <20030812135655.7334887b.shemminger@osdl.org> <20030812230951.E28977@jeroen.pe1rxq.ampr.org> <20030812153901.6e700dcb.shemminger@osdl.org> <20030813010301.K28977@jeroen.pe1rxq.ampr.org> <20030812172151.7de0c950.shemminger@osdl.org> <20030813031159.6c6c9629.davem@redhat.com> <20030813173446.A2604@jeroen.pe1rxq.ampr.org> <20030813084252.7b667fb8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AWniW0JNca5xppdA"
Content-Transfer-Encoding: 8bit
Cc: shemminger@osdl.org, linux-hams@vger.kernel.org, ralf@linux-mips.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S . Miller" <davem@redhat.com>
In-Reply-To: <20030813084252.7b667fb8.davem@redhat.com>; from davem@redhat.com on Wed, Aug 13, 2003 at 17:42:52 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AWniW0JNca5xppdA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

On 2003.08.13 17:42:52 +0200 David S. Miller wrote:
> On Wed, 13 Aug 2003 17:34:46 +0200
> Jeroen Vreeken <pe1rxq@amsat.org> wrote:
> 
> > This is my last patch (rxq4) plus Stephen's last three (dev locking,
> > setsockopt, seq_file)
> 
> Please don't combine the patches, I want the each individual
> patch with the author and his comments for that change.
> 
> If you combine all the work, this information gets lost.

After posting this mega patch I have been away for some days....

Fortunatly Stephen already reduced the amount of work by doing the netrom
stuff.
The next four patches are the remaining ax25 (and a litle netrom) patches:


ax25_cb-lock.diff

	This is the biggest one:
	- ax25_cb's use refcounting
	- the ax25_cb list uses hlists
	- Lots of socket locking.
	This patch touches almost everything in the ax25 directory.

hard_header.diff

	Makes ax25_subr.c use the devices hard_header_len instead of
	some predicted worst case.
	(also contains a small socket locking patch)

iface-lists.diff

	Fixes the list usage and list locking in ax25_iface.c

netrom-refcnt.diff

	Small changes to netrom as a result of the ax25_cb refcounting.


Jeroen

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="netrom-refcnt.diff"

--- linux-2.6.0-test3.bk/net/netrom/nr_route.c	2003-08-20 19:17:18.000000000 +0200
+++ linux-2.6.0-test3.bk.rxq/net/netrom/nr_route.c	2003-08-20 19:34:51.000000000 +0200
@@ -735,7 +735,7 @@
 	if (nr_neigh == NULL) return;
 
 	nr_neigh->ax25 = NULL;
-	// ax25_cb_put(ax25);
+	ax25_cb_put(ax25);
 
 	if (++nr_neigh->failed < sysctl_netrom_link_fails_count) {
 		nr_neigh_put(nr_neigh);
@@ -829,7 +829,7 @@
 	ax25s = ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);
 	if (nr_neigh->ax25 && ax25s) {
 		/* We were already holding this ax25_cb */
-		// ax25_cb_put(ax25s);
+		ax25_cb_put(ax25s);
 	}
 	nr_neigh->ax25 = ax25s;
 

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=ISO-8859-1
Content-Disposition: attachment; filename="ax25_cb-lock.diff"
Content-Transfer-Encoding: quoted-printable

diff -ruN linux-2.6.0-test3.bk/net/ax25/af_ax25.c linux-2.6.0-test3.bk.rxq/=
net/ax25/af_ax25.c=0A--- linux-2.6.0-test3.bk/net/ax25/af_ax25.c	2003-08-20=
 19:00:29.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/af_ax25.c=
	2003-08-20 19:58:29.000000000 +0200=0A@@ -51,54 +51,27 @@=0A =0A =0A =0A-a=
x25_cb *ax25_list;=0A+HLIST_HEAD(ax25_list);=0A spinlock_t ax25_list_lock =
=3D SPIN_LOCK_UNLOCKED;=0A =0A static struct proto_ops ax25_proto_ops;=0A =
=0A-/*=0A- *	Free an allocated ax25 control block. This is done to centrali=
se=0A- *	the MOD count code.=0A- */=0A-void ax25_free_cb(ax25_cb *ax25)=0A-=
{=0A-	if (ax25->digipeat !=3D NULL) {=0A-		kfree(ax25->digipeat);=0A-		ax25=
->digipeat =3D NULL;=0A-	}=0A-=0A-	kfree(ax25);=0A-}=0A-=0A static void ax2=
5_free_sock(struct sock *sk)=0A {=0A-	ax25_free_cb(ax25_sk(sk));=0A+	ax25_c=
b_put(ax25_sk(sk));=0A }=0A =0A /*=0A  *	Socket removal during an interrupt=
 is now safe.=0A  */=0A-static void ax25_remove_socket(ax25_cb *ax25)=0A+st=
atic void ax25_cb_del(ax25_cb *ax25)=0A {=0A-	ax25_cb *s;=0A-=0A-	spin_lock=
_bh(&ax25_list_lock);=0A-	if ((s =3D ax25_list) =3D=3D ax25) {=0A-		ax25_li=
st =3D s->next;=0A+	if (!hlist_unhashed(&ax25->ax25_node)) {=0A+		spin_lock=
_bh(&ax25_list_lock);=0A+		hlist_del_init(&ax25->ax25_node);=0A 		spin_unlo=
ck_bh(&ax25_list_lock);=0A-		return;=0A-	}=0A-=0A-	while (s !=3D NULL && s-=
>next !=3D NULL) {=0A-		if (s->next =3D=3D ax25) {=0A-			s->next =3D ax25->=
next;=0A-			spin_unlock_bh(&ax25_list_lock);=0A-			return;=0A-		}=0A-=0A-		=
s =3D s->next;=0A+		ax25_cb_put(ax25);=0A 	}=0A-	spin_unlock_bh(&ax25_list_=
lock);=0A }=0A =0A /*=0A@@ -108,12 +81,13 @@=0A {=0A 	ax25_dev *ax25_dev;=
=0A 	ax25_cb *s;=0A+	struct hlist_node *node;=0A =0A 	if ((ax25_dev =3D ax2=
5_dev_ax25dev(dev)) =3D=3D NULL)=0A 		return;=0A =0A 	spin_lock_bh(&ax25_li=
st_lock);=0A-	for (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_=
for_each(s, node, &ax25_list) {=0A 		if (s->ax25_dev =3D=3D ax25_dev) {=0A =
			s->ax25_dev =3D NULL;=0A 			ax25_disconnect(s, ENETUNREACH);=0A@@ -153,1=
1 +127,11 @@=0A /*=0A  *	Add a socket to the bound sockets list.=0A  */=0A-=
void ax25_insert_socket(ax25_cb *ax25)=0A+void ax25_cb_add(ax25_cb *ax25)=
=0A {=0A 	spin_lock_bh(&ax25_list_lock);=0A-	ax25->next =3D ax25_list;=0A-	=
ax25_list  =3D ax25;=0A+	ax25_cb_hold(ax25);=0A+	hlist_add_head(&ax25->ax25=
_node, &ax25_list);=0A 	spin_unlock_bh(&ax25_list_lock);=0A }=0A =0A@@ -169=
,17 +143,18 @@=0A 	struct net_device *dev, int type)=0A {=0A 	ax25_cb *s;=
=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	fo=
r (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node=
, &ax25_list) {=0A 		if ((s->iamdigi && !digi) || (!s->iamdigi && digi))=0A=
 			continue;=0A 		if (s->sk && !ax25cmp(&s->source_addr, addr) &&=0A 		   =
 s->sk->sk_type =3D=3D type && s->sk->sk_state =3D=3D TCP_LISTEN) {=0A 			/=
* If device is null we match any device */=0A 			if (s->ax25_dev =3D=3D NUL=
L || s->ax25_dev->dev =3D=3D dev) {=0A+				sock_hold(s->sk);=0A 				spin_un=
lock_bh(&ax25_list_lock);=0A-=0A 				return s->sk;=0A 			}=0A 		}=0A@@ -197=
,9 +172,10 @@=0A {=0A 	struct sock *sk =3D NULL;=0A 	ax25_cb *s;=0A+	struct=
 hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (s =3D ax=
25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_each(s, node, &ax25_lis=
t) {=0A 		if (s->sk && !ax25cmp(&s->source_addr, my_addr) &&=0A 		    !ax25=
cmp(&s->dest_addr, dest_addr) &&=0A 		    s->sk->sk_type =3D=3D type) {=0A@=
@ -223,9 +199,10 @@=0A 	ax25_digi *digi, struct net_device *dev)=0A {=0A 	a=
x25_cb *s;=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_loc=
k);=0A-	for (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	ax25_for_ea=
ch(s, node, &ax25_list) {=0A 		if (s->sk && s->sk->sk_type !=3D SOCK_SEQPAC=
KET)=0A 			continue;=0A 		if (s->ax25_dev =3D=3D NULL)=0A@@ -240,6 +217,7 @=
@=0A 				if (s->digipeat !=3D NULL && s->digipeat->ndigi !=3D 0)=0A 					co=
ntinue;=0A 			}=0A+			ax25_cb_hold(s);=0A 			spin_unlock_bh(&ax25_list_lock=
);=0A =0A 			return s;=0A@@ -257,9 +235,10 @@=0A {=0A 	struct sock *sk =3D =
NULL;=0A 	ax25_cb *s;=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax=
25_list_lock);=0A-	for (s =3D ax25_list; s !=3D NULL; s =3D s->next) {=0A+	=
ax25_for_each(s, node, &ax25_list) {=0A 		if (s->sk !=3D NULL && ax25cmp(&s=
->source_addr, addr) =3D=3D 0 &&=0A 		    s->sk->sk_type =3D=3D SOCK_RAW) {=
=0A 			sk =3D s->sk;=0A@@ -267,6 +246,7 @@=0A 			break;=0A 		}=0A 	}=0A+=0A=
 	spin_unlock_bh(&ax25_list_lock);=0A =0A 	return sk;=0A@@ -299,7 +279,16 @=
@=0A  */=0A static void ax25_destroy_timer(unsigned long data)=0A {=0A-	ax2=
5_destroy_socket((ax25_cb *)data);=0A+	ax25_cb *ax25=3D(ax25_cb *)data;=0A+=
	struct sock *sk;=0A+	=0A+	sk=3Dax25->sk;=0A+	=0A+	bh_lock_sock(sk);=0A+	so=
ck_hold(sk);=0A+	ax25_destroy_socket(ax25);=0A+	bh_unlock_sock(sk);=0A+	soc=
k_put(sk);=0A }=0A =0A /*=0A@@ -312,7 +301,7 @@=0A {=0A 	struct sk_buff *sk=
b;=0A =0A-	ax25_remove_socket(ax25);=0A+	ax25_cb_del(ax25);=0A =0A 	ax25_st=
op_heartbeat(ax25);=0A 	ax25_stop_t1timer(ax25);=0A@@ -337,22 +326,27 @@=0A=
 =0A 			kfree_skb(skb);=0A 		}=0A+		while ((skb =3D skb_dequeue(&ax25->sk->=
sk_write_queue)) !=3D NULL) {=0A+			kfree_skb(skb);=0A+		}=0A 	}=0A =0A 	if=
 (ax25->sk !=3D NULL) {=0A 		if (atomic_read(&ax25->sk->sk_wmem_alloc) ||=
=0A 		    atomic_read(&ax25->sk->sk_rmem_alloc)) {=0A 			/* Defer: outstand=
ing buffers */=0A-			init_timer(&ax25->timer);=0A-			ax25->timer.expires  =
=3D jiffies + 10 * HZ;=0A-			ax25->timer.function =3D ax25_destroy_timer;=
=0A-			ax25->timer.data     =3D (unsigned long)ax25;=0A-			add_timer(&ax25-=
>timer);=0A+			init_timer(&ax25->dtimer);=0A+			ax25->dtimer.expires  =3D j=
iffies + 2 * HZ;=0A+			ax25->dtimer.function =3D ax25_destroy_timer;=0A+			=
ax25->dtimer.data     =3D (unsigned long)ax25;=0A+			add_timer(&ax25->dtime=
r);=0A 		} else {=0A-			sock_put(ax25->sk);=0A+			struct sock *sk=3Dax25->s=
k;=0A+			ax25->sk=3DNULL;=0A+			sock_put(sk);=0A 		}=0A 	} else {=0A-		ax25=
_free_cb(ax25);=0A+		ax25_cb_put(ax25);=0A 	}=0A }=0A =0A@@ -421,7 +415,7 @=
@=0A =0A   	case AX25_N2:=0A   		if (ax25_ctl.arg < 1 || ax25_ctl.arg > 31)=
=0A-  			return -EINVAL;=0A+			return -EINVAL;=0A   		ax25->n2count =3D 0;=
=0A   		ax25->n2 =3D ax25_ctl.arg;=0A   		break;=0A@@ -448,7 +442,7 @@=0A  =
 		return -EINVAL;=0A 	  }=0A =0A-	  return 0;=0A+	return 0;=0A }=0A =0A /*=
=0A@@ -507,6 +501,7 @@=0A 		return NULL;=0A =0A 	memset(ax25, 0x00, sizeof(=
*ax25));=0A+	atomic_set(&ax25->refcount, 1);=0A =0A 	skb_queue_head_init(&a=
x25->write_queue);=0A 	skb_queue_head_init(&ax25->frag_queue);=0A@@ -655,6 =
+650,7 @@=0A 		   (sock->state !=3D SS_UNCONNECTED ||=0A 		    sk->sk_state=
 =3D=3D TCP_LISTEN)) {=0A 			res =3D -EADDRNOTAVAIL;=0A+			dev_put(dev);=0A=
 			break;=0A 		}=0A =0A@@ -877,7 +873,7 @@=0A 		break;=0A 	default:=0A 		s=
k_free(sk);=0A-		ax25_free_cb(ax25);=0A+		ax25_cb_put(ax25);=0A 		return NU=
LL;=0A 	}=0A =0A@@ -937,6 +933,7 @@=0A 	if (sk =3D=3D NULL)=0A 		return 0;=
=0A =0A+	sock_hold(sk);=0A 	lock_sock(sk);=0A 	ax25 =3D ax25_sk(sk);=0A =0A=
@@ -944,13 +941,15 @@=0A 		switch (ax25->state) {=0A 		case AX25_STATE_0:=
=0A 			ax25_disconnect(ax25, 0);=0A-			goto drop;=0A+			ax25_destroy_socket=
(ax25);=0A+			break;=0A =0A 		case AX25_STATE_1:=0A 		case AX25_STATE_2:=0A=
 			ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);=0A 			ax=
25_disconnect(ax25, 0);=0A-			goto drop;=0A+			ax25_destroy_socket(ax25);=
=0A+			break;=0A =0A 		case AX25_STATE_3:=0A 		case AX25_STATE_4:=0A@@ -993=
,16 +992,14 @@=0A 		sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A 		sk->sk_state_c=
hange(sk);=0A 		sock_set_flag(sk, SOCK_DEAD);=0A-		goto drop;=0A+		ax25_des=
troy_socket(ax25);=0A 	}=0A =0A 	sock->sk   =3D NULL;=0A 	sk->sk_socket =3D=
 NULL;	/* Not used, but we should do this */=0A 	release_sock(sk);=0A-	retu=
rn 0;=0A- drop:=0A-	release_sock(sk);=0A-	ax25_destroy_socket(ax25);=0A+	so=
ck_put(sk);=0A+=0A 	return 0;=0A }=0A =0A@@ -1077,7 +1074,7 @@=0A 		ax25_fi=
llin_cb(ax25, ax25_dev);=0A =0A done:=0A-	ax25_insert_socket(ax25);=0A+	ax2=
5_cb_add(ax25);=0A 	sk->sk_zapped =3D 0;=0A =0A out:=0A@@ -1093,7 +1090,7 @=
@=0A 	int addr_len, int flags)=0A {=0A 	struct sock *sk =3D sock->sk;=0A-	a=
x25_cb *ax25 =3D ax25_sk(sk);=0A+	ax25_cb *ax25 =3D ax25_sk(sk), *ax25t;=0A=
 	struct full_sockaddr_ax25 *fsa =3D (struct full_sockaddr_ax25 *)uaddr;=0A=
 	ax25_digi *digi =3D NULL;=0A 	int ct =3D 0, err =3D 0;=0A@@ -1199,7 +1196=
,7 @@=0A 			goto out;=0A =0A 		ax25_fillin_cb(ax25, ax25->ax25_dev);=0A-		a=
x25_insert_socket(ax25);=0A+		ax25_cb_add(ax25);=0A 	} else {=0A 		if (ax25=
->ax25_dev =3D=3D NULL) {=0A 			err =3D -EHOSTUNREACH;=0A@@ -1208,11 +1205,=
12 @@=0A 	}=0A =0A 	if (sk->sk_type =3D=3D SOCK_SEQPACKET &&=0A-	    ax25_f=
ind_cb(&ax25->source_addr, &fsa->fsa_ax25.sax25_call, digi,=0A-		    	 ax25=
->ax25_dev->dev)) {=0A+	    (ax25t=3Dax25_find_cb(&ax25->source_addr, &fsa-=
>fsa_ax25.sax25_call, digi,=0A+		    	 ax25->ax25_dev->dev))) {=0A 		if (di=
gi !=3D NULL)=0A 			kfree(digi);=0A 		err =3D -EADDRINUSE;		/* Already such=
 a connection */=0A+		ax25_cb_put(ax25t);=0A 		goto out;=0A 	}=0A =0A@@ -12=
73,6 +1271,8 @@=0A 				lock_sock(sk);=0A 				continue;=0A 			}=0A+			curren=
t->state =3D TASK_RUNNING;=0A+			remove_wait_queue(sk->sk_sleep, &wait);=0A=
 			return -ERESTARTSYS;=0A 		}=0A 		current->state =3D TASK_RUNNING;=0A@@ =
-1288,10 +1288,11 @@=0A =0A 	sock->state =3D SS_CONNECTED;=0A =0A+	err=3D0;=
=0A out:=0A 	release_sock(sk);=0A =0A-	return 0;=0A+	return err;=0A }=0A =
=0A =0A@@ -1331,15 +1332,18 @@=0A 		if (skb)=0A 			break;=0A =0A-		current-=
>state =3D TASK_INTERRUPTIBLE;=0A 		release_sock(sk);=0A+		current->state =
=3D TASK_INTERRUPTIBLE;=0A 		if (flags & O_NONBLOCK)=0A 			return -EWOULDBL=
OCK;=0A 		if (!signal_pending(tsk)) {=0A 			schedule();=0A+			current->stat=
e =3D TASK_RUNNING;=0A 			lock_sock(sk);=0A 			continue;=0A 		}=0A+		curren=
t->state =3D TASK_RUNNING;=0A+		remove_wait_queue(sk->sk_sleep, &wait);=0A =
		return -ERESTARTSYS;=0A 	}=0A 	current->state =3D TASK_RUNNING;=0A@@ -151=
9,7 +1523,7 @@=0A 	SOCK_DEBUG(sk, "AX.25: sendto: building packet.\n");=0A =
=0A 	/* Assume the worst case */=0A-	size =3D len + 3 + ax25_addr_size(dp) =
+ AX25_BPQ_HEADER_LEN;=0A+	size =3D len + ax25->ax25_dev->dev->hard_header_=
len;=0A =0A 	skb =3D sock_alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTW=
AIT, &err);=0A 	if (skb =3D=3D NULL)=0A@@ -1780,7 +1784,7 @@=0A =0A 		/* ol=
d structure? */=0A 		if (cmd =3D=3D SIOCAX25GETINFOOLD) {=0A-			static int =
warned;=0A+			static int warned =3D 0;=0A 			if (!warned) {=0A 				printk(K=
ERN_INFO "%s uses old SIOCAX25GETINFO\n",=0A 					current->comm);=0A@@ -184=
5,6 +1849,7 @@=0A 	int len =3D 0;=0A 	off_t pos =3D 0;=0A 	off_t begin =3D =
0;=0A+	struct hlist_node *node;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A =
=0A@@ -1853,7 +1858,7 @@=0A 	 * magic dev src_addr dest_addr,digi1,digi2,..=
 st vs vr va t1 t1 t2 t2 t3 t3 idle idle n2 n2 rtt window paclen Snd-Q Rcv-=
Q inode=0A 	 */=0A =0A-	for (ax25 =3D ax25_list; ax25 !=3D NULL; ax25 =3D a=
x25->next) {=0A+	ax25_for_each(ax25, node, &ax25_list) {=0A 		len +=3D spri=
ntf(buffer+len, "%8.8lx %s %s%s ",=0A 				(long) ax25,=0A 				ax25->ax25_de=
v =3D=3D NULL? "???" : ax25->ax25_dev->dev->name,=0A@@ -1882,10 +1887,12 @@=
=0A 			ax25->paclen);=0A =0A 		if (ax25->sk !=3D NULL) {=0A+			bh_lock_sock=
(ax25->sk);=0A 			len +=3D sprintf(buffer + len, " %d %d %ld\n",=0A 				ato=
mic_read(&ax25->sk->sk_wmem_alloc),=0A 				atomic_read(&ax25->sk->sk_rmem_a=
lloc),=0A 				ax25->sk->sk_socket !=3D NULL ? SOCK_INODE(ax25->sk->sk_socke=
t)->i_ino : 0L);=0A+			bh_unlock_sock(ax25->sk);=0A 		} else {=0A 			len +=
=3D sprintf(buffer + len, " * * *\n");=0A 		}=0Adiff -ruN linux-2.6.0-test3=
.bk/net/ax25/ax25_ds_in.c linux-2.6.0-test3.bk.rxq/net/ax25/ax25_ds_in.c=0A=
--- linux-2.6.0-test3.bk/net/ax25/ax25_ds_in.c	2003-08-20 19:00:30.00000000=
0 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_ds_in.c	2003-08-20 19:=
58:29.000000000 +0200=0A@@ -65,6 +65,7 @@=0A 		ax25->state   =3D AX25_STATE=
_3;=0A 		ax25->n2count =3D 0;=0A 		if (ax25->sk !=3D NULL) {=0A+			bh_lock_=
sock(ax25->sk);=0A 			ax25->sk->sk_state =3D TCP_ESTABLISHED;=0A 			/*=0A 	=
		 * For WAIT_SABM connections we will produce an accept=0A@@ -72,6 +73,7 @=
@=0A 			 */=0A 			if (!sock_flag(ax25->sk, SOCK_DEAD))=0A 				ax25->sk->sk_=
state_change(ax25->sk);=0A+			bh_unlock_sock(ax25->sk);=0A 		}=0A 		ax25_da=
ma_on(ax25);=0A =0Adiff -ruN linux-2.6.0-test3.bk/net/ax25/ax25_ds_subr.c l=
inux-2.6.0-test3.bk.rxq/net/ax25/ax25_ds_subr.c=0A--- linux-2.6.0-test3.bk/=
net/ax25/ax25_ds_subr.c	2003-08-20 19:00:30.000000000 +0200=0A+++ linux-2.6=
.0-test3.bk.rxq/net/ax25/ax25_ds_subr.c	2003-08-20 19:58:29.000000000 +0200=
=0A@@ -40,6 +40,7 @@=0A void ax25_ds_enquiry_response(ax25_cb *ax25)=0A {=
=0A 	ax25_cb *ax25o;=0A+	struct hlist_node *node;=0A =0A 	/* Please note th=
at neither DK4EG=B4s nor DG2FEF=B4s=0A 	 * DAMA spec mention the following =
behaviour as seen=0A@@ -80,7 +81,7 @@=0A 	ax25_ds_set_timer(ax25->ax25_dev)=
;=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25o =3D ax25_list; ax25=
o !=3D NULL; ax25o =3D ax25o->next) {=0A+	ax25_for_each(ax25o, node, &ax25_=
list) {=0A 		if (ax25o =3D=3D ax25)=0A 			continue;=0A =0A@@ -160,9 +161,10=
 @@=0A {=0A 	ax25_cb *ax25;=0A 	int res =3D 0;=0A+	struct hlist_node *node;=
=0A =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25 =3D ax25_list; ax25 !=
=3D NULL ; ax25 =3D ax25->next)=0A+	ax25_for_each(ax25, node, &ax25_list)=
=0A 		if (ax25->ax25_dev =3D=3D ax25_dev && (ax25->condition & AX25_COND_DA=
MA_MODE) && ax25->state > AX25_STATE_1) {=0A 			res =3D 1;=0A 			break;=0Ad=
iff -ruN linux-2.6.0-test3.bk/net/ax25/ax25_ds_timer.c linux-2.6.0-test3.bk=
.rxq/net/ax25/ax25_ds_timer.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_ds_t=
imer.c	2003-08-20 19:00:29.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/n=
et/ax25/ax25_ds_timer.c	2003-08-20 19:58:29.000000000 +0200=0A@@ -74,6 +74,=
7 @@=0A {=0A 	ax25_dev *ax25_dev =3D (struct ax25_dev *) arg;=0A 	ax25_cb *=
ax25;=0A+	struct hlist_node *node;=0A =0A 	if (ax25_dev =3D=3D NULL || !ax2=
5_dev->dama.slave)=0A 		return;			/* Yikes! */=0A@@ -84,7 +85,7 @@=0A 	}=0A=
 =0A 	spin_lock_bh(&ax25_list_lock);=0A-	for (ax25=3Dax25_list; ax25 !=3D N=
ULL; ax25 =3D ax25->next) {=0A+	ax25_for_each(ax25, node, &ax25_list) {=0A =
		if (ax25->ax25_dev !=3D ax25_dev || !(ax25->condition & AX25_COND_DAMA_MO=
DE))=0A 			continue;=0A =0A@@ -98,15 +99,26 @@=0A =0A void ax25_ds_heartbea=
t_expiry(ax25_cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk;=0A+=0A+	if (sk=
)=0A+		bh_lock_sock(sk);=0A+=0A 	switch (ax25->state) {=0A =0A 	case AX25_S=
TATE_0:=0A 		/* Magic here: If we listen() and a new link dies before it=0A=
 		   is accepted() it isn't 'dead' so doesn't get removed. */=0A-		if (!ax=
25->sk || sock_flag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax25->sk->sk_state=
 =3D=3D TCP_LISTEN &&=0A-		     sock_flag(ax25->sk, SOCK_DEAD))) {=0A-			ax=
25_destroy_socket(ax25);=0A+		if (!sk || sock_flag(sk, SOCK_DESTROY) ||=0A+=
		    (sk->sk_state =3D=3D TCP_LISTEN &&=0A+		     sock_flag(sk, SOCK_DEAD)=
)) {=0A+			if (sk) {=0A+				sock_hold(sk);=0A+				ax25_destroy_socket(ax25)=
;=0A+				sock_put(sk);=0A+				bh_unlock_sock(sk);=0A+			} else=0A+				ax25_=
destroy_socket(ax25);=0A 			return;=0A 		}=0A 		break;=0A@@ -115,9 +127,9 @=
@=0A 		/*=0A 		 * Check the state of the receive buffer.=0A 		 */=0A-		if (=
ax25->sk !=3D NULL) {=0A-			if (atomic_read(&ax25->sk->sk_rmem_alloc) <=0A-=
			    (ax25->sk->sk_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) {=0A+			if (atom=
ic_read(&sk->sk_rmem_alloc) <=0A+			    (sk->sk_rcvbuf / 2) &&=0A 			    (a=
x25->condition & AX25_COND_OWN_RX_BUSY)) {=0A 				ax25->condition &=3D ~AX2=
5_COND_OWN_RX_BUSY;=0A 				ax25->condition &=3D ~AX25_COND_ACK_PENDING;=0A@=
@ -127,6 +139,9 @@=0A 		break;=0A 	}=0A =0A+	if (sk)=0A+		bh_unlock_sock(sk=
);=0A+=0A 	ax25_start_heartbeat(ax25);=0A }=0A =0A@@ -157,6 +172,7 @@=0A 	a=
x25_stop_t3timer(ax25);=0A =0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock=
(ax25->sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_er=
r       =3D 0;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -164,6 +=
180,7 @@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 			sock_set_flag(ax2=
5->sk, SOCK_DEAD);=0A 		}=0A+		bh_lock_sock(ax25->sk);=0A 	}=0A }=0A =0Adif=
f -ruN linux-2.6.0-test3.bk/net/ax25/ax25_in.c linux-2.6.0-test3.bk.rxq/net=
/ax25/ax25_in.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_in.c	2003-08-20 19=
:00:29.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_in.c	20=
03-08-20 19:58:29.000000000 +0200=0A@@ -147,6 +147,7 @@=0A 	}=0A =0A 	if (a=
x25->sk !=3D NULL && ax25->ax25_dev->values[AX25_VALUES_CONMODE] =3D=3D 2) =
{=0A+		bh_lock_sock(ax25->sk);=0A 		if ((!ax25->pidincl && ax25->sk->sk_pro=
tocol =3D=3D pid) ||=0A 		    ax25->pidincl) {=0A 			if (sock_queue_rcv_skb=
(ax25->sk, skb) =3D=3D 0)=0A@@ -154,6 +155,7 @@=0A 			else=0A 				ax25->con=
dition |=3D AX25_COND_OWN_RX_BUSY;=0A 		}=0A+		bh_unlock_sock(ax25->sk);=0A=
 	}=0A =0A 	return queued;=0A@@ -329,6 +331,7 @@=0A 		if (ax25_process_rx_f=
rame(ax25, skb, type, dama) =3D=3D 0)=0A 			kfree_skb(skb);=0A =0A+		ax25_c=
b_put(ax25);=0A 		return 0;=0A 	}=0A =0A@@ -357,11 +360,14 @@=0A 		sk =3D a=
x25_find_listener(next_digi, 1, dev, SOCK_SEQPACKET);=0A =0A 	if (sk !=3D N=
ULL) {=0A+		bh_lock_sock(sk);=0A 		if (sk->sk_ack_backlog =3D=3D sk->sk_max=
_ack_backlog ||=0A 		    (make =3D ax25_make_new(sk, ax25_dev)) =3D=3D NULL=
) {=0A 			if (mine)=0A 				ax25_return_dm(dev, &src, &dest, &dp);=0A 			kfr=
ee_skb(skb);=0A+			bh_unlock_sock(sk);=0A+			sock_put(sk);=0A =0A 			return=
 0;=0A 		}=0A@@ -374,6 +380,8 @@=0A 		make->sk_pair  =3D sk;=0A =0A 		sk->s=
k_ack_backlog++;=0A+		bh_unlock_sock(sk);=0A+		sock_put(sk);=0A 	} else {=
=0A 		if (!mine) {=0A 			kfree_skb(skb);=0A@@ -429,7 +437,7 @@=0A =0A 	ax25=
->state =3D AX25_STATE_3;=0A =0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_add=
(ax25);=0A =0A 	ax25_start_heartbeat(ax25);=0A 	ax25_start_t3timer(ax25);=
=0Adiff -ruN linux-2.6.0-test3.bk/net/ax25/ax25_ip.c linux-2.6.0-test3.bk.r=
xq/net/ax25/ax25_ip.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_ip.c	2003-08=
-20 19:00:29.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_i=
p.c	2003-08-20 19:58:29.000000000 +0200=0A@@ -107,6 +107,7 @@=0A 	ax25_addr=
ess *src, *dst;=0A 	ax25_dev *ax25_dev;=0A 	ax25_route _route, *route =3D &=
_route;=0A+	ax25_cb *ax25;=0A =0A 	dst =3D (ax25_address *)(bp + 1);=0A 	sr=
c =3D (ax25_address *)(bp + 8);=0A@@ -167,9 +168,14 @@=0A 			skb_pull(oursk=
b, AX25_HEADER_LEN - 1);	/* Keep PID */=0A 			ourskb->nh.raw =3D ourskb->da=
ta;=0A =0A-			ax25_send_frame(ourskb, ax25_dev->values[AX25_VALUES_PACLEN],=
 &src_c,=0A-&dst_c, route->digipeat, dev);=0A-=0A+			ax25=3Dax25_send_frame=
(=0A+			    ourskb, =0A+			    ax25_dev->values[AX25_VALUES_PACLEN], =0A+		=
	    &src_c,=0A+			    &dst_c, route->digipeat, dev);=0A+			if (ax25) {=0A+=
				ax25_cb_put(ax25);=0A+			}=0A 			goto put;=0A 		}=0A 	}=0Adiff -ruN lin=
ux-2.6.0-test3.bk/net/ax25/ax25_out.c linux-2.6.0-test3.bk.rxq/net/ax25/ax2=
5_out.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_out.c	2003-08-20 19:00:30.=
000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_out.c	2003-08-=
20 19:58:29.000000000 +0200=0A@@ -71,7 +71,7 @@=0A =0A 	if (digi !=3D NULL)=
 {=0A 		if ((ax25->digipeat =3D kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) =3D=
=3D NULL) {=0A-			ax25_free_cb(ax25);=0A+			ax25_cb_put(ax25);=0A 			return=
 NULL;=0A 		}=0A 		memcpy(ax25->digipeat, digi, sizeof(ax25_digi));=0A@@ -9=
3,7 +93,7 @@=0A #endif=0A 	}=0A =0A-	ax25_insert_socket(ax25);=0A+	ax25_cb_=
add(ax25);=0A =0A 	ax25->state =3D AX25_STATE_1;=0A =0Adiff -ruN linux-2.6.=
0-test3.bk/net/ax25/ax25_route.c linux-2.6.0-test3.bk.rxq/net/ax25/ax25_rou=
te.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_route.c	2003-08-20 19:00:30.0=
00000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_route.c	2003-08=
-20 19:58:29.000000000 +0200=0A@@ -162,6 +162,7 @@=0A 		if (ax25_rt->digipe=
at !=3D NULL)=0A 			kfree(ax25_rt->digipeat);=0A 		kfree(ax25_rt);=0A+		ret=
urn;=0A 	}=0A =0A 	/*=0A@@ -434,8 +435,11 @@=0A 		ax25_adjust_path(addr, ax=
25->digipeat);=0A 	}=0A =0A-	if (ax25->sk !=3D NULL)=0A+	if (ax25->sk !=3D =
NULL) {=0A+		bh_lock_sock(ax25->sk);=0A 		ax25->sk->sk_zapped =3D 0;=0A+		b=
h_unlock_sock(ax25->sk);=0A+	}=0A =0A put:=0A 	ax25_put_route(ax25_rt);=0Ad=
iff -ruN linux-2.6.0-test3.bk/net/ax25/ax25_std_in.c linux-2.6.0-test3.bk.r=
xq/net/ax25/ax25_std_in.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_std_in.c=
	2003-08-20 19:00:29.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax2=
5/ax25_std_in.c	2003-08-20 19:58:29.000000000 +0200=0A@@ -73,10 +73,12 @@=
=0A 			ax25->state   =3D AX25_STATE_3;=0A 			ax25->n2count =3D 0;=0A 			if =
(ax25->sk !=3D NULL) {=0A+				bh_lock_sock(ax25->sk);=0A 				ax25->sk->sk_s=
tate =3D TCP_ESTABLISHED;=0A 				/* For WAIT_SABM connections we will produ=
ce an accept ready socket here */=0A 				if (!sock_flag(ax25->sk, SOCK_DEAD=
))=0A 					ax25->sk->sk_state_change(ax25->sk);=0A+				bh_unlock_sock(ax25-=
>sk);=0A 			}=0A 		}=0A 		break;=0Adiff -ruN linux-2.6.0-test3.bk/net/ax25/=
ax25_std_timer.c linux-2.6.0-test3.bk.rxq/net/ax25/ax25_std_timer.c=0A--- l=
inux-2.6.0-test3.bk/net/ax25/ax25_std_timer.c	2003-08-20 19:00:29.000000000=
 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_std_timer.c	2003-08-20 =
19:58:29.000000000 +0200=0A@@ -33,14 +33,25 @@=0A =0A void ax25_std_heartbe=
at_expiry(ax25_cb *ax25)=0A {=0A+	struct sock *sk=3Dax25->sk;=0A+	=0A+	if (=
sk)=0A+		bh_lock_sock(sk);=0A+=0A 	switch (ax25->state) {=0A 	case AX25_STA=
TE_0:=0A 		/* Magic here: If we listen() and a new link dies before it=0A 	=
	   is accepted() it isn't 'dead' so doesn't get removed. */=0A-		if (!ax25=
->sk || sock_flag(ax25->sk, SOCK_DESTROY) ||=0A-		    (ax25->sk->sk_state =
=3D=3D TCP_LISTEN &&=0A-		     sock_flag(ax25->sk, SOCK_DEAD))) {=0A-			ax2=
5_destroy_socket(ax25);=0A+		if (!sk || sock_flag(sk, SOCK_DESTROY) ||=0A+	=
	    (sk->sk_state =3D=3D TCP_LISTEN &&=0A+		     sock_flag(sk, SOCK_DEAD))=
) {=0A+			if (sk) {=0A+				sock_hold(sk);=0A+				ax25_destroy_socket(ax25);=
=0A+				bh_unlock_sock(sk);=0A+				sock_put(sk);=0A+			} else=0A+				ax25_d=
estroy_socket(ax25);=0A 			return;=0A 		}=0A 		break;=0A@@ -50,9 +61,9 @@=
=0A 		/*=0A 		 * Check the state of the receive buffer.=0A 		 */=0A-		if (a=
x25->sk !=3D NULL) {=0A-			if (atomic_read(&ax25->sk->sk_rmem_alloc) <=0A-	=
		    (ax25->sk->sk_rcvbuf / 2) &&=0A+		if (sk !=3D NULL) {=0A+			if (atomi=
c_read(&sk->sk_rmem_alloc) <=0A+			    (sk->sk_rcvbuf / 2) &&=0A 			    (ax=
25->condition & AX25_COND_OWN_RX_BUSY)) {=0A 				ax25->condition &=3D ~AX25=
_COND_OWN_RX_BUSY;=0A 				ax25->condition &=3D ~AX25_COND_ACK_PENDING;=0A@@=
 -62,6 +73,9 @@=0A 		}=0A 	}=0A =0A+	if (sk)=0A+		bh_unlock_sock(sk);=0A+=
=0A 	ax25_start_heartbeat(ax25);=0A }=0A =0A@@ -94,6 +108,7 @@=0A 	ax25_sto=
p_t3timer(ax25);=0A =0A 	if (ax25->sk !=3D NULL) {=0A+		bh_lock_sock(ax25->=
sk);=0A 		ax25->sk->sk_state     =3D TCP_CLOSE;=0A 		ax25->sk->sk_err      =
 =3D 0;=0A 		ax25->sk->sk_shutdown |=3D SEND_SHUTDOWN;=0A@@ -101,6 +116,7 @=
@=0A 			ax25->sk->sk_state_change(ax25->sk);=0A 			sock_set_flag(ax25->sk, =
SOCK_DEAD);=0A 		}=0A+		bh_unlock_sock(ax25->sk);=0A 	}=0A }=0A =0Adiff -ru=
N linux-2.6.0-test3.bk/net/ax25/ax25_timer.c linux-2.6.0-test3.bk.rxq/net/a=
x25/ax25_timer.c=0A--- linux-2.6.0-test3.bk/net/ax25/ax25_timer.c	2003-08-2=
0 19:00:30.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_tim=
er.c	2003-08-20 19:58:29.000000000 +0200=0A@@ -141,13 +141,10 @@=0A {=0A 	i=
nt proto =3D AX25_PROTO_STD_SIMPLEX;=0A 	ax25_cb *ax25 =3D (ax25_cb *)param=
;=0A-	struct sock *sk =3D ax25->sk;=0A =0A 	if (ax25->ax25_dev)=0A 		proto =
=3D ax25->ax25_dev->values[AX25_VALUES_PROTOCOL];=0A =0A-	bh_lock_sock(sk);=
=0A-=0A 	switch (proto) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PR=
OTO_STD_DUPLEX:=0A@@ -163,15 +160,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_=
unlock_sock(sk);=0A }=0A =0A static void ax25_t1timer_expiry(unsigned long =
param)=0A {=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D=
 ax25->sk;=0A =0A-	bh_lock_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX2=
5_VALUES_PROTOCOL]) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_=
STD_DUPLEX:=0A@@ -185,15 +179,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlo=
ck_sock(sk);=0A }=0A =0A static void ax25_t2timer_expiry(unsigned long para=
m)=0A {=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax2=
5->sk;=0A =0A-	bh_lock_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VA=
LUES_PROTOCOL]) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_=
DUPLEX:=0A@@ -207,15 +198,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_s=
ock(sk);=0A }=0A =0A static void ax25_t3timer_expiry(unsigned long param)=
=0A {=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25-=
>sk;=0A =0A-	bh_lock_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALU=
ES_PROTOCOL]) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DU=
PLEX:=0A@@ -231,15 +219,12 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_soc=
k(sk);=0A }=0A =0A static void ax25_idletimer_expiry(unsigned long param)=
=0A {=0A 	ax25_cb *ax25 =3D (ax25_cb *)param;=0A-	struct sock *sk =3D ax25-=
>sk;=0A =0A-	bh_lock_sock(sk);=0A 	switch (ax25->ax25_dev->values[AX25_VALU=
ES_PROTOCOL]) {=0A 	case AX25_PROTO_STD_SIMPLEX:=0A 	case AX25_PROTO_STD_DU=
PLEX:=0A@@ -255,5 +240,4 @@=0A 		break;=0A #endif=0A 	}=0A-	bh_unlock_sock(=
sk);=0A }=0Adiff -ruN linux-2.6.0-test3.bk/net/ax25/sysctl_net_ax25.c linux=
-2.6.0-test3.bk.rxq/net/ax25/sysctl_net_ax25.c=0A--- linux-2.6.0-test3.bk/n=
et/ax25/sysctl_net_ax25.c	2003-08-20 19:00:29.000000000 +0200=0A+++ linux-2=
.6.0-test3.bk.rxq/net/ax25/sysctl_net_ax25.c	2003-08-20 19:58:29.000000000 =
+0200=0A@@ -204,8 +204,10 @@=0A 	for (ax25_table_size =3D sizeof(ctl_table)=
, ax25_dev =3D ax25_dev_list; ax25_dev !=3D NULL; ax25_dev =3D ax25_dev->ne=
xt)=0A 		ax25_table_size +=3D sizeof(ctl_table);=0A =0A-	if ((ax25_table =
=3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL)=0A+	if ((ax25_table =
=3D kmalloc(ax25_table_size, GFP_ATOMIC)) =3D=3D NULL) {=0A+		spin_unlock_b=
h(&ax25_dev_lock);=0A 		return;=0A+	}=0A =0A 	memset(ax25_table, 0x00, ax25=
_table_size);=0A =0A--- linux-2.6.0-test3.bk/include/net/ax25.h	2003-08-20 =
19:05:22.000000000 +0200=0A+++ linux-2.6.0-test3.bk.rxq/include/net/ax25.h	=
2003-08-20 19:41:56.000000000 +0200=0A@@ -10,6 +10,7 @@=0A #include <linux/=
ax25.h>=0A #include <linux/spinlock.h>=0A #include <linux/timer.h>=0A+#incl=
ude <linux/list.h>=0A #include <asm/atomic.h>=0A =0A #define	AX25_T1CLAMPLO=
  		1=0A@@ -180,7 +181,7 @@=0A } ax25_dev;=0A =0A typedef struct ax25_cb {=
=0A-	struct ax25_cb		*next;=0A+	struct hlist_node	ax25_node;=0A 	ax25_addre=
ss		source_addr, dest_addr;=0A 	ax25_digi		*digipeat;=0A 	ax25_dev		*ax25_d=
ev;=0A@@ -197,17 +198,32 @@=0A 	struct sk_buff_head	ack_queue;=0A 	struct s=
k_buff_head	frag_queue;=0A 	unsigned char		window;=0A-	struct timer_list	ti=
mer;=0A+	struct timer_list	timer, dtimer;=0A 	struct sock		*sk;		/* Backlin=
k to socket */=0A+	atomic_t		refcount;=0A } ax25_cb;=0A =0A #define ax25_sk=
(__sk) ((ax25_cb *)(__sk)->sk_protinfo)=0A =0A+#define ax25_for_each(__ax25=
, node, list) \=0A+	hlist_for_each_entry(__ax25, node, list, ax25_node)=0A+=
=0A+#define ax25_cb_hold(__ax25) \=0A+	atomic_inc(&((__ax25)->refcount))=0A=
+=0A+static __inline__ void ax25_cb_put(ax25_cb *ax25)=0A+{=0A+	if (atomic_=
dec_and_test(&ax25->refcount)) {=0A+		if (ax25->digipeat)=0A+			kfree(ax25-=
>digipeat);=0A+		kfree(ax25);=0A+	}=0A+}=0A+=0A /* af_ax25.c */=0A-extern a=
x25_cb *ax25_list;=0A+extern struct hlist_head ax25_list;=0A extern spinloc=
k_t ax25_list_lock;=0A-extern void ax25_free_cb(ax25_cb *);=0A-extern void =
ax25_insert_socket(ax25_cb *);=0A+extern void ax25_cb_add(ax25_cb *);=0A st=
ruct sock *ax25_find_listener(ax25_address *, int, struct net_device *, int=
);=0A struct sock *ax25_get_socket(ax25_address *, ax25_address *, int);=0A=
 extern ax25_cb *ax25_find_cb(ax25_address *, ax25_address *, ax25_digi *, =
struct net_device *);=0A
--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="hard_header.diff"

--- linux-2.6.0-test3.bk/net/ax25/ax25_subr.c	2003-08-20 19:00:29.000000000 +0200
+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_subr.c	2003-08-20 19:58:29.000000000 +0200
@@ -158,10 +158,10 @@
 	struct sk_buff *skb;
 	unsigned char  *dptr;
 
-	if ((skb = alloc_skb(AX25_BPQ_HEADER_LEN + ax25_addr_size(ax25->digipeat) + 2, GFP_ATOMIC)) == NULL)
+	if ((skb = alloc_skb(ax25->ax25_dev->dev->hard_header_len + 2, GFP_ATOMIC)) == NULL)
 		return;
 
-	skb_reserve(skb, AX25_BPQ_HEADER_LEN + ax25_addr_size(ax25->digipeat));
+	skb_reserve(skb, ax25->ax25_dev->dev->hard_header_len);
 
 	skb->nh.raw = skb->data;
 
@@ -202,10 +202,10 @@
 	if (dev == NULL)
 		return;
 
-	if ((skb = alloc_skb(AX25_BPQ_HEADER_LEN + ax25_addr_size(digi) + 1, GFP_ATOMIC)) == NULL)
+	if ((skb = alloc_skb(dev->hard_header_len + 1, GFP_ATOMIC)) == NULL)
 		return;	/* Next SABM will get DM'd */
 
-	skb_reserve(skb, AX25_BPQ_HEADER_LEN + ax25_addr_size(digi));
+	skb_reserve(skb, dev->hard_header_len);
 	skb->nh.raw = skb->data;
 
 	ax25_digi_invert(digi, &retdigi);
@@ -282,6 +282,7 @@
 	ax25_link_failed(ax25, reason);
 
 	if (ax25->sk != NULL) {
+		bh_lock_sock(ax25->sk);
 		ax25->sk->sk_state     = TCP_CLOSE;
 		ax25->sk->sk_err       = reason;
 		ax25->sk->sk_shutdown |= SEND_SHUTDOWN;
@@ -289,5 +290,6 @@
 			ax25->sk->sk_state_change(ax25->sk);
 			sock_set_flag(ax25->sk, SOCK_DEAD);
 		}
+		bh_unlock_sock(ax25->sk);
 	}
 }

--AWniW0JNca5xppdA
Content-Type: application/octet-stream; charset=us-ascii
Content-Disposition: attachment; filename="iface-lists.diff"

--- linux-2.6.0-test3.bk/net/ax25/ax25_iface.c	2003-08-20 19:00:29.000000000 +0200
+++ linux-2.6.0-test3.bk.rxq/net/ax25/ax25_iface.c	2003-08-20 19:58:29.000000000 +0200
@@ -33,20 +33,20 @@
 	struct protocol_struct *next;
 	unsigned int pid;
 	int (*func)(struct sk_buff *, ax25_cb *);
-} *protocol_list;
+} *protocol_list = NULL;
 static rwlock_t protocol_list_lock = RW_LOCK_UNLOCKED;
 
 static struct linkfail_struct {
 	struct linkfail_struct *next;
 	void (*func)(ax25_cb *, int);
-} *linkfail_list;
+} *linkfail_list = NULL;
 static spinlock_t linkfail_lock = SPIN_LOCK_UNLOCKED;
 
 static struct listen_struct {
 	struct listen_struct *next;
 	ax25_address  callsign;
 	struct net_device *dev;
-} *listen_list;
+} *listen_list = NULL;
 static spinlock_t listen_lock = SPIN_LOCK_UNLOCKED;
 
 int ax25_protocol_register(unsigned int pid,
@@ -129,8 +129,10 @@
 
 	spin_lock_bh(&linkfail_lock);
 	linkfail = linkfail_list;
-	if (linkfail == NULL)
+	if (linkfail == NULL) {
+		spin_unlock_bh(&linkfail_lock);
 		return;
+	}
 
 	if (linkfail->func == func) {
 		linkfail_list = linkfail->next;
@@ -180,8 +182,10 @@
 
 	spin_lock_bh(&listen_lock);
 	listen = listen_list;
-	if (listen == NULL)
+	if (listen == NULL) {
+		spin_unlock_bh(&listen_lock);
 		return;
+	}
 
 	if (ax25cmp(&listen->callsign, callsign) == 0 && listen->dev == dev) {
 		listen_list = listen->next;
@@ -226,8 +230,10 @@
 
 	spin_lock_bh(&listen_lock);
 	for (listen = listen_list; listen != NULL; listen = listen->next)
-		if (ax25cmp(&listen->callsign, callsign) == 0 && (listen->dev == dev || listen->dev == NULL))
+		if (ax25cmp(&listen->callsign, callsign) == 0 && (listen->dev == dev || listen->dev == NULL)) {
+			spin_unlock_bh(&listen_lock);
 			return 1;
+	}
 	spin_unlock_bh(&listen_lock);
 
 	return 0;

--AWniW0JNca5xppdA--
