From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Thu, 02 Feb 2017 05:31:10 -0800
Message-ID: <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202115240.GH17590@x4>
         <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170202123427.GA7212@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36330 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750933AbdBBNbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 08:31:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so1855365pgf.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 05:31:12 -0800 (PST)
In-Reply-To: <20170202123427.GA7212@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 13:34 +0100, Markus Trippelsdorf wrote:
> On 2017.02.02 at 04:32 -0800, Eric Dumazet wrote:
> > On Thu, 2017-02-02 at 12:52 +0100, Markus Trippelsdorf wrote:
> > > Hi,
> > > 
> > > from time to time I see the following warning in my kernel log:
> > > 
> > >  TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised.
> > > 
> > > This happens although I run "/usr/sbin/ethtool -K eth0 gro off" in my
> > > local boot script. 
> > > What is the warning trying to tell me?
> > > 
> > 
> > Please report
> > 
> > ethtool -i eth0
> 
> driver: ATL1E
> version: 1.0.0.7-NAPI
> firmware-version: L1e
> expansion-rom-version:
> bus-info: 0000:02:00.0
> supports-statistics: no
> supports-test: no
> supports-eeprom-access: no
> supports-register-dump: yes
> supports-priv-flags: no
> 

Note that this driver does not implement GRO yet.

Hard to believe there is such push back on GRO in 2017.

Anyway, I suspect the test is simply buggy ;)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 41dcbd568cbe2403f2a9e659669afe462a42e228..5394a39fcce964a7fe7075b1531a8a1e05550a54 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -164,7 +164,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	if (len >= icsk->icsk_ack.rcv_mss) {
 		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
 					       tcp_sk(sk)->advmss);
-		if (unlikely(icsk->icsk_ack.rcv_mss != len))
+		if (unlikely(icsk->icsk_ack.rcv_mss != len && skb_is_gso(skb)))
 			tcp_gro_dev_warn(sk, skb);
 	} else {
 		/* Otherwise, we make more careful check taking into account,
