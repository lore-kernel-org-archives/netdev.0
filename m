From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: [RESEND PATCH 0/3] netem/iproute2 solving correlated loss issue
Date: Tue, 29 Dec 2009 20:59:00 +0100
Message-ID: <4B3A5F84.4050603@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:52856 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbZL2T7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 14:59:04 -0500
Received: by fxm25 with SMTP id 25so5509274fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 11:59:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

following the comments we have received from Stefan Hemmminger and David 
Miller we are resending the patch that enhances netem module and the 
iproute2 utilities as follows:

- add deterministic loss generation according to a pattern that can be 
specified in a file in the iproute2 command line
- new statistical models for generation of correlated loss (the existing 
model does not work), including loss models commonly used in literature 
(bernoulli, Gilbert, Gilbert Elliot) and the new GI (General and 
Intuitive model)
- enhanced logging functionality for loss events in dmesg

The patch should now be backward compatible, we have not changed the 
existing structure for iproute2 to kernel communication (tc_netem_qopt), 
but where needed we have added new structures (same approach used in the 
"reorder" patch at 
http://www.opensubscriber.com/message/netdev@oss.sgi.com/1362582.html)

Additional information on the motivations for this work and additional 
details can also be found at: 
http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetEm2

Examples of new iproute2 syntax is reported hereafter (full info in the 
man page).

1) generate loss according to a deterministic pattern:

tc qdisc add/change dev eth0 root netem loss_pattern filename

2) generate loss according to different loss models including the ones 
commonly used in the literature (bernoulli, gilbert, gilbert-elliot) and 
the new GI (General and Intuitive) model:

tc qdisc add/change dev eth0 root netem2 loss_GI ploss [burst_length 
[density [pisol [good_burst_length]]]]
tc qdisc add/change dev eth0 root netem2 loss_GI_tran p13 p31 [p32 p23 
[p14]]
tc qdisc add/change dev eth0 root netem2 loss_bern p
tc qdisc add/change dev eth0 root netem2 loss_gilb p r [1-h]
tc qdisc add/change dev eth0 root netem2 loss_gilbell p r [1-h [1-k]]

3) convert parameters between intuitive and Markov transition 
probabilities (query mode)

this applies to loss_GI and loss_GI_tran options. If the query label is 
specified before the model label the transition probabilities or the GI 
parameters that corresponds to the specified input parameters are 
calculated and printed to screen, but no operation is done on the qdisc. 
In this way the user can understands what he would obtain with certain 
input parameters without necessarily make changes to the network's 
behaviour.

4) enable enhanced logging in dmesg:

tc qdisc add/change dev eth0 root netem logging 1 loss_GI 5 10

for each loss event the kernel logs will include a line like "netem2 
loss event loss_GI 30 RFPLE 15" where RFPLE stands for "Received From 
Previous Loss Event" and it counts the number y of good packets received 
between two loss events while x is the number of all lost packets

Stefano Salsano and Fabio Ludovici
