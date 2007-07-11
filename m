From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC 0/3] lro: Generic Large Receive Offload for TCP traffic
Date: Wed, 11 Jul 2007 16:21:24 +0200
Message-ID: <200707111621.24852.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:36347 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbXGKOrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 10:47:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Generic Large Receive Offload proposal

After some discussions on the mailing list concerning our LRO approach,
we agreed to provide a generic LRO patch. The algorithm is based on
the version we developed for eHEA. The performance improvements we
observed were significant.

The LRO functionality is provided as a module, the files are put in
linux/net/ipv4/inet_lro.c
linux/include/linux/inet_lro.h

Would this be the proper place for this functionality?

Currently, the interface is exported via EXPORT_SYMBOL. Or should we use
EXPORT_SYMBOL_GPL instead?


The interface for the network drivers (see inet_lro.h):

A driver has to declare a "LRO Management" struct (lro_mgr) and a LRO descriptor array
of a driver defined size and enters the address of the array and the number of its
elements in the lro_mgr struct. The driver also specifies how many packets
may be aggregated per tcp session in the lro_mgr struct. In addition to that
the driver provides a function that determines the TCP and IP header for the
incoming packet (also entered in the lro_mgr struct). For some ethernet chips this
function doesn't need to do a lot of checking there as the tcp / ip checksums are 
checked by the HW and provides information about the packet protocoll.

To pass packets to the network stack using LRO the following functions are used 
in the NAPI poll function:

void lro_receive_skb(struct net_lro_mgr *lro_mgr,
                     struct sk_buff *skb,
                     void *priv);

or 

void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
                                  struct sk_buff *skb,
                                  struct vlan_group *vgrp,
                                  u16 vlan_tag,
                                  void *priv);

and before leaving the poll function the driver has to flush all open LRO sessions 
and pass the aggregated packets to the stack:

void lro_flush_all(struct net_lro_mgr *lro_mgr);

[RFC 3/3] includes an eHEA patch which shows how LRO is integrated
in the eHEA driver using this interface.


Regards,
Jan-Bernd
