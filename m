From: David Miller <davem@davemloft.net>
Subject: Re: include/linux/netlink.h: problem when included by an
 application
Date: Sun, 07 Aug 2011 22:48:29 -0700 (PDT)
Message-ID: <20110807.224829.233892140193944735.davem@davemloft.net>
References: <1312580748.2326.15.camel@Thor>
	<1312679707.2591.987.camel@deadeye>
	<1312755263.2908.6.camel@Thor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: michel@digirati.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1HHFsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:48:42 -0400
In-Reply-To: <1312755263.2908.6.camel@Thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michel Machado <michel@digirati.com.br>
Date: Sun, 07 Aug 2011 18:14:23 -0400

>> >    The simplest solution that I came up was replacing sa_family_t in
>> > include/linux/netlink.h to 'unsigned short' as header
>> > include/linux/socket.h does for struct __kernel_sockaddr_storage
>> > available to applications.
>> 
>> Maybe we should do something like this in <linux/socket.h>:
>> 
>> typedef unsigned short __kernel_sa_family_t;
>> #ifdef __KERNEL__
>> typedef __kernel_sa_family_t sa_family_t;
>> #endif
>> 
>> and then use __kernel_sa_family_t in <linux/netlink.h>.
>> 
>> Ben.
> 
>    I like this solution, it solves both struct __kernel_sockaddr_storage
> in include/linux/socket.h, and struct sockaddr_nl in
> include/linux/netlink.h.

Ok, I've applied the following patch:

--------------------
net: Make userland include of netlink.h more sane.

Currently userland will barf when including linux/netlink.h unless it
precisely includes sys/socket.h first.  The issue is where the
definition of "sa_family_t" comes from.

We've been back and forth on how to fix this issue in the past, see:

http://thread.gmane.org/gmane.linux.debian.devel.bugs.general/622621
http://thread.gmane.org/gmane.linux.network/143380

Ben Hutchings suggested we take a hint from how we handle the
sockaddr_storage type.  First we define a "__kernel_sa_family_t"
to linux/socket.h that is always defined.

Then if __KERNEL__ is defined, we also define "sa_family_t" as
equal to "__kernel_sa_family_t".

Then in places like linux/netlink.h we use __kernel_sa_family_t
in user visible datastructures.

Reported-by: Michel Machado <michel@digirati.com.br>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netlink.h |    2 +-
 include/linux/socket.h  |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 2e17c5d..180540a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -29,7 +29,7 @@
 #define MAX_LINKS 32		
 
 struct sockaddr_nl {
-	sa_family_t	nl_family;	/* AF_NETLINK	*/
+	__kernel_sa_family_t	nl_family;	/* AF_NETLINK	*/
 	unsigned short	nl_pad;		/* zero		*/
 	__u32		nl_pid;		/* port ID	*/
        	__u32		nl_groups;	/* multicast groups mask */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index e17f822..d0e77f6 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -8,8 +8,10 @@
 #define _K_SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
 				/* Implementation specific desired alignment */
 
+typedef unsigned short __kernel_sa_family_t;
+
 struct __kernel_sockaddr_storage {
-	unsigned short	ss_family;		/* address family */
+	__kernel_sa_family_t	ss_family;		/* address family */
 	/* Following field(s) are implementation specific */
 	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
 				/* space to achieve desired size, */
@@ -35,7 +37,7 @@ struct seq_file;
 extern void socket_seq_show(struct seq_file *seq);
 #endif
 
-typedef unsigned short	sa_family_t;
+typedef __kernel_sa_family_t	sa_family_t;
 
 /*
  *	1003.1g requires sa_family_t and that sa_data is char.
-- 
1.7.6

