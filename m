From: Ed Swierk <eswierk@skyportsystems.com>
Subject: Disable all network protocols on an interface?
Date: Mon, 14 Nov 2016 20:41:45 -0800
Message-ID: <f7a8d4f6-dbe8-f966-0efb-1091cc0403c5@skyportsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Ed Swierk <eswierk@skyportsystems.com>
To: linux-netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35032 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965111AbcKOEq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 23:46:57 -0500
Received: by mail-pg0-f50.google.com with SMTP id p66so62092343pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 20:46:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a Linux kernel 4.4 system hosting a number of kvm VMs. Physical interface eth0 connects to an 802.1Q trunk port on an external switch. Each VM has a virtual interface (e1000 or virtio-net) connected to the physical NIC through a macvtap interface and a VLAN interface; traffic between the external switch and the host is tagged with a per-VM tag. The only logic is demultiplexing incoming traffic by VLAN tag and stripping the tag, and adding the tag for outgoing traffic. Other than that, the eth0-VM datapath is a dumb pipe.

eth0 is assigned an IP address for host applications to send and receive untagged packets. For example, here's the setup with 2 VMs.

        +- (untagged) 192.168.0.2
  eth0 -+- (tag 1) --- eth0.1 --- macvtap1 --- VM1
        +- (tag 2) --- eth0.2 --- macvtap2 --- VM2

Various iptables rules filter the untagged packets received for host applications. The last rule in the INPUT chain logs incoming packets that don't match earlier rules:

  -A INPUT -m limit --limit 10/min -j LOG --log-prefix FilterInput

This all works, but I see occasional FilterInput messages for traffic received on eth0.1 and eth0.2: so far, only DHCP packets with destination MAC address ff:ff:ff:ff:ff:ff.

  FilterInput IN=eth0.1 OUT= MAC=ff:ff:ff:ff:ff:ff:00:01:02:03:04:05:08:00 SRC=0.0.0.0 DST=255.255.255.255 LEN=328 TOS=0x10 PREC=0x00 TTL=128 ID=0 PROTO=UDP SPT=68 DPT=67 LEN=308

Even though these are IP packets, I naively expect packets received on the VLAN interface lacking IP address to be either consumed by the attached macvtap or dropped before they trigger an iptables filter INPUT rule. It's a bit alarming to see packets destined for a VM to be processed at all by the host IP stack.

Digging through the code, I find that the core packet receive function __netif_receive_skb_core() first gives master devices like bridges and macvlans/macvtaps a chance to consume the packet; otherwise the packet gets handled by all installed protocols like IPv4. The packet gets pretty far down the IP receive process before it's discovered that there's nowhere to route it to, and no local sockets to deliver it to. The iptables INPUT chain is invoked well before that happens. (As far as I can tell, there's no explicit check in the IP receive code whether a local interface has an IP address.)

The macvlan's rx_handler definitively consumes or drops unicast packets, depending on the destination MAC address. But for broadcast packets, it  passes the packet to the attached VM interface and also tells the core receive function to continue processing it. Presumably this is to allow a macvlan to attach to one or more VMs as well as have a local IP address.

The logic in the bridge driver is a bit different: it consumes all packets from the slave interface. This makes sense as only the bridge master interface can be assigned a local IP address.

However in my application, I'm setting up the macvtap interfaces in passthrough mode, which precludes assigning a local IP address, just like a bridge slave. So it stands to reason that for a macvlan in passthrough mode, its rx_handler should consume or drop all packets, and not allow broadcast packets to also be handled locally.

This one-line change seems to do the trick:

--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -411,7 +411,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
        rx_handler_result_t handle_res;

        port = macvlan_port_get_rcu(skb->dev);
-       if (is_multicast_ether_addr(eth->h_dest)) {
+       if (is_multicast_ether_addr(eth->h_dest) && !port->passthru) {
                skb = ip_check_defrag(dev_net(skb->dev), skb, IP_DEFRAG_MACVLAN);
                if (!skb)
                        return RX_HANDLER_CONSUMED;

Well, mostly. I still see FilterInput log messages in the brief window between creating the VLAN interface and attaching the macvtap to it, since there's no rx_handler to consume them. Hooking the VLAN interface to a bridge rather than a macvtap suppresses local IP processing on the slave but enables it on the bridge master interface. Apparently any non-slave interface can handle IP traffic to some extent, even if it doesn't have an IP address.

I worry that allowing any IP processing at all on eth0-VM traffic is a potential security hole, and I'm one configuration typo away from letting VM's traffic leak into another VM or a host application, and vice versa. And logging those FilterInput messages for non-local traffic just looks like sloppy security.

Is there some way to stop all local protocols from handling packets received on an interface--a protocol-agnostic equivalent of net.ipv6.conf.INTF.disable_ipv6? Would it be reasonable to implement one?

--Ed
