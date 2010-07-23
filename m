From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: set device in RLB ARP packet handler
Date: Fri, 23 Jul 2010 16:25:19 -0400
Message-ID: <20100723202519.GT7497@gospo.rdu.redhat.com>
References: <20100723193456.GS7497@gospo.rdu.redhat.com> <20100723195947.GA7123@w-gedwards.lhn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg Edwards <greg.edwards@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100723195947.GA7123@w-gedwards.lhn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 01:59:47PM -0600, Greg Edwards wrote:
> On Fri, Jul 23, 2010 at 07:34:56PM +0000, Andy Gospodarek wrote:
> > On Thu, Jul 22, 2010 at 3:52 PM, Greg Edwards <greg.edwards@hp.com> wrote:
> >> With commit 6146b1a4, the dev field in the RLB ARP packet handler was
> >> set to NULL to wildcard and accommodate balancing VLANs on top of
> >> bonds.
> >>
> >> This has the side-effect of the packet handler being called against
> >> other, non RLB-enabled bonds, and a kernel oops results when it tries
> >> to
> >> dereference rx_hashtbl in rlb_update_entry_from_arp(), which won't be
> >> set for those bonds, e.g. active-backup.
> >>
> >> With the __netif_receive_skb() changes from commit 1f3c8804, frames
> >> received on VLANs correctly make their way to the bond's handler,
> >> so we no longer need to wildcard the device.
> >
> > I see this problem as well, but I would propose to fix it another way to
> > not alter the receive path so close to the release of 2.6.35 and to
> > catch this for 802.3ad bonds as well.
> 
> Is the problem demonstrable with 802.3ad bonds?  bond_register_lacpdu()
> sets pk_type->dev = bond->dev.
> 

Doh!  You are right.

Plus Jay just posted your patch again, so we can go with that solution.

> >> Signed-off-by: Greg Edwards <greg.edwards@hp.com>
> >> ---
> >> Jay,
> >>
> >> The oops can be reproduced by:
> >>
> >> modprobe bonding
> >>
> >> echo active-backup > /sys/class/net/bond0/bonding/mode
> >> echo 100 > /sys/class/net/bond0/bonding/miimon
> >> ifconfig bond0 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> >> echo +eth0 > /sys/class/net/bond0/bonding/slaves
> >> echo +eth1 > /sys/class/net/bond0/bonding/slaves
> >>
> >> echo +bond1 > /sys/class/net/bonding_masters
> >> echo balance-alb > /sys/class/net/bond1/bonding/mode
> >> echo 100 > /sys/class/net/bond1/bonding/miimon
> >> ifconfig bond1 xxx.xxx.xxx.xxx netmask xxx.xxx.xxx.xxx
> >> echo +eth2 > /sys/class/net/bond1/bonding/slaves
> >> echo +eth3 > /sys/class/net/bond1/bonding/slaves
> >>
> >> Pass some traffic on bond0.  Boom.
> >>
> >
> > bonding: make sure mode-specific handlers handle appropriate frames
> >
> > This patch will exit out of rlb_arp_recv and bond_3ad_lacpdu_recv early
> > if the bond receiving the frame isn't using that mode.
> 
> I had originally thought of doing something like this, but it didn't
> seem as clean.  I don't have strong feelings one way or the other,
> though.
> 
> Greg
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
