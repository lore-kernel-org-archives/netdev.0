From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next v2 00/13] Change DSA's FDB API and perform
 switchdev cleanup
Date: Sun, 23 Jul 2017 18:00:28 +0300
Message-ID: <ede22100-3a66-f54d-a618-a3b840a2664c@mellanox.com>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
 <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <099a0552-0139-20d4-2529-c1202303d772@mellanox.com>
 <87pocvnkfw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10048.outbound.protection.outlook.com ([40.107.1.48]:22256
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751467AbdGWPAj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Jul 2017 11:00:39 -0400
In-Reply-To: <87pocvnkfw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/20/2017 07:26 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>> Hi, thanks for the test. If the fdb is marked as self its not in the
>> bridge at all. So before my patch it was OK because you supported the
>> self thing.
>>
>> Please notice that both fdbs you added are marked the same because the
>> default is self: vim bridge/fdb.c +499 (I think this is a bug because
>> the man page states that master is the default). So in order to put it
>> in the bridge you should specify "master":
>>
>> $bridge fdb add e4:1d:2d:a5:f0:4a dev sw1p7 master
>> $bridge fdb show brport sw1p7
>> e4:1d:2d:a5:f0:4a vlan 1 offload master br0 permanent <---also should
>> e4:1d:2d:46:13:f1 vlan 1 master br0 permanent             be offloaded*
>> e4:1d:2d:46:13:f1 master br0 permanent
>> e4:1d:2d:a5:f0:4a offload master br0 permanent
>> 33:33:00:00:00:01 self permanent
>> 01:00:5e:00:00:01 self permanent
>> 33:33:ff:46:13:f1 self permanent
>>
>> *you should take the latest iproute.
> 
> Thanks for the explanation, it makes more sense now. Now with latest
> net-next iproute2 and your patch, I have this behavior, first before
> your patchset:
> 
>     # bridge fdb add e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb add e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     2a:6e:b6:a8:25:f1 dev lan0 master br0 permanent
>     e4:1d:2d:a5:f0:2a dev lan3 self static
>     e4:1d:2d:a5:f0:4a dev lan4 master br0 permanent
>     01:00:5e:00:00:01 dev br0 self permanent
>     # bridge fdb del e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb del e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     2a:6e:b6:a8:25:f1 dev lan0 master br0 permanent
>     01:00:5e:00:00:01 dev br0 self permanent
> 
> and after your patchset:
> 
>     # bridge fdb add e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb add e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     e4:1d:2d:a5:f0:2a dev eth1 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     da:ac:a3:36:f2:10 dev lan0 master br0 permanent
>     e4:1d:2d:a5:f0:4a dev lan4 offload master br0 permanent
>     e4:1d:2d:a5:f0:4a dev lan4 self static
>     01:00:5e:00:00:01 dev br0 self permanent
>     # bridge fdb del e4:1d:2d:a5:f0:2a dev lan3
>     # bridge fdb del e4:1d:2d:a5:f0:4a dev lan4 master
>     # bridge fdb show
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     da:ac:a3:36:f2:10 dev lan0 master br0 permanent
>     01:00:5e:00:00:01 dev br0 self permanent
> 
> For lan4, the behavior seems correct. Even if reporting "lan4 self
> static" seems odd and redundant with the above "lan4 offload master".

Yeah, but remember that because we didn't remove the fdb dump from DSA
the dump operation will dumps the bridge fdb and then dumps the DSA's
fdbs (via the .ndo_fdb_dump()). So we see it twice due to the hw
limitation for syncing the bridge.

> However, adding an address to lan3 without flag (hence self...) ends up
> in the switch master device (i.e. SoC side of the CPU port conduit.)
> 
> Do you have an idea why the patchset changes that?
> 

Yeah, think that I figured it out, after my patchset there is no DSA
driver implementation for ndo_fdb_add(), thus, the default
implementation will be called:

vim net/core/rtnetlink.c +3113

The default ndo_fdb_add() implementation does two things
(Commit 090096bf3):

1. Adds the address to the unicast list of the device.
2. Calls __dev_set_rx_mode.

In dsa, the set_rx_mode implementation, dsa_slave_set_rx_mode(),
will sync the master device with the addresses.

After that an fdb dump will show this address also on the master
device.

I think this default implementation is relevant mostly for nics
and is not relevant for switchdev net devices.

We can discuss how to bypass this default implementation in our
case because at least in case of mlxsw it does not make sense.
I can send it as followup patch.

>> Also it seems strange that I removed the self support from the driver
>> but you still managed to configure it. The reason is the default
>> self implementation:
>>
>> vim net/core/rtnetlink.c +3112
>>
>> I think it is relevant for NICs mostly, so we can ignore it.
> 
> Regardless your patchset, this is unfortunately inconsistent with the
> bridge man page, describing:
> 
>     self - the address is associated with the port drivers fdb. Usually
>            hardware.
>     master - the address is associated with master devices fdb. Usually
>              software (default).
> 
> So a user would imagine "master" (which is the default) programs the
> address in the software bridge only. Adding "self" means please also
> call into the driver to program the underlying hardware.
> 

As it seems that the default is "self" so this is a) bug, b) just
inconsistent documentation.

> Now we have the "offload" read only flag, which is good to inform about
> a successfully programmed hardware, but adds another level of complexity
> to understand the interaction with the hardware.
> 
> I think iproute2 is getting more and more confusing. From what I
> understood, respecting the "self" flag as described is not possible
> anymore due to some retro-compatibility reasons.
> 
> Also Linux must use the hardware as an accelerator (so "self" or
> "offload" must be the default), and always fall back to software
> otherwise, hence "master" do not make sense here.
> 
> What do you think about this synopsis for bridge fdb add?
> 
>     # bridge fdb add LLADDR dev DEV [ offload { on | off } ]
> 
> Where offload defaults to "on". This option should also be ported to
> other offloaded features like MDB and VLAN. Even though this is a bit
> out of scope of this patchset, do you think this is feasible?
>

I agree completely that currently its confusing. The documentation
should be updated for sure. I think that 'self' was primarily introduced
(Commit 77162022a) for NIC embedded switches which are used for sriov, in
that case the self is related to the internal eswitch, which completely
diverge from the software one (clearly not swithcdev).

IMHO For switchdev devices 'self' should not be an option at all, or any
other arg regarding hardware. Furthermore, the 'offload' flag should be
only relevant during the dump as an indication to the user.

Unfortunately, the  lack of ability of syncing the sw with hw in DSA's
case introduces a problem for indicating that the entries are only
in hw, I mean marking it only as offloaded is not enough.

Thanks,
Arkadi

> 
> Thanks,
> 
>         Vivien
> 
