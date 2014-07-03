From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 2/2] bridge: netlink dump interface at
 par with brctl
Date: Thu, 03 Jul 2014 17:54:56 +0530
Message-ID: <53B54B98.603@gmail.com>
References: <1404380290-17040-1-git-send-email-jhs@emojatatu.com> <1404380290-17040-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:59758 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbaGCM0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 08:26:06 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so142743pdj.8
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 05:26:05 -0700 (PDT)
In-Reply-To: <1404380290-17040-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2014 03:08 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Actually better than brctl showmacs because we can filter by bridge
> port in the kernel.
> The current bridge netlink interface doesnt scale when you have many
> bridges each with large fdbs or even bridges with many bridge ports
>
> And now for the science non-fiction novel you have all been
> waiting for..
>
> //lets see what bridge ports we have
> root@moja-1:/configs/may30-iprt/bridge# ./bridge link show
> 8: eth1 state DOWN : <BROADCAST,MULTICAST> mtu 1500 master br0 state
> disabled priority 32 cost 19
> 17: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master br0 state
> disabled priority 32 cost 100
>
> // show all..
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show
> 33:33:00:00:00:01 dev bond0 self permanent
> 33:33:00:00:00:01 dev dummy0 self permanent
> 33:33:00:00:00:01 dev ifb0 self permanent
> 33:33:00:00:00:01 dev ifb1 self permanent
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:22:01:01 dev eth0 self permanent
> 02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 dev eth1 self permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 33:33:00:00:00:01 dev gretap0 self permanent
> da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
>
> //filter by bridge
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0
> 02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 dev eth1 self permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
>
> // bridge sw1 has no ports attached..
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br sw1
>
> //filter by port
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show brport eth1
> 02:00:00:12:01:02 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 self permanent
> 33:33:00:00:00:01 self permanent
>
> // filter by port + bridge
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0 brport
> sw1-p1
> da:ac:46:27:d9:53 vlan 0 master br0 permanent
> 33:33:00:00:00:01 self permanent
>
> // for shits and giggles (as they say in New Brunswick), lets
> // change the mac that br0 uses
> // Note: a magical fdb entry with no brport is added ...
> root@moja-1:/configs/may30-iprt/bridge# ip link set dev br0 address
> 02:00:00:12:01:04
>
> // lets see if we can see the unicorn ..
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show
> 33:33:00:00:00:01 dev bond0 self permanent
> 33:33:00:00:00:01 dev dummy0 self permanent
> 33:33:00:00:00:01 dev ifb0 self permanent
> 33:33:00:00:00:01 dev ifb1 self permanent
> 33:33:00:00:00:01 dev eth0 self permanent
> 01:00:5e:00:00:01 dev eth0 self permanent
> 33:33:ff:22:01:01 dev eth0 self permanent
> 02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 dev eth1 self permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 33:33:00:00:00:01 dev gretap0 self permanent
> 02:00:00:12:01:04 dev br0 vlan 0 master br0 permanent <=== there it is
> da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
>
> //can we see it if we filter by bridge?
> root@moja-1:/configs/may30-iprt/bridge# ./bridge fdb show br br0
> 02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
> 00:17:42:8a:b4:07 dev eth1 self permanent
> 33:33:00:00:00:01 dev eth1 self permanent
> 02:00:00:12:01:04 dev br0 vlan 0 master br0 permanent <=== there it is
> da:ac:46:27:d9:53 dev sw1-p1 vlan 0 master br0 permanent
> 33:33:00:00:00:01 dev sw1-p1 self permanent
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   net/bridge/br_fdb.c  |   14 +++++++---
>   net/core/rtnetlink.c |   73 +++++++++++++++++++++++++++++++++++++++-----------
>   2 files changed, 69 insertions(+), 18 deletions(-)
>
>
[...]

WARNING: line over 80 characters
#12: FILE: net/bridge/br_fdb.c:695:
+			if (filter_dev && (!f->dst || f->dst->dev != filter_dev)) {

WARNING: braces {} are not necessary for single statement blocks
#63: FILE: net/core/rtnetlink.c:2560:
+		if (!br_dev) {
+			return -ENODEV;
+		}

WARNING: line over 80 characters
#100: FILE: net/core/rtnetlink.c:2593:
+				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev, idx);


total: 0 errors, 3 warnings, 0 checks, 106 lines checked


-- 
Varka Bhadram
