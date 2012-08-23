From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] team: add support for non-ethernet devices
Date: Thu, 23 Aug 2012 10:04:12 +0200
Message-ID: <20120823080412.GB1592@minipsycho.orion>
References: <1345212048-1378-1-git-send-email-jiri@resnulli.us>
 <CAJZOPZLzL5KMF=HjJ=HZYNUerBXV2Es0cDq9rdP=ZYvsEJv7gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38817 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160Ab2HWIER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 04:04:17 -0400
Received: by bkwj10 with SMTP id j10so115813bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 01:04:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZLzL5KMF=HjJ=HZYNUerBXV2Es0cDq9rdP=ZYvsEJv7gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 23, 2012 at 09:37:40AM CEST, or.gerlitz@gmail.com wrote:
>On Fri, Aug 17, 2012 at 5:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This is resolved by two things:
>> 1) allow dev_addr of different length than ETH_ALEN
>> 2) during port add, check for dev->type and change it if necessary
>> +static void team_setup_by_port(struct net_device *dev,
>> +                              struct net_device *port_dev)
>> +{
>> +       dev->header_ops = port_dev->header_ops;
>> +       dev->type = port_dev->type;
>> +       dev->hard_header_len = port_dev->hard_header_len;
>> +       dev->addr_len = port_dev->addr_len;
>> +       dev->mtu = port_dev->mtu;
>> +       memcpy(dev->broadcast, port_dev->broadcast, port_dev->addr_len);
>> +       memcpy(dev->dev_addr, port_dev->dev_addr, port_dev->addr_len);
>> +       dev->addr_assign_type &= ~NET_ADDR_RANDOM;
>> +}
>
>Hi Jiri,
>
>I'm not sure if here, or in the area where this is called, but, aren't
>we missing re-computation of the team device features
>that follows what the port supports?
>
>I've been playing a bit with the patch and IPoIB, using iproute2/ip I
>was able to create team device and set/unset it as the master of IPoIB
>devices.  I had little configuration problem with building libteam
>(will comm off list to fix that) which means that teaming was fully
>using its defaults. I had set IP address for the team device and
>issued a ping, I don't see that team attempts to xmit the ARPs through
>the ib0 port though, the team drop counter keeps increasing. Could
>that be me falling into a non-supported area, since I didn't
>explicitly set mode used by teaming?

The problem is that by default, no mode is selected. You have to select
the mode either by team_manual_control or preferably by using teamd.

>
>Also, re the features issue, I was able to trigger a concrete problem,
>with IPoIB vlans are implemented with child devices that use IB
>partitions, and hence IPoIB advertized being vlan challenged.  I was
>able to create a 8021q vlan device over a teaming device that has
>IPoIB port, which shouldn't be the case.

You are right. NETIF_F_VLAN_CHALLENGED feature needs to be considered in
team code.

>
>Here are some logs, basically, there's some failure print here which I
>wasn't sure to follow
>
>IPv6: ADDRCONF(NETDEV_UP): ib0: link is not ready
>IPv6: ADDRCONF(NETDEV_CHANGE): ib0: link becomes ready
>(unregistered net_device): Failed to send options change via netlink (err -3)

I agree this is misleading. I will change/remove this message.

Thanks!

Jiri

>team0: Device ib0 is up. Set it down before adding it as a team port
>8021q: adding VLAN 0 to HW filter on device team0
>
>the sequence I used is
>
>$ ip link add name team0 type team
>$ ip link set master team0
>$ ifconfig team0 192.168.20.18/24 up
>$ vconfig add team0 51
>
>Or.
