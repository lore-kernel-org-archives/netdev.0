From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Fri, 13 Aug 2004 09:38:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813093838.6961c0d4.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040813090314.448c971d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks guys.  This patch should fix both problems.

Herbert, if we check inetdev->dead when trying to grab
a reference it fixes the RCU destroy race you mentioned.
I really don't want to put that ref drop into the
RCU callback as that would kill performance.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/13 09:17:07-07:00 davem@nuts.davemloft.net 
#   [IPV4]: Fix two bugs in inetdev RCU handling.
#   
#   - Two missing smp_read_barrier_depends() noticed by
#     Stephen Hemminger.
#   - Fix RCU inetdev destroy race spotted by Herbert Xu.
#     Check in_dev->dead when trying to grab a reference.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/devinet.c
#   2004/08/13 09:15:41-07:00 davem@nuts.davemloft.net +1 -0
#   [IPV4]: Fix two bugs in inetdev RCU handling.
# 
# include/linux/inetdevice.h
#   2004/08/13 09:15:41-07:00 davem@nuts.davemloft.net +7 -2
#   [IPV4]: Fix two bugs in inetdev RCU handling.
# 
diff -Nru a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h	2004-08-13 09:20:01 -07:00
+++ b/include/linux/inetdevice.h	2004-08-13 09:20:01 -07:00
@@ -143,9 +143,14 @@
 	struct in_device *in_dev;
 
 	rcu_read_lock();
+	smp_read_barrier_depends();
 	in_dev = dev->ip_ptr;
-	if (in_dev)
-		atomic_inc(&in_dev->refcnt);
+	if (in_dev) {
+		if (in_dev->dead)
+			in_dev = NULL;
+		else
+			atomic_inc(&in_dev->refcnt);
+	}
 	rcu_read_unlock();
 	return in_dev;
 }
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2004-08-13 09:20:01 -07:00
+++ b/net/ipv4/devinet.c	2004-08-13 09:20:01 -07:00
@@ -210,6 +210,7 @@
 int inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b)
 {
 	rcu_read_lock();
+	smp_read_barrier_depends();
 	for_primary_ifa(in_dev) {
 		if (inet_ifa_match(a, ifa)) {
 			if (!b || inet_ifa_match(b, ifa)) {
