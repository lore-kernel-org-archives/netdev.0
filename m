From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 13:53:44 -0800
Message-ID: <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	jesse@kernel.org, Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33656 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbbKWVxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 16:53:45 -0500
Received: by igcmv3 with SMTP id mv3so38585176igc.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 13:53:44 -0800 (PST)
In-Reply-To: <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index cb2f89f..72415aa 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -9,6 +9,12 @@
>  #include <net/addrconf.h>
>  #endif
>
> +enum udp_tunnel_type {
> +       UDP_TUNNEL_UNSPEC,
> +       UDP_TUNNEL_VXLAN,
> +       UDP_TUNNEL_GENEVE,
> +};
> +

Sorry, I still don't like this. Grant it least it gets rid of of VXLAN
specific ops, but the problem is there no such things as a common set
of encapsulations in the kernel (e.g. foo-over-udp adds a bunch of
encapsulations not represented here), no defined common set of device
functionality that needs this, and this precludes the use of the RX
accelerations to be available from a userpsace  implementation.

The bad effect of this model is that it is encourages HW vendors to
continue implement HW protocol specific support for encapsulations, we
get so much more benefit if they implement protocol generic
mechanisms. For instance, it is much better that they return
CHECKSUM_COMPLETE rather than giving us checksum unnecessary
indication for a TCP checksum within VXLAN.

If the devices needs to be configured for some protocol specific
actions then ntuple filters on the port seems like the right
interface. Really the only common NIC offload that might need this at
all is LRO. RSS, the checksum offloads, and LSO (for UDP tunnels) can
all be implemented generically without regard to the specific
encapsulation being used.

Tom
