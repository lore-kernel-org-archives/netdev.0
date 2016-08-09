From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 09 Aug 2016 11:21:31 -0700
Message-ID: <16281.1470766891@famine>
References: <20160808211530.GH22974@cork> <20160808212112.GI22974@cork> <20160808214812.GJ22974@cork> <57A93D81.4030808@huawei.com> <20160809030956.GL22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3Fiso-8859-1=3FQ=3FJ=3DF6rn=3F=3D?= Engel
	<joern@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53484 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcHISVi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:21:38 -0400
In-reply-to: <20160809030956.GL22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jörn Engel <joern@purestorage.com> wrote:

>Hello Tianhong!
>
>On Tue, Aug 09, 2016 at 10:18:41AM +0800, Ding Tianhong wrote:
>> 
>> I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
>> and we will try to fix it.
>
>Here is a trivial testcase:
>openvpn --mktun --dev tun0
>echo +tun0 > /sys/class/net/bond0/bonding/slaves
>
>Worked fine before your patch, no longer works after your patch.  Works
>again after my patch.

	Could you describe your use case a bit further?  Are you bonding
together multiple VPN tunnels?

	This may be a regression, but since the patch that nominally
introduced it was 2 years ago, the impact appears to be very narrow.

>> and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
>> could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.
>
>Using bonding in balance-rr mode, there doesn't seem to be a need to
>change the mac address.  I suppose you might care in other modes, but I
>don't.

	The balance-rr mode (as well as the -xor mode) is designed to
interoperate with a Cisco Etherchannel-style static link aggregation,
which requires all members to have the same MAC address for proper
function.

	Now, the above notwithstanding, I don't have an issue if you
want to bond together a couple of tun devices and can make it work.
However, for the standard balance-rr case, the enslavement must fail if
the call to set the slave MAC fails, as permitting the slave into the
bond after set-MAC fails can result in a bond that silently loses
packets.

	My tentative suggestion is that we extened fail_over_mac to
cover additional modes, as a sort of "I really know what I'm doing"
flag, and allow the enslavement to succeed when it is set.  This would
require setting an additional bonding option for this situation, but
that doesn't seem to be a undue burden as this looks to be a niche use
case.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
