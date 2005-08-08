From: "bdschuym@pandora.be" <bdschuym@telenet.be>
Subject: Re:  [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Mon, 08 Aug 2005 09:06:19 +0000
Message-ID: <W911141491296841123491979@kostunerix.telenet-ops.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "Harald Welte" <laforge@netfilter.org>
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

(using webmail)

>----- Oorspronkelijk bericht -----
>Van: Harald Welte [mailto:laforge@netfilter.org]
>Ok, so this is actually the opposite problem of the ipt_physdev.c
>problem.  Here we have the physical device, but not the bridge group.
>
>This means we have to handle two separate cases:
>
>1) when nf_log_packet() gets called from the bridging code
>	indev == eth0
>	outdev == eth1
>		-> we need to resolve br0 from dev->br_port member
>
>2) when nf_log_packet() gets called from the ipv4 code:
>	indev == br0
>	outdev == br0
>		-> we need to resolve ethX from skb->nf_bridge member
>
>If I'm now correct, what about the following [reverse] patch (also
>attached the whole resulting file for your reference, since you don't
>have access to the tree).

There is one case missing: the brouter case. If br0=eth0+eth1 and a packet arrives at eth0 (not br0) in the IP code (not the bridge code), then the indev must be eth0, not br0.
How about something like this?

if (pf == PF_BRIDGE) { /* Called from ebtables */
	NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
		sizeof(tmp_uint), &tmp_uint);
	tmp_uint = htonl(indev->br_port->br->dev->ifindex);
	NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
		sizeof(tmp_uint), &tmp_uint);
} else {
	NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
		sizeof(tmp_uint), &tmp_uint);

	if (skb->nf_bridge && skb->nf_bridge->physindev)
		/* Called inside bridge code, but not from ebtables. */
		tmp_uint = htonl(skb->nf_bridge->physindev->ifindex);
	NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
		sizeof(tmp_uint), &tmp_uint);
}

cheers,
Bart
