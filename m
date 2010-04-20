From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 12:56:20 -0700
Message-ID: <C7F354F4.29CC8%scofeldm@cisco.com>
References: <201004201548.26609.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:28161 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059Ab0DTT47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 15:56:59 -0400
In-Reply-To: <201004201548.26609.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/10 6:48 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Monday 19 April 2010, Scott Feldman wrote:
> 
>> IOV netlink (IOVNL) adds I/O Virtualization control support to a master
>> device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
>> control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
>> design allows for the case where master and slave are the
>> same netdev interface.
> 
> What is the reason for controlling the slave device through the master,
> rather than talking to the slave directly? The kernel always knows
> the master for each slave, so it seems to me that this information
> is redundant.

The interface would allow talking to the slave directly. In fact, that's the
example with enic port-profile in patch 2/2.  But, it would be nice not to
rule out the case where the master proxies slave control and the master is
under exclusively controlled by hypervisor.
 
> Is this new interface only for the case that you have a switch integrated
> in the NIC, or also for the case where you do an LLDP and EDP exchange
> with an adjacent bridge and put the device into VEPA mode?

All of the above.  Basing this on netlink give us flexibility to work with
user-space mgmt tools or directly with kernel netdev as in the enic case.
Not trying to make assumptions about where (user-space, kernel) and by which
entity sources or sinks the netlink msg.
 
>> One control setting example is MAC/VLAN settings for a VF.  Another
>> example control setting is a port-profile for a VF.  A port-profile is an
>> identifier that defines policy-based settings on the network port
>> backing the VF.  The network port settings examples are VLAN membership,
>> QoS settings, and L2 security settings, typical of a data center network.
>> 
>> This patch adds the iovnl interface definitions and an iovnl module.
> 
> How does this relate to the existing DCB netlink interface? My feeling
> is that there is some overlap in how it would get used, and some parts
> that are very distinct. In particular, I'd guess that you'd want to
> be able to set DCB parameters for each VF, but not all DCB adapters
> would support SR-IOV.
>
> Did you consider making this code an extension to the DCB interface
> instead of a separate one? What was the reason for your decision
> to keep it separate?

Considered it but DCB interface is well defined for DCB and it didn't seem
right gluing on interfaces not specified within DCB.  I agree that there is
some overlap in the sense that both interface are used to configure a netdev
with some properties interesting for the data center, but the DCB interface
is for local setting of the properties on the host whereas iovnl is about
pushing the setting of those properties to the network for policy-based
control.
 
> Also, do you expect your interface to be supported by dcbd/lldpad,
> or is there a good reason to create a new tool for iovnl?

Lldpad supporting this interface would seem right, for those cases where
lldpad is responsible for configuring the netdev.
 
>> + * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
>> + * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)
> 
> Can you elaborate more on what these do? Who is the 'client' and the 'host'
> in this case, and why do you need to identify them?

Those are optional and useful, for example, by the network mgmt tool for
presenting a view such as:

    - blade 1/2                     // know by host uuid
        - vm-rhel5-eth0             // client name
            - port-profile: xyz

Something like that.
 
>> + * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])
> 
> Just one mac address? What happens if we want to assign multiple mac
> addresses to the VF later? Also, how is this defined specifically?
> Will a SIOCSIFHWADDR with a different MAC address on the VF fail
> later, or is this just the default value?

Depends on how the VF wants to handle this.  For our use-case with enic we
only need the port-profile op so I'm not sure what the best design is for
mac+vlan on a VF.  Looking for advise from folks like yourself.  If it's not
needed, let's scratch it.

-scott

