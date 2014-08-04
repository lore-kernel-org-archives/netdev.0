From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH 1/1] iproute2 bridge: bring to above par with
 brctl show macs
Date: Mon, 4 Aug 2014 09:34:03 -0700
Message-ID: <20140804093403.0d4cd9c2@haswell.linuxnetplumber.net>
References: <1404477430-12261-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47805 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaHDQeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:34:07 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so10334104pad.13
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 09:34:06 -0700 (PDT)
In-Reply-To: <1404477430-12261-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Jul 2014 08:37:10 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> root@moja-mojo:bridge# ./bridge fdb help
> Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]
>               [router] [ dst IPADDR] [ vlan VID ]
>               [ port PORT] [ vni VNI ] [via DEV]
>        bridge fdb {show} [ br BRDEV ] [ brport DEV ]
> 
>  Lets start with two bridges each with a port...
> 
> root@moja-mojo:bridge# ./bridge link
> 10: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master sw1 state disabled priority 32 cost 100
> 11: eth1 state DOWN : <BROADCAST,NOARP> mtu 1500 master br0 state disabled priority 32 cost 100
> 
> show all...
> root@moja-mojo:bridge# ./bridge fdb show
> 33:33:00:00:00:01 dev ifb0 self permanent
> 33:33:00:00:00:01 dev ifb1 self permanent
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:92:c0:60 dev eth0 self permanent
> 33:33:00:00:00:fb dev eth0 self permanent
> 01:00:5e:00:00:fb dev eth0 self permanent
> 01:00:5e:7f:ff:fd dev eth0 self permanent
> 01:00:5e:00:00:01 dev wlan0 self permanent
> 33:33:00:00:00:01 dev wlan0 self permanent
> 33:33:ff:c2:84:3b dev wlan0 self permanent
> 33:33:00:00:00:fb dev wlan0 self permanent
> 01:00:5e:00:00:01 dev virbr0 self permanent
> 01:00:5e:00:00:fb dev virbr0 self permanent
> 33:33:00:00:00:01 dev br0 self permanent
> 33:33:00:00:00:01 dev sw1 self permanent
> 33:33:00:00:00:01 dev dummy0 self permanent
> 5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master sw1 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
> b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 
> Lets see a netdev that is *not* attached to a bridge
> 
> root@moja-mojo:bridge# ./bridge fdb show brport eth0
> 33:33:00:00:00:01 self permanent
> 01:00:5e:00:00:01 self permanent
> 33:33:ff:92:c0:60 self permanent
> 33:33:00:00:00:fb self permanent
> 01:00:5e:00:00:fb self permanent
> 01:00:5e:7f:ff:fd self permanent
> 
> Lets see a netdev that is bridge port
> root@moja-mojo:bridge# ./bridge fdb show brport eth1
> hadi@jhs-1:/media/MT1/other-gits/iproute-jul04/bridge$ ./bridge fdb show brport eth1
> b6:5e:dd:ce:d7:5e vlan 0 master br0 permanent
> 33:33:00:00:00:01 self permanent
> 
> Specify the correct bridge and you get good stuff
> root@moja-mojo:bridge# ./bridge fdb show brport eth1 br br0
> 6:5e:dd:ce:d7:5e vlan 0 master br0 permanent
> 33:33:00:00:00:01 self permanent
> 
> Specify the wrong bridge and you get good nada
> root@moja-mojo:bridge# ./bridge fdb show brport eth1 br sw1
> 
> dump br0
> root@moja-mojo:bridge# ./bridge fdb show br br0
> 33:33:00:00:00:01 dev br0 self permanent
> b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 
> dump sw1
> root@moja-mojo:bridge# ./bridge fdb show br sw1
> 33:33:00:00:00:01 dev sw1 self permanent
> 5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master sw1 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
> 
> Lets move a port from one bridge to another for shits-and-giggles
> (as the New Brunswickians like to say)
> root@moja-mojo:bridge# ip link set sw1-p1 master br0
> 
> Now dump again br0
> root@moja-mojo:bridge# ./bridge fdb show br br0
> 33:33:00:00:00:01 dev br0 self permanent
> 5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
> b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
