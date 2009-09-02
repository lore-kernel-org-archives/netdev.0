From: Andreas Jaggi <aj@open.ch>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Wed, 2 Sep 2009 10:05:16 +0200
Message-ID: <20090902080516.GA6766@urbino.open.ch>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk> <4A9D04A2.60307@trash.net> <20090901121033.GA18731@urbino.open.ch> <4A9D11A3.5070809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:21475 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbZIBIEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 04:04:35 -0400
Content-Disposition: inline
In-Reply-To: <4A9D11A3.5070809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 02:20:51PM +0200, Patrick McHardy wrote:
> Its unfortunately necessary to drop packets in some cases after parsing
> errors when the helper might have already (partially) mangled the
> packet.

Do the helpers also mangle packets when there is no NAT involved?
(in out setup we don't use NAT, btw)
If they don't, would it be reasonable to return NF_ACCEPT when there is
no NAT. For example like in the patch below?

> You could try this patch in combination with ulogd and the pcap output
> plugin to capture the packets which are dropped by the helper for
> analysis.

Unfortunately the videoconferencing system is currently not available
for testing (and might be so for while). But I can have some tcpdumps from
both sides of the Linux Gateway from which I can extract the packets that
were dropped by the H.323 helper.

Andreas


--- a/net/netfilter/nf_conntrack_h323_main.c	2009-05-19 01:52:34.000000000 +0200
+++ b/net/netfilter/nf_conntrack_h323_main.c	2009-09-01 17:36:08.000000000 +0200
@@ -596,8 +596,12 @@
 		}
 
 		/* Process H.245 signal */
-		if (process_h245(skb, ct, ctinfo, &data, dataoff, &mscm) < 0)
-			goto drop;
+		if (process_h245(skb, ct, ctinfo, &data, dataoff, &mscm) < 0) {
+			if (ct->status & IPS_NAT_MASK)
+				goto drop;
+			else
+				break;
+		}
 	}
 
 	spin_unlock_bh(&nf_h323_lock);
@@ -1141,8 +1145,12 @@
 		}
 
 		/* Process Q.931 signal */
-		if (process_q931(skb, ct, ctinfo, &data, dataoff, &q931) < 0)
-			goto drop;
+		if (process_q931(skb, ct, ctinfo, &data, dataoff, &q931) < 0) {
+			if (ct->status & IPS_NAT_MASK)
+				goto drop;
+			else
+				break;
+		}
 	}
 
 	spin_unlock_bh(&nf_h323_lock);
@@ -1716,7 +1724,8 @@
 	}
 
 	/* Process RAS message */
-	if (process_ras(skb, ct, ctinfo, &data, &ras) < 0)
+	if ((process_ras(skb, ct, ctinfo, &data, &ras) < 0) &&
+	    (ct->status & IPS_NAT_MASK))
 		goto drop;
 
       accept:
