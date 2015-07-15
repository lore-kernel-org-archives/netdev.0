From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: rfc: making rds-tcp netns aware
Date: Wed, 15 Jul 2015 13:04:53 +0200
Message-ID: <20150715110453.GH6541@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47856 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbGOLFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 07:05:00 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t6FB4xYN030300
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:04:59 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t6FB4whX025736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:04:59 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t6FB4wC5010925
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:04:58 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am working on making rds-tcp to be netns-aware, and in addition
to a few bug fixes that I'm lining up, there's a basic issue with 
the way rds-tcp sets up the listen socket that is causing problems

The RDS tcp listen endpoint is created as part of module init.
(rds_tcp_init -> rds_tcp_listen_init()). So this means that
if I create a "blue" netns, and 'modprobe rds_tcp' within that netns,
I get a kernel socket attached to the blue netns (which is good),
but then I cannot use the same technique to set up a socket
for a different netns ('modprobe rds_tcp' in that netns 
will return silently, as it should). 

And there's another downside to this design: the socket wont
get released till the module is unloaed, so it ends up holding
the reference on the net.

So perhaps it was not a good idea to set up the listen socket
as part of module init, but I'm trying to figure out a clean
design for setting up the listen socket.

Some uspace daemon that listens for changes to namespaces and
reacts appropriately? A separate sysctl that sets up the listen
endpoint in each namespace? 

Are there other subsystems that have to handle a similar case?  
I suspect that RDS-TCP is somewhat unusual here- I think most other
similar encaps protocols like vxlan etc are associated with a network 
driver, so the listen endpoint is created as part of the ->ndo_open

Suggestions for other modules that have to deal with a similar
situation that I can refer to are invited..

--Sowmini
