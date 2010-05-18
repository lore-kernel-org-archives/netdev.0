From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: dev_get_valid_name buggy with hash collision
Date: Tue, 18 May 2010 12:17:10 +0200
Message-ID: <4BF26926.4070507@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090205050905020903050505"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:60379 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab0ERKRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 06:17:15 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4IAHD0V013354
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 10:17:13 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4IAHDOt1429704
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 11:17:13 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4IAHCaf028111
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 11:17:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090205050905020903050505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Hi all,

the commit:

commit d90310243fd750240755e217c5faa13e24f41536
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Wed Nov 18 02:36:59 2009 +0000

     net: device name allocation cleanups

introduced a bug when there is a hash collision making impossible to 
rename a device with eth%d

This bug is very hard to reproduce and appears rarely, but finally I 
succeed to reproduce it with the program in attachment which fail to 
rename a device with errno ENFILE.

The test program creates a new network namespace in order to avoid 
messing the real network and to be sure we don't have any ethernet 
devices. Hence, we know if we create one ethernet device with the name 
eth%d the result will be 'eth0'.

The first step is to find a conflicting name with 'eth0':
  1) We compute the hash of 'eth0' with the hashing functions imported 
from the kernel
  2) We create a temporary name, compute its hash
  3) We compare the hash with the one we found for 'eth0'.

We loop until the hashes are different. When they are the same, then the 
temporary name is a conflicting name.

We create a dummy device with the temporary conflicting name and then we 
try to rename it with 'eth%d' (expecting 'eth0'), that fails with ENFILE 
due to the kernel bug.

 From the kernel POV, this is what happen:

dev_change_name does:
---------------------

     [ ... ]

     dev_get_valid_name(net, newname, dev->name, 1);

     [ ... ]

Note the dev->name parameter and newname is 'eth%d'.

dev_get_valid_name does:
------------------------

     [ ... ]

     if (fmt && strchr(name, '%'))
         return __dev_alloc_name(net, name, buf);

     [ ... ]

Note the 'buf' parameter is the 'dev->name' parameter and 'name' is "eth%d"

__dev_alloc_name does:
----------------------

     [ ... ]

         for_each_netdev(net, d) {
             if (!sscanf(d->name, name, &i))
                 continue;
             if (i < 0 || i >= max_netdevices)
                 continue;

             /*  avoid cases where sscanf is not exact inverse of printf */
             snprintf(buf, IFNAMSIZ, name, i);
             if (!strncmp(buf, d->name, IFNAMSIZ))
                 set_bit(i, inuse);
         }

     [ ... ]

Here the buf parameter is 'dev->name', so while we are browsing the 
network devices, we change the name of our eth device we want to rename. 
But in the context of our test program, that does not happen because 
there is no "eth[0-9]" network devices in the namespace, then we exit 
the loop with 'i == 0'.

Right after we do:

     if (buf != name)
         snprintf(buf, IFNAMSIZ, name, i);

Here buf and name pointers are different, so we modify 'buf' which is 
'dev->name', that is the network device name directly. So we have 
'dev->name' == "eth0" after this line.


So right after we are trying to find ourself :)

     [ ... ]

     if (!__dev_get_by_name(net, buf))
         return i;

     [ ... ]

When hashing are the same for the oldname and the newname, the function 
'__dev_get_by_name':

     [ ... ]

     struct hlist_head *head = dev_name_hash(net, name);

     hlist_for_each_entry(dev, p, head, name_hlist)
         if (!strncmp(dev->name, name, IFNAMSIZ))
             return dev;

     [ ... ]

will find the network device because we do __dev_get_by_name(net, 
"eth0"), the dev->name is already modified with "eth0" and the hashing 
of the temporary name and "eth0" are the same so returning the same hash 
entry.

We are lucky, most of the time, because the name of the network device 
and the new name have different hash entry, so we compare to ourself 
very rarely.


IMO, the bug is to pass the 'dev->name' parameter to __dev_alloc_name 
directly instead of a temporary name.

The patch in attachment fix the problem but I am not sure we shouldn't 
go further and do more cleanup around this bug, so you may consider it 
as a RFC more than a fix. If it is acceptable, I will send it as a patch 
against net-2.6.

Thanks
   -- Daniel















--------------090205050905020903050505
Content-Type: text/x-csrc;
 name="myethash.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="myethash.c"

#include <stdio.h>
#include <net/if.h>
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <sys/types.h>

/* 
 * We import the hash function from the kernel, so we can compute a conflicting
 * name directly in this program and reproduce the bug easily
 */

#define NETDEV_HASHBITS  8

/*************** from include/linux/dcache.h *****************************/

#define init_name_hash()  0
static inline unsigned long
partial_name_hash(unsigned long c, unsigned long prevhash)
{
        return (prevhash + (c << 4) + (c >> 4)) * 11;
}

static inline unsigned long end_name_hash(unsigned long hash)
{
        return (unsigned int) hash;
}

static inline unsigned int
full_name_hash(const unsigned char *name, unsigned int len)
{
        unsigned long hash = init_name_hash();
        while (len--)
                hash = partial_name_hash(*name++, hash);
        return end_name_hash(hash);
}

/***************** from include/linux/hash.h *****************************/

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32 0x9e370001UL

static inline unsigned int hash_32(unsigned int val, unsigned int bits)
{
        /* On some cpus multiply is faster, on others gcc will do shifts */
        unsigned int hash = val * GOLDEN_RATIO_PRIME_32;

        /* High bits are more random, so use them. */
        return hash >> (32 - bits);
}

/*************************************************************************/


unsigned int dev_name_hash(const char *name)
{
	return hash_32(full_name_hash(name, strnlen(name, IFNAMSIZ)), 
                        NETDEV_HASHBITS);
}

int main(int argc, char *argv[])
{
	char devname[IFNAMSIZ];
	char cmd[4096];
	unsigned int val, val2;
	
	if (getuid()) {
		fprintf(stderr, "you have to be root !\n");
		return -1;
	}

	/*
	 * Unshare the network namespace, we don't mess the network
         * and we can assume the eth%d rename will be eth0
	 */
	if (unshare(CLONE_NEWNET)) {
		perror("unshare");
		return -1;
	}		

	val = dev_name_hash("eth0");

	while (1) {

		snprintf(devname, IFNAMSIZ, "ethXXXXXX");
		mktemp(devname);

		val2 = dev_name_hash(devname);

		if (val == val2) {
			printf("'%s' has same hash entry\n", devname);
			break;
		}
	}

	/*
	 * We create a dummy interface with the conflicting name
	 * and then we rename it with an kernel allocated name
	 * The kernel will fail to rename with -ENFILE.
	 */

	sprintf(cmd, "ip link add %s type dummy", devname);

	if (system(cmd)) {
		perror("system");
		return -1;
	}

	sprintf(cmd, "ip link set name eth%%d dev %s", devname);
	printf("%s\n", cmd);
	system(cmd); 

	return 0;
}

--------------090205050905020903050505
Content-Type: text/x-diff;
 name="fix-dev_get_valid_name.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="fix-dev_get_valid_name.patch"

Subject: fix dev_get_valid_name
From: Daniel Lezcano <daniel.lezcano@free.fr>

the commit:

commit d90310243fd750240755e217c5faa13e24f41536
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Wed Nov 18 02:36:59 2009 +0000

    net: device name allocation cleanups

introduced a bug when there is a hash collision making impossible
to rename a device with eth%d. This bug is very hard to reproduce
and appears rarely.

The problem is coming from we don't pass a temporary buffer to
__dev_alloc_name but 'dev->name' which is modified by the function.

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
---
 net/core/dev.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c
+++ net-2.6/net/core/dev.c
@@ -936,18 +936,22 @@ int dev_alloc_name(struct net_device *de
 }
 EXPORT_SYMBOL(dev_alloc_name);
 
-static int dev_get_valid_name(struct net *net, const char *name, char *buf,
-			      bool fmt)
+static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt)
 {
+	struct net *net;
+
+	BUG_ON(!dev_net(dev));
+	net = dev_net(dev);
+
 	if (!dev_valid_name(name))
 		return -EINVAL;
 
 	if (fmt && strchr(name, '%'))
-		return __dev_alloc_name(net, name, buf);
+		return dev_alloc_name(dev, name);
 	else if (__dev_get_by_name(net, name))
 		return -EEXIST;
-	else if (buf != name)
-		strlcpy(buf, name, IFNAMSIZ);
+	else if (strncmp(dev->name, name, IFNAMSIZ))
+		 strlcpy(dev->name, name, IFNAMSIZ);
 
 	return 0;
 }
@@ -979,7 +983,7 @@ int dev_change_name(struct net_device *d
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
-	err = dev_get_valid_name(net, newname, dev->name, 1);
+	err = dev_get_valid_name(dev, newname, 1);
 	if (err < 0)
 		return err;
 
@@ -5083,7 +5087,7 @@ int register_netdevice(struct net_device
 		}
 	}
 
-	ret = dev_get_valid_name(net, dev->name, dev->name, 0);
+	ret = dev_get_valid_name(dev, dev->name, 0);
 	if (ret)
 		goto err_uninit;
 
@@ -5661,7 +5665,7 @@ int dev_change_net_namespace(struct net_
 		/* We get here if we can't use the current device name */
 		if (!pat)
 			goto out;
-		if (dev_get_valid_name(net, pat, dev->name, 1))
+		if (dev_get_valid_name(dev, pat, 1))
 			goto out;
 	}
 

--------------090205050905020903050505--
