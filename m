From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/2] ipvlan: always allow the broadcast MAC address
Date: Fri, 27 Mar 2015 22:56:15 -0700
Message-ID: <CAF2d9jh_-DxxUMcTjFK3TUAJhC=B9ORrmH0=tVH1KBiWsYPpLg@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com> <1427409822.18540.13.camel@redhat.com>
 <CAF2d9jjxoKFoX7bvJ7+cA685iBT9fPgjvjTKe8ppE_J3oWJgrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35093 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbC1F4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:56:36 -0400
Received: by qgh3 with SMTP id 3so135505590qgh.2
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:56:36 -0700 (PDT)
In-Reply-To: <CAF2d9jjxoKFoX7bvJ7+cA685iBT9fPgjvjTKe8ppE_J3oWJgrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 5:52 PM, Mahesh Bandewar <maheshb@google.com> wrote:
> On Thu, Mar 26, 2015 at 3:43 PM, Dan Williams <dcbw@redhat.com> wrote:
>> ipvlan currently fails DHCP addressing for two reasons:
>>
>> 1) DHCP offers are typically unicast back to the device's MAC
>> address, and at the IP layer have a destination IP address
>> matching the new lease address.  In ipvlan unicast packets
>> are checked against existing addresses assigned to the ipvlan
>> interface, so clearly this fails hard because the ipvlan
>> interface has no IP addresses yet.  Workaround: request
>> that the server broadcast replies (-B for dhclient), which
>> don't get checked against the IP address list.
>>
>> 2) Even when that's done, mac_filters only allows the
>> broadcast MAC address when the interface has >= 1 IPv4
>> addresses, so double-fail, and the incoming DHCP offer
>> gets dropped on the floor again.
>>
>> Instead of doing ugly stuff like watching for outgoing DHCP
>> requests and adding the broadcast MAC to mac_filters for
>> a period of time, just always allow the broadcast MAC.  This
>> lets the ipvlan interface be configured with DHCP in
>> Layer2 mode as long as as broadcast replies are used.
>>
> Guys, stop thinking that we live in IPv4-only world! Think about a
> hybrid environment where all your IPvlan slaves are IPv6 only while
> your network has IPv4 (with crap-load of broadcast traffic) and IPv6
> traffic. In that situation IPvlan demuxer has to forward all that
> broadcast-traffic to it's slaves which they don't care at all.
>
> I agree that the current driver falls short of handling DHCPv4 and
> needs a fix. But for couple of initial config packets, it's not wise
> to loose the performance forever. I don't like this patch.
>
I think the easiest way to fix this would be to flip the logic -

The current logic disables broadcast by default and enables only when
an IPv4 address is added. If this is inverted and -
enables broadcast by default but disables it when only IPv6
address(es) is / are added. These links can have multiple addresses
and hence have to be careful if any one of those is IPv4 then
broadcast bit has to be set.
>
>> Signed-off-by: Dan Williams <dcbw@redhat.com>
>> ---
>>  drivers/net/ipvlan/ipvlan_main.c | 21 ++++-----------------
>>  1 file changed, 4 insertions(+), 17 deletions(-)
>>
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> index d34f580..787d7fb 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>> @@ -214,17 +214,6 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
>>                 dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
>>  }
>>
>> -static void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
>> -{
>> -       struct net_device *dev = ipvlan->dev;
>> -       unsigned int hashbit = ipvlan_mac_hash(dev->broadcast);
>> -
>> -       if (set && !test_bit(hashbit, ipvlan->mac_filters))
>> -               __set_bit(hashbit, ipvlan->mac_filters);
>> -       else if (!set && test_bit(hashbit, ipvlan->mac_filters))
>> -               __clear_bit(hashbit, ipvlan->mac_filters);
>> -}
>> -
>>  static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>>  {
>>         struct ipvl_dev *ipvlan = netdev_priv(dev);
>> @@ -239,11 +228,11 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>>                 netdev_for_each_mc_addr(ha, dev)
>>                         __set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
>>
>> +               /* always allow broadcast frames */
>> +               __set_bit(ipvlan_mac_hash(dev->broadcast), mc_filters);
>> +
>>                 bitmap_copy(ipvlan->mac_filters, mc_filters,
>>                             IPVLAN_MAC_FILTER_SIZE);
>> -
>> -               if (ipvlan->ipv4cnt)
>> -                       ipvlan_set_broadcast_mac_filter(ipvlan, true);
>>         }
>>         dev_uc_sync(ipvlan->phy_dev, dev);
>>         dev_mc_sync(ipvlan->phy_dev, dev);
>> @@ -470,6 +459,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>>         INIT_LIST_HEAD(&ipvlan->addrs);
>>         ipvlan->ipv4cnt = 0;
>>         ipvlan->ipv6cnt = 0;
>> +       __set_bit(ipvlan_mac_hash(dev->broadcast), ipvlan->mac_filters);
>>
>>         /* TODO Probably put random address here to be presented to the
>>          * world but keep using the physical-dev address for the outgoing
>> @@ -694,7 +684,6 @@ static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>>         list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>>         ipvlan->ipv4cnt++;
>>         ipvlan_ht_addr_add(ipvlan, addr);
>> -       ipvlan_set_broadcast_mac_filter(ipvlan, true);
>>
>>         return 0;
>>  }
>> @@ -711,8 +700,6 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>>         list_del_rcu(&addr->anode);
>>         ipvlan->ipv4cnt--;
>>         WARN_ON(ipvlan->ipv4cnt < 0);
>> -       if (!ipvlan->ipv4cnt)
>> -           ipvlan_set_broadcast_mac_filter(ipvlan, false);
>>         kfree_rcu(addr, rcu);
>>
>>         return;
>> --
>> 2.1.0
>>
>>
