From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [next-queue v6 PATCH 7/7] i40e: Add support to get switch id
 and port number for port netdevs
Date: Thu, 30 Mar 2017 18:16:18 -0700
Message-ID: <20170330181618.41e37ffc@cakuba.netronome.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
        <1490833375-2788-8-git-send-email-sridhar.samudrala@intel.com>
        <20170330144529.0c7ee4c8@cakuba.netronome.com>
        <CAKgT0UcM9dtM5DPNpdobevfOfWA9aZQgg_jx6wAgkjM6umt5Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Simon Horman <simon.horman@netronome.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36846 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934584AbdCaBQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:16:22 -0400
Received: by mail-pg0-f42.google.com with SMTP id g2so54358308pge.3
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:16:21 -0700 (PDT)
In-Reply-To: <CAKgT0UcM9dtM5DPNpdobevfOfWA9aZQgg_jx6wAgkjM6umt5Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Mar 2017 15:31:01 -0700, Alexander Duyck wrote:
> On Thu, Mar 30, 2017 at 2:45 PM, Jakub Kicinski
> <jakub.kicinski@netronome.com> wrote:
> > On Wed, 29 Mar 2017 17:22:55 -0700, Sridhar Samudrala wrote:  
> >> Introduce switchdev_ops to PF and port netdevs to return the switch id via
> >> SWITCHDEV_ATTR_ID_PORT_PARENT_ID attribute.
> >> Also, ndo_get_phys_port_name() support is added to port netdevs to return
> >> the port number.
> >>  
> > ...  
> >> +static int
> >> +i40e_port_netdev_get_phys_port_name(struct net_device *dev, char *buf,
> >> +                                 size_t len)
> >> +{
> >> +     struct i40e_port_netdev_priv *priv = netdev_priv(dev);
> >> +     struct i40e_vf *vf;
> >> +     int ret;
> >> +
> >> +     switch (priv->type) {
> >> +     case I40E_PORT_NETDEV_VF:
> >> +             vf = (struct i40e_vf *)priv->f;
> >> +             ret = snprintf(buf, len, "%d", vf->vf_id);
> >> +             break;
> >> +     case I40E_PORT_NETDEV_PF:
> >> +             ret = snprintf(buf, len, "%d", I40E_MAIN_VSI_PORT_ID);
> >> +             break;
> >> +     default:
> >> +             return -EOPNOTSUPP;
> >> +     }
> >> +
> >> +     if (ret >= len)
> >> +             return -EOPNOTSUPP;
> >> +
> >> +     return 0;
> >> +}  
> >
> > You are using only an integer here, which forces you to manually name
> > the netdev in patch 2, and that is what phys_port_name is supposed to
> > help avoid doing AFAIU.
> >
> > We have naming rules in Documentation/networking/switchdev.txt for
> > switch ports suggested as pX for physical ports or pXsY for ports which
> > are broken out/split.  Could we establish similar suggestion for vf and
> > pf representors and document it? (note: we may need pf representors for
> > multi-host devices.)
> >
> > IMHO naming representors pfr%d or vfr%d would make sense.  This way
> > actual VF and PF netdevs could be called pf%d and vf%d, and
> > udev/systemd will give all netdevs nice, meaningful names without any
> > custom rules.
> >
> > Sorry for the bike shedding but I was hoping we could save some user
> > pain by establishing those rules (more or less) upfront.  
> 
> This is something we should probably discuss at netdev/netconf next
> week. It seems like the convention has been to just use an integer and
> I think we might want to look at doing something like you are
> suggesting where if nothing else we come up with a way of identifying
> that a VF versus something like a segmented port which is the only
> thing currently defined in the documentation.

Sure.  If we want to talk about this at netdev there is another
more minor thing we were pondering.  How to represent the VF -- PCI DEV
-- representor netdev relation nicely e.g. for OpenStack integration?

AFAIU when PCI device is added to a VM user space should add the
representors to appropriate bridges and fire the legacy sriov ndos
to set mac/vlan.  VF PCI dev and PF PCI dev are nicely linked in sysfs
via virtfnX and physfn files.  But going from VF PCI dev to the
representor requires iteration over all representor netdevs to find the
right switchdev_id + phys_port_name combination.

One way to solve this would be to SET_NETDEV_DEV() the representor
netdev to the VF pci dev, but then representors may not share the base
enpXsYfZ name since they will be using different PCI devices as the
parent...
