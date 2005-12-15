From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Thu, 15 Dec 2005 00:58:05 -0800 (PST)
Message-ID: <20051215.005805.114145703.davem@davemloft.net>
References: <20051214215613.70f9cafa@localhost.localdomain>
	<OFB8B21C56.4F9E9A3C-ON882570D8.002CBD7B-882570D8.002FF8B1@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org,
	mpm@selenic.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, sri@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965187AbVLOI7Y@vger.kernel.org>
To: dlstevens@us.ibm.com
In-Reply-To: <OFB8B21C56.4F9E9A3C-ON882570D8.002CBD7B-882570D8.002FF8B1@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 15 Dec 2005 00:44:52 -0800

> In our internal discussions

I really wish this hadn't been discussed internally before being
implemented.  Any such internal discussions are lost completely upon
the community that ends up reviewing such a core and invasive patch
such as this one.

>         The critical socket(s) simply have to be out of the zero-sum game
> for the rest of the allocations, because those are the (only) path to
> getting a working swap device again.

The core fault of the critical socket idea is that it is painfully
simple to create a tree of dependant allocations that makes the
critical pool useless.  IPSEC and tunnels are simple examples.

The idea to mark, for example, IPSEC key management daemon's sockets
as critical is flawed, because the key management daemon could hit a
swap page over the iSCSI device.  Don't even start with the idea to
lock the IPSEC key management daemon into ram with mlock().

Tunnels are similar, and realistic nesting cases can be shown that
makes sizing via a special pool simply unfeasible, and whats more
there are no sockets involved.

Sockets do not exist in an allocation vacuum, they need to talk over
routes, and there are therefore many types of auxiliary data
associated with sending a packet besides the packet itself.  All you
need is a routing change of some type and you're going to start
burning GFP_ATOMIC allocations on the next packet send.

I think making GFP_ATOMIC better would be wise.  Alan's ideas harping
from the old 2.0.x/2.2.x NFS days could use some consideration as well.
