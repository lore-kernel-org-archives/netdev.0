From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Bonding two 802.1q interfaces triggers "sleeping function called from invalid context"
Date: Tue, 1 May 2007 18:06:48 -0400
Message-ID: <20070501220647.GA7546@gospo.rdu.redhat.com>
References: <46378B5F.9060301@redhat.com> <20070501193105.GA4737@gospo.rdu.redhat.com> <6380.1178051606@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Chuck Ebbert <cebbert@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946029AbXEAWG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 18:06:56 -0400
Content-Disposition: inline
In-Reply-To: <6380.1178051606@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 01:33:26PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >> I need to use a bonding through two 802.1q tag VLAN virtual interface in the
> >> same physical network interface. When I bond interface with command :
> >> ifenslave bond0 eth1.10 eth1.20
> >> Console and dmesg will continues report BUG:
> >> --------------Output1 begin kernel 2.6.20-1.2933.fc6------------
> >> BUG: sleeping function called from invalid context at include/asm/uaccess.h:500
> >> in_atomic():1, irqs_disabled():0
> >>  [<c04ecadb>] copy_from_user+0x35/0x66
> >>  [<c05c2e78>] dev_ethtool+0x51/0xa0d
> >>  [<c05ee503>] tcp_current_mss+0x71/0xdf
> >>  [<c05ee169>] tcp_rcv_established+0x74f/0x7de
> >>  [<c04cf48f>] selinux_netlbl_sock_rcv_skb+0x1d/0x5b
> >>  [<c05f3a78>] tcp_v4_do_rcv+0x1bf/0x49c
> >>  [<c05f5f1b>] tcp_v4_rcv+0x564/0x8b1
> >>  [<d8a3ac03>] vlan_dev_ioctl+0x7b/0xa7 [8021q]
> >>  [<d8a3ab88>] vlan_dev_ioctl+0x0/0xa7 [8021q]
> >>  [<d8a53102>] bond_update_speed_duplex+0x88/0xd7 [bonding]
> >>  [<d8a5688e>] bond_mii_monitor+0x0/0x403 [bonding]
> >>  [<d8a56c01>] bond_mii_monitor+0x373/0x403 [bonding]
> >
> >Jay Vosburgh and I have been working on something to address this and
> >other issues related to possible sleeping activities that might come
> >from the monitoring functions.  I feel like we are getting close to
> >something so I hope we can post something soon.
> >
> >Care to add anything, Jay?
> 
> 	I was thinking about this one a couple of days ago; it's a
> little tricky to get out of, since we nominally need to do the ethtool
> calls holding only rtnl, but don't want to cycle rtnl for each monitor
> pass.
> 
> 	The warning only shows up with VLANs because VLAN get_settings()
> calls dev_ethtool() directly, and the copy_from_user() in dev_ethtool()
> is the complaining party here.
> 

Agreed.  All locks held when calling bond_update_speed_duplex for a vlan
interface and need to be non bh-locks and the call needs to be done as a
user-process.  This might be hard to avoid with bond_enslave but could
be avoided with some code restructing.


> 	Calling an end device driver's get_settings() directly doesn't
> trigger the warning.  I think that's safe without rtnl (at least insofar
> as the slave won't vanish), since the slave cannot vanish without
> bonding being notified via the NETDEV_UNREGISTER notifier.

This does look to be something specific to vlan interfaces being
enslaved.  Which makes me wonder: Why are we supporting that anyway?  I
*guess* there might be some crazy network admin that might like this,
but it doesn't seem right...



> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
