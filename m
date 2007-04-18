From: "Laurent Chavey" <chavey@google.com>
Subject: AF_PACKET how to get the original netdev from a packet received from a bonded master
Date: Wed, 18 Apr 2007 16:05:27 -0700
Message-ID: <97949e3e0704181605v39e24bh18ac278adc8b823f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:5919 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933089AbXDRXFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 19:05:38 -0400
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id l3IN5Ymk013544
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2007 00:05:34 +0100
Received: from ug-out-1314.google.com (ugcl31.prod.google.com [10.66.113.31])
	by spaceape12.eur.corp.google.com with ESMTP id l3IN5SOD030100
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2007 00:05:28 +0100
Received: by ug-out-1314.google.com with SMTP id l31so455521ugc
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2007 16:05:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using PF_PACKET socket with bonded interfaces, there is no
way to get the slave interface (physical interface) the packet was
actually received on.

It looks like  there isn't a way to pass the original device {see
packet_rcv() in ./net/packet/af_packet.c} to the socket reader.
When an interface is bounded, dev, by the time it reaches this function,
points to the the bonding interface not the Ethernet interface the packet
was receive on.  sockaddr_ll does not contain any fields that could be use to
pass the original device in.  As such there is no ways for an application
that is interested on the "physical interface" the packet was received on,
to get the information when running a bond (one that uses the same mac address
for all of its slave).


observation,
if one uses tcpdump on a bonded slave, only egress packets are taped.
if one uses tcpdump on a bonded master, ingress packets are taped, egress
packets are taped

from the above, it would make sense to have the same behavior on ingress/egress
for both slave and master. the later would require the taped packet be
"duplicated"
at packet_rcv() and passed up to the socket layer as two copies
   - one associated with the master dev
   - one associated with the slave dev.
