From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for
 enic dynamic vnics
Date: Wed, 28 Apr 2010 11:39:01 -0700
Message-ID: <C7FDCED5.2C841%scofeldm@cisco.com>
References: <201004281532.47875.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:30362 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755159Ab0D1SjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:39:20 -0400
In-Reply-To: <201004281532.47875.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/10 6:32 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 28 April 2010, Scott Feldman wrote:
>> +static int enic_set_port_profile(struct net_device *netdev,
>> +       struct ifla_port_profile *ipp)
>> +{
>> +       struct enic *enic = netdev_priv(netdev);
>> +       struct vic_provinfo *vp;
>> +       u8 oui[3] = VIC_PROVINFO_CISCO_OUI;
>> +       u8 *mac = ipp->mac;
>> +       int err;
>> +
>> +       memset(&enic->port_profile, 0, sizeof(enic->port_profile));
>> +
>> +       if (!enic_is_dynamic(enic))
>> +               return -EOPNOTSUPP;
> 
> Not sure I understand how this fits together. You said in an earlier mail:
> 
>>> Anything that ties port profiles to VFs seems fundamentally flawed AFAICT,
>>> at least when we want to extend this to adapters that don't do it in
>>> firmware.
>> 
>> Ya, I tend I agree.  Let's just make port-profile a setting of any netdev,
>> an eth, macvtap, eth.x, bond, etc.  That's probably what I should have done
>> in the first place.  Something like:
> 
> I thought you had meant that we can do the association of attached interfaces
> through any interface, rather than tying it to the slave interface. While I'm
> not sure I read your code correctly, it seems like you now only talk to the
> slave interface, not to the master at all!
> 
> At least the check above should be 'if (enic_is_dynamic(enic)) return
> -EOPNOTSUPP', not the other way round.
> Moreover, if the netdev is the master here, you only allow a single slave,
> which is not enough for larger setups (n > 1), though that could be a
> limitation of your first version.

The code is correct.  I probably confused you with earlier patches trying to
accommodate master/slave devices and you might have assumed enic was such a
device.  But it's not.  For enic, there are two device IDs, let's call one
"static" and the other "dynamic".  The only difference between the two is
static enics load up fully ready to go just like a normal nic, whereas
dynamic enics load up but can't yet pass traffic because they're not
"plugged in" to the network.  To plug them in, you need to associate a
port-profile.  The physical analogy is this: server admin tells network
admin: plug my nic into a switch port with these characteristics.  Here, the
port-profile describes those switch port characteristics.  Now, there is no
master/slave relationship between static and dynamic enics.  There could be
with a simple firmware update, but it's not there today.  Also, I want to
point out that a single phys Cisco nic can be provisioned to expose many
static and/or many dynamic enics to the host.  On the order of 100s.  The
code above is to block port-profile association on static enics.  Static
enics where already provisioned on the network when created so there is no
need for a port-profile push from the host.
 
> Passing just the slave device however would not work in the general case, as I
> tried to point out in the mail you replied to. If the slave interface is owned
> by a guest using PCI passthrough, or it sits below a stack of nested
> interfaces
> (vlan, bridge, tap, vhost, ...), it's impossible to know what interface is
> responsible for setting up the slave.

For port-profile, we want to pass the device that is to be "plugged-in" to
the network based on port-profile association.  This is the device that
gives basic connectivity to the guest interface, regardless of how the guest
interface is wired to the device.  It could be direct PCI pass-thru, macvtap
stack, some yet-to-be-invented kernel-bypass stack, etc.

> Note that you cannot perform the association
> through the slave interface itself because the remote switch would discard any
> traffic originating from an unassociated interface.

That's not a limitation of our device/switch.

-scott

