From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: update some distro-specific documentation
Date: Mon, 17 Sep 2007 17:46:29 -0400
Message-ID: <20070917214628.GB9140@gospo.rdu.redhat.com>
References: <20070830212429.GA12676@gospo.rdu.redhat.com> <21001.1189189669@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756221AbXIQVqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 17:46:34 -0400
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
> 	-J

Jay,

I took your advice -- here's an updated patch.

-andy


Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bonding.txt |   53 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1da5666..2402412 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -755,9 +755,9 @@ the system /etc/modules.conf or /etc/modprobe.conf configuration file.
 ------------------------------------------
 
 	This section applies to distros using a version of initscripts
-with bonding support, for example, Red Hat Linux 9 or Red Hat
-Enterprise Linux version 3 or 4.  On these systems, the network
-initialization scripts have some knowledge of bonding, and can be
+with bonding support, for example, Red Hat Linux 9, Red Hat Enterprise
+Linux version 3, 4 or 5, Fedora, etc.  On these systems, the network
+initialization scripts have some knowledge of bonding, and can be 
 configured to control bonding devices.
 
 	These distros will not automatically load the network adapter
@@ -802,18 +802,27 @@ BROADCAST=192.168.1.255
 ONBOOT=yes
 BOOTPROTO=none
 USERCTL=no
+BONDING_OPTS="mode=active-backup arp_monitor=+192.168.1.254"
 
 	Be sure to change the networking specific lines (IPADDR,
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
-
-	Finally, it is necessary to edit /etc/modules.conf (or
+You also need to set the BONDING_OPTS= line to specify the desired
+options for your bond0 interface.  Specifying bonding options in this
+way is the preferred method for configuring bonding interfaces.  The
+options specified in BONDING_OPTS are identical to the bonding module
+parameters except for the arp_monitor field.  Each target should be
+included as a separate address and should be preceded by a '+' to 
+indicate it should be added to the list of queried targets.
+
+	It is no longer necessary to edit /etc/modules.conf (or
 /etc/modprobe.conf, depending upon your distro) to load the bonding
 module with your desired options when the bond0 interface is brought
 up.  The following lines in /etc/modules.conf (or modprobe.conf) will
-load the bonding module, and select its options:
+load the bonding module, and select its options but this is no longer
+the preferred method.
 
 alias bond0 bonding
-options bond0 mode=balance-alb miimon=100
+options bond0 mode=active-backup arp_monitor=192.168.1.254
 
 	Replace the sample parameters with the appropriate set of
 options for your configuration.
@@ -826,8 +835,9 @@ up and running.
 ---------------------------------
 
 	Recent versions of initscripts (the version supplied with
-Fedora Core 3 and Red Hat Enterprise Linux 4 is reported to work) do
-have support for assigning IP information to bonding devices via DHCP.
+Fedora Core 3 and Red Hat Enterprise Linux 4 and later is reported to
+work) do have support for assigning IP information to bonding devices
+via DHCP.
 
 	To configure bonding for DHCP, configure it as described
 above, except replace the line "BOOTPROTO=none" with "BOOTPROTO=dhcp"
@@ -837,18 +847,19 @@ is case sensitive.
 3.2.2 Configuring Multiple Bonds with Initscripts
 -------------------------------------------------
 
-	At this writing, the initscripts package does not directly
-support loading the bonding driver multiple times, so the process for
-doing so is the same as described in the "Configuring Multiple Bonds
-Manually" section, below.
-
-	NOTE: It has been observed that some Red Hat supplied kernels
-are apparently unable to rename modules at load time (the "-o bond1"
-part).  Attempts to pass that option to modprobe will produce an
-"Operation not permitted" error.  This has been reported on some
-Fedora Core kernels, and has been seen on RHEL 4 as well.  On kernels
-exhibiting this problem, it will be impossible to configure multiple
-bonds with differing parameters.
+	Initscripts packages that are included with Fedora 7 and Red
+Hat Enterprise Linux 5 support multiple bonding interfaces by simply
+specifying the appropriate BONDING_OPTS= in ifcfg-bondX where X is
+the number of the bond.  Other distros may not include support in
+initscripts for multiple bonding interfaces, so you may need to follow
+the process as described in the "Configuring Multiple Bonds Manually"
+section, below.
+
+	It has been observed that much older kernels are apparently
+unable to rename modules at load time (the "-o bond1" part).  Attempts
+to pass that option to modprobe will produce an "Operation not 
+permitted" error.  On kernels exhibiting this problem, it will be 
+impossible to configure multiple bonds with differing parameters.
 
 3.3 Configuring Bonding Manually with Ifenslave
 -----------------------------------------------
