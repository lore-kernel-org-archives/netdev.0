From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: [PATCH] 2.6.3 fix vlan-encapsulated fragmented IP traffic
Date: Mon, 1 Mar 2004 19:47:51 +0100
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <200403011947.51621.bdschuym@pandora.be>
References: <200402291914.53578.bdschuym@pandora.be> <200403010806.29759.bdschuym@pandora.be> <20040301003525.522d6db2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "David S. Miller" <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20040301003525.522d6db2.davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5ji9XKYC2TYK4Io4DoRGLOrNAH6kLmebB@public.gmane.org>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5lLLH9aP38KF1pqr+6INuaA@public.gmane.org>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5R9m/fhtKvoLKtGCp0j7rLg@public.gmane.org>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

On Monday 01 March 2004 09:35, David S. Miller wrote:
> Let us say that on input, br strips the 4 bytes as you say, iptables looks
> at the thing and rewrites the IP source/destination address or whatever,
> and this causes the packet to actually get forwarded out via a different IP
> route, and let us say that this new IP route causes the packet to go out
> via an IPIP tunnel device, which must do all the same kind of crap the code
> you're patching here does, that is determine the LL header size etc. in
> order to make sure there is enough headroom to slap on the new IP
> encapsulating header.
>
> If you can show that this kind of scenerio would never be generated in the
> cases where br-netfilter is involved, then fine.

The IPIP code does
dev->hard_header_len=LL_MAX_HEADER+sizeof(struct iphdr);
so there's no problem there because the macro LL_RESERVED_SPACE uses that 
value. There should never be a problem like that with routing.
When routing IP packets, skb->protocol will always be set to ETH_P_IP, so 
nf_bridge_pad doesn't do anything.

Obviously, adding a normal Ethernet device and, say, a vlan-enabled device as 
bridge ports of the same bridge is bound to give problems because full 
Ethernet frames will arrive on the normal device and there's no room to 
insert a vlan header before sending them onto the vlan-enabled port. For IP 
packets we might be able to fix this when ip_conntrack is loaded by using 
fragmenting, but I don't think this currently works. I'll have to experiment.

Note that changing the IP destination in a vlan-embedded packet makes the 
bridge code pass the packet up to higher layers (unless it can still be 
bridged), but the vlan header is not yet stripped. So only if the bridge 
device itself is vlan-enabled, will the packet be able to be routed. But 
first the vlan tag will be stripped (by the vlan-enabled bridge device).

cheers,
Bart



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
