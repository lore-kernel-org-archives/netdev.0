From: Michal Kazior <michal.kazior@tieto.com>
Subject: IPv6: routing/forwarding/masking link-local addresses
Date: Thu, 31 Mar 2016 11:44:58 +0200
Message-ID: <CA+BoTQnC-OKZ8eRohBYetfyW6-xo31kJtS8Lh+svxC=fkVsrXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network Development <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35734 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756455AbcCaJo7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 05:44:59 -0400
Received: by mail-wm0-f44.google.com with SMTP id 191so119693142wmq.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 02:44:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The most commonly used framing/addressing in 802.11 is 3addr. This is
how most Access Points work and Clients follow suit.

However it is impossible to put a 3addr Client interface into a bridge
because it's not possible to properly distinguish RA/TA/DA/SA
addresses.

There is 4addr framing in 802.11 (often referred to as WDS or
Repeater) but it's a loose standard and various vendors implement it
differently. For this kind of framing to work both AP and Client must
support the same flavor of the framing. Many APs don't even allow the
user to enable WDS. This makes it troublesome to extend wireless
networks without replacing AP equipment (upgrading AP software isn't
always an option).

There is already a userspace tool which solves this problem for IPv4
called relayd [1]. It forwards ARP/DHCP packets (and replaces MAC
addresses accordingly) between non-bridged interfaces and adds
additional route entries to the firewall to, effectively, act as a
bridge transparently. via routing. Compared to ARP Proxy it doesn't
require IP address configuration on local interfaces.

I'm trying to add IPv6 support for relayd. The problem is I can't get
link-local addresses to route properly.

I can easily get things like 2000::/32 to route perfectly fine but
fe80:: just won't work. Upon inspection I've noticed:

; ip link add veth0 type veth peer name veth1
; ip link set veth0 up
; ip link set veth1 up
; ip route add fe80::1 dev veth0
; ip route add 2000::1 dev veth0
; ip route get iif veth1 fe80::1
fe80::1 from :: dev veth1  metric 0
    cache  iif veth1
; ip route get iif veth1 2000::1
2000::1 from :: dev veth0  metric 0
    cache  iif veth1
; ip link del veth0

If I remove default fe80::/64 routes I get:

; ip link del veth0
; ip link add veth0 type veth peer name veth1
; ip link set veth0 up
; ip link set veth1 up
; ip route del fe80::/64 dev veth0
; ip route del fe80::/64 dev veth1
; ip route add fe80::1 dev veth0
; ip route add 2000::1 dev veth0
; ip route get iif veth1 fe80::1
unreachable fe80::1 from :: dev lo  table unspec  proto kernel  metric
4294967295  error -101 iif veth1
; ip route get iif veth1 2000::1
2000::1 from :: dev veth0  metric 0
    cache  iif veth1

The fe80:: route gets ignored completely in both cases.

My question is: can I make it work (a kernel knob I'm not aware of) or
does it require patching the kernel? Thoughts/ideas/hints?


Micha=C5=82

[1]: http://git.openwrt.org/?p=3Dproject/relayd.git;a=3Dsummary
