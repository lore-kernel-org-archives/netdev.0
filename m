From: Karlis Peisenieks <karlis@mt.lv>
Subject: ip multicast bug
Date: Tue, 17 Feb 2004 17:55:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217155516.GA20477@mt.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Patch below fixes kernel crash when multicast group is joined on 
disabled interface with IP address added.

The problem is 
ip_mc_join_group->ip_mc_inc_group->igmp_group_added
->igmp_ifc_event->igmp_ifc_start_timer which does mod_timer on 
uninitialized timer_struct (mr_ifc_timer). As soon as timer fires, 
kernel crashes.

Multicast related fields of in_device are only initialized in ip_mc_up
which gets called when device is enabled.

Perhaps somebody with more clue on multicast implementation can comment 
on this fix - is this fix enough or maybe wrong.


Karlis

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="igmp.c.patch"

--- igmp.c	2 Dec 2003 08:53:00 -0000	1.1.1.7
+++ igmp.c	17 Feb 2004 15:51:58 -0000
@@ -1151,12 +1151,14 @@
 	im->next=in_dev->mc_list;
 	in_dev->mc_list=im;
 	write_unlock_bh(&in_dev->lock);
+
+	if (in_dev->dev->flags & IFF_UP) {
 #ifdef CONFIG_IP_MULTICAST
-	igmpv3_del_delrec(in_dev, im->multiaddr);
+		igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
-	igmp_group_added(im);
-	if (in_dev->dev->flags & IFF_UP)
+		igmp_group_added(im);
 		ip_rt_multicast_event(in_dev);
+	}
 out:
 	return;
 }

--17pEHd4RhPHOinZp--
