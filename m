From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Tue, 24 Mar 2015 10:58:15 -0700
Message-ID: <CAE4R7bDLi2hjA8iqtHZgbW=D4KZwJ_LLnpK2b0kNHzHoAVvN9g@mail.gmail.com>
References: <550C92F3.50302@cumulusnetworks.com>
	<20150320220946.GB31769@lunn.ch>
	<20150323002215.GA6074@roeck-us.net>
	<550F6D7D.7030403@gmail.com>
	<550F8102.7040701@roeck-us.net>
	<550F8600.2020300@gmail.com>
	<550F8987.5070600@roeck-us.net>
	<5510498D.5010001@cumulusnetworks.com>
	<CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
	<20150324142921.GA2026@nanopsycho.orion>
	<20150324160126.GA17104@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, roopa <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35976 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbCXR6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:58:17 -0400
Received: by qgez102 with SMTP id z102so834736qge.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 10:58:16 -0700 (PDT)
In-Reply-To: <20150324160126.GA17104@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 9:01 AM, Guenter Roeck <linux@roeck-us.net> wrote:
> On Tue, Mar 24, 2015 at 03:29:21PM +0100, Jiri Pirko wrote:
>> >
>> >diff --git a/drivers/net/ethernet/rocker/rocker.c
>> >b/drivers/net/ethernet/rocker/rocker.c
>> >index aab962c..0f7217f7 100644
>> >--- a/drivers/net/ethernet/rocker/rocker.c
>> >+++ b/drivers/net/ethernet/rocker/rocker.c
>> >@@ -3931,15 +3931,28 @@ unmap_frag:
>> >        return -EMSGSIZE;
>> > }
>> >
>> >+static bool rocker_port_dev_check(struct net_device *dev);
>> >+
>> > static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct
>> >net_device *dev)
>> > {
>> >        struct rocker_port *rocker_port = netdev_priv(dev);
>> >        struct rocker *rocker = rocker_port->rocker;
>> >        struct rocker_desc_info *desc_info;
>> >        struct rocker_tlv *frags;
>> >+       struct net_device *in_dev;
>> >        int i;
>> >        int err;
>> >
>> >+       if (rocker_port_is_bridged(rocker_port)) {
>> >+               rcu_read_lock();
>> >+               in_dev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
>>
>> Hmm, you iterate over all ports for every xmit call :/
>> Would be nicer if skb_iif would be netdev poiter. Not sure it is doable.
>>
> It may be easier (and faster) to loop through all rocker ports and try to find
> one with the same ifindex. Then the dev_check call would not be necessary.
>
> If the rocker switch can be attached to multiple bridges, it may also be
> necessary to check if the bridge group is the same for both ports.
>
> Guenter

Yes, good suggestions.  This is the flexibility part if we do the
check in the driver rather than code above.
