From: Greg Kuperman <gregk@MIT.EDU>
Subject: Requeues and ECN marking
Date: Mon, 3 Feb 2014 09:50:06 -0500
Message-ID: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-3.mit.edu ([18.9.25.14]:58307 "EHLO
	dmz-mailsec-scanner-3.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbaBCOua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 09:50:30 -0500
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	by mailhub-auth-4.mit.edu (8.13.8/8.9.2) with ESMTP id s13EoSil009557
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 09:50:29 -0500
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	(authenticated bits=0)
        (User authenticated as gregk@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.13.8/8.12.4) with ESMTP id s13EoQ2O030921
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 09:50:28 -0500
Received: by mail-pd0-f180.google.com with SMTP id x10so6943732pdj.39
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 06:50:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am testing a new congestion control protocol that relies on explicit
congestion notifications (ECN) to notify the receiver of a congestion
event. I have a rate limited link of 1 Mbps, and I am using the RED
queuing discipline with ECN enabled. What I have noticed is that no
matter how small I set my queue size, or how low I set my minimum
marking level, the first ECN marked packet does not get sent out for
about 10 seconds after the input rate exceeds the output rate. Further
examination shows that ECN marking does not occur until the number or
requeues hits 1000. Below are two queries of tc -s -d qdisc ls dev
eth1.

qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
30 Plog 21 Scell_log 31
 Sent 1307892 bytes 1247 pkt (dropped 0, overlimits 0 requeues 960)
 backlog 1052118b 962p requeues 960
  marked 0 early 0 pdrop 0 other 0

qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
30 Plog 21 Scell_log 31
 Sent 1379262 bytes 1312 pkt (dropped 0, overlimits 72 requeues 1024)
 backlog 1122468b 1027p requeues 1024
  marked 72 early 0 pdrop 0 other 0


The txqueuelen defaults to 1000 for the interface, so I figured that
packets maybe buffering there, and then dequeuing, before any packets
are marked. I set txqueuelen to lower values (all the way down to 1),
but the exact same behavior occurs (no marked packets until number of
dequeues hits 1000). In contrast, if I set txqueuele to something very
high, I get no requeues, drops, or marked packets.

My goal is for packets to be marked as soon as the ingress rate
exceeds the egress. Am I correct in thinking that the requeuing
operation is the culprit? Can I eliminate requeues? Is there something
else I can do to get the behavior I am looking for?

Thank you all for the help. And please cc me in your replies; I'm not
100% sure if I get all the messages from this mailing list.

Best,
Greg
