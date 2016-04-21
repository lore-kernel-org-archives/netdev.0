From: Patrick Schaaf <netdev@bof.de>
Subject: bridge not learning from locally sent gratuitous ARP?
Date: Thu, 21 Apr 2016 08:37:32 +0200
Message-ID: <CAJ26g5SKzs=+0MmanfC4Hfuti_jLo5R=e6T6imNc98rXVsA1ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:33264 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbcDUGnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 02:43:43 -0400
Received: from localhost (localhost [127.0.0.1])
	by mars.intermailgate.com (Postfix) with ESMTP id 5CA544043D
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 08:37:34 +0200 (CEST)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by mars.intermailgate.com (Postfix) with ESMTPSA id B21F84030E
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 08:37:33 +0200 (CEST)
Received: by mail-io0-f180.google.com with SMTP id f89so58679042ioi.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 23:37:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdev,

I've got a peculiar issue, and hope for clarification / workarounds here.

Scenario:
- a bridge interface br0, over some ethernet base
- a macvlan interface br0-vrrp on top, set up by keepalived, with VRRP VMAC
- keepalived regularly sending gratuitous ARP with that VRRP VMAC
- (new) an additional tap interface in br0, for an openvpn link

In principle, everything is working fine. The base keepalived setup
has been in operation for a long time, running directly over a VLAN
interface. The conversion to a bridge interface is also working
without any issues by itself. The additional tap to openvpn, and the
VPN setup it realizes, is also working fine, in principle...

Issue:
- openvpn runs at 100% CPU ....
- because it it sent all packets destined to the VRRP VMAC
- because that VMAC is not in the br0 learned MAC address table (brctl showmacs)
- thus the (production webserver outbound...) traffic is flooded to
all br0 ports

Diagnosis I did so far:
- with tcpdump, verified that I can see the gratuitous ARPs on both the macvlan
  and bridge interface.
- verified that "brctl showmacs" does not contain the VRRP VMAC
- identical setup for a different VLAN with almost no traffic to the
VMAC, has openvpn running without the huge CPU consumption
- straced the openvpn daemon with the issue, seeing the packet rate
expected as tap reads / sends to the remote site

Kernel:
3.14.48 (vanilla)
keepalived 1.2.13 (with repeated gratuitous ARP support patched in)

Can anybody shed a light on how to cope with this issue?

best regards
  Patrick
