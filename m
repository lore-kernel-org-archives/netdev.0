From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] if_link: Add VF multicast promiscuous mode control
Date: Tue, 20 Jan 2015 12:42:57 +0100
Message-ID: <874mrlu18e.fsf@nemi.mork.no>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi\, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
	(Hiroshi Shimamoto's message of "Tue, 20 Jan 2015 10:50:23 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> writes:

> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Add netlink directives and ndo entry to control VF multicast promiscu=
ous mode.
>
> Intel ixgbe and ixgbevf driver can handle only 30 multicast MAC addre=
sses
> per VF. It means that we cannot assign over 30 IPv6 addresses to a si=
ngle
> VF interface on VM. We want thousands IPv6 addresses in VM.
>
> There is capability of multicast promiscuous mode in Intel 82599 chip=
=2E
> It enables all multicast packets are delivered to the target VF.
>
> This patch prepares to control that VF multicast promiscuous function=
ality.

Adding a new hook for this seems over-complicated to me.  And it still
doesn't solve the real problems that
 a) the user has to know about this limit, and
 b) manually configure the feature

Most of us, lacking the ability to imagine such arbitrary hardware
limitations, will go through a few hours of frustrating debugging befor=
e
we figure this one out...

Why can't the ixgbevf driver just automatically signal the ixgbe driver
to enable multicast promiscuous mode whenever the list grows past the
limit?

I'd also like to note that this comment in
drivers/net/ethernet/intel/ixgbevf/vf.c
indicates that the author had some ideas about how more than 30
addresses could/should be handled:

static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
					  struct net_device *netdev)
{
	struct netdev_hw_addr *ha;
	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
	u16 *vector_list =3D (u16 *)&msgbuf[1];
	u32 cnt, i;

	/* Each entry in the list uses 1 16 bit word.  We have 30
	 * 16 bit words available in our HW msg buffer (minus 1 for the
	 * msg type).  That's 30 hash values if we pack 'em right.  If
	 * there are more than 30 MC addresses to add then punt the
	 * extras for now and then add code to handle more than 30 later.
	 * It would be unusual for a server to request that many multi-cast
	 * addresses except for in large enterprise network environments.
	 */



The last 2 lines of that comment are of course totally bogus and
pointless and should be deleted in any case...  It's obvious that 30
multicast addresses is ridiculously low for lots of normal use cases.


Bj=C3=B8rn
