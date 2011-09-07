From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 7 Sep 2011 15:34:37 +0300
Message-ID: <20110907123435.GF9337@redhat.com>
References: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dragos.tatulea@gmail.com, arnd@arndb.de,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab1IGQ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:29:39 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p87GTXb1032588
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Sep 2011 12:29:38 -0400
Content-Disposition: inline
In-Reply-To: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2011 at 03:35:40PM -0700, Roopa Prabhu wrote:
> This patch is an attempt at providing address filtering support for macvtap 
> devices in PASSTHRU mode. Its still a work in progress.
> Briefly tested for basic functionality. Wanted to get some feedback on the 
> direction before proceeding.
> 

Good work, thanks.

> I have hopefully CC'ed all concerned people.

kvm crowd might also be interested.
Try using ./scripts/get_maintainer.pl as well.

> PASSTHRU mode today sets the lowerdev in promiscous mode. In PASSTHRU mode
> there is a 1-1 mapping between macvtap device and physical nic or VF. And all
> filtering is done in lowerdev hw. The lowerdev does not need to be in 
> promiscous mode as long as the guest filters are passed down to the lowerdev. 
> This patch tries to remove the need for putting the lowerdev in promiscous mode. 
> I have also referred to the thread below where TUNSETTXFILTER was mentioned in 
> this context: 
>  http://patchwork.ozlabs.org/patch/69297/
> 
> This patch basically passes the addresses got by TUNSETTXFILTER to macvlan 
> lowerdev.
> 
> I have looked at previous work and discussions on this for qemu-kvm 
> by Michael Tsirkin, Alex Williamson and Dragos Tatulea
> http://patchwork.ozlabs.org/patch/78595/
> http://patchwork.ozlabs.org/patch/47160/
> https://patchwork.kernel.org/patch/474481/
> 
> Redhat bugzilla by Michael Tsirkin:
> https://bugzilla.redhat.com/show_bug.cgi?id=655013
> 
> I used Michael's qemu-kvm patch for testing the changes with KVM 
> 
> I would like to cover both MAC and vlan filtering in this work.
> 
> Open Questions/Issues:
> - There is a need for vlan filtering to complete the patch. It will require 
>   a new tap ioctl cmd for vlans. 
>   Some ideas on this are: 
> 
>   a) TUNSETVLANFILTER: This will entail we send the whole vlan bitmap filter 
> 	(similar to tun_filter for addresses). Passing the vlan id's to lower
> 	device will mean going thru the whole list of vlans every time.
> 
>   OR
> 
>   b) TUNSETVLAN with vlan id and flag to set/unset
> 
>   Does option 'b' sound ok ?
> 
> - In this implementation we make the macvlan address list same as the address 
>   list that came in the filter with TUNSETTXFILTER. This will not cover cases 
>   where the macvlan device needs to have other addresses that are not 
>   necessarily in the filter. Is this a problem ?

What cases do you have in mind?

> - The patch currently only supports passing of IFF_PROMISC and IFF_MULTICAST 
> filter flags to lowerdev
> 
> This patch series implements the following 
> 01/3 - macvlan: Add support for unicast filtering in macvlan 
> 02/3 - macvlan: Add function to set addr filter on lower device in passthru mode
> 03/3 - macvtap: Add support for TUNSETTXFILTER
> 
> Please comment. Thanks.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

The security isn't lower than with promisc, so I don't see
a problem with this as such.

There are more features we'll want down the road though,
so let's see whether the interface will be able to
satisfy them in a backwards compatible way before we
set it in stone. Here's what I came up with:

How will the filtering table be partitioned within guests?

A way to limit what the guest can do would also be useful.
How can this be done? selinux?

Any thoughts on spoofing filtering?

Would it be possible to make the filtering programmable
using netlink, e.g. ethtool, ip, or some such?
That would make this useful for bridged setups besides
macvtap/virtualization.

Thanks,

-- 
MST
