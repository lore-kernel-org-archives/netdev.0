From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next v2 00/13] Change DSA's FDB API and perform
 switchdev cleanup
Date: Thu, 20 Jul 2017 12:04:46 +0300
Message-ID: <099a0552-0139-20d4-2529-c1202303d772@mellanox.com>
References: <1500480294-10604-1-git-send-email-arkadis@mellanox.com>
 <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40084.outbound.protection.outlook.com ([40.107.4.84]:40540
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934945AbdGTJE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 05:04:57 -0400
In-Reply-To: <87mv80ji63.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/19/2017 11:17 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> I am testing your patch series the behavior changes suspiciously:
> 
>     # brctl show br0
>     bridge name	bridge id		STP enabled	interfaces
>     br0		8000.f6d5ef06ccdd	no		lan0
>                                                         lan1
>                                                         lan2
>                                                         lan3
>                                                         lan4
>                                                         lan5
>                                                         lan6
>                                                         lan7
>                                                         lan8
>                                                         optical3
>                                                         optical4
> 
> Without the patchset I have this behavior:
> 
>     # bridge fdb add 00:11:22:33:44:55 dev lan4
>     # bridge fdb add 22:33:44:55:66:77 dev lan2 self
>     # bridge fdb show                               
>     01:00:5e:00:00:01 dev eth0 self permanent
>     01:00:5e:00:00:01 dev eth1 self permanent
>     0a:3f:f6:06:a2:ee dev lan0 master br0 permanent
>     22:33:44:55:66:77 dev lan2 self static
>     00:11:22:33:44:55 dev lan4 self static
>     01:00:5e:00:00:01 dev br0 self permanent
> 
> And now with the patchset applied I have:
> 
> # bridge fdb add 00:11:22:33:44:55 dev lan4
> # bridge fdb add 22:33:44:55:66:77 dev lan2 self
> # bridge fdb show
> 01:00:5e:00:00:01 dev eth0 self permanent
> 00:11:22:33:44:55 dev eth1 self permanent
> 22:33:44:55:66:77 dev eth1 self permanent
> 01:00:5e:00:00:01 dev eth1 self permanent
> 0a:ca:c8:6b:05:65 dev lan0 master br0 permanent
> 01:00:5e:00:00:01 dev br0 self permanent
> 
> 
> It looks like the FDB entries are reported to be associated with the
> master net device (eth1). Is the dump broken or is it the whole add?
> 
> Thanks,
> 
>         Vivien
> 

Hi, thanks for the test. If the fdb is marked as self its not in the
bridge at all. So before my patch it was OK because you supported the
self thing.

Please notice that both fdbs you added are marked the same because the
default is self: vim bridge/fdb.c +499 (I think this is a bug because
the man page states that master is the default). So in order to put it
in the bridge you should specify "master":

$bridge fdb add e4:1d:2d:a5:f0:4a dev sw1p7 master
$bridge fdb show brport sw1p7
e4:1d:2d:a5:f0:4a vlan 1 offload master br0 permanent <---also should
e4:1d:2d:46:13:f1 vlan 1 master br0 permanent             be offloaded*
e4:1d:2d:46:13:f1 master br0 permanent
e4:1d:2d:a5:f0:4a offload master br0 permanent
33:33:00:00:00:01 self permanent
01:00:5e:00:00:01 self permanent
33:33:ff:46:13:f1 self permanent

*you should take the latest iproute.

Also it seems strange that I removed the self support from the driver
but you still managed to configure it. The reason is the default
self implementation:

vim net/core/rtnetlink.c +3112

I think it is relevant for NICs mostly, so we can ignore it.
