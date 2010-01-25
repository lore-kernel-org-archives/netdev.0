From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Mon, 25 Jan 2010 16:07:43 +0100
Message-ID: <4B5DB3BF.1080409@tvk.rwth-aachen.de>
References: <200912261703.49067.denys@visp.net.lb>
 <201001232337.19122.denys@visp.net.lb>
 <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
 <201001240045.52846.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:47190 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750773Ab0AYPHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 10:07:45 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KWT0026960VPW80@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 25 Jan 2010 16:07:43 +0100 (CET)
In-reply-to: <201001240045.52846.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko schrieb:
>> Cool, thanks for testing.
>>
>> Dave, please send into stable too (besides net-2.6). If we want less strict
>> state check we can continue playing with that in net-next, IMHO.
>>
> Maybe better to wait. Sad news, got messages after while (before they was 
> appearing  almost immediately on such load).
> 
> [ ... ]

Hi Denys,
could you test the following patch, please?

Damian


diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..ec2fc91 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -530,7 +530,11 @@ static inline void tcp_bound_rto(const struct sock *sk)
 
 static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 {
-	return (tp->srtt >> 3) + tp->rttvar;
+	u32 rto = (tp->srtt >> 3) + tp->rttvar;
+	if (unlikely(rto < TCP_RTO_MIN))
+		return TCP_RTO_MIN;
+	else
+		return rto;
 }
 
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
