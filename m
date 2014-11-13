From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Thu, 13 Nov 2014 08:50:41 -0800
Message-ID: <CAF2d9jjmFymJdZmnfDCCUTRSSm-63RPaEFdB3TeYOq9S3jcPOA@mail.gmail.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
 <546386AF.9030300@parallels.com> <CAF2d9jgRFZzjtEkwVqo5Jw1rzbAS_9NC8LiOtO6xHgWqkVM2Zg@mail.gmail.com>
 <546490E6.2050509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:65329 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933352AbaKMQvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 11:51:03 -0500
Received: by mail-vc0-f174.google.com with SMTP id la4so3923051vcb.19
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 08:51:02 -0800 (PST)
In-Reply-To: <546490E6.2050509@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 3:07 AM, Pavel Emelyanov <xemul@parallels.com> wrote:
>>>> +static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>>>> +                        struct nlattr *tb[], struct nlattr *data[])
>>>> +{
>>>> +     struct ipvl_dev *ipvlan = netdev_priv(dev);
>>>> +     struct ipvl_port *port;
>>>> +     struct net_device *phy_dev;
>>>> +     int err;
>>>> +
>>>> +     ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
>>>> +     if (!tb[IFLA_LINK]) {
>>>> +             ipvlan_dbg(3, "%s[%d]: Returning -EINVAL...\n",
>>>> +                        __func__, __LINE__);
>>>> +             return -EINVAL;
>>>> +     }
>>>> +
>>>> +     phy_dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
>>>> +     if (phy_dev == NULL) {
>>>> +             ipvlan_dbg(3, "%s[%d]: Returning -ENODEV...\n",
>>>> +                        __func__, __LINE__);
>>>> +             return -ENODEV;
>>>> +     }
>>>> +
>>>> +     /* TODO will someone try creating ipvlan-dev on an ipvlan-virtual dev?*/
>>>> +     if (!ipvlan_dev_master(phy_dev)) {
>>>> +             err = ipvlan_port_create(phy_dev);
>>>> +             if (err < 0) {
>>>> +                     ipvlan_dbg(3, "%s[%d]: Returning error (%d)...\n",
>>>> +                                __func__, __LINE__, err);
>>>> +                     return err;
>>>> +             }
>>>> +     }
>>>> +
>>>> +     port = ipvlan_port_get_rtnl(phy_dev);
>>>> +     /* Get the mode if specified. */
>>>> +     if (data && data[IFLA_IPVLAN_MODE])
>>>> +             port->mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
>>>
>>> Should the invalid value be checked here? There are places
>>> where we BUG() in mode being "unknown".
>>>
>> Assuming the calls come over netlink, the ".validate" will be called
>> before ".newlink", so that would be unnecessary, isn't it?
>
> Yes, you're right. I've missed the validate callback.
>
>>>> +             break;
>>>> +
>>>
>>>> +static int ipvlan_addr4_event(struct notifier_block *unused,
>>>> +                           unsigned long event, void *ptr)
>>>> +{
>>>> +     struct in_ifaddr *if4 = (struct in_ifaddr *)ptr;
>>>> +     struct net_device *dev = (struct net_device *)if4->ifa_dev->dev;
>>>> +     struct ipvl_dev *ipvlan = netdev_priv(dev);
>>>> +     struct in_addr ip4_addr;
>>>> +
>>>> +     ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
>>>> +     if (!ipvlan_dev_slave(dev))
>>>> +             return NOTIFY_DONE;
>>>> +
>>>> +     if (!ipvlan || !ipvlan->port)
>>>> +             return NOTIFY_DONE;
>>>> +
>>>> +     switch (event) {
>>>> +     case NETDEV_UP:
>>>
>>> Can it be (in the future) somehow restricted so that net-namespace wouldn't
>>> be able to assign arbitrary IP address here? One of the reasons for using
>>> such devices is to enforce the container to use the IP address given from
>>> the host.
>>>
>> Probably this could be a config (sysfs?) entry which would lockup the
>> config coming from ns when set. So code could look like -
>>           case NETDEV_UP:
>>                          if (!restrict_ns_config) {
>>                             ...
>>                          }
>>                          break;
>
> Maybe introduce some "lock" call for ipvlan device after which no new IP addresses
> can be assigned? And the configuration would look like
>
> 1. create ipvlan
> 2. move to proper net namespace
> 3. add addresses
> 4. lock
>
> ?
Yes. Exporting this "locked" property on the master device so that it
can be controlled from masters' net-ns. Only thing we have to ensure
is that both possibilities are allowed i.e. trusted ns where config do
not need to be locked as well as untrusted/hostile ns where one can
lock it down. However this is a future enhancement and if your
implementation idea is different than this concept; we can discuss it
at the time of implementation.
>
> Thanks,
> Pavel
>
