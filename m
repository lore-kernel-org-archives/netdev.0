From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 6/6] bridge: add vlan info to bridge setlink and dellink
 notification messages
Date: Mon, 29 Dec 2014 21:17:15 -0800
Message-ID: <54A2355B.6060903@cumulusnetworks.com>
References: <1419887132-7084-7-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCnqBX8TWmG4O_wppKtbnnCEWaaz+bHreybd8pPfUPs+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43075 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbaL3FRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 00:17:17 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so18646656pdi.30
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 21:17:17 -0800 (PST)
In-Reply-To: <CAE4R7bCnqBX8TWmG4O_wppKtbnnCEWaaz+bHreybd8pPfUPs+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/14, 3:42 PM, Scott Feldman wrote:
> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> vlan add/deletes are not notified to userspace today. This patch fixes it.
>> Notifications will contain vlans compressed into ranges whereever applicable.
> Why is this notification needed?  On VLAN add/del, the port driver
> will already get called if it implements ndo_vlan_rx_add_vid and
> ndo_vlan_rx_kill_vid.
This is strictly for userspace.

>    The port driver already gets the notification
> it needs to filter vlans.  User space can query for vlan port
> membership if it needs to know.

You mean request a dump ?. yes it can if it needs all the configured vlans.
But for notifications, we must at the least notify what changed with 
respect to vlans with RTM_SETLINK/DELLINK, no ?
>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   net/bridge/br_netlink.c |    3 ++-
>>   net/core/rtnetlink.c    |    3 ++-
>>   2 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 16bdd5a..cebfb03 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -303,7 +303,8 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
>>          if (skb == NULL)
>>                  goto errout;
>>
>> -       err = br_fill_ifinfo(skb, port, 0, 0, event, 0, 0, port->dev);
>> +       err = br_fill_ifinfo(skb, port, 0, 0, event, 0,
>> +                            RTEXT_FILTER_BRVLAN_COMPRESSED, port->dev);
> This doesn't look right.  The skb wasn't allocated large enough to
> hold vlan info.  If this is working in your tests, you're getting
> lucky due to some skb padding.
>
> skb was allocated with br_nlmsg_size(), which doesn't include vlan info.
>
>>          if (err < 0) {
>>                  /* -EMSGSIZE implies BUG in br_nlmsg_size() */
>>                  WARN_ON(err == -EMSGSIZE);
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index d06107d..dad5fb6 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2878,7 +2878,8 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
>>
>>          if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
>>              br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
>> -               err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
>> +               err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev,
>> +                                       RTEXT_FILTER_BRVLAN_COMPRESSED);
>>                  if (err < 0)
>>                          goto errout;
>>          }
>> --
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
