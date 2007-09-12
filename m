From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: update some distro-specific documentation
Date: Wed, 12 Sep 2007 14:18:40 -0400
Message-ID: <20070912181839.GD3754@gospo.rdu.redhat.com>
References: <20070830212429.GA12676@gospo.rdu.redhat.com> <21001.1189189669@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967457AbXILSXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 14:23:45 -0400
Content-Disposition: inline
In-Reply-To: <21001.1189189669@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 07, 2007 at 11:27:49AM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> 	This all looks fine except for one nit (well, request for extra
> detail, really):
> 
> >@@ -802,15 +802,20 @@ BROADCAST=192.168.1.255
> > ONBOOT=yes
> > BOOTPROTO=none
> > USERCTL=no
> >+BONDING_OPTS="mode=balance-alb miimon=100"
> >
> > 	Be sure to change the networking specific lines (IPADDR,
> > NETMASK, NETWORK and BROADCAST) to match your network configuration.
> >+You also need to set the BONDING_OPTS= line to specify the desired
> >+options for your bond0 interface.  Specifying bonding options in this
> >+way is the preferred method for configuring bonding interfaces.
> 
> 	Can you add something here that mentions that, for the
> arp_ip_target option, it has to be supplied as "arp_ip_target=+10.0.0.1"
> and not just "arp_ip_target=10.0.0.1"?  Also, multiple targets require
> multiple instances of the arp_ip_target option; it doesn't work to put
> multiple IP addresses as in the module option (i.e.,
> "arp_ip_target=10.0.0.1,10.0.0.2").
> 
> 	This is necessary because ifup-eth isn't adding the "+" when it
> translates the option for use with sysfs or parsing the multiple IP
> address syntax.
> 

Jay,

I could do that, or we could just take this as-is and get initscripts
fixed up to account for this.  Does that seem reasonable?

I'd rather go that route, and I've even got a patch that *seems* to work
already:

--- initscripts-8.45.17.EL/sysconfig/network-scripts/ifup-eth.orig
+++ initscripts-8.45.17.EL/sysconfig/network-scripts/ifup-eth
@@ -125,7 +125,16 @@ if [ "$ISALIAS" = no ] && is_bonding_dev
     for arg in $BONDING_OPTS ; do   
         key=${arg%%=*};
         value=${arg##*=};
-        echo $value > /sys/class/net/${DEVICE}/bonding/$key
+        OLDIFS=$IFS;
+        IFS=',';
+        if [ "${key}" = "arp_ip_target" ]; then
+           for arp_ip in $value; do
+             echo +$arp_ip > /sys/class/net/${DEVICE}/bonding/$key
+           done
+        else
+           echo $value > /sys/class/net/${DEVICE}/bonding/$key
+        fi
+        IFS=$OLDIFS;
     done
 
     /sbin/ip link set dev ${DEVICE} up

-andy


