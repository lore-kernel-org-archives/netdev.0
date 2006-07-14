From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netem does not work with loopback
Date: Fri, 14 Jul 2006 11:39:00 -0700
Message-ID: <20060714113900.029e6a2f@dxpl.pdx.osdl.net>
References: <44B7AB76.2030700@yahoo.fr>
	<20060714083847.6997a460@localhost.localdomain>
	<44B7CE81.8020800@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65242 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422707AbWGNSi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:38:58 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
In-Reply-To: <44B7CE81.8020800@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006 19:04:01 +0200
Guillaume Chazarain <guichaz@yahoo.fr> wrote:

> Stephen Hemminger wrote :
> > Isn't the skb owned by netem at that point...
> >   
> Thank you, that makes sense to me.
> But then the loopback device reinjects the skb without cleaning skb->cb.
> 
> The attached patch solves the problem for me (netem on lo). Maybe the
> correct solution would be to make a skb->destructor function for netem,
> but I am not sure this is the intended use of a destructor function.
> 

No, the correct fix is to make IP input not accept any options from the
device.  Does this work?


diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e1a7dba..184c78c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -428,6 +428,9 @@ int ip_rcv(struct sk_buff *skb, struct n
 		goto drop;
 	}
 
+	/* Remove any debris in the socket control block */
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+
 	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
