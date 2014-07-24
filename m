From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [Patch net-next 1/3] ipv4: fail early when creating netdev named
 all or default
Date: Wed, 23 Jul 2014 23:00:54 -0400
Message-ID: <20140724030054.GB2978@gospo.home.greyhouse.net>
References: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
 <1406153852-22511-2-git-send-email-xiyou.wangcong@gmail.com>
 <CAGVrzcbnEkN1gsUVZBYvtRLdYEGtTZnYATG0oVAKJjWHyfGU0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, stephane.chazelas@gmail.com,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:56797 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758593AbaGXDA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 23:00:58 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcbnEkN1gsUVZBYvtRLdYEGtTZnYATG0oVAKJjWHyfGU0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 06:05:07PM -0700, Florian Fainelli wrote:
> 2014-07-23 15:17 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
> > We create a proc dir for each network device, this will cause
> > conflicts when the devices have name "all" or "default".
> >
> > Rather than emitting an ugly kernel warning, we could just
> > fail earlier by checking the device name.
> >
> > Reported-by: Stephane Chazelas <stephane.chazelas@gmail.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > ---
> 
> [snip]
> 
> >
> > -static void devinet_sysctl_register(struct in_device *idev)
> > +static int devinet_sysctl_register(struct in_device *idev)
> >  {
> > -       neigh_sysctl_register(idev->dev, idev->arp_parms, NULL);
> > -       __devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
> > +       int err;
> > +
> > +       if (!strcmp(idev->dev->name, "default") ||
> > +           !strcmp(idev->dev->name, "all"))
> > +               return -EINVAL;
> 
> Since this exact same check is done in the ipv6 counterpart, how about
> moving this to a helper function like: sysctl_dev_name_is_allowed()
> such that you centralize where the naming policy is enforced? In case
> we need to blacklist some other interface names, there should be one
> place to update.

Agree that a common function would be useful.

There also might be cases where one would want to impose more limits
than just what is limited based on /proc, so this may be something to consider
in core networking code.

> 
> > +
> > +       err = neigh_sysctl_register(idev->dev, idev->arp_parms, NULL);
> > +       if (err)
> > +               return err;
> > +       err = __devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
> >                                         &idev->cnf);
> > +       if (err)
> > +               neigh_sysctl_unregister(idev->arp_parms);
> > +       return err;
> >  }
> >
> >  static void devinet_sysctl_unregister(struct in_device *idev)
> > --
> > 1.8.3.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> -- 
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
