From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] ref count bug in MLDv2
Date: Wed, 12 Nov 2003 16:56:20 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311121630100.1794-100000@linux.local>
References: <OF9FB7F6ED.3B4FEB1E-ON88256DDD.0002886E@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: krkumar@us.ibm.com, <netdev@oss.sgi.com>, <dlstevens@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <OF9FB7F6ED.3B4FEB1E-ON88256DDD.0002886E@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Stevens and I  found this problem when the device is going down,
mc_destroy_dev() calls igmp6_group_dropped which checks for IFF_UP before
calling mld_add_delrec and posting a timer.

IFF_UP need not be set though the device is going down (eg last address
deletion). So timer can get started at this time. The problem is that
when the timer fires (after ifdown is over) for the last time
(mld_ifc_timer_expire), it does a __in6_dev_put() and that will not free
up the idev.

To fix that that the check must be for idev->dead instead.

Thanks,

- KK

---------------------------------------------------------------------------
diff -ruN linux-2.6.0-test9-bk9/net/ipv6/mcast.c linux-2.6.0-test9-bk9.new/net/ipv6/mcast.c
--- linux-2.6.0-test9-bk9/net/ipv6/mcast.c	2003-11-12 16:42:05.000000000 -0800
+++ linux-2.6.0-test9-bk9.new/net/ipv6/mcast.c	2003-11-12 16:41:36.000000000 -0800
@@ -664,7 +664,7 @@
 		goto done;
 	spin_unlock_bh(&mc->mca_lock);

-	if (dev->flags&IFF_UP)
+	if (!mc->idev->dead)
 		igmp6_leave_group(mc);

 	spin_lock_bh(&mc->mca_lock);
-----------------------------------------------------------------------------

Test script :
insmod /lib/modules/2.6.0-test9-bk9/kernel/drivers/net/3c59x.ko
ifup eth0
~kkumar/t1 &
a=$!
sleep 1
ifdown eth0
rmmod 3c59x
-----------------------------------------------------------------------------

where t1.c is :


#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>

#define MCAST_JOIN_GROUP                42
#define MCAST_LEAVE_GROUP               45

#define _K_SS_MAXSIZE   128     /* Implementation specific max size */

struct __kernel_sockaddr_storage {
        unsigned short  ss_family;              /* address family */
        /* Following field(s) are implementation specific */
        char            __data[_K_SS_MAXSIZE - sizeof(unsigned short)];
                                /* space to achieve desired size, */
                                /* _SS_MAXSIZE value minus size of ss_family */
};
struct group_req
{
        uint32_t                            gr_interface;  /* interface index */
	struct __kernel_sockaddr_storage gr_group;
};

main()
{
	struct group_req greq;
	struct sockaddr_in6 *psin6;
	int s;

	s = socket(AF_INET6, SOCK_DGRAM, 0);
	if (s < 0) {
		perror("socket");
		exit(1);
	}
	psin6 = (struct sockaddr_in6 *)&greq.gr_group;
	psin6->sin6_family = AF_INET6;
	if (inet_pton(AF_INET6, "ff02::3", &psin6->sin6_addr) <= 0) {
		perror("inet_pton");
		exit(0);
	}
	greq.gr_interface = if_nametoindex("eth0");
	if (setsockopt(s, SOL_IPV6, MCAST_JOIN_GROUP, &greq, sizeof(greq))
	    < 0) {
		perror("MCAST_JOIN_GROUP");
		exit(1);
	}
	while(1);
}
