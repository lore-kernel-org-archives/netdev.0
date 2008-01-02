From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take2] Re: Nested VLAN causes recursive locking error
Date: Thu, 3 Jan 2008 00:41:08 +0100
Message-ID: <20080102234107.GA6902@ami.dom.local>
References: <m3r6h0dvtz.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:11254 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbYABXjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 18:39:09 -0500
Received: by fk-out-0910.google.com with SMTP id z23so6384441fkz.5
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 15:39:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <m3r6h0dvtz.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen wrote, On 01/02/2008 05:40 PM:
...
> The box that shows the problem is "almost-production", so it doesn't
> have a build system. Is there a chance you could get the patch into
> Rawhide or some other testing repository? It takes forever and a lot
> of disk space to rebuild a kernel RPM, so if I could get someone else
> to do the hard work, that would be lovely...
> 
> If not, I'll probably find the time to do the RPM rebuild sometime
> within the next week or so.

...I guess this is to Chuck?

As a matter of fact I started to doubt it's a real problem: 2 vlan
headers in the row - is it working?

Anyway, as Patrick pointed, the previous patch was a bit buggy, and
deeper nesting needs a little more (if it's can work too...). So,
here is something minimal.

Patrick, if you think about something else, then of course don't care
about this patch.

Regards,
Jarek P.

------------------> (take 2)

Subject: [PATCH] nested VLAN: fix lockdep's recursive locking warning

Allow vlans nesting other vlans without lockdep's warnings (max. 2 levels
i.e. parent + child). Thanks to Patrick McHardy for pointing a bug in the
first version of this patch.

Reported-by: Benny Amorsen
Tested-by: Benny Amorsen	(?) STILL NEEDS TESTING!

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-rc6-mm1-/net/8021q/vlan.c 2.6.24-rc6-mm1+/net/8021q/vlan.c
--- 2.6.24-rc6-mm1-/net/8021q/vlan.c	2007-12-23 14:55:38.000000000 +0100
+++ 2.6.24-rc6-mm1+/net/8021q/vlan.c	2008-01-02 23:50:19.000000000 +0100
@@ -323,6 +323,7 @@ static const struct header_ops vlan_head
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~IFF_UP;
@@ -349,7 +350,11 @@ static int vlan_dev_init(struct net_devi
 		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
 	}
 
-	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
+		subclass = 1;
+
+	lockdep_set_class_and_subclass(&dev->_xmit_lock,
+				&vlan_netdev_xmit_lock_key, subclass);
 	return 0;
 }
 
