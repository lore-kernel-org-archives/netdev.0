From: jamal <hadi@cyberus.ca>
Subject: [PATCHES] TX batching
Date: Sun, 23 Sep 2007 13:53:07 -0400
Message-ID: <1190569987.4256.52.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:53882 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbXIWRxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 13:53:13 -0400
Received: by an-out-0708.google.com with SMTP id d31so196026and
        for <netdev@vger.kernel.org>; Sun, 23 Sep 2007 10:53:12 -0700 (PDT)
In-Reply-To: <1189988958.4230.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I had plenty of time this weekend so i have been doing a _lot_ of
testing.  My next emails will send a set of patches:
 
Patch 1: Introduces explicit tx locking
Patch 2: Introduces batching interface
Patch 3: Core uses batching interface
Patch 4: get rid of dev->gso_skb

Testing
-------
Each of these patches has been performance tested and the results
are in the logs on a per-patch basis. 
My system under test hardware is a 2xdual core opteron with a couple of 
tg3s. 
My test tool generates udp traffic of different sizes for upto 60 
seconds per run or a total of 30M packets. I have 4 threads each 
running on a specific CPU which keep all the CPUs as busy as they can 
sending packets targetted at a directly connected box's udp discard
port.

All 4 CPUs target a single tg3 to send. The receiving box has a tc rule 
which counts and drops all incoming udp packets to discard port - this
allows me to make sure that the receiver is not the bottleneck in the
testing. Packet sizes sent are {64B, 128B, 256B, 512B, 1024B}. Each
packet size run is repeated 10 times to ensure that there are no
transients. The average of all 10 runs is then computed and collected.

I have not run testing on patch #4 because i had to let the machine
go, but will have some access to it tommorow early morning where i can
run some tests.

Comments
--------
Iam trying to kill ->hard_batch_xmit() but it would be tricky to do
without it for LLTX drivers. Anything i try will require a few extra
checks. OTOH, I could kill LLTX for the drivers i am using that
are LLTX and then drop that interface or I could say "no support
for LLTX". I am in a dilema.

Dave please let me know if this meets your desires to allow devices
which are SG and able to compute CSUM benefit just in case i
misunderstood. 
Herbert, if you can look at at least patch 4 i will appreaciate it.

More patches to follow  - i didnt want to overload people by dumping 
too many patches. Most of these patches below are ready to go; some are
need some testing and others need a little porting from an earlier
kernel: 
- tg3 driver (tested and works well, but dont want to send 
- tun driver
- pktgen
- netiron driver
- e1000 driver
- ethtool interface
- There is at least one other driver promised to me

I am also going to update the two documents i posted earlier.
Hopefully i can do that today.

cheers,
jamal

