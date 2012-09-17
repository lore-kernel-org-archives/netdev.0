From: Chris Clayton <chris2553@googlemail.com>
Subject: Possible networking regression in 3.6.0
Date: Mon, 17 Sep 2012 16:44:26 +0100
Message-ID: <5057455A.7050108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43142 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232Ab2IQPoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 11:44:18 -0400
Received: by eaac11 with SMTP id c11so2506884eaa.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 08:44:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having a problem with networking. I'm running Windows XP as a KVM 
guest on a laptop running kernel 3.6.0-rc6. The identical configuration 
works fine with kernels 3.5.4 and 3.4.11 (and has done so, largely 
unchanged, since since KVM was introduced in 2.6.<whatever>.)

The configuration is:

XP guest:	192.168.200.1 (gateway 192.168.200.254)
tap0:		192.168.200.254
host:		192.168.0.40 (gateway 192.168.0.1)
router:		192.168.0.1

The script that starts up the firewall includes the following commands:

# Load the connection-sharing for qemu/kvm guests
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
...
# allow traffic to and from the qemu/kvm virtual networks
NETS="200 201"
for net in $NETS; do
   iptables -A INPUT -s 192.168.$net.0/24 -j ACCEPT
   iptables -A OUTPUT -d 192.168.$net.0/24 -j ACCEPT
done
...

The network-related modules that are loaded are:

$ lsmod
Module                  Size  Used by
tun                    12412  0
xt_state                 891  1
iptable_filter           852  1
ipt_MASQUERADE          1222  1
iptable_nat             3087  1
nf_nat                 10901  2 ipt_MASQUERADE,iptable_nat
nf_conntrack_ipv4       4942  4 nf_nat,iptable_nat
nf_defrag_ipv4           815  1 nf_conntrack_ipv4
nf_conntrack           37644  5 
ipt_MASQUERADE,nf_nat,xt_state,iptable_nat,nf_conntrack_ipv4
...
r8169                  47159  0

 From the host I can successfully ping the guest, tap0 and the router as 
you would expect, but from the guest, although I can ping the host and 
tap0, I cannot ping the router. In practice, this means I have no 
internet access from the guest. As I say, this configuration works 
perfectly under 3.5.x and 3.4.x kernels.

I'll do a coarse-grained "bisect" of Linus' 3.6 release candidates and 
report back, but does anyone have any prime-suspect patches that may be 
at the cause of this problem?

Let me know if there are any other diagnostics I can provide. Also, as 
I'm not subscribed to netdev, please cc me to any reply.

Thanks,

Chris
