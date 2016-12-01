From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port
	configuration
Date: Thu, 1 Dec 2016 12:21:10 -0800
Message-ID: <802ba9cd-1f7b-dbe2-c4ce-e91eb4cfad37@gmail.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
	<20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
	<e9bbd22e-215f-a1fd-62ba-c0d33b255154@gmail.com>
	<20161123134856.cwk6sznnwa7p4xtq@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: idosch@mellanox.com, andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jiri@mellanox.com, davem@davemloft.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161123134856.cwk6sznnwa7p4xtq@splinter.mtl.com>
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

On 11/23/2016 05:48 AM, Ido Schimmel wrote:
> Hi Florian,
> 
> On Tue, Nov 22, 2016 at 09:56:30AM -0800, Florian Fainelli wrote:
>> On 11/22/2016 09:41 AM, Ido Schimmel wrote:
>>> Hi Florian,
>>>
>>> On Mon, Nov 21, 2016 at 11:09:22AM -0800, Florian Fainelli wrote:
>>>> Hi all,
>>>>
>>>> This patch series allows using the bridge master interface to configure
>>>> an Ethernet switch port's CPU/management port with different VLAN attributes than
>>>> those of the bridge downstream ports/members.
>>>>
>>>> Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
>>>> tested this with b53 and a mockup DSA driver.
>>>
>>> We'll need to add a check in mlxsw and ignore any VLAN configuration for
>>> the bridge device itself. Otherwise, any configuration done on br0 will
>>> be propagated to all of its slaves, which is incorrect.
>>>
>>>>
>>>> Open questions:
>>>>
>>>> - if we have more than one bridge on top of a physical switch, the driver
>>>>   should keep track of that and verify that we are not going to change
>>>>   the CPU port VLAN attributes in a way that results in incompatible settings
>>>>   to be applied
>>>>
>>>> - if the default behavior is to have all VLANs associated with the CPU port
>>>>   be ingressing/egressing tagged to the CPU, is this really useful?
>>>
>>> First of all, I want to be sure that when we say "CPU port", we're
>>> talking about the same thing. In mlxsw, the CPU port is a pipe between
>>> the device and the host, through which all packets trapped to the host
>>> go through. So, when a packet is trapped, the driver reads its Rx
>>> descriptor, checks through which port it ingressed, resolves its netdev,
>>> sets skb->dev accordingly and injects it to the Rx path via
>>> netif_receive_skb(). The CPU port itself isn't represented using a
>>> netdev.
>>
>> In the case of DSA, the CPU port is a normal Ethernet MAC driver, but in
>> premise, this driver plus the DSA tag protocol hook do exactly the same
>> things as you just describe.
> 
> Thanks for the detailed explanation! I also took the time to read
> dsa.txt, however I still don't quite understand the motivation for
> VLAN filtering on the CPU port. In which cases would you like to prevent
> packets from going to the host due to their VLAN header? This change
> would make sense to me if you only had a limited number of VLANs you
> could enable on the CPU port, but from your response I understand that
> this isn't the case.

It's not much about VLAN filtering per-se, but more about the default
VLAN membership of the CPU port, in the absence of any explicit
configuration. As an user, I find it a little inconvenient to have to
create one VLAN interface per VLAN that I am adding to the bridge to be
able to terminate that traffic properly towards the host/CPU/management
interface, especially when this VLAN is untagged.

This is really the motivation for these patches: if there is only one
VLAN configured, and it's the default VLAN for all ports, then the
bridge master interface also terminates this VLAN with the same
properties as those added by default (typically with default_pvid: VID 1
untagged, unless changed of course).

If you don't want that as an user, you now have the ability to change
it, and make this VLAN (or any other for that matter) to be terminated
differently at the host/CPU/management port level than how it is
egressing at the downstream ports part of that VLAN too.

Maybe it's a bit overkill...

> 
> FWIW, I don't have a problem with patches if they are useful for you,
> I'm just trying to understand the use case. We can easily patch mlxsw to
> ignore calls with orig_dev=br0.

OK, if I resubmit, I will try to take care of mlxsw and rocker as well.

Thanks!
-- 
Florian
