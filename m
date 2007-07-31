From: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Tue, 31 Jul 2007 06:03:02 +0100
Message-ID: <46AEC286.2030302@netbauds.net>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu> <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi> <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi> <20070729160721.GA31276@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S969624AbXGaFDm@vger.kernel.org>
Received: from host217-43-20-243.range217-43.btcentralplus.com ([217.43.20.243]:47851
	"EHLO [172.16.32.4]" smtp-auth: "darryl" TLS-CIPHER: "DHE-RSA-AES256-SHA
	keybits 256/256 version TLSv1/SSLv3" TLS-PEER-CN1: <none>
	rhost-flags-OK-OK-OK-FAIL) by mail-1.netbauds.net with ESMTPSA
	id S613265AbXGaFDD (ORCPT <rfc822;netdev@vger.kernel.org> + 1 other);
	Tue, 31 Jul 2007 06:03:03 +0100
In-Reply-To: <20070729160721.GA31276@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've been able to capture a tcpdump from both ends during the problem 
and its my belief there is a bug in 2.6.20.1 (at the client side) in 
that it issues a SACK option for an old sequence which the current 
window being advertised is beyond it.  This is the most concerning issue 
as the integrity of the sequence numbers doesn't seem right (to my 
limited understanding anyhow).

There is another concern of why the SERVER performed a retransmission in 
the first place, when the tcpdump shows the ack covering it has been seen.


I have made available the full dumps at:

http://darrylmiles.org/snippets/lkml/20070731/


There are some changes in 2.6.22 that appear to affect TCP SACK handling 
does this fix a known issue ?



This sequence is interesting from the client side:

03:58:56.419034 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16345815 819458859> # S1
03:58:56.419100 IP CLIENT.43726 > SERVER.ssh: . ack 27464 win 501 
<nop,nop,timestamp 819458884 16345815> # C1
03:58:56.422019 IP SERVER.ssh > CLIENT.43726: P 27464:28176(712) ack 
4239 win 2728 <nop,nop,timestamp 16345815 819458859> # S2
03:58:56.422078 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 
<nop,nop,timestamp 819458884 16345815> # C2

The above 4 packets look as expect to me.  Then we suddenly see a 
retransmission of 26016:27464.

03:58:56.731597 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16346128 819458864> # S3

So the client instead of discarding the retransmission of duplicate 
segment, issues a SACK.

03:58:56.731637 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 
<nop,nop,timestamp 819458962 16345815,nop,nop,sack sack 1 {26016:27464} 
 > # C3

In response to this the server is confused ???  It responds to 
sack{26016:27464} but the client is also saying "wnd 28176".  Wouldn't 
the server expect "wnd < 26016" to there is a segment to retransmit ?

03:58:57.322800 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16346718 819458864> # S4




Now viewed from the server side:

03:58:56.365655 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16345815 819458859> # S1
03:58:56.365662 IP SERVER.ssh > CLIENT.43726: P 27464:28176(712) ack 
4239 win 2728 <nop,nop,timestamp 16345815 819458859> # S2
03:58:56.374633 IP CLIENT.43726 > SERVER.ssh: . ack 24144 win 488 
<nop,nop,timestamp 819458861 16345731> # propagation delay
03:58:56.381630 IP CLIENT.43726 > SERVER.ssh: . ack 25592 win 501 
<nop,nop,timestamp 819458863 16345734> # propagation delay
03:58:56.384503 IP CLIENT.43726 > SERVER.ssh: . ack 26016 win 501 
<nop,nop,timestamp 819458864 16345734> # propagation delay
03:58:56.462583 IP CLIENT.43726 > SERVER.ssh: . ack 27464 win 501 
<nop,nop,timestamp 819458884 16345815> # C1
03:58:56.465707 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 
<nop,nop,timestamp 819458884 16345815> # C2

The above packets just as expected.

03:58:56.678546 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16346128 819458864> # S3

I guess the above packet is indeed a retransmission of "# S1" but why 
was it retransmitted, when we can clearly see "# C1" above acks this 
segment ?  It is not even as if the retransmission escaped before the 
kernel had time to process the ack, as 200ms elapsed.  CONCERN NUMBER TWO

03:58:56.774778 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 
<nop,nop,timestamp 819458962 16345815,nop,nop,sack sack 1 {26016:27464} 
 > # C3

CONCERN NUMBER ONE, why in response to that escaped retransmission was a 
SACK the appropriate response ?  When at the time the client sent the 
SACK it had received all data upto 28176, a fact it continues to 
advertise in the "# C3" packet above.

There is nothing wrong is the CLIENT expecting to see a retransmission 
of that segment at this point in time that is an expected circumstance.

03:58:57.269529 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 
4239 win 2728 <nop,nop,timestamp 16346718 819458864> # S4





Darryl
