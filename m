From: "David S. Miller" <davem@redhat.com>
Subject: Re: Problem with __check_and_rekey
Date: Tue, 12 Aug 2003 06:53:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812065347.331e9066.davem@redhat.com>
References: <20030812132050.GA27178@mochrul.balabit>
	<20030812.225527.35784879.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sasa@balabit.hu, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030812.225527.35784879.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 22:55:27 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> > +               local_bh_disable();
> >                 tp->write_seq = secure_tcp_sequence_number(sk->saddr, sk->daddr,
> >                                                            sk->sport, usin->sin_port);
> > +               local_bh_enable();
> 
> You must forgot braces.
> But anyway, I can't find these lines in linux-2.4.21 (or even in 2.6.x).
> Are you sure you're working on the vanilla kernel?

It doesn't matter, a proper fix was put into drivers/char/random.c
already.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1019.3.9 -> 1.1019.3.10
#	drivers/char/random.c	1.17    -> 1.18   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/28	olof@austin.ibm.com	1.1019.3.10
# [RANDOM]: Fix SMP deadlock in __check_and_rekey().
# --------------------------------------------
#
diff -Nru a/drivers/char/random.c b/drivers/char/random.c
--- a/drivers/char/random.c	Tue Aug 12 06:56:52 2003
+++ b/drivers/char/random.c	Tue Aug 12 06:56:52 2003
@@ -251,6 +251,8 @@
 #include <linux/random.h>
 #include <linux/poll.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
 
 #include <asm/processor.h>
 #include <asm/uaccess.h>
@@ -2069,7 +2071,7 @@
 static struct keydata *__check_and_rekey(time_t time)
 {
 	struct keydata *keyptr;
-	spin_lock(&ip_lock);
+	spin_lock_bh(&ip_lock);
 	keyptr = &ip_keydata[ip_cnt&1];
 	if (!keyptr->rekey_time || (time - keyptr->rekey_time) > REKEY_INTERVAL) {
 		keyptr = &ip_keydata[1^(ip_cnt&1)];
@@ -2079,7 +2081,7 @@
 		mb();
 		ip_cnt++;
 	}
-	spin_unlock(&ip_lock);
+	spin_unlock_bh(&ip_lock);
 	return keyptr;
 }
 
