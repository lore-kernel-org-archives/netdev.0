From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net] core: Don't attempt to load the "" driver.
Date: Tue, 2 Sep 2014 13:48:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58942 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752791AbaIBNur convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 09:50:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11556-06 for <netdev@vger.kernel.org>;
 Tue,  2 Sep 2014 14:50:37 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Requests like 'ifconfig ""' cause dev_load(net, "") be called, since
request_module("") return 0 (success) this generates the error message:
"Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev- instead."

Since dev_load() doesn't have to work, just ignore such names.
---

If you search for the above error message, you'll find a lot of complaints.
While the applications shouldn't be calling an SIOCxxx ioctl with ifr_name[0] == 0
the kernel shouldn't be tracing the error either.

Due to the complaints from users, this might be a backport candidate.

 net/core/dev_ioctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index cf999e0..84edf16 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -358,6 +358,9 @@ void dev_load(struct net *net, const char *name)
 	struct net_device *dev;
 	int no_module;
 
+	if (!name[0])
+		return;
+
 	rcu_read_lock();
 	dev = dev_get_by_name_rcu(net, name);
 	rcu_read_unlock();
-- 
1.8.1.2
