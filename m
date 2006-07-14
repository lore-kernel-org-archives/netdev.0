From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: Netem does not work with loopback
Date: Fri, 14 Jul 2006 19:04:01 +0200
Message-ID: <44B7CE81.8020800@yahoo.fr>
References: <44B7AB76.2030700@yahoo.fr> <20060714083847.6997a460@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030402010607000704050809"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:3991 "EHLO smtp4-g19.free.fr")
	by vger.kernel.org with ESMTP id S1161248AbWGNRDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 13:03:00 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060714083847.6997a460@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030402010607000704050809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote :
> Isn't the skb owned by netem at that point...
>   
Thank you, that makes sense to me.
But then the loopback device reinjects the skb without cleaning skb->cb.

The attached patch solves the problem for me (netem on lo). Maybe the
correct solution would be to make a skb->destructor function for netem,
but I am not sure this is the intended use of a destructor function.

Thanks.

-- 
Guillaume


--------------030402010607000704050809
Content-Type: text/x-patch;
 name="loopback_zero_cb.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="loopback_zero_cb.diff"

--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -156,6 +156,9 @@
 	lb_stats->tx_packets = lb_stats->rx_packets;
 	put_cpu();
 
+	/* Get rid of all the private data accumulated in the sending part */
+	memset(skb->cb, 0, sizeof(skb->cb));
+
 	netif_rx(skb);
 
 	return(0);

-- 
Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>

--------------030402010607000704050809--
