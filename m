From: jamal <hadi@cyberus.ca>
Subject: [RFC][IPSEC]: tunnel mode processing
Date: Thu, 31 Aug 2006 20:55:27 -0400
Message-ID: <1157072127.5057.39.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:28652 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932322AbWIAAza
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 20:55:30 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GIxJo-0002wk-1q
	for netdev@vger.kernel.org; Thu, 31 Aug 2006 20:55:36 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


At the moment transport mode processing is not dependent on skb->dst
being passed. Tunnel mode derives the ip->id and ttl from it. More like
computes ip->id.

I am trying to generate traffic via pktgen and it would be nice if i
could get the same behavior on tunnel mode as in transport mode. I dont
think it matters what the values of those two fields are.

Would it be reasonable to do a check so that incase a skb->dst doesnt
exist, the inner headers values can be used i.e something along 
xfrm4_tunnel_output()::

----
        top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
                0 : (iph->frag_off & htons(IP_DF));
	if (dst) {
		if (!top_iph->frag_off) 
			__ip_select_ident(top_iph, dst->child, 0);
		top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
	} else {
		top_iph->id = iph->id;
		top_iph->ttl = iph->ttl;
	}
----

cheers,
jamal

