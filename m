From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix tuntap oversight
Date: Mon, 12 Apr 2004 12:43:30 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <407AC732.1090000@pobox.com>
References: <20040412065947.GC18810@net-ronin.org> <20040412001551.05476658.davem@redhat.com> <20040412162916.GA5046@net-ronin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeremy Martin <martinjd@csc.uvic.ca>
In-Reply-To: <20040412162916.GA5046@net-ronin.org>
List-Id: netdev.vger.kernel.org

Jeremy Martin wrote:
> On Mon, Apr 12, 2004 at 12:15:51AM -0700, David S. Miller wrote:
> 
>>This netif_running() check is not necessary, and in fact
>>wrong.
>>
>>In fact, if ethernet drivers erroneously do this, this causes
>>them to fail to support the ALB bonding driver modes which
>>require on-the-fly MAC address changes while the interface is
>>up.
>>
> 
> 
> I just took a look in drivers/net/
> and 
> 	acenic.c
> 	atarilance.c
> 	b44.c
> 	cs89x0.c
> 	net_init.c
> 	typhoon.c
> 
> all use that netif_running() check when setting the MAC.  I actually just pulled
> the function from net_init.c for the tun change.  Are these broken?
> (I'm asking in total ignorance so be gentle :).

It's different for a driver that drives real hardware.

struct net_device::set_mac_address() is called inside rtnl_lock().  The 
safe thing to do is
1) read MAC address from eeprom on probe
2) write MAC address to hardware upon each dev->open()
3) use default eth_mac_addr() from net_init.c

And the netif_running() check in eth_mac_addr() is correct, because it 
does not update the hardware MAC address (which in this API would be 
impossible).

Normally the netif_running() check is for hardware that cannot update 
its MAC address safely during operation.

	Jeff
