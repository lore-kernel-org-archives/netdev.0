From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Mon, 08 Aug 2005 06:57:40 +0000
Message-ID: <1123484260.3686.1.camel@localhost.localdomain>
References: <20050730110353.GD6620@rama.de.gnumonks.org>
	<20050730.210423.111177162.davem@davemloft.net>
	<20050731070509.GD3835@rama.de.gnumonks.org>
	<1123241167.3377.15.camel@localhost.localdomain>
	<20050805163709.GF4033@rama.de.gnumonks.org>
	<20050805171028.GA7855@rama.de.gnumonks.org>
	<1123450076.3378.18.camel@localhost.localdomain>
	<20050807213340.GA4508@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050807213340.GA4508@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Op zo, 07-08-2005 te 23:33 +0200, schreef Harald Welte: 
> > indev->br_port->br->dev->ifindex points to the ifindex of the bridge br0
> > when indev is a bridge port (eth0). So you need this to fill in the
> > input device (assuming we agree that the bridge is called the input
> > device, and the bridge port is called the physical input device).
> > Filling in the physical input device is done with indev (in case
> > indev->br_port is not NULL).
> 
> I'm not sure if I can follow you.  What basically happens is:
> 
> ebt_ulog calls nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, ...) where
> "in" and "out" are struct net_device as passed to the ebt_ulog function
> (which is part of the ebt_watcher).  
> 
> [...]
> 
> the code ends up at the function you are quoting above.  "indev"
> is "in" and "outdev" is "out", transparently passed from
> nf_log_packet().
> 
> So I think it should reflect exactly what you currently do in ebt_ulog.
> The only diference is that you now get the ifindex and not the device
> name string.

ebt_ulog code snippet:
strcpy(pm->physindev, in->name);
/* If in isn't a bridge, then physindev==indev */
if (in->br_port)
strcpy(pm->indev, in->br_port->br->dev->name);
else
strcpy(pm->indev, in->name);

Your code snippet:
if (indev->br_port) {
tmp_uint = htonl(indev->br_port->br->dev->ifindex);
NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
        sizeof(tmp_uint), &tmp_uint);
}

These two code fragments do not do the same thing. If indev is a bridge
port (meaning indev->br_port != NULL), then the NFULA_IFINDEX_PHYSINDEV
must be indev, while the NFULA_IFINDEX_INDEV must be in->br_port->br-
>dev->name.
If indev is not a bridge port, the ebt_ulog code makes
NFULA_IFINDEX_PHYSINDEV and NFULA_IFINDEX_INDEV the same (indev).

cheers,
Bart
