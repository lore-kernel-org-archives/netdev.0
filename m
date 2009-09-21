From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Mon, 21 Sep 2009 22:11:57 +0200
Message-ID: <20090921201157.GA5460@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<20090910142436.GB10547@linux-mips.org> <4AA9288B.2070205@upmc.fr>
<20090911120557.GA12175@linux-mips.org> <4AB5EAE5.6070605@upmc.fr>
<20090920210242.GA9804@del.dom.local> <4AB73CDE.4030709@upmc.fr>
In-Reply-To: <4AB73CDE.4030709@upmc.fr>

Bernard Pidoux wrote, On 09/21/2009 10:44 AM:

> Hi Jarek,
> 
> Good fishing !
> 
> During the night I catched the following two identical AX25_DBG
> messages with netconsole
> sending already reported message: kernel BUG at kernel/timer.c:913!
> and followed by kernel
> panics and the machine rebooting.
> 
> 
> Sep 21 03:24:06 f6bvp-11 klogd: ------------[ cut here ]------------
> Sep 21 03:24:06 f6bvp-11 klogd: WARNING: at include/net/ax25.h:260
> ax25_kiss_rcv+0x650/0xab0 [ax25]()

Thanks for testing. Alas I don't get how it's possible at this place
(unless I miss the place), especially with a nosmp kernel. So here is
take 2 (to apply after reverting the previous one).

Regards,
Jarek P.
--- (debugging patch, take 2)

 include/net/ax25.h |   36 ++++++++++++++++++++++++++++++++++++
 net/ax25/af_ax25.c |   12 ++++++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 717e219..7fefbb0 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -252,9 +252,45 @@ typedef struct ax25_cb {
 #define ax25_cb_hold(__ax25) \
 	atomic_inc(&((__ax25)->refcount))
 
+static __inline__ int ax25_timers_warn(ax25_cb *ax25)
+{
+	int err = 0;
+
+	if (del_timer(&ax25->timer)) {
+		WARN_ON_ONCE(1);
+		err = 1;
+	}
+	if (del_timer(&ax25->t1timer)) {
+		WARN_ON_ONCE(1);
+		err += 2;
+	}
+	if (del_timer(&ax25->t2timer)) {
+		WARN_ON_ONCE(1);
+		err += 4;
+	}
+	if (del_timer(&ax25->t3timer)) {
+		WARN_ON_ONCE(1);
+		err += 8;
+	}
+	if (del_timer(&ax25->idletimer)) {
+		WARN_ON_ONCE(1);
+		err += 16;
+	}
+	if (del_timer(&ax25->dtimer)) {
+		WARN_ON_ONCE(1);
+		err += 32;
+	}
+	if (err)
+		printk(KERN_WARNING "AX25_DBG: %d %p %u %s %d\n", err, ax25,
+		       ax25->state, __func__, __LINE__);
+
+	return err;
+}
+
 static __inline__ void ax25_cb_put(ax25_cb *ax25)
 {
 	if (atomic_dec_and_test(&ax25->refcount)) {
+		ax25_timers_warn(ax25);
 		kfree(ax25->digipeat);
 		kfree(ax25);
 	}
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index da0f64f..f1f515c 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -58,6 +58,9 @@ static const struct proto_ops ax25_proto_ops;
 
 static void ax25_free_sock(struct sock *sk)
 {
+	if (ax25_timers_warn(ax25_sk(sk)))
+		printk(KERN_WARNING "AX25_DBG: %p %u %u %u\n", sk,
+		       sk->sk_family, sk->sk_type, sk->sk_protocol);
 	ax25_cb_put(ax25_sk(sk));
 }
 
@@ -222,6 +225,8 @@ ax25_cb *ax25_find_cb(ax25_address *src_addr, ax25_address *dest_addr,
 		if (s->ax25_dev == NULL)
 			continue;
 		if (ax25cmp(&s->source_addr, src_addr) == 0 && ax25cmp(&s->dest_addr, dest_addr) == 0 && s->ax25_dev->dev == dev) {
+			int ref;
+
 			if (digi != NULL && digi->ndigi != 0) {
 				if (s->digipeat == NULL)
 					continue;
@@ -231,6 +236,13 @@ ax25_cb *ax25_find_cb(ax25_address *src_addr, ax25_address *dest_addr,
 				if (s->digipeat != NULL && s->digipeat->ndigi != 0)
 					continue;
 			}
+			ref = atomic_read(&s->refcount);
+			if (ref < 2) {
+				WARN_ON_ONCE(1);
+				printk(KERN_WARNING "AX25_DBG: %d %p %d %s\n",
+				       ref, s, s->state, __func__);
+			}
+
 			ax25_cb_hold(s);
 			spin_unlock_bh(&ax25_list_lock);
 

