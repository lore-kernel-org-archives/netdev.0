From: Andrew Morton <akpm@osdl.org>
Subject: Fw: X.25 : Debug: sleeping function called from invalid context at
 net/core/sock.c:1203
Date: Tue, 26 Oct 2004 03:43:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026034347.1ff35e3d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


gack.  It looks like there are lots of things in x25_destroy_socket()
which aren't safe from timer handler context.  Should the whole thing
be using schedule_work()?

Begin forwarded message:

Date: Mon, 25 Oct 2004 10:10:30 +1000
From: Andrew Hendry <ahendry@tusc.com.au>
To: linux-x25@vger.kernel.org, eis@baty.hanse.de
Cc: trivial@rustcorp.com.au, linux-kernel@vger.kernel.org
Subject: X.25 : Debug: sleeping function called from invalid context at net/core/sock.c:1203


2.6.8.1

When called from x25_heartbeat_expiry, x25_destroy_socket trips the
following:

Oct 20 12:19:01 localhost kernel: Debug: sleeping function called from
invalid context at net/core/sock.c:1203
Oct 20 12:19:01 localhost kernel: in_atomic():1, irqs_disabled():0
Oct 20 12:19:01 localhost kernel:  [<c0117e55>] __might_sleep+0x9a/0xa2
Oct 20 12:19:01 localhost kernel:  [<c025964e>] lock_sock+0x12/0x3d
Oct 20 12:19:01 localhost kernel:  [<f89a1a1e>]
x25_heartbeat_expiry+0x0/0x4d [x25]
Oct 20 12:19:01 localhost kernel:  [<f899d3e2>]
x25_destroy_socket+0x10/0xd5 [x25]
Oct 20 12:19:01 localhost kernel:  [<f89a1a1e>]
x25_heartbeat_expiry+0x0/0x4d [x25]
Oct 20 12:19:01 localhost kernel:  [<c01202f4>]
run_timer_softirq+0xa1/0x13c
Oct 20 12:19:01 localhost kernel:  [<c0120466>] do_timer+0xcd/0xd2
Oct 20 12:19:01 localhost kernel:  [<c011ceaf>] __do_softirq+0x77/0x79
Oct 20 12:19:01 localhost kernel:  [<c011ced7>] do_softirq+0x26/0x28
Oct 20 12:19:01 localhost kernel:  [<c010749d>] do_IRQ+0xd4/0x107
Oct 20 12:19:01 localhost kernel:  [<c0105d90>]
common_interrupt+0x18/0x20
Oct 20 12:19:01 localhost kernel:  [<c01da7ae>]
acpi_processor_idle+0xd4/0x1c7
Oct 20 12:19:01 localhost kernel:  [<c010409b>] cpu_idle+0x2c/0x35
Oct 20 12:19:01 localhost kernel:  [<c034c655>] start_kernel+0x163/0x19f
Oct 20 12:19:01 localhost kernel:  [<c034c2cf>]
unknown_bootoption+0x0/0x144

Looking at other protocols setup the same way, rose and ax25 dont have
the lock_sock in destroy. Is the lock_sock needed here?

diff -up linux-2.6.8.1/net/x25/af_x25.c.orig
linux-2.6.8.1/net/x25/af_x25.c
--- linux-2.6.8.1/net/x25/af_x25.c.orig 2004-10-25 08:49:40.780391664
+1000
+++ linux-2.6.8.1/net/x25/af_x25.c      2004-10-25 09:47:02.578158872
+1000
@@ -322,7 +322,6 @@ void x25_destroy_socket(struct sock *sk)
        struct sk_buff *skb;
  
        sock_hold(sk);
-       lock_sock(sk);
        x25_stop_heartbeat(sk);
        x25_stop_timer(sk);
  
@@ -353,7 +352,6 @@ void x25_destroy_socket(struct sock *sk)
                __sock_put(sk);
        }
  
-       release_sock(sk);
        sock_put(sk);
 }


