From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 09:47:13 -0700
Message-ID: <1396284433.29410.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
	 <1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAOMZO5Ac2s9bA8Af+ObDOR+5q0FJAnQ9RoGRO62tCpMvK-npbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:44217 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbaCaQrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:47:15 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so8208199pdj.12
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:47:14 -0700 (PDT)
In-Reply-To: <CAOMZO5Ac2s9bA8Af+ObDOR+5q0FJAnQ9RoGRO62tCpMvK-npbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 13:35 -0300, Fabio Estevam wrote:
> Hi Eric,
> 
> On Mon, Mar 31, 2014 at 1:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Hi Fabio
> >
> > Could you try the following patch ?
> >
> > diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > index e1e47350784b..74a774af8265 100644
> > --- a/net/ipv6/mcast.c
> > +++ b/net/ipv6/mcast.c
> > @@ -1588,7 +1588,7 @@ static void mld_sendpack(struct sk_buff *skb)
> >
> >         rcu_read_lock();
> >         idev = __in6_dev_get(skb->dev);
> > -       IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
> > +       IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUT, skb->len);
> 
> Thanks for the suggestion, but still get the same problem.

Arg, I reversed the patch , problem is that we can be called from
process context, not from softirq

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e1e47350784b..11a8d352c6b4 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1620,12 +1620,12 @@ static void mld_sendpack(struct sk_buff *skb)
 		      dst_output);
 out:
 	if (!err) {
-		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
-	} else
-		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
-
+		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
+		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, payload_len);
+	} else {
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
+	}
 	rcu_read_unlock();
 	return;
 
