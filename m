From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: very strange inet_sock corruption with rpc
Date: Wed, 25 Apr 2007 17:03:52 -0400
Message-ID: <462FC238.4040305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:58601 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215AbXDYVEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 17:04:06 -0400
Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id 38A8835077
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 17:03:54 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

To support a piece of custom functionality, we needed to add
2 member to the struct inet_sock.  During testing, we started
seeing an interesting corruption.  Following a hunch, we've
completely ripped out all of our code with the exception of
5 lines that do this:

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ce6da97..605f5c0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -140,6 +140,8 @@ struct inet_sock {
                __be32                  addr;
                struct flowi            fl;
        } cork;
+       void *foo;
+       u32  bar;
 };
 
 #define IPCORK_OPT     1       /* ip-options has been held in ipcork.opt */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf358c8..98ad2c2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -335,6 +335,9 @@ lookup_protocol:
 
        sk_refcnt_debug_inc(sk);
 
+       inet->foo = NULL;
+       inet->bar = 0;
+
        if (inet->num) {
                /* It assumes that any protocol which allows
                 * the user to assign a number at socket

(Variables were really named something else, but I hacked this into
 net-2.6 to see if I could reproduce).

With just the above patch, I can catch a corruption of the inet_sock
in the inet_cks_bind_conflict() with this:

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 43fb160..5cd5b6d 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -45,6 +45,18 @@ int inet_csk_bind_conflict(const struct sock *sk,
        int reuse = sk->sk_reuse;
 
        sk_for_each_bound(sk2, node, &tb->owners) {
+               if (inet_sk(sk2)->foo) {
+                       printk(KERN_WARN "sk2 might be corrupt.  Info:\n");
+                       printk(KERN_WARN "\tsk2 = %p\n", sk2);
+                       printk(KERN_WARN "\ttb->port = %d\n", tb->port);
+                       printk(KERN_WARN "\tinet_sk(sk2)->num = %d\n",
+                                       inet_sk(sk2)->num);
+                       printk(KERN_WARN "\tinet_sk(sk2)->foo = %p\n",
+                                       inet_sk(sk2)->foo);
+                       printk(KERN_WARN "\tinet_sk(sk2)->bar = %p\n",
+                                       inet_sk(sk2)->bar);
+                       WARN_ON(1);
+               }

Nobody outside of inet_create() writes to the foo pointer so it should
always be NULL.  I've enabled SLAB debugging, stack overflow debugging, VM
debugging and nothing triggers.

The corruption is triggered after about 10 minutes of running the following
script:

nfspath = $1
localpath = $2
while true; do
	mount "$nfspath" "$localpath"
	sleep 5
	cp /boot/vmlinuz "$localpath"
	sleep 5
	rm $localpath/vmlinuz
	sleep 5
	umount "$localpath"
done


And looks like this:

sk2 might be corrupt.  Info:
        sk2 = ffff8100f004d080
        tb->port = 844
        inet_sk(sk2)->num = 61695
        inet_sk(sk2)->foo = 24242424243f243f
        inet_sk(sk2)->bar = 3f24243f
BUG: at net/ipv4/inet_connection_sock.c:58 inet_csk_bind_conflict()

Call Trace:
 [<ffffffff803cc591>] inet_csk_bind_conflict+0xcb/0x178
 [<ffffffff803cc4c6>] inet_csk_bind_conflict+0x0/0x178
 [<ffffffff803cc2ff>] inet_csk_get_port+0x11a/0x1ef
 [<ffffffff803ddf51>] inet_bind+0x117/0x1f5
 [<ffffffff88184e13>] :sunrpc:xs_bindresvport+0x4e/0xbf
 [<ffffffff881853a4>] :sunrpc:xs_tcp_connect_worker+0x0/0x2a0
 [<ffffffff88185433>] :sunrpc:xs_tcp_connect_worker+0x8f/0x2a0
 [<ffffffff80248bd3>] run_workqueue+0x8f/0x137
 [<ffffffff80245687>] worker_thread+0x0/0x14a
 [<ffffffff8024579b>] worker_thread+0x114/0x14a
 [<ffffffff8027e544>] default_wake_function+0x0/0xe
 [<ffffffff8022ff49>] kthread+0xd1/0x100
 [<ffffffff80258f68>] child_rip+0xa/0x12
 [<ffffffff8022fe78>] kthread+0x0/0x100
 [<ffffffff80258f5e>] child_rip+0x0/0x12


It looks like someone is stepping all over the inet_sock.
We'll continue looking, but if anyone has any ideas of what might
be going on, I'd appreciate it.

It looks like a serious bug lurking somewhere.

-vlad

p.s  the mount is using nfsv3 over UDP (nothing fancy at all)
