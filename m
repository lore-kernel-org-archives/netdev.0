From: =?ISO-8859-1?Q?Peter_Bostr=F6m?= <peter.bostrom@netrounds.com>
Subject: Wrong source MAC for 8021q VLAN interfaces with TX VLAN offload enabled
Date: Tue, 04 Mar 2014 20:38:14 +0100
Message-ID: <53162BA6.9080707@netrounds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:46963 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaCDTiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 14:38:17 -0500
Received: by mail-la0-f48.google.com with SMTP id gf5so5871763lab.21
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 11:38:15 -0800 (PST)
Received: from [192.168.13.100] (c-dc2170d5.05-148-6c756c10.cust.bredbandsbolaget.se. [213.112.33.220])
        by mx.google.com with ESMTPSA id bm3sm16003521lbb.12.2014.03.04.11.38.14
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 11:38:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

The patch committed as 2205369a314e12fcec4781cc73ac9c08fc2b47de (vlan: Fix header ops passthru when doing TX VLAN offload.) seems to have introduced a bug for me. It's reproducible in the current 3.14-rc5 as well as older versions for which the patch was applied.

By configuring a VLAN interface and changing the MAC address to something different from the parent interface, frames will be sent using the wrong source address. Tagged frames will have the source MAC address of the parent interface.

This affects only interfaces with TX VLAN offload enabled. By turning off the TX VLAN offload before creating the VLAN interface it works as expected.



How to reproduce:
# ip link add link eth1 name eth1.2 type vlan proto 802.1q id 2
# ip link set dev eth1.2 address 02:aa:aa:aa:aa:aa
# ip addr add dev eth1.2 10.0.2.1/24
# ip link set dev eth1 up
# ping 10.0.2.2

tcpdump on the receiver shows
16:42:26.757634 02:aa:aa:aa:aa:aa > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 56: Request who-has 10.0.2.2 tell 10.0.2.1, length 42
16:42:26.757644 00:25:90:20:54:b9 > 02:aa:aa:aa:aa:aa, ethertype ARP (0x0806), length 42: Reply 10.0.2.2 is-at 00:25:90:20:54:b9, length 28
16:42:26.757783 00:25:90:d4:30:90 > 00:25:90:20:54:b9, ethertype IPv4 (0x0800), length 98: 10.0.2.1 > 10.0.2.2: ICMP echo request, id 1893, seq 1, length 64
16:42:26.757791 00:25:90:20:54:b9 > 02:aa:aa:aa:aa:aa, ethertype IPv4 (0x0800), length 98: 10.0.2.2 > 10.0.2.1: ICMP echo reply, id 1893, seq 1, length 64
16:42:27.756677 00:25:90:d4:30:90 > 00:25:90:20:54:b9, ethertype IPv4 (0x0800), length 98: 10.0.2.1 > 10.0.2.2: ICMP echo request, id 1893, seq 2, length 64
16:42:27.756683 00:25:90:20:54:b9 > 02:aa:aa:aa:aa:aa, ethertype IPv4 (0x0800), length 98: 10.0.2.2 > 10.0.2.1: ICMP echo reply, id 1893, seq 2, length 64

Notice that the ARP packets are actually sent with the correct(configured) source MAC while the ICMP is sent using the address of the parent interface(00:25:90:d4:30:90).



A potential fix is to set the saddr in the vlan_passthru_hard_header function.
This works for me. But since I lack a good understanding of how the TX VLAN offload actually works I can't really tell whether this is a proper solution or not.
Any input would be appreciated.

--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -538,6 +538,9 @@
      struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
      struct net_device *real_dev = vlan->real_dev;

+    if (!saddr)
+        saddr = dev->dev_addr;
+
      return dev_hard_header(skb, real_dev, type, daddr, saddr, len);
  }
