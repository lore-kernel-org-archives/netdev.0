From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC] net,socket: introduce build_sockaddr_check helper to catch
	overflow at build time
Date: Wed, 21 Oct 2009 21:07:32 +0400
Message-ID: <20091021170732.GE5976@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: Linux-Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:57682 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493AbZJURHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 13:07:30 -0400
Received: by ewy3 with SMTP id 3so6264471ewy.17
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 10:07:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while were sneaking thru sockets code I've got the idea that we may
check for __kernel_sockaddr_storage overflow at build time. At moment
this structure is big enough and I hardly believe it could be overflowed
ever (hmm?).

Anyway just an idea which could be stupid perhaps but I decided to
put it out. An idea is that before copy protocol specific data in
socket->ops->getname implementation the driver code may put

build_sockaddr_check(sizeof(some_struct));

and be sure it doesn't overflow the hosting unit.

Feel free to just ignore this RFC, was just an idea to share.

	-- Cyrill
---
net,socket: introduce build_sockaddr_check helper to catch overflow at build time

proto_ops->getname implies copying protocol specific data
into storage unit (particulary to __kernel_sockaddr_storage).
So when one implements new protocol he either may keep this
in mind (or may not).

Lets introduce build_sockaddr_check helper which check if
storage unit is not overfowed. Note that the check is build
time and introduce no slowdown at execution time.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 include/linux/socket.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.git/include/linux/socket.h
=====================================================================
--- linux-2.6.git.orig/include/linux/socket.h
+++ linux-2.6.git/include/linux/socket.h
@@ -24,6 +24,9 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
+#define build_sockaddr_check(size)	\
+	BUILD_BUG_ON(((size) > sizeof(struct __kernel_sockaddr_storage)))
+
 #ifdef __KERNEL__
 # ifdef CONFIG_PROC_FS
 struct seq_file;
