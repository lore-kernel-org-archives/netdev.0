From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: RE: [E1000-devel] [PATCH] ixgbe, ixgbevf: Add new mbox API to
 enable MC promiscuous mode
Date: Tue, 16 Dec 2014 00:49:17 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05DDD231@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05DBFDAD@BPXM14GP.gisp.nec.co.jp>
 <54809D57.9060804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Subject: Re: [E1000-devel] [PATCH] ixgbe, ixgbevf: Add new mbox API to enable MC promiscuous mode
> >
> > On 11/27/2014 02:39 AM, Hiroshi Shimamoto wrote:
> > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > >
> > > The limitation of the number of multicast address for VF is not enough
> > > for the large scale server with SR-IOV feature.
> > > IPv6 requires the multicast MAC address for each IP address to handle
> > > the Neighbor Solicitation message.
> > > We couldn't assign over 30 IPv6 addresses to a single VF interface.
> > >
> > > The easy way to solve this is enabling multicast promiscuous mode.
> > > It is good to have a functionality to enable multicast promiscuous mode
> > > for each VF from VF driver.
> > >
> > > This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> > > enable/disable multicast promiscuous mode in VF. If multicast promiscuous
> > > mode is enabled the VF can receive all multicast packets.
> > >
> > > With this patch, the ixgbevf driver automatically enable multicast
> > > promiscuous mode when the number of multicast addresses is over than 30
> > > if possible.
> > >
> > > This also bump the API version up to 1.2 to check whether the API,
> > > IXGBE_VF_SET_MC_PROMISC is available.
> > >
> > > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > > Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> >
> > This is a REALLY bad idea unless you plan to limit this to privileged VFs.
> >
> > I would recommend looking at adding an ndo operation to control this
> > feature so that it could be disabled by default in the PF and only
> > enabled on the host side if specifically requested.  Otherwise the
> 
> Do you mean that PF driver should have the flag to enable or disable per VF
> and disallow the request from VF?

Could you answer about that?

> 
> > problem is I can easily see this leading security issues as the VFs
> > might begin getting access to messages that they aren't supposed to.
> 
> OK, by the way, I think that the current ixgbe and ixgbevf implementation
> has already such issue. The guest can add hash entry to receive MAC and it
> can get every multicast MAC frame with the current mbox API.
> Does your concern come from the easiness of doing that?

There is the single MTA per PF, not per VF.
VF requests PF to register the hash of MC MAC, then PF set a bit in the MTA
and set the flag IXGBE_VMOLR_ROMPE of VF, which enables packets switching to
the VF if MC MAC hits the hash entry in the MTA.
If VM1 has VF1 which uses MC MAC1 and VM2 has VF2 which uses MC MAC2, both
of VM1 and VM2 will receive MC MAC1. VM2 doesn't know why it receives MAC1.
In other words, in the current implementation, a VF receives all multicast
packets which are registered from other VFs.
Because the above reason, I hadn't imagined that enabling MC promiscuous mode
increases receiving the MC messages that they aren't supposed to.
I think that this patch doesn't change that behavior.

thanks,
Hiroshi
