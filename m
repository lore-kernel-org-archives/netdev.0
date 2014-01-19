From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: issues with vxlan RX checksum offload under OVS datapath
Date: Mon, 20 Jan 2014 00:05:15 +0200
Message-ID: <52DC4C1B.5000309@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:39364 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbaASWFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 17:05:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

While testing the gro udp patches over a setup with openvswitch I noted 
that the RX checksum offload support introduced by Joseph's commit 
0afb166 "vxlan: Add capability of Rx checksum offload for inner packet" 
works fine when you use a setup made of

NIC --> IP stack --> vxlan device --> bridge --> tap

but not when its

NIC --> IP stack --> ovs vxlan port --> OVS DP --> tap

I narrowed it down to the fact the when going the OVS 
pathskb->encapsulation remains true also after the decap is done. 
Basically, this is the original hunk


> @@ -607,7 +607,17 @@ static int vxlan_udp_encap_recv(struct sock *sk, 
> struct sk_buff *skb)
>
>         __skb_tunnel_rx(skb, vxlan->dev);
>         skb_reset_network_header(skb);
> -       skb->ip_summed = CHECKSUM_NONE;
> +
> +       /* If the NIC driver gave us an encapsulated packet with
> +        * CHECKSUM_UNNECESSARY and Rx checksum feature is enabled,
> +        * leave the CHECKSUM_UNNECESSARY, the device checksummed it
> +        * for us. Otherwise force the upper layers to verify it.
> +        */
> +       if (skb->ip_summed != CHECKSUM_UNNECESSARY || 
> !skb->encapsulation ||
> +           !(vxlan->dev->features & NETIF_F_RXCSUM))
> +               skb->ip_summed = CHECKSUM_NONE;
> +
> +       skb->encapsulation = 0;

which was moved by your commits

5cfccc5 vxlan: Add vxlan recv demux.
7ce0475 vxlan: Restructure vxlan receive.

to a code which isn't shared by the vxlan driver and ovs vxlan datapath 
code, and I was thinking lets just move it back to vxlan_udp_encap_recv. 
However, we can't really make the "vxlan->dev->features & 
NETIF_F_RXCSUM" check - since there's no vxlan device for ovs datapath, 
any idea how to overcome this.

Moving this to shared code (while removing the check for 
vxlan->dev->features) made things to work on my setup, but this misses 
one of the original conditions, ideas?

I believe its too late for 3.13 unless there is going to be -rc9, but 
lets first see what's the right fix.

Or.
