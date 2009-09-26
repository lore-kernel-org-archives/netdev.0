From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 9/9] Add explicit bound checks in net/socket.c
Date: Sat, 26 Sep 2009 21:05:32 +0200
Message-ID: <20090926210532.4c664705@infradead.org>
References: <20090926204951.424e567e@infradead.org>
	<20090926205432.24aa1023@infradead.org>
	<20090926190103.GB4356@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	mingo@elte.hu, netdev@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58925 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbZIZTFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 15:05:10 -0400
In-Reply-To: <20090926190103.GB4356@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Sep 2009 23:01:03 +0400
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> [Arjan van de Ven - Sat, Sep 26, 2009 at 08:54:32PM +0200]
> | From: Arjan van de Ven <arjan@linux.intel.com>
> | Subject: [PATCH 9/9] Add explicit bound checks in net/socket.c
> | CC: netdev@vger.kernel.org
> | 
> | The sys_socketcall() function has a very clever system for the copy
> | size of its arguments. Unfortunately, gcc cannot deal with this in
> | terms of proving that the copy_from_user() is then always in bounds.
> | This is the last (well 9th of this series, but last in the kernel)
> such | case around.
> | 
> | With this patch, we can turn on code to make having the boundary
> provably | right for the whole kernel, and detect introduction of new
> security | accidents of this type early on.
> | 
> | Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> | 
> | 
> | diff --git a/net/socket.c b/net/socket.c
> | index 49917a1..13a8d67 100644
> | --- a/net/socket.c
> | +++ b/net/socket.c
> | @@ -2098,12 +2098,17 @@ SYSCALL_DEFINE2(socketcall, int, call,
> unsigned long __user *, args) |  	unsigned long a[6];
> |  	unsigned long a0, a1;
> |  	int err;
> | +	unsigned int len;
> |  
> |  	if (call < 1 || call > SYS_ACCEPT4)
> |  		return -EINVAL;
> |  
> | +	len = nargs[call];
> | +	if (len > 6)
> 
> Hi Arjan, wouldn't ARRAY_SIZE suffice beter there?
> Or I miss something?

yeah you missed that I screwed up ;(

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
+	if (len > 6 * sizeof(unsiged long))
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
