From: John Valko <jovalko@cisco.com>
Subject: Re: Bonding MAC failover behavior with VLAN interfaces
Date: Sat, 13 Feb 2016 18:28:20 -0500
Message-ID: <56BFBC14.5010807@cisco.com>
References: <56BAA15F.4080609@cisco.com> <12288.1455310724@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Dwight Frye (dfrye)" <dfrye@cisco.com>,
	Wally Dixon <wdixon@cisco.com>,
	"Leo Lee (lelee2)" <lelee2@cisco.com>,
	"Nishant Thakre (nthakre)" <nthakre@cisco.com>,
	"Parvez Shaikh (pshaikh)" <pshaikh@cisco.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-3.cisco.com ([173.37.86.74]:55035 "EHLO
	rcdn-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcBMXh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 18:37:56 -0500
In-Reply-To: <12288.1455310724@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2016 03:58 PM, Jay Vosburgh wrote:
> John Valko <jovalko@cisco.com> wrote:
>
>> Hi all,
>>
>> I have observed the following on CentOS 6 using the
>> 2.6.32-573.8.1.el6.x86_64 kernel as well as Ubuntu 15.10 with
>> 4.2.0-25-generic.. I have not yet tried with a vanilla kernel but with the
>> large time/distro gap it didn't seem likely to be caused by distro
>> changes.
> [ ...example of VLAN-over-bond's MAC not changing when bonding
> fail_over_mac=active has a failover... ]
>
>> So, herein lies my confusion.  I expect that the VLAN interfaces should
>> also pick up the new MAC address, but they don't.  It seems like a bug to
>> me, but I don't want to be presumptuous so if in fact this is expected
>> behavior, how do you recommend we approach making it switch when the bond
>> fails over?  Right now, the MAC must be manually set for each vlan
>> interface.
> [...]
>> I can see it set the mac of the bond to the new active slave MAC, but I
>> don't see any indication of looping over vlan interfaces or anything, if
>> that is expected... or would it be expected that the 8021q module receives
>> an event that should make it change?
> 	Your observation is correct: the fail_over_mac functionality
> does not propagate beyond the bonding master device itself.  The
> presumption at the VLAN level is that the underlying device can support
> multiple MAC addresses; this same effect (different MACs between VLAN
> and its lower device) occurs if the device logically below a VLAN
> interface changes its MAC.  This is handled by vlan_sync_address, which
> is called via the NETDEV_CHANGEADDR notifier (which happens when the
> bonding master changes its MAC due to f_o_m=active).
>
> 	The original need for f_o_m=active was IPoIB devices that cannot
> change their MAC address.  Those don't support VLANs, either, so
> propagation to VLANs was not a consideration.
>
> 	In your "real" SR-IOV sitation, is there something that
> necessitates the use of fail_over_mac=active (I don't recall that SR-IOV
> itself prohibits a VF from changing its MAC address), or is this being
> done for other reasons?
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
Hi Jay,

Thanks for your response.  I see in vlan.c the code you mentioned where 
the VLAN interface receives the NETDEV_CHANGEADDR.  And, after thinking 
on it for a while it would probably be undesirable (or at least not so 
useful) for a VLAN interface to follow the MAC of whatever interface 
it's attached to in general.

However, with SR-IOV in our case the reason we are using the active 
f_o_m policy is that the Intel NIC we are using implements anti-spoofing 
rules which will cause any frames with the old MAC to appear as spoofed 
and to be dropped.  While it is possible to disable this feature, we are 
deploying into a customer cloud where the customer has said they do not 
want it turned off.

Our current plan is to work around this by instead creating the VLAN 
interfaces directly on top of the VFs and then bonding each pair of 
those, so that the MAC of each VLAN interface never needs to change.  
The result feels perhaps less elegant but should work we think.

Since the original implementation of the active failover policy didn't 
consider VLAN interfaces, would it be reasonable to extend it so that 
when this policy is selected and there are VLAN interfaces on top of the 
bond that those change as well (e.g. by adding a check in 
vlan_sync_address())?  If that's a reasonable proposal I may be 
interested in taking a crack at a patch to submit.

Thanks,

--John
