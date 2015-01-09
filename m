From: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Subject: be2net: SR-IOV, vlan isolation issue
Date: Fri, 09 Jan 2015 10:31:29 +0100
Message-ID: <54AF9FF1.3040906@univ-nantes.fr>
Reply-To: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Yoann Juet <yoann.juet@univ-nantes.fr>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls1-cha.cpub.univ-nantes.fr ([193.52.103.113]:49504 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752904AbbAIJjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 04:39:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I recently discovered unattended behavior from Emulex cards with KVM 
hypervisor and SR-IOV. On such 10Gbps cards (be2net module, Emulex 
OneConnect OCm14102-U3-D devices), guest machines attached to VFs on the 
Emulex Physical Functions (PF) see all multicast and broadcast (not 
unicast) traffic from/to other VM located on the same PF **BUT** on 
other vlans. Just put into promiscuous mode the guest machine's 
interface and you will observe inbound, outbound (multicast + broadcast 
only) irrelevant traffic.

Please note that irrelevant traffic is not sent to the guest machine 
TCP/IP stack. No firewall hitting for instance. The issue is about 
traffic monitoring with a VF put into promiscuous mode using a sniffer 
like tshark, tcpdump... Vlan isolation seems not 100% effective from the 
guest perspective since mcast+bcast information leaks.

A similar issue has already been observed with Broadcom cards and then 
patched by the developer team. Refer to the post in archive "bnx2x + 
SR-IOV, no internal L2 switching", 12 Feb 2014. Emulex driver seems to 
suffer the same problem, isn't it ?

Many thanks for considering my request,
Best regards,
Yoann Juet

----

# ethtool -i eth2
driver: be2net
version: 10.4u
firmware-version: 10.2.470.14
bus-info: 0000:04:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: no
supports-priv-flags: no

#lspci -vv
...
[V1] Vendor specific: Emulex OneConnect OCm14102-U3-D 2-port 10GbE Mezz CNA
[V2] Vendor specific: OCm14102-U3-D
...

# uname -a
Linux machriemoor.u06.univ-nantes.prive 3.18.1-dsiun-141008 #12 SMP Wed 
Dec 24 11:34:32 CET 2014 x86_64 GNU/Linux

# virsh version
Compiled against library: libvirt 1.2.9
Using library: libvirt 1.2.9
Using API: QEMU 1.2.9
Running hypervisor: QEMU 2.1.2

I'm using libvirt with <hostdev> XML blocks to assign VF to a particular 
vlan: For instance:

     <interface type='network'>
       <mac address='de:ad:ef:ef:f3:01'/>
       <source network='pf-eth2'/>
       <vlan>
         <tag id='888'/>
       </vlan>
     </interface>

----
