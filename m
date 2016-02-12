From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Bonding MAC failover behavior with VLAN interfaces
Date: Fri, 12 Feb 2016 12:58:44 -0800
Message-ID: <12288.1455310724@famine>
References: <56BAA15F.4080609@cisco.com>
Cc: netdev@vger.kernel.org, "Dwight Frye (dfrye)" <dfrye@cisco.com>,
	Wally Dixon <wdixon@cisco.com>,
	"Leo Lee (lelee2)" <lelee2@cisco.com>,
	"Nishant Thakre (nthakre)" <nthakre@cisco.com>,
	"Parvez Shaikh (pshaikh)" <pshaikh@cisco.com>
To: John Valko <jovalko@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49694 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcBLU6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 15:58:47 -0500
In-reply-to: <56BAA15F.4080609@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Valko <jovalko@cisco.com> wrote:

>Hi all,
>
>I have observed the following on CentOS 6 using the
>2.6.32-573.8.1.el6.x86_64 kernel as well as Ubuntu 15.10 with
>4.2.0-25-generic.. I have not yet tried with a vanilla kernel but with the
>large time/distro gap it didn't seem likely to be caused by distro
>changes.

[ ...example of VLAN-over-bond's MAC not changing when bonding
fail_over_mac=active has a failover... ]

>So, herein lies my confusion.  I expect that the VLAN interfaces should
>also pick up the new MAC address, but they don't.  It seems like a bug to
>me, but I don't want to be presumptuous so if in fact this is expected
>behavior, how do you recommend we approach making it switch when the bond
>fails over?  Right now, the MAC must be manually set for each vlan
>interface.
[...]
>I can see it set the mac of the bond to the new active slave MAC, but I
>don't see any indication of looping over vlan interfaces or anything, if
>that is expected... or would it be expected that the 8021q module receives
>an event that should make it change?

	Your observation is correct: the fail_over_mac functionality
does not propagate beyond the bonding master device itself.  The
presumption at the VLAN level is that the underlying device can support
multiple MAC addresses; this same effect (different MACs between VLAN
and its lower device) occurs if the device logically below a VLAN
interface changes its MAC.  This is handled by vlan_sync_address, which
is called via the NETDEV_CHANGEADDR notifier (which happens when the
bonding master changes its MAC due to f_o_m=active).

	The original need for f_o_m=active was IPoIB devices that cannot
change their MAC address.  Those don't support VLANs, either, so
propagation to VLANs was not a consideration.

	In your "real" SR-IOV sitation, is there something that
necessitates the use of fail_over_mac=active (I don't recall that SR-IOV
itself prohibits a VF from changing its MAC address), or is this being
done for other reasons?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
