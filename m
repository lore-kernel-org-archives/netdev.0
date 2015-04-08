From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH v3 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Wed, 8 Apr 2015 23:18:08 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7D92D@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
	<5525A876.2000407@gmail.com>
	<1428532092.2616.3.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1428532092.2616.3.camel@jtkirshe-mobl.jf.intel.com>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> Subject: Re: [E1000-devel] [PATCH v3 3/3] ixgbe: Add new ndo to allow VF multicast promiscuous mode
> 
> On Wed, 2015-04-08 at 15:15 -0700, Alexander Duyck wrote:
> > On 04/07/2015 10:38 PM, Hiroshi Shimamoto wrote:
> > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > >
> > > Implements the new netdev op to allow VF multicast promiscuous mode.
> > >
> > > The multicast promiscuous mode is not allowed for all VFs by default.
> > >
> > > The administrator can allow to VF multicast promiscuous mode for only
> > > trusted VM. After allowing multicast promiscuous mode from the host,
> > > we can use over 30 IPv6 addresses on VM.
> > >  # ip link set dev eth0 vf 1 mc_promisc on
> > >
> > > When disallowing multicast promiscuous mode, ixgbevf can only handle 30
> > > IPv6 addresses at most.
> > >  # ip link set dev eth0 vf 1 mc_promisc off
> > >
> > > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> > > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > > ---
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32 ++++++++++++++++++++++++--
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
> > >  4 files changed, 40 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > > index 08e65b6..4a9f74d 100644
> > > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > > @@ -153,6 +153,7 @@ struct vf_data_storage {
> > >  	u16 vlan_count;
> > >  	u8 spoofchk_enabled;
> > >  	bool rss_query_enabled;
> > > +	u8 mc_promisc_allowed;
> > >  	unsigned int vf_api;
> > >  };
> > >
> > > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > index 2f41403..c0e07c5 100644
> > > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > > @@ -3663,6 +3663,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
> > >  		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
> > >  					      adapter->vfinfo[i].rss_query_enabled);
> > >  	}
> > > +
> > > +	/* Reconfigure multicast promiscuous mode */
> > > +	for (i = 0; i < adapter->num_vfs; i++) {
> > > +		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
> > > +					adapter->vfinfo[i].mc_promisc_allowed);
> > > +	}
> > >  }
> > >
> > >  static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
> >
> > This doesn't need to be a separate loop.  You can push it up into the
> > block above since it is already looping through all VFs.
> >
> > Once that is fixed the rest of this patch and the other two looked fine
> > to me.
> 
> Hiroshi I am dropping this series and will await v4.
> 
> Remember to send them to intel-wired-lan mailing list, please.

yep, will do.

thanks,
Hiroshi
------------------------------------------------------------------------------
BPM Camp - Free Virtual Workshop May 6th at 10am PDT/1PM EDT
Develop your own process in accordance with the BPMN 2 standard
Learn Process modeling best practices with Bonita BPM through live exercises
http://www.bonitasoft.com/be-part-of-it/events/bpm-camp-virtual- event?utm_
source=Sourceforge_BPM_Camp_5_6_15&utm_medium=email&utm_campaign=VA_SF
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
