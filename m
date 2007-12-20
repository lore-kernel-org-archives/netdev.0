From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: Nested VLAN causes recursive locking error
Date: Thu, 20 Dec 2007 14:52:53 +0100
Message-ID: <20071220135253.GA10932@ff.dom.local>
References: <476851DB.5080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:13377 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbXLTNro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 08:47:44 -0500
Received: by ug-out-1314.google.com with SMTP id z38so456284ugc.16
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 05:47:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <476851DB.5080107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-12-2007 00:03, Chuck Ebbert wrote:
> From:
> https://bugzilla.redhat.com/show_bug.cgi?id=426164
> 
> 
> kernel version is 2.6.24-0.107.rc5.git3.fc9
> 
> From boot log on serial console:
> (full log attached)
> 
> Added VLAN with VID == 2 to IF -:eth0.1568:-
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.24-0.107.rc5.git3.fc9 #1
> ---------------------------------------------
> ifconfig/15011 is trying to acquire lock:
>  (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d9450>] dev_mc_sync+0x1c/0x102
> 
> but task is already holding lock:
>  (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d51bd>] dev_set_rx_mode+0x14/0x3c
> 
> other info that might help us debug this:
> 2 locks held by ifconfig/15011:
>  #0:  (rtnl_mutex){--..}, at: [<c05de4f7>] rtnl_lock+0xf/0x11
>  #1:  (&vlan_netdev_xmit_lock_key){-+..}, at: [<c05d51bd>] dev_set_rx_mode+0x14/0x3c
...


Subject: [PATCH] nested VLAN: fix lockdep's recursive locking warning

Allow vlans nesting other vlans without lockdep's warnings (max. 8 levels).

Reported-by: Benny Amorsen
Tested-by: Benny Amorsen	(?) NEEDS TESTING!

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp linux-2.6.24-rc5-/net/8021q/vlan.c linux-2.6.24-rc5+/net/8021q/vlan.c
--- linux-2.6.24-rc5-/net/8021q/vlan.c	2007-12-17 13:29:19.000000000 +0100
+++ linux-2.6.24-rc5+/net/8021q/vlan.c	2007-12-20 14:21:02.000000000 +0100
@@ -307,12 +307,15 @@ int unregister_vlan_device(struct net_de
 	return ret;
 }
 
+#ifdef CONFIG_LOCKDEP
 /*
  * vlan network devices have devices nesting below it, and are a special
  * "super class" of normal network devices; split their locks off into a
  * separate class since they always nest.
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
+static int subclass; /* vlan nesting vlan */
+#endif
 
 static const struct header_ops vlan_header_ops = {
 	.create	 = vlan_dev_hard_header,
@@ -349,7 +352,14 @@ static int vlan_dev_init(struct net_devi
 		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
 	}
 
-	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+#ifdef CONFIG_LOCKDEP
+	if ((real_dev->priv_flags & IFF_802_1Q_VLAN) &&
+	    subclass < MAX_LOCKDEP_SUBCLASSES - 1)
+		subclass++;
+
+	lockdep_set_class_and_subclass(&dev->_xmit_lock,
+				&vlan_netdev_xmit_lock_key, subclass);
+#endif
 	return 0;
 }
 
