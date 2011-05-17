From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 1/1] igmp: call ip_mc_clear_src() only when we have no
 users of ip_mc_list
Date: Tue, 17 May 2011 15:38:01 +0200
Message-ID: <20110517133801.GC30366@darkmag.usersys.redhat.com>
References: <20110515165945.GA20024@darkmag.usersys.redhat.com>
 <20110516.140359.111037536766782557.davem@davemloft.net>
 <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	mmarek@suse.cz, netdev@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In igmp_group_dropped() we call ip_mc_clear_src(), which resets the number
of source filters per mulitcast. However, igmp_group_dropped() is also
called on NETDEV_DOWN, NETDEV_PRE_TYPE_CHANGE and NETDEV_UNREGISTER, which
means that the group might get added back on NETDEV_UP, NETDEV_REGISTER and
NETDEV_POST_TYPE_CHANGE respectively, leaving us with broken source
filters.

To fix that, we must clear the source filters only when there are no users
in the ip_mc_list, i.e. in ip_mc_dec_group().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1fd3d9c..732e30b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1182,7 +1182,6 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 	}
 done:
 #endif
-	ip_mc_clear_src(im);
 }
 
 static void igmp_group_added(struct ip_mc_list *im)
@@ -1319,6 +1318,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 				*ip = i->next_rcu;
 				in_dev->mc_count--;
 				igmp_group_dropped(i);
+				ip_mc_clear_src(i);
 
 				if (!in_dev->dead)
 					ip_rt_multicast_event(in_dev);
