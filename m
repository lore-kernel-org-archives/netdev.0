From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Panic in ipv6_add_dev
Date: Mon, 09 Jun 2003 17:55:46 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EE52C92.4060509@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru, "David S. Miller" <davem@redhat.com>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am using 2.5.70 and using VLAN to configure many interfaces, and after some 
are configured, the system panics in unregister_sysctl_table called from (STACK) 
neigh_sysctl_unregister, neigh_parms_release, ipv_add_dev. The problem is that 
we have called neigh_parms_alloc, but not neigh_sysctl_register. Hence calling 
neigh_parms_release() in the middle frees up the sysctl_header entry for the 
nd_table as a side-effect (due to the memcpy in neigh_parms_alloc).

We need to initialize sysctl_table to NULL in neigh_parms_alloc so that a 
release can be called safely at any time.

Thanks,

- KK

diff -ruN linux-2.5.70.org/net/core/neighbour.c linux-2.5.70/net/core/neighbour.c
--- linux-2.5.70.org/net/core/neighbour.c	2003-06-09 17:32:10.000000000 -0700
+++ linux-2.5.70/net/core/neighbour.c	2003-06-09 17:36:22.000000000 -0700
@@ -1094,6 +1094,7 @@
  			kfree(p);
  			return NULL;
  		}
+		p->sysctl_table = NULL;
  		write_lock_bh(&tbl->lock);
  		p->next		= tbl->parms.next;
  		tbl->parms.next = p;


