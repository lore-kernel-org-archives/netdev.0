From: Larry Baker <baker@usgs.gov>
Subject: PROBLEM: decnet: /proc/sys/net/decnet sysctl entries disappear (2.6.27 through 3.3.x)
Date: Tue, 12 Feb 2013 14:13:11 -0800
Message-ID: <E7A56FB5-BAC1-4C41-8103-61ABA321EA88@usgs.gov>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:52900 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896Ab3BLWNO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 17:13:14 -0500
In-Reply-To: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PROBLEM

decnet: /proc/sys/net/decnet sysctl entries disappear (2.6.27 through 3.3.x)

DESCRIPTION

The decnet kernel module is configured using entries under /proc/sys/net/decnet.  There are DECnet executor (host) node settings in /proc/sys/net/decnet, template network device settings in /proc/sys/net/decnet/conf/{ddcmp,ethernet,ipgre,loopback}, and active network device settings for DECnet devices in /proc/sys/net/decnet/conf/{lo,eth0,...}.  The normal sequence is to load the decnet module, configure the module, then load a deamon to handle remote file access requests.

When I load the decnet module and configure it on the latest Arch Linux ARM kernel (3.1.10-15-ARCH), most of the /proc/sys/net/decnet sysctl entries disappear.  I found the same behavior when I tested the decnet module on the latest CentOS (Red Hat) 6.3 x86_64 kernel (2.6.32-279.19.1.el6.x86_64).  The latest CentOS 5.9 i386 kernel (2.6.18-348.1.1.el5) does not exhibit this behavior; the CentOS 6.0 i386 kernel (2.6.32-71.el6.i686) is the earliest CentOS kernel that exhibits this behavior.

This is the expected behavior (CentOS 5.9 i386):

> # modprobe decnet   <--- load the decnet kernel module

> # ls /proc/sys/net/decnet   <--- there are static sysctl entries in /proc/sys/net/decnet
> conf        decnet_rmem     di_count  dst_gc_interval  no_fc_max_cwnd
> debug       decnet_wmem     dn_count  node_address     time_wait
> decnet_mem  default_device  dr_count  node_name

> # ls /proc/sys/net/decnet/conf   <--- there are both static and dynamic (eth0 and lo) sysctl entries in /proc/sys/net/decnet/conf
> ddcmp  eth0  ethernet  ipgre  lo  loopback

> # echo 0.0 >/proc/sys/net/decnet/node_address   <--- set the DECnet node address (the number does not matter)

> # ls /proc/sys/net/decnet   <--- the sysctl entries in /proc/sys/net/decnet are still there
> conf        decnet_rmem     di_count  dst_gc_interval  no_fc_max_cwnd
> debug       decnet_wmem     dn_count  node_address     time_wait
> decnet_mem  default_device  dr_count  node_name

> # ls /proc/sys/net/decnet/conf   <--- so are the sysctl entries in /proc/sys/net/decnet/conf
> ddcmp  eth0  ethernet  ipgre  lo  loopback

This is the aberrant behavior (CentOS 6.0 i386):

> # modprobe decnet

> # ls /proc/sys/net/decnet
> conf        decnet_rmem     di_count  dst_gc_interval  no_fc_max_cwnd
> debug       decnet_wmem     dn_count  node_address     time_wait
> decnet_mem  default_device  dr_count  node_name

> # ls /proc/sys/net/decnet/conf
> ddcmp  eth0  ethernet  ipgre  lo  loopback

> # echo 0.0 >/proc/sys/net/decnet/node_address

> # ls /proc/sys/net/decnet   <--- after writing to/proc/sys/net/decnet/node_address, all the static sysctl entries in /proc/sys/net/decnet are gone
> conf

> # ls /proc/sys/net/decnet/conf   <--- so are all the static sysctl entries in /proc/sys/net/decnet/conf (because only the dynamic entries have been reregistered)
> eth0  lo

DIAGNOSIS

I found that the disappearance of the decnet /proc/sys/net/decnet sysctl entries coincided with a change in the sysctl subsystem from using a list to a tree for the ctl_table data structures.  I corresponded with Eric Biederman, the maintainer of sysctl, and described the change in behavior and my diagnosis that the sysctl changes were suspect.  Eric described what was likely the source of the problem:

> Looking into the git history it looks like the last substantive change
> to 2.6.32 was Al Viro's sysctl optimization that avoided walking the
> entire sysctl structure on look ups.  Unfortunately it made the
> assumption that there would always be an empty directory created if
> there were multiple children registered in that that directory.  The
> common sysctls the few places this wasn't true were fixed rather
> quickly.  Apparently for decnet no one noticed.
> 
> The good news is that my latest rework of the sysctls made a verifiable
> set of assumptions.  So it will probably just work although there is a
> slight chance the modern code will error out with sensible error
> message.


SOLUTION

Eric was also kind enough to verify that his later rewrite of the sysctl code cured the problem:

> My rewrite to remove the silly assumption
> and to make sysctl even more scalable was merged in 3.4-rc1.  So
> anything 3.4 based or later should work.

and

> I have confirmed in the lastest kernel I can set the decnet node address
> without all of the sysctl files going away.  So it looks like I fixed
> the bug you are running into.


PATCHES

I still care about running DECnet on CentOS and Arch Linux ARM.  Following Eric's guidance, I rearranged the order that the /proc/sys/net/decnet sysctl entries are created and I added an empty /proc/sys/net/decnet/conf sysctl entry to workaround the sysctl tree walking bug.  I made three sets of patches that cover the changes to the sysctl API over time:

. Kernels 2.6.27 through 2.6.32 (tree-structured sysctl, struct ctl_path includes .ctl_name) - e.g., for the current CentOS (Red Hat)
. Kernels 2.6.33 through 3.4.x (struct ctl_path no longer includes .ctl_name, rtnl_register() adds rtnl_calcit_func calcit) - e.g., for the current Arch Linux ARM
. Kernels 3.5 and later (register_net_sysctl()/unregister_net_sysctl_table() in place of register_sysctl_paths()/unregister_sysctl_table()) - for the current trunk

As I described in my earlier post (11 February 2013 4:26:00 PM PST), my patches include more than just this fix, so they are not yet ready to submit.  However, I am using the first two in my application systems, so I am confident they work and there is no need for anyone else to work on a fix.

My questions for this forum are:

. Which patches (if any) should be submitted to netdev@vger.kernel.org?
. Which patches (if any) should be submitted to stable@vger.kernel.org?
. Should I prepare be a patch file for every kernel major.minor version?
. If not, which kernel major.minor versions should I create a patch file for?
. How should they be labeled to indicate they are related but distinct?
. The decnet dmesg banner is stale -- it has not changed in years.  Should that be changed?  To what?  What's the numbering scheme?  By me?  By the maintainer?

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov
