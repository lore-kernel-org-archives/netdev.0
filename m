From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid
 not used
Date: Thu, 6 Jan 2011 19:24:59 -0800
Message-ID: <20110107032459.GA17959@mcarlson.broadcom.com>
References: <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
 <20101206222703.32fbe852@xenia.leun.net>
 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
 <20101213224510.GB17400@mcarlson.broadcom.com>
 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
 <20101214191500.GD19951@mcarlson.broadcom.com>
 <20101215012430.120fd47f@xenia.leun.net>
 <20101215013431.GA21173@mcarlson.broadcom.com>
 <20101215081606.18e12fc9@xenia.leun.net>
 <AANLkTi=hGRW+DwoKQzxPAZao6-y_tvn6nNXS-tj_-Y6T@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Leun" <lkml20101129@newton.leun.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Greear" <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jesse Gross" <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=hGRW+DwoKQzxPAZao6-y_tvn6nNXS-tj_-Y6T@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 18, 2010 at 07:38:00PM -0800, Jesse Gross wrote:
> On Tue, Dec 14, 2010 at 11:16 PM, Michael Leun
> <lkml20101129@newton.leun.net> wrote:
> > OK - all tests done on that DL320G5:
> >
> > For completeness, 2.6.37-rc5 unpatched:
> >
> > eth0, no vlan configured: totally broken - see double tagged vlans
> > without tag, single or untagged packets missing at all
> 
> Random behavior?  This one is somewhat hard to explain - maybe there
> are some other factors.  eth0 has ASF on, so it always strips tags.  I
> would expect it to behave like the vlan configured case.
> 
> >
> > eth0, vlan configured: see packets without vlan tag (see double tagged
> > packets with one vlan tag)
> 
> Both ASF and vlan group configured cause tag stripping to be enabled.
> Missing tag.
> 
> >
> > eth1 same as originally reported:
> > without vlan configured see vlan tags (single and double tagged as
> > expected)
> 
> No ASF and no vlan group means tag stripping is disabled.  Have tag.
> 
> > with vlan configured: see packets without vlan tag (see double tagged
> > packets with one vlan tag)
> 
> Configuring vlan group causes stripping to be enabled.  Missing tag.
> 
> >
> >
> > 2.6.37-rc5, your tg3 use new vlan-code patch:
> >
> > eth0, no vlan configured: ?see packets without vlan tag (see double
> > tagged packets with one vlan tag)
> 
> ASF enables tag stripping.  Missing tag.
> 
> > eth1, no vlan configured: see vlan tags (single and double tagged as
> > expected)
> 
> No ASF, no vlan group means no stripping.  Have tag.
> 
> >
> >
> > eth0, vlan configured: as without vlan
> 
> ASF enables stripping.  Missing tag.
> 
> > eth1, vlan configured: as without vlan
> 
> With this patch vlan stripping is only enabled when ASF is on, so no
> stripping.  Have tag.
> 
> >
> > 2.6.37-rc5, your tg3 use new vlan-code patch with test patch ontop
> >
> > eth1 no vlan configured: see packets without vlan tag (see double tagged
> > packets with one vlan tag)
> 
> With the second patch, vlan stripping is always enabled.  Missing tag.
> 
> > eth1 with vlan: the same
> 
> Stripping still always enabled.  Missing tag.
> 
> The bottom line is whenever vlan stripping is enabled we're missing
> the outer tag.  It might be worth adding some debugging in the area
> before napi_gro_receive/vlan_gro_receive (depending on version).  My
> guess is that (desc->type_flags & RXD_FLAG_VLAN) is false even for
> vlan packets on this NIC.
> 
> You said that everything works on the 5752?  Matt, is it possible that
> the 5714 either has a problem with vlan stripping or a different way
> of reporting it?

I don't think this is a 5714 specific issue.  I think the problem is
rooted in the fact that the VLAN tag stripping is enabled.

Your RXD_FLAG_VLAN idea sounds unlikely to me, but it's worth a check.

The patch here is using __vlan_hwaccel_put_tag(), which informs the
stack a VLAN tag is present.  If this is indeed a reporting problem, I'm
not sure what else the driver should be doing.

> Also, why does ASF require vlan stripping?

This is a firmware limitation.
