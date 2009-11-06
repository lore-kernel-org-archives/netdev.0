From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_bindtodevice() RCU-ification
Date: Thu, 05 Nov 2009 22:39:21 -0800 (PST)
Message-ID: <20091105.223921.83639611.davem@davemloft.net>
References: <4AF201FC.3040908@gmail.com>
	<20091105.210830.108657873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751077AbZKFGi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 01:38:56 -0500
In-Reply-To: <20091105.210830.108657873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 05 Nov 2009 21:08:30 -0800 (PST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 04 Nov 2009 23:36:44 +0100
> 
>> Avoid dev_hold()/dev_put() in sock_bindtodevice()
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied to net-next-2.6, thanks.

Eric I had to add the following patch to cure a build
warning after this, just FYI:

net: Fix build warning in sock_bindtodevice().

net/core/sock.c: In function 'sock_setsockopt':
net/core/sock.c:396: warning: 'index' may be used uninitialized in this function
net/core/sock.c:396: note: 'index' was declared here

GCC can't see that all paths initialize index, so just
set it to the default (0) and eliminate the specific
code block that handles the null device name string.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/sock.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 38820ea..76ff58d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -417,9 +417,8 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 	if (copy_from_user(devname, optval, optlen))
 		goto out;
 
-	if (devname[0] == '\0') {
-		index = 0;
-	} else {
+	index = 0;
+	if (devname[0] != '\0') {
 		struct net_device *dev;
 
 		rcu_read_lock();
-- 
1.6.5.2

