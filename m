From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: possible issue between bridge igmp/multicast  handling & bnx2x
 on kernel 2.6.34 and >
Date: Fri, 07 Jan 2011 11:40:36 +0100
Message-ID: <4D26EDA4.7060502@univ-nantes.fr>
References: <4D23234E.30709@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:58577 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1AGKlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 05:41:46 -0500
Received: from localhost (debian [127.0.0.1])
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTP id 709BC9540D
	for <netdev@vger.kernel.org>; Fri,  7 Jan 2011 11:41:45 +0100 (CET)
Received: from smtp-tls.univ-nantes.fr ([127.0.0.1])
	by localhost (smtp-tls1.d101.univ-nantes.fr [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id rGiB0H791LC9 for <netdev@vger.kernel.org>;
	Fri,  7 Jan 2011 11:41:45 +0100 (CET)
Received: from [172.20.13.9] (tomintoul.cri.univ-nantes.prive [172.20.13.9])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTPSA id 57B119540C
	for <netdev@vger.kernel.org>; Fri,  7 Jan 2011 11:41:45 +0100 (CET)
In-Reply-To: <4D23234E.30709@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2011 14:40, Yann Dupont a =E9crit :
=2E..
> We just added BCM57711 10G cards (bnx2x driver) on our blade servers=20
> (connected to 10G Power Connect M8024).
> Since then, we are experiencing random lost of packets.
>
> Symptom : packets are lost on some vlans for a few seconds, then=20
> things go back to normal (and stops again a few minutes later)
>

As I didn't had answer so far , I digged a little more and captured mor=
e=20
packets.
I just noticed that an event trigger that problem : IPv6 neighbor=20
discovery packet .

This is , of course, a multicast packet.

Just saw that 2.6.36.3 should include this fix :

> From: David Stevens<dlstevens@us.ibm.com>
>
> [ Upstream commit 04bdf0c9a451863e50fff627713a900a2cabb998 ]
>
> This patch fixes a missing ntohs() for bridge IPv6 multicast snooping=
=2E
But in fact , I just tested, and this doesn't cure the problem :(

This bug
- only occurs with bnx2x with tagged vlans, attached to bridges. Other=20
interfaces (bnx2 , for exemple) works fine. bnx2x without bridges works=
=20
fine.
- only happens when bridge is compiled with CONFIG_BRIDGE_IGMP_SNOOPING=
=20
(default setting)
- is triggered by IPv6 neighbor discovery packet. Just after that=20
packet, others packets are discarded for some time.
- packets originating from same vlans are not affected, only packets=20
previously routed are discarded. Examinating those packets, I don't=20
undersand why, apart TTL (and mac address), they seems similar .
- has origin circa 2.6.33 :
fe2d7c70b747d5d968f4e8fa210676d49d40059 is the first bad commit
commit 3fe2d7c70b747d5d968f4e8fa210676d49d40059
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sun Feb 28 00:49:38 2010 -0800

     bridge: Add multicast start/stop hooks

     This patch hooks up the bridge start/stop and add/delete/disable
     port functions to the new multicast module.

     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
     Signed-off-by: David S. Miller <davem@davemloft.net>



What can I do to help fixing this bug ?
regards,

--=20
Yann Dupont - Service IRTS, DSI Universit=E9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr

