From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: [PATCH] 2.6.3 fix vlan-encapsulated fragmented IP traffic
Date: Mon, 1 Mar 2004 08:06:29 +0100
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <200403010806.29759.bdschuym@pandora.be>
References: <200402291914.53578.bdschuym@pandora.be> <20040229215421.0ca987e8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "David S. Miller" <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20040229215421.0ca987e8.davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Monday 01 March 2004 06:54, David S. Miller wrote:
> Can you explain the 'mtu' fiddling a little bit?  I think it's correct...
> but you know :)

Between the Ethernet header and the IP header, there will be put a 
vlan-header. This is done in br_dev_queue_push_xmit(), with 
nf_bridge_maybe_copy_header(). By changing the mtu we make sure the IP 
packets arre small enough to allow the vlan header to be added.

> The one case I'm concerned about is when the device does hw acceleration
> of vlan tagging (ie. therefore things are transparent supposedly), is
> the 'mtu' adjustment thing correct in that case?

I don't think that's a problem. We only have this problem when the vlan-tagged 
IP packet enters the bridge as a whole, so the incoming bridge port doesn't 
strip the vlan header. Therefore, the outgoing bridge port shouldn't be 
adding the vlan-header, as it's already supposed to be there.
The difference between the slow_path and the normal path in ip_fragment() is 
that in the normal path we can use the skbuffs of the fragments and these 
already have enough space for the vlan header and the IP fragment size is 
small enough. In the slow_path the skbuffs are constructed and then we need 
these special measures.

> I'm applying this for now, as I can't come up with a better fix either.
> If we find a problem with this change, we'll fix that up.
>
> I'm really concerned, btw, that this is going to propagate to other places
> as well, what if something that gets handled this way gets sent over an
> IPIP tunnel via some route, and then IPIP has to make all of these crazy
> adjustments too?  That's going too far and we'll have to find a better
> way if that is the case.

I'm not sure how IPIP tunnels are implemented, but I'm assuming they strip the 
first IP header like the vlan code strips the vlan header when a vlan-packet 
arrives on a vlan-enabled device. Then there should be no problem with this. 
Even if it's done differently, I don't _think_ it will give a problem.
The problem is caused purely by the fact that the bridge-nf code 
(br_netfilter.c) skb_pulls the packet by 4 bytes if it's an IP packet inside 
a vlan-header, allowing the IP packet to be filtered by iptables, and as far 
as the IP code and iptables is concerned, there is no vlan-header. So we need 
to give the IP code a little help.
Extra code, analogous to the code for vlan, would need to be added in 
nf_bridge_pad() if we were to allow filtering IP packets inside a bridged 
IPIP packet, of course.

cheers,
Bart



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
