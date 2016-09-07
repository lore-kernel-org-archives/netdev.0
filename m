From: Michal Soltys <soltys@ziu.info>
Subject: Re: vlan aware bridge doesn't propagate mac changes to vlans on top
 of it
Date: Wed, 7 Sep 2016 20:22:00 +0200
Message-ID: <af2e0cf8-c580-83b5-3b7d-3a23a1cba06a@ziu.info>
References: <d8cc158b-8b3b-17eb-91cc-7a46d7fc011e@ziu.info>
 <1fb1ce35-60e8-481c-9533-afe2e585f6ca@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:37794 "EHLO drutsystem.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbcIGSWH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 14:22:07 -0400
In-Reply-To: <1fb1ce35-60e8-481c-9533-afe2e585f6ca@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-09-07 02:44, Toshiaki Makita wrote:
> On 2016/09/07 6:59, Michal Soltys wrote:
>> Consider following scenario:
>> 
>> - create vlan aware bridge (say br0)
>> - setup br0's vlans, e.g.
>> 
>> bridge vlan add dev br0 vid 10 self
>> 
>> This will add necessary fdb entries directing appropriate traffic to the
>> bridge itself.
>> 
>> - create appropriate vlan interfaces on top of it, for example:
>> 
>> ip li add link br0 name br0.10 type vlan id 10
>> ip add add 10.0.0.1/8 dev br0.10 ....
>> 
>> This will add vlan devices on top of br0 and *inherit br0's mac address*.
>> 
>> - now after all of the above is done
>> 
>> ip li set eth0 master br0
>> 
>> This will attach interface eth0 to the bridge. With this being the first
>> interface attached, br0 will take it's mac address as its own. Any
>> further changes to br0's ports may cause the same, with the lowest mac
>> address of some port becoming br0's mac.
>> 
>> This will update fdb entries as well, but all vlan interfaces on top of
>> br0 (e.g. br0.10) will be using old mac address from the time when vlan
>> was created.
>> 
>> The side effect of it is that any traffic addressed to such interface
>> will be flooded to all ports (and br0 itself).
>> 
>> The only workaround I found is to either manually update mac addresses
>> with 'ip' or recreate vlans (bridge fdb refused to update relevant entries).
>> 
>> But if br0's mac changes due to some port changes - shouldn't it be
>> somehow propagated automatically to vlans created on top of it ?
> 
> This should have been addressed at least in kernel 4.7...
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=308453aa9156a3b8ee382c0949befb507a32b0c1
> 
> Which kernel version do you use?
> 

4.7.2
git describe on that commit suggests it's been available since 4.6.x

What I did in details:

ip li add name port1b type veth peer name port1e
ip li add br0 type bridge
ip li set dev br0 type bridge vlan_default_pvid 0
ip li set dev br0 type bridge vlan_filtering 1
bridge vlan add dev br0 vid 10 self
bridge vlan add dev br0 vid 250 untagged pvid self
ip li add link br0 name vlan10 type vlan id 10
ip li set port1b master br0

At this point br0.vlan10 had outdated mac after br0 took port1b's one as
its own.
