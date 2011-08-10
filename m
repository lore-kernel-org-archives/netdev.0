From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets (was:
 3.0-rc1 Bridge not forwarding unicast packages)
Date: Wed, 10 Aug 2011 11:00:15 +0200
Message-ID: <20110810090014.GB1909@minipsycho.brq.redhat.com>
References: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, sebastian.belden@googlemail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Guntsche <mguntsche@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Aug 10, 2011 at 02:50:20AM CEST, mguntsche@gmail.com wrote:
>Good evening/morning,
>
>> I just upgraded my router/bridge combo to 3.1-rc1 from 3.0 for
>> testing. On a first look everything seemed to work fine, but when I
>> tried to connect via openvpn to my internal network (tap0 being bridged
>> with the internal network) I noticed that I was not able to access the
>> server on my internal network. I could access the bridge (which is
>> acting as the openvpn server as well) just fine though.
>> To debug this I ran tcpdump on the openvpn client and started a ping to the
>> internal network. I could see the ARP requests being answered.....
><snip>
>
>After much digging and testing I found the commit that causes the
>problem for me here.
>
>87c288c6e gianfar: do vlan cleanup
>
>Before this commit my bridge works fine. I simplified the test case
>and just tried to access the server from a local wireless device with
>gets also bridged via
>a gianfar nic to the wired lan. Before commit 87c288c6e I can ping the
>device from the internal network afterwards it stops.
>For testing purposes I reverted this commit (plus some others to make
>the code compile) and it started working again.
>The hardware is a routerboard with three onboard nics two of em gianfar.
>The gianfar nics do not support any kind of offloading,
>
>Offload parameters for lan_wire:
>rx-checksumming: off
>tx-checksumming: off
>scatter-gather: off
>tcp-segmentation-offload: off
>udp-fragmentation-offload: off
>generic-segmentation-offload: off
>generic-receive-offload: on
>large-receive-offload: off
>rx-vlan-offload: off
>tx-vlan-offload: off
>ntuple-filters: off
>receive-hashing: off
>
>The Bridge device on the other hand....
>
>Offload parameters for lan:
>rx-checksumming: on
>tx-checksumming: on
>scatter-gather: off
>tcp-segmentation-offload: off
>udp-fragmentation-offload: off
>generic-segmentation-offload: off
>generic-receive-offload: on
>large-receive-offload: off
>rx-vlan-offload: off
>tx-vlan-offload: on
  ^^^^^^^^^^^^^^^^^^^ is this gfar?
>ntuple-filters: off
>receive-hashing: off

>
>Is it possible that the new code is tripped up by the bridge offload
>parameters somehow and thinks that the gianfar nic supports it as
>well?
>As I wrote in my initial mail, connecting to the Bridge itself works,
>I can also see ARP requests and Broadcasts, the rest just seems to
>disappear.
>
>As for the commits I reverted:
>a4aeb2662 vlan: kill __vlan_hwaccel_rx and vlan_hwaccel_rx
>6dacaddd4 vlan: kill vlan_hwaccel_receive_skb
>7890a5b9c vlan: kill ndo_vlan_rx_register
>b852b7208 gianfar: fix bug caused by 87c288c6e9aa31720b72e2bc2d665e24e1653c3e
>
>87c288c6e gianfar: do vlan cleanup
>
>I really think that there is only some small change in the gianfar
>code needed, but I could not figure it out myself.
>Please tell me if you need any more information.
>
>Kind regards,
>Michael Guntsche
