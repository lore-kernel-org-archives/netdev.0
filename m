From: Andrew Lutomirski <amluto@gmail.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Sun, 5 Apr 2009 00:00:51 -0400
Message-ID: <cb0375e10904042100o1a203512l593021ee66cb591d@mail.gmail.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	 <20090404.170539.148727646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:44083 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbZDEEAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 00:00:55 -0400
In-Reply-To: <20090404.170539.148727646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 4, 2009 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Lutomirski <amluto@gmail.com>
> Date: Wed, 1 Apr 2009 11:40:06 -0400
>
>> When a network driver registers a new interface, linkwatch will not notice,
>> and hence not set the rfc2863 operstate, until netif_carrier_on gets called.
>> If the new interface has no carrier when it is connected, then a status of
>> "unknown" is reported to userspace, which confuses various tools
>> (NetworkManager, for example).
>>
>> This fires a linkwatch event for all new interfaces, so that operstate
>> gets set reasonably quickly.
>>
>> Signed-off-by: Andrew Lutomirski <amluto@gmail.com>
>
> The default assumed state for a freshly registered network
> device is that the link is up.
>
> If that disagrees from reality, the driver should make the
> appropriate netif_carrier_off() call.
>
> I'm sure you'll find that the e1000 driver is not doing this
> and that is what causes the bug you are seeing.
>

Nope.  The end of e1000_probe (in e1000e) is:

        /* tell the stack to leave us alone until e1000_open() is called */
        netif_carrier_off(netdev);
        netif_tx_stop_all_queues(netdev);

        strcpy(netdev->name, "eth%d");
        err = register_netdev(netdev);
        if (err)
                goto err_register;

        e1000_print_device_info(adapter);

netif_carrier_off does:

void netif_carrier_off(struct net_device *dev)
{
        if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
                if (dev->reg_state == NETREG_UNINITIALIZED)
                        return;
                linkwatch_fire_event(dev);
        }
}

So, either it should be illegal to call netif_carrier_off on an
unregistered net_device (and there should be a WARN() in
netif_carrier_off), or it should work correctly, and
register_netdevice should do the right thing when there is no carrier
(i.e. something like my patch).

--Andy
