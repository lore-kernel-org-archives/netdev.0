From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 9 Aug 2012 17:52:57 -0300
Message-ID: <20120809175257.30983523@obelix.rh>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com>
	<1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
	<20120809163906.6dc0b6d4@obelix.rh>
	<20120809195539.GB1783@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573Ab2HIUxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 16:53:13 -0400
In-Reply-To: <20120809195539.GB1783@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Aug 2012 21:55:39 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Thu, Aug 09, 2012 at 09:39:06PM CEST, fbl@redhat.com wrote:
> >On Thu, 9 Aug 2012 20:03:23 +0100
> >Ben Hutchings <bhutchings@solarflare.com> wrote:
> >
> >> On Thu, 2012-08-09 at 15:30 -0300, Flavio Leitner wrote:
> >> > It doesn't make any sense to allow the master to become
> >> > its slave. That creates a loop of events causing a crash.
> >> 
> >> What if there are other intermediate devices, e.g. the slave is a VLAN
> >> sub-device of the bond?  And doesn't team also have this problem?
> >> 
> >> I think a more general check for such loops might be required.
> >
> >Maybe patching netdev_set_master() to fail in the loop case is
> >the way to go.  That would work for bonding, team and bridge.
> >
> >What you think?
> 
> How about other devices who do not use "->master" like vlan, macvlan?

Didn't get you. This is what I had in mind, just to show the idea.

diff --git a/net/core/dev.c b/net/core/dev.c
index f91abf8..a404afb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4424,6 +4424,24 @@ static int __init dev_proc_init(void)
 #define dev_proc_init() 0
 #endif	/* CONFIG_PROC_FS */
 
+bool netdev_check_loop(struct net_device *master, struct net_device *dev)
+{
+	if (master == dev)
+		return true;
+
+	if (is_vlan_dev(dev))
+		return nedev_check_loop(vlan_dev_real_dev(dev));
+
+	/* is a bridge ?*/
+	if (dev->priv_flags & IFF_EBRIDGE) {
+		list_for_each_entry(p, &br->port_list, list) {
+			if (nedev_check_loop(p->dev))
+				return true;
+		}
+	}
+
+	return false;
+}
 
 /**
  *	netdev_set_master	-	set up master pointer
@@ -4447,6 +4465,9 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 		dev_hold(master);
 	}
 
+	if (netdev_check_loop(master, slave))
+		return -EINVAL;
+
 	slave->master = master;
 
 	if (old)


fbl
