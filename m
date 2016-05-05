From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] macvtap: add namespace support to the
 sysfs device class
Date: Thu, 05 May 2016 17:23:40 -0400 (EDT)
Message-ID: <20160505.172340.471035414547235808.davem@davemloft.net>
References: <20160504.235308.1088954708869507214.davem@davemloft.net>
	<1462443266-3166-1-git-send-email-marc@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: marc@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702AbcEEVXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 17:23:43 -0400
In-Reply-To: <1462443266-3166-1-git-send-email-marc@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Angel <marc@arista.com>
Date: Thu,  5 May 2016 12:14:26 +0200

> When creating macvtaps that are expected to have the same ifindex
> in different network namespaces, only the first one will succeed.
> The others will fail with a sysfs_warn_dup warning due to them trying
> to create the following sysfs link (with 'NN' the ifindex of macvtapX):
> 
> /sys/class/macvtap/tapNN -> /sys/devices/virtual/net/macvtapX/tapNN
> 
> This is reproducible by running the following commands:
> 
> ip netns add ns1
> ip netns add ns2
> ip link add veth0 type veth peer name veth1
> ip link set veth0 netns ns1
> ip link set veth1 netns ns2
> ip netns exec ns1 ip l add link veth0 macvtap0 type macvtap
> ip netns exec ns2 ip l add link veth1 macvtap1 type macvtap
> 
> The last command will fail with "RTNETLINK answers: File exists" (along
> with the kernel warning) but retrying it will work because the ifindex
> was incremented.
> 
> The 'net' device class is isolated between network namespaces so each
> one has its own hierarchy of net devices.
> This isn't the case for the 'macvtap' device class.
> The problem occurs half-way through the netdev registration, when
> `macvtap_device_event` is called-back to create the 'tapNN' macvtap
> class device under the 'macvtapX' net class device.
> 
> This patch adds namespace support to the 'macvtap' device class so
> that /sys/class/macvtap is no longer shared between net namespaces.
> 
> However, making the macvtap sysfs class namespace-aware has the side
> effect of changing /sys/devices/virtual/net/macvtapX/tapNN  into
> /sys/devices/virtual/net/macvtapX/macvtap/tapNN.
> 
> This is due to Commit 24b1442 ("Driver-core: Always create class
> directories for classses that support namespaces") and the fact that
> class devices supporting namespaces are really not supposed to be placed
> directly under other class devices.
> 
> To avoid breaking userland, a tapNN symlink pointing to macvtap/tapNN is
> created inside the macvtapX directory.
> 
> Signed-off-by: Marc Angel <marc@arista.com>

Applied, thanks.
