From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Sun, 20 Sep 2009 23:02:42 +0200
Message-ID: <20090920210242.GA9804@del.dom.local>
References: <4AA82BF0.7040203@upmc.fr>
 <20090910142436.GB10547@linux-mips.org>
 <4AA9288B.2070205@upmc.fr>
 <20090911120557.GA12175@linux-mips.org>
 <4AB5EAE5.6070605@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AB5EAE5.6070605@upmc.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 20, 2009 at 10:42:13AM +0200, Bernard Pidoux wrote:
> Hi,
> 
> Here are the first events noticed since I turned on
> CONFIG_DEBUG_OBJECTS_TIMERS option.
> 
> First a kernel BUG, second a kernel panic.
...
> ------------[ cut here ]------------
> kernel BUG at kernel/timer.c:913!

Alas this BUG doesn't show much (this new debugging didn't trigger
here). Maybe the patch below will be luckier.

Best regards,
Jarek P.
---

 include/net/ax25.h |   36 ++++++++++++++++++++++++++++++++++++
 net/ax25/af_ax25.c |    3 +++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 717e219..e8f6e33 100644
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
+		printk(KERN_WARNING "AX25_DBG: %d %p %u\n", err, ax25,
+		       ax25->state);
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
index da0f64f..f443fe0 100644
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
 
