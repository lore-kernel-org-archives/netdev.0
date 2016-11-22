From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port
	configuration
Date: Tue, 22 Nov 2016 09:56:30 -0800
Message-ID: <e9bbd22e-215f-a1fd-62ba-c0d33b255154@gmail.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
	<20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: idosch@mellanox.com, andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jiri@mellanox.com, davem@davemloft.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 11/22/2016 09:41 AM, Ido Schimmel wrote:
> Hi Florian,
> 
> On Mon, Nov 21, 2016 at 11:09:22AM -0800, Florian Fainelli wrote:
>> Hi all,
>>
>> This patch series allows using the bridge master interface to configure
>> an Ethernet switch port's CPU/management port with different VLAN attributes than
>> those of the bridge downstream ports/members.
>>
>> Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
>> tested this with b53 and a mockup DSA driver.
> 
> We'll need to add a check in mlxsw and ignore any VLAN configuration for
> the bridge device itself. Otherwise, any configuration done on br0 will
> be propagated to all of its slaves, which is incorrect.
> 
>>
>> Open questions:
>>
>> - if we have more than one bridge on top of a physical switch, the driver
>>   should keep track of that and verify that we are not going to change
>>   the CPU port VLAN attributes in a way that results in incompatible settings
>>   to be applied
>>
>> - if the default behavior is to have all VLANs associated with the CPU port
>>   be ingressing/egressing tagged to the CPU, is this really useful?
> 
> First of all, I want to be sure that when we say "CPU port", we're
> talking about the same thing. In mlxsw, the CPU port is a pipe between
> the device and the host, through which all packets trapped to the host
> go through. So, when a packet is trapped, the driver reads its Rx
> descriptor, checks through which port it ingressed, resolves its netdev,
> sets skb->dev accordingly and injects it to the Rx path via
> netif_receive_skb(). The CPU port itself isn't represented using a
> netdev.

In the case of DSA, the CPU port is a normal Ethernet MAC driver, but in
premise, this driver plus the DSA tag protocol hook do exactly the same
things as you just describe.

> 
> Given the above, having VLAN filters (or STP) on the CPU port itself
> isn't really helpful (we do have them for physical ports of course...).
> So, mlxsw will not benefit from this patchset and if we've the same
> concept of "CPU port", then I'm not sure why you don't just enable all
> the VLANs on it?

We do enable all VLANs on the CPU port (at least with b53, but I think
mv88e6xxx does it too), but compared to e.g: mlxsw, we trap all traffic
by default, and actually, quite often (always actually, until we add IP
routing offloads) the CPU is involved in the LAN/WAN routing, so it is
not infrequent to have the following packet flow:

LAN port -> VLAN 1 -> eth0.1 -> NAT/routing -> eth0.2 -> VLAN 2 -> WAN port

In that case, having the ability to define the per-port membership for
VLANs, including the CPU, kind of helps, especially if there are
private/guests VLAN on either the LAN or WAN segments that the CPU does
not necessarily need to play a role in.

NB: this scheme works because in most configurations that we support
today, the CPU port's speed is greater or equal than the speed of the
downstream/front panel ports.

> 
> Also, how are you going to set the VLAN filters for the CPU port when
> you don't offload a bridge, but instead vlan devices between which you
> route packets? You lose your abstraction of CPU port...

As far as I can tell today, this is not particularly helpful with DSA,
where we start with all traffic going to the CPU (each DSA created
network device is segregated from the other) and only then we require
having bridge VLAN filtering enabled in the kernel, and configuring
bridge VLAN membership to have a proper VLAN-based scheme.

If you did configure VLAN membership with e.g: port0.<vid> we could
support that just fine, but that programming interface does not allow
configuring the default VLAN, and in our case, it matters a bit to
support the LAN/WAN routing scenario described. We could agree that all
untagged traffic should go to VLAN 0 or 1 for instance, but that could
then, vary on a per-driver/HW basis.

Hope this clarifies things a bit!
-- 
Florian
