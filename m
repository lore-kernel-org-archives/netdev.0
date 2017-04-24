From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Mon, 24 Apr 2017 08:14:38 -0700
Message-ID: <CAJieiUi6Uu-=QBMfBXOjrEDXLCZx=mFo9SyLhgb+CcG2=uiyRA@mail.gmail.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com> <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:34039 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165840AbdDXPOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:14:39 -0400
Received: by mail-ua0-f174.google.com with SMTP id h2so114875478uaa.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:14:39 -0700 (PDT)
In-Reply-To: <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 23, 2017 at 6:07 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
> On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
> > @@ -1276,9 +1277,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
> >       return err;
> >  }
> >
> > +static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
> > +{
> > +     u32 rtnl_event;
> > +
> > +     switch (event) {
> > +     case NETDEV_REBOOT:
> > +             rtnl_event = IFLA_EVENT_REBOOT;
> > +             break;
> > +     case NETDEV_FEAT_CHANGE:
> > +             rtnl_event = IFLA_EVENT_FEAT_CHANGE;
> > +             break;
> > +     case NETDEV_BONDING_FAILOVER:
> > +             rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
> > +             break;
> > +     case NETDEV_NOTIFY_PEERS:
> > +             rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
> > +             break;
> > +     case NETDEV_RESEND_IGMP:
> > +             rtnl_event = IFLA_EVENT_RESEND_IGMP;
> > +             break;
> > +     case NETDEV_CHANGEINFODATA:
> > +             rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
> > +             break;
> > +     default:
> > +             return 0;
> > +     }
> > +
> > +     return nla_put_u32(skb, IFLA_EVENT, rtnl_event);
> > +}
> > +
>
> I still have doubts about encoding kernel events into a uapi.

agree. I don't see why user-space will need NETDEV_CHANGEINFODATA and
others david listed.

My other concerns are, once we have this exposed to user-space and
user-space starts relying on it, it will need accurate information and
will expect to have this event information all the time.
IIUC, we cannot cover multiple events in a single notification and not
all link notifications will contain an IFLA_EVENT attribute. In other
words, we will be telling user-space to not expect that the kernel
will send IFLA_EVENT every time.



>
> For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
> about the name suggests it is a bonding notification. This one was added
> specifically to notify userspace (d4261e5650004), yet seems to happen
> only during a changelink and that already generates a RTM_NEWLINK
> message via do_setlink. Since the rtnetlink_event message does not
> contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
> really serve besides duplicating netlink messages to userspace.
>
> The REBOOT, IGMP, FEAT_CHANGE and BONDING_FAILOVER seem to be unique
> messages (code analysis only) which I get for notifying userspace.
>
> NETDEV_NOTIFY_PEERS is not so clear in how often it duplicates other
> messages.
