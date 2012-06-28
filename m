From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [PATCH 00/02] iproute2: Add support for new tunnel type VTI.
Date: Wed, 27 Jun 2012 18:01:46 -0700
Message-ID: <20120628010146.GA3971@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33503 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227Ab2F1BGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 21:06:08 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 2EE1E141032E
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 18:06:07 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id D8GuyB7AbCgg for <netdev@vger.kernel.org>;
	Wed, 27 Jun 2012 18:06:02 -0700 (PDT)
Received: from localhost (eng-dhcp-126.vyatta.com [10.3.0.126])
	by mail.vyatta.com (Postfix) with ESMTP id BE0661410189
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 18:06:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Resubmitting after taking into account review comments:
The VTI tunnel is applicable to esp, ah and ipcomp.

Introduction:
Virtual tunnel interface is a way to represent policy based IPsec tunnels as virtual interfaces in linux. This is similar to Cisco's VTI (virtual tunnel interface) and Juniper's representaion of secure tunnel (st.xx). The advantage of representing an IPsec tunnel as an interface is that it is possible to plug Ipsec tunnels into the routing protocol infrastructure of a router. Therefore it becomes possible to influence the packet path by toggling the link state of the tunnel or based on routing metrics.

Overview:
Natively linux kernel does not support ipsec as an interface. Also secure interface assume a ipsec policy 4 tupple of {dst-ip-any, src-ip-any, dst-port-any, src-port-any}. Applying this 4 tuple in linux would result in all traffic matching the ipsec policy. What is needed is a tunnel distinguisher. The linux kernel skbuff has fwmark which is used for policy based routing (PBR). Linux kernel version 2.6.35 enhanced SPD/SADB to use fwmark as part of the IPsec policy. Strongswan has also introduced support for this kernel feature with version 4.5.0. We can therefore use the fwmark as the distinguisher for tunnel interface. We can also create a light weight tunnel kernel module (vti) to give the notion of an interface for rest of the kernel routing system. The tunnel module does not do any enc
 apsulation/decapsulation. The kernel's xfrm modules still do the esp encryption/decryption. 

Enhancement to iproute2:
Add support to configure and display VTI tunnel using ioctl and rtnetlink.

Usage:
ip tunnel add sti15 mode vti remote 12.0.0.1 local 12.0.0.3 ikey 15
or
ip link add sti15 type vti key 15 remote 12.0.0.1 local 12.0.0.3

Sample strongswan config would be:
conn peer-12.0.0.1-tunnel-1
   left=12.0.0.3
   right=12.0.0.1
   leftsubnet=0.0.0.0/0
   rightsubnet=0.0.0.0/0
   ike=aes128-sha1-modp1024!
   ikelifetime=28800s
   keyingtries=%forever
   esp=aes128-sha1!
   keylife=3600s
   rekeymargin=540s
   type=tunnel
   pfs=yes
   compress=no
   authby=secret
   auto=start
   mark_in=0xf
   mark_out=0xf
   keyexchange=ikev1


Also you need the iptables rule for ingress esp and udp-4500 packets:
-A PREROUTING -s 12.0.0.1/32 -d 12.0.0.3/32 -p esp -j MARK --set-xmark 0xf/0xffffffff

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>

---
