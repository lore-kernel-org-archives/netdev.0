From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 1/2] Documentation:
 sysfs-class-net-statistics: Clarify rx_bytes and tx_bytes
Date: Thu, 25 May 2017 08:10:28 -0700
Message-ID: <20170525081028.04b49ff3@xeon-e3>
References: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
        <1495573858-32346-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        hayeswang <hayeswang@realtek.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33476 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934176AbdEYPKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 11:10:36 -0400
Received: by mail-pf0-f172.google.com with SMTP id e193so170099163pfh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 08:10:36 -0700 (PDT)
In-Reply-To: <1495573858-32346-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 May 2017 23:10:57 +0200
Andrew Lunn <andrew@lunn.ch> wrote:

> Document what is expected for the rx_bytes and tx_bytes statistics in
> /sys/class/net/<device>/statistics. The FCS should be included in the
> statistics. However, since this has been unclear until now, it is
> expected a number of drivers don't. But maybe with time they will.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  Documentation/ABI/testing/sysfs-class-net-statistics | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-class-net-statistics b/Documentation/ABI/testing/sysfs-class-net-statistics
> index 397118de7b5e..a487cbb79458 100644
> --- a/Documentation/ABI/testing/sysfs-class-net-statistics
> +++ b/Documentation/ABI/testing/sysfs-class-net-statistics
> @@ -21,7 +21,8 @@ Contact:	netdev@vger.kernel.org
>  Description:
>  		Indicates the number of bytes received by this network device.
>  		See the network driver for the exact meaning of when this
> -		value is incremented.
> +		value is incremented. However, for an Ethernet frame, it should
> +		include the Ethernet header, data, and frame check sum.
>  
>  What:		/sys/class/<iface>/statistics/rx_compressed
>  Date:		April 2005
> @@ -125,7 +126,8 @@ Description:
>  		device. See the network driver for the exact meaning of this
>  		value, in particular whether this accounts for all successfully
>  		transmitted packets or all packets that have been queued for
> -		transmission.
> +		transmission. For an Ethernet frame, it should include the
> +		Ethernet header, data, and frame check sum.
>  
>  What:		/sys/class/<iface>/statistics/tx_carrier_errors
>  Date:		April 2005

Sysfs statistics must match the netlink statistics. What matters is the
values reported in netlink, proc, and sysfs are the same.
Documenting the sysfs value here is nice but less important.
I worry that some naive implementer or tester might expect sysfs values
to follow different standard than other places.

For devices the important thing is that rx and tx values match. I.e if
FCS is counted on RX then it needs to get counted on Tx. I don't think
FCS should be part of data  statistics since many devices are virtual
and have no visible FCS.  For example if a packet is sent of virtio (no FCS)
to host vhost (no FCS) and then through bridge to physical hardware
which with your proposal does have FCS; all the data counts all matched.

With the advent of overlay networks this gets even more confusing.
Does overlay header count?

Linux in general has followed the BSD model of NOT including FCS
in device statistics. Some hardware vendors do include the FCS in
their stats but that is really a porting bug.

Unfortunately, even the router vendors can't agree on this.
RFC 2665 says that FCS should be included, but BSD derived systems
like Juniper do not. This is a mess.
