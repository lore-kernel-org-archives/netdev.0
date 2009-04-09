From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13006] New: Bonding: Holes in arp_ip_target
 list cause ARP replies to be ignored
Date: Thu, 9 Apr 2009 14:18:34 -0700
Message-ID: <20090409141834.715a3d05.akpm@linux-foundation.org>
References: <bug-13006-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, steve@astutenetworks.com
To: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41709 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753506AbZDIVXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 17:23:16 -0400
In-Reply-To: <bug-13006-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 3 Apr 2009 20:17:37 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13006
> 
>                URL: www.astutenetworks.com
>            Summary: Bonding: Holes in arp_ip_target list cause ARP replies
>                     to be ignored
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: steve@astutenetworks.com
>         Regression: No
> 
> 
> I know there have been changes to bonding driver since 2.6.25, but
> this bug is still there.
> 
> To Recreate:
> 
> Set up a bond as follows:
>   mode active-backup
>   arp_interval 1000
>   arp_ip_target 1.1.1.1 2.2.2.2 (address 2 points to a reachable target)
> 
> /sys/class/net/bond0/bonding/active_slave contains an interface name
> 
> Now delete the first target (cat -1.1.1.1 >arp_ip_target)
> 
> The first target is deleted, but active_slave is now empty.
> 
> The proglem is in line 2611 of bond_main.c, in bond_validate_arp()
> 
>     for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
> 
> This is the loop that searches the arp_ip_targets array for a match
> with an incomming ARP.  The problem is that when we deleted the first
> entry, it was set to zero.  This "for" loop exits before comparing with
> the remaining entries in targets[].
> 
> One fix is to delete the " && targets[i]" from the termination conditions.
> Then the loop will always search the full list.
> 
> A better fix is to make sure there are no empty holes in the target[]
> array, beceause there may other code which expects no holes. 
> 
> This can be done by modifying this loop in bond_sysfs.c at line 792,
> which is where entries are deleted in bonding_store_arp_targets().
> This change deletes the hole just created by removing an entry.
> 
>         for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>             if (targets[i] == newtarget) {
>                 printk(KERN_INFO DRV_NAME
>                        ": %s: removing ARP target %d.%d.%d.%d.\n",
>                        bond->dev->name, NIPQUAD(newtarget));
>                 targets[i] = 0;
>                 done = 1;
> 
>                 // Move any entries after this one into the newly
>                 // empty slot, so there are no holes.  Be careful not to access
>                 // more than BOND_MAX_ARP_TARGETS in the array.
>                 for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j + 1];
> j++) {
>                     targets[j] = targets[j + 1];
>                     targets[j + 1] = 0;
>                 }
>             }
>         }1
> 
> 
> Here is the output of ver_linux:
> 
>  Linux caspianB012a 2.6.25-astute-v15 #19 SMP Fri Apr 3 09:32:28 PDT 2009 i686
> GNU/Linux
>  Gnu C                  18:
>  /stim2/steve/work/acp/host/caspian/pd/kernel/scripts/ver_linux: line 24: ld:
> command not found
>  binutils               
>  util-linux             2.13
>  mount                  2.13
>  module-init-tools      3.2-pre1
>  e2fsprogs              1.40
>  Linux C Library        2.5.90
>  /stim2/steve/work/acp/host/caspian/pd/kernel/scripts/ver_linux: line 69: ldd:
> command not found
>  Procps                 3.2.7
>  Net-tools              1.60
>  Kbd                    82:
>  Sh-utils               5.97
>  udev                   105
>  Modules Loaded         nfs lockd sunrpc pegasus iSCSITarget ScsiGatewayShim
> ScsiGateway an2000_l2pthru amod linux_user_bde linux_kernel_bde
> astute_hostapi_mod megaraid_sas an2k afpga e1000e ipmi_poweroff ipmi_watchdog
> ipmi_devintf ipmi_si ipmi_msghandler

