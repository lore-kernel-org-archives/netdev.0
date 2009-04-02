From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] socket: use percpu_add() while updating sockets_in_use
Date: Thu, 02 Apr 2009 08:58:00 +0200
Message-ID: <49D461F8.20906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46963 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbZDBG6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 02:58:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_alloc() currently uses following code to update sockets_in_use

get_cpu_var(sockets_in_use)++;
put_cpu_var(sockets_in_use);

This translates to :

c0436274:       b8 01 00 00 00          mov    $0x1,%eax
c0436279:       e8 42 40 df ff          call   c022a2c0 <add_preempt_count>
c043627e:       bb 20 4f 6a c0          mov    $0xc06a4f20,%ebx
c0436283:       e8 18 ca f0 ff          call   c0342ca0 <debug_smp_processor_id>
c0436288:       03 1c 85 60 4a 65 c0    add    -0x3f9ab5a0(,%eax,4),%ebx
c043628f:       ff 03                   incl   (%ebx)
c0436291:       b8 01 00 00 00          mov    $0x1,%eax
c0436296:       e8 75 3f df ff          call   c022a210 <sub_preempt_count>
c043629b:       89 e0                   mov    %esp,%eax
c043629d:       25 00 e0 ff ff          and    $0xffffe000,%eax
c04362a2:       f6 40 08 08             testb  $0x8,0x8(%eax)
c04362a6:       75 07                   jne    c04362af <sock_alloc+0x7f>
c04362a8:       8d 46 d8                lea    -0x28(%esi),%eax
c04362ab:       5b                      pop    %ebx
c04362ac:       5e                      pop    %esi
c04362ad:       c9                      leave
c04362ae:       c3                      ret
c04362af:       e8 cc 5d 09 00          call   c04cc080 <preempt_schedule>
c04362b4:       8d 74 26 00             lea    0x0(%esi,%eiz,1),%esi
c04362b8:       eb ee                   jmp    c04362a8 <sock_alloc+0x78>

While percpu_add(sockets_in_use, 1) translates to a single instruction :

c0436275:   64 83 05 20 5f 6a c0    addl   $0x1,%fs:0xc06a5f20

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/socket.c b/net/socket.c
index 91d0c02..791d71a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -493,8 +493,7 @@ static struct socket *sock_alloc(void)
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
 
-	get_cpu_var(sockets_in_use)++;
-	put_cpu_var(sockets_in_use);
+	percpu_add(sockets_in_use, 1);
 	return sock;
 }
 
@@ -536,8 +535,7 @@ void sock_release(struct socket *sock)
 	if (sock->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
-	get_cpu_var(sockets_in_use)--;
-	put_cpu_var(sockets_in_use);
+	percpu_sub(sockets_in_use, 1);
 	if (!sock->file) {
 		iput(SOCK_INODE(sock));
 		return;
