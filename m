From: David Miller <davem@davemloft.net>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are
 never delivered
Date: Sun, 11 Jun 2006 21:29:13 -0700 (PDT)
Message-ID: <20060611.212913.70218067.davem@davemloft.net>
References: <200606061925.40327@this-message-has-been-logged>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@coreworks.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29836
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751146AbWFLE3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 00:29:06 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200606061925.40327@this-message-has-been-logged>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 6 Jun 2006 19:25:40 +0100

> Fix:   Move the `UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS)' statement from 
>        udp_queue_rcv_skb to udp_recvmsg. Now InDatagrams only counts those
>        datagrams which were really delivered (as per RFC 2013). 
> 
> Please CC: any correspondence to gerrit@erg.abdn.ac.uk  
> 
> Signed-off-by: <gerrit@erg.abdn.ac.uk>

Unfortunately this breaks NFS and other in-kernel UDP socket usages,
which never call recvmsg() and instead take the packet via the
->data_ready() callback done by sock_queue_receive_skb().

Your patch will make the counter never get incremented when such
a user is using the UDP socket.

Probably a better way to handle this is to correct the
INDATAGRAMS value by decrementing it when we notice that
the checksum is incorrect in a deferred manner.

