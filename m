From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCHES] TX batching
Date: Sun, 30 Sep 2007 14:50:05 -0400
Message-ID: <1191178205.6165.25.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190569987.4256.52.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Latest net-2.6.24 breaks the patches i posted last week; so this is an
update to resolve that. If you are receiving these emails and are
finding them overloading, please give me a shout and i will remove your
name.

Please provide feedback on the code and/or architecture.
Last time i posted them i received none. They are now updated to 
work with the latest net-2.6.24 from a few hours ago.

Patch 1: Introduces batching interface
Patch 2: Core uses batching interface
Patch 3: get rid of dev->gso_skb

I have decided i will kill ->hard_batch_xmit() and not support any
more LLTX drivers. This is the last of patches that will have
->hard_batch_xmit() as i am supporting an e1000 that is LLTX.

Dave please let me know if this meets your desires to allow devices
which are SG and able to compute CSUM benefit just in case i
misunderstood. 
Herbert, if you can look at at least patch 3 i will appreaciate it
(since it kills dev->gso_skb that you introduced).

More patches to follow later if i get some feedback - i didnt want to 
overload people by dumping too many patches. Most of these patches 
mentioned below are ready to go; some need some re-testing and others 
need a little porting from an earlier kernel: 
- tg3 driver (tested and works well, but dont want to send 
- tun driver
- pktgen
- netiron driver
- e1000 driver (LLTX)
- e1000e driver (non-LLTX)
- ethtool interface
- There is at least one other driver promised to me

Theres also a driver-howto i wrote that was posted on netdev last week
as well as one that describes the architectural decisions made.

Each of these patches has been performance tested (last with DaveM's
tree from last weekend) and the results are in the logs on a per-patch 
basis.  My system under test hardware is a 2xdual core opteron with a 
couple of tg3s. I have not re-run the tests with this morning's tree
but i suspect not much difference.
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

cheers,
jamal
