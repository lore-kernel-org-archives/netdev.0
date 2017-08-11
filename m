From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 18:39:57 +0200
Message-ID: <20170811183957.47f418e6@griffin>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
        <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Girish Moodalbail <girish.moodalbail@oracle.com>,
        pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752995AbdHKQkB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 12:40:01 -0400
In-Reply-To: <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 09:19:34 -0700, Roopa Prabhu wrote:
> >         if (tb[IFLA_ADDRESS]) {
> >                 if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
> > -                       pr_debug("invalid link address (not ethernet)\n");
> > +                       NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
> > +                                           "Provided link layer address is not Ethernet");
> >                         return -EINVAL;
> >                 }
> 
> keep it simple and closer to the original msg: "invalid link layer address"

I prefer more explanatory wording. Girish's is better.

> >
> >                 if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
> > -                       pr_debug("invalid all zero ethernet address\n");
> > +                       NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
> > +                                           "Provided Ethernet address is not unicast");
> >                         return -EADDRNOTAVAIL;
> 
> keep it simple and closer to the original msg: "invalid all zero
> ethernet address"

This would be incorrect message. The is_valid_ether_addr function does
not check only for all zeroes but also for !multicast. Girish's wording
better expresses what's going on.

> > +       if (!data) {
> > +               NL_SET_ERR_MSG(extack,
> > +                              "Not enough attributes provided to perform the operation");
> >                 return -EINVAL;
> > +       }
> 
> "not enough attributes"

You're missing part of the sentence.

> >         if (data[IFLA_VXLAN_ID]) {
> >                 u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
> >
> > -               if (id >= VXLAN_N_VID)
> > +               if (id >= VXLAN_N_VID) {
> > +                       NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_VXLAN_ID],
> > +                                           "VXLAN ID must be lower than 16777216");
> >                         return -ERANGE;
> 
> "invalid vxlan-id"

This is exactly what I objected against in Girish's v1. It would be
useless to have extended error reporting but report things that don't
help users. I like the current Girish's wording, it's clear and helpful.

> > @@ -2761,8 +2772,8 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
> >                         = nla_data(data[IFLA_VXLAN_PORT_RANGE]);
> >
> >                 if (ntohs(p->high) < ntohs(p->low)) {
> > -                       pr_debug("port range %u .. %u not valid\n",
> > -                                ntohs(p->low), ntohs(p->high));
> > +                       NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_VXLAN_PORT_RANGE],
> > +                                           "Provided source port range bounds is invalid");
> >                         return -EINVAL;
> >                 }
> 
> "invalid source port range"

Could be. But please honor proper capitalization.

> > @@ -2933,6 +2945,8 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
> >                  */
> >                 if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
> >                     !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
> > +                       NL_SET_ERR_MSG(extack,
> > +                                      "VXLAN GPE does not support this combination of attributes");
> >                         return -EINVAL;
> >                 }
> 
> "collect metadata not supported with vxlan gpe"

That's completely wrong message. Not saying that the capitalization is
wrong, too. Girish's wording precisely explains what went wrong.

> > -       if (vxlan_addr_multicast(&conf->saddr))
> > +       if (vxlan_addr_multicast(&conf->saddr)) {
> > +               NL_SET_ERR_MSG(extack, "Local address cannot be multicast");
> >                 return -EINVAL;
> 
> "invalid local address. multicast not supported"

Roopa, what happened to your shift key? And how is this better to what
Girish proposed?

> > +                       NL_SET_ERR_MSG(extack,
> > +                                      "IPv6 support not enabled in the kernel");
> 
> "invalid address family. ipv6 not enabled"

Ditto.

> >                 lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
> > -               if (!lowerdev)
> > +               if (!lowerdev) {
> > +                       NL_SET_ERR_MSG(extack,
> > +                                      "Specified interface for tunnel endpoint communications not found");
> >                         return -ENODEV;
> 
> "invalid vxlan remote link interface, device not found"

Finally one that looks better :-) Modulo the missing capitalization,
though.

> > -               if (vxlan_addr_multicast(&conf->remote_ip))
> > +               if (vxlan_addr_multicast(&conf->remote_ip)) {
> > +                       NL_SET_ERR_MSG(extack,
> > +                                      "Interface need to be specified for multicast destination");
> 
> "vxlan remote link interface required for multicast remote destination"

I like this one better, too.

> >  #if IS_ENABLED(CONFIG_IPV6)
> > -               if (conf->flags & VXLAN_F_IPV6_LINKLOCAL)
> > +               if (conf->flags & VXLAN_F_IPV6_LINKLOCAL) {
> > +                       NL_SET_ERR_MSG(extack,
> > +                                      "Interface need to be specified for link-local local/remote addresses");
> >                         return -EINVAL;
> 
> "vxlan link interface required for link-local local/remote addresses"

Okay but to be consistent (and more clear), it should be "remote link
interface".

> > @@ -3038,6 +3082,7 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
> >                     tmp->cfg.remote_ifindex != conf->remote_ifindex)
> >                         continue;
> >
> > +               NL_SET_ERR_MSG(extack, "Specified VNI is duplicate");
> 
> "duplicate vni. vxlan device with vni exists."

What about "A VXLAN device with the specified VNI already exists."?

 Jiri
