From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 14:48:00 -0700 (PDT)
Message-ID: <20050519.144800.71090042.davem@davemloft.net>
References: <20050518235329.GA17946@us.ibm.com>
	<20050519133333.07a992e6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050519133333.07a992e6@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 19 May 2005 13:33:33 -0700

> The bridge doesn't need locking, or checksumming and can allow highdma
> buffers; all of which are handled by net/core/dev.c if needed.

As discuesed elsewhere, this handling by net/core/dev.c makes
TCP sending much more expensive when it is actually used.

Furthermore, I just found another hole in the idea to propagate
sub-device features into the bridge device.

If one device has NETIF_F_HW_CSUM and the others have NETIF_F_IP_CSUM,
both bits will be set in the bridge device and things will entirely
break.  The two checksumming on output schemes are different, and all
of the stack assumes that only one of these two bits are set.

I have such a setup in two of my sparc64 systems (sunhme does
NETIF_F_HW_CSUM, and tg3 does NETIF_F_IP_CSUM).  Also, my PowerMAC G5
has this problem too, the onboard sungem chip does NETIF_F_HW_CSUM and
the tg3 I have in a PCI slot does NETIF_F_P_CSUM.  So given that
half the machines I have powered on right here could trigger the
problem, it's far from theoretical :-)

There are multiple spots that want to do this kind of stuff
now (bridging, vlan, bonding) which indicates that some sort
of common infrastructure should be written to implement this
kind of stuff.
