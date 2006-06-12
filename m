From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are never delivered
Date: Mon, 12 Jun 2006 07:02:45 +0100
Message-ID: <200606120702.46014@strip-the-willow>
References: <200606061925.40327@this-message-has-been-logged> <20060611.212913.70218067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@coreworks.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:10909 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1750949AbWFLGDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 02:03:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060611.212913.70218067.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller:
|  
|  > Fix:   Move the `UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS)' statement from 
|  >        udp_queue_rcv_skb to udp_recvmsg. Now InDatagrams only counts those
|  >        datagrams which were really delivered (as per RFC 2013). 
|  > 
|  
|  Unfortunately this breaks NFS and other in-kernel UDP socket usages,
|  which never call recvmsg() and instead take the packet via the
|  ->data_ready() callback done by sock_queue_receive_skb().
|  
|  Your patch will make the counter never get incremented when such
|  a user is using the UDP socket.
|  
|  Probably a better way to handle this is to correct the
|  INDATAGRAMS value by decrementing it when we notice that
|  the checksum is incorrect in a deferred manner.
This is clearly preferable - would it look like this:

csum_copy_err:
     UDP_INC_STATS_BH(UDP_MIB_INERRORS);
     UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS); /* requires new macro */

     skb_kill_datagram(sk, skb, flags);
     /* ... */

in udp_recvmsg? Here I must pass - there is no xxx_DEC_BH macro in 
include/net/snmp.h and I don't know whether the following guess is correct:

#define SNMP_DEC_STATS_BH(mib, field) 	\
	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]--)

If this is correct, then it seems done; one could use this macro or add
a corresponding UDP_DEC_STATS_BH to include/net/udp.h .



