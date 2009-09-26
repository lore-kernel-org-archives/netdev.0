From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH 9/9] Add explicit bound checks in net/socket.c
Date: Sat, 26 Sep 2009 20:54:32 +0200
Message-ID: <20090926205432.24aa1023@infradead.org>
References: <20090926204951.424e567e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	mingo@elte.hu, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752740AbZIZSyW@vger.kernel.org>
In-Reply-To: <20090926204951.424e567e@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [PATCH 9/9] Add explicit bound checks in net/socket.c
CC: netdev@vger.kernel.org

The sys_socketcall() function has a very clever system for the copy
size of its arguments. Unfortunately, gcc cannot deal with this in
terms of proving that the copy_from_user() is then always in bounds.
This is the last (well 9th of this series, but last in the kernel) such
case around.

With this patch, we can turn on code to make having the boundary provably
right for the whole kernel, and detect introduction of new security
accidents of this type early on.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>


diff --git a/net/socket.c b/net/socket.c
index 49917a1..13a8d67 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2098,12 +2098,17 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 	unsigned long a[6];
 	unsigned long a0, a1;
 	int err;
+	unsigned int len;
 
 	if (call < 1 || call > SYS_ACCEPT4)
 		return -EINVAL;
 
+	len = nargs[call];
+	if (len > 6)
+		return -EINVAL;
+
 	/* copy_from_user should be SMP safe. */
-	if (copy_from_user(a, args, nargs[call]))
+	if (copy_from_user(a, args, len))
 		return -EFAULT;
 
 	audit_socketcall(nargs[call] / sizeof(unsigned long), a);


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
