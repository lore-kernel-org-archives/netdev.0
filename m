From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Wed, 15 Jul 2015 15:34:55 +0900
Message-ID: <20150715063453.GB7603@vergenet.net>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bChu5sAKpU5tUkENfWZMhaWSs3EQZeggUxR=BjKSOqOeg@mail.gmail.com>
 <20150715044521.GA7603@vergenet.net>
 <CAE4R7bBH3dTfivKqo9qzRVhtpUiDzGdDmoeceY5YBq6A3VR03g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36712 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbbGOGfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 02:35:06 -0400
Received: by pdjr16 with SMTP id r16so19388936pdj.3
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 23:35:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBH3dTfivKqo9qzRVhtpUiDzGdDmoeceY5YBq6A3VR03g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 10:32:54PM -0700, Scott Feldman wrote:
> On Tue, Jul 14, 2015 at 9:45 PM, Simon Horman

[snip]

> > How about this?
> 
> Looks good, some inline comments...

[snip]

> > @@ -321,9 +322,21 @@ static u16 rocker_port_vlan_to_vid(const struct rocker_port *rocker_port,
> >         return ntohs(vlan_id);
> >  }
> >
> > +static bool rocker_port_is_bridged__(const struct rocker_port *rocker_port,
> > +                                    const char *kind)
> 
> Maybe use __rocker_port_is_bridged?  (leading '__'; I've not seen use
> of trailing '__').  Or __rocker_port_is_slave(port, kind)?

Perhaps rocker_port_is_slave() would be a good choice?

> > +{
> > +       return rocker_port->bridge_dev &&
> > +               !strcmp(rocker_port->bridge_dev->rtnl_link_ops->kind, kind);
> > +}
> > +
> >  static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
> >  {
> > -       return !!rocker_port->bridge_dev;
> > +       return rocker_port_is_bridged__(rocker_port, "bridge");
> > +}
> > +
> > +static bool rocker_port_is_ovs(const struct rocker_port *rocker_port)
> 
> rocker_port_is_ovsed?  Just to be consistent with is_bridged.

Sure, for the sake of consistency I'll change things as you suggest.

[snip]

> > @@ -5263,11 +5301,16 @@ static int rocker_port_master_changed(struct net_device *dev)
> >          * 3. Other, e.g. being added to or removed from a bond or openvswitch,
> >          *    in which case nothing is done
> >          */
> 
> Maybe comment above needs adjusting?

Indeed, sorry for missing that.
How about this?


        /* There are currently five cases handled here:
         * 1. Joining a bridge
         * 2. Joining a Open vSwitch datapath
         * 3. Leaving a previously joined bridge
         * 4. Leaving a previously joined Open vSwitch datapath
         * 5. Other, e.g. being added to or removed from a bond,
         *    in which case nothing is done
         */

[snip]
