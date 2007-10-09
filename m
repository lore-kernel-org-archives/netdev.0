From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCHES] TX batching rev2.5
Date: Tue, 09 Oct 2007 18:07:19 -0400
Message-ID: <1191967639.5324.25.camel@localhost>
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


Please provide feedback on the code and/or architecture.
They are now updated to work with the latest rebased net-2.6.24 
from a few hours ago.
I am on travel mode so wont have time to do more testing for the next
few days - i do consider this to be stable at this point based on
what i have been testing (famous last words).

Patch 1: Introduces batching interface
Patch 2: Core uses batching interface
Patch 3: get rid of dev->gso_skb

What has changed since i posted last:
-------------------------------------

1) There was some cruft leftover from prep_frame feature that i forgot
to remove last time - it is now gone.
2) In the shower this AM, i realized that it is plausible that a 
batch of packets sent to the driver may all be dropped because
they are badly formatted. Current drivers all return NETDEV_TX_OK
in all such cases. This will lead for us to call dev->hard_end_xmit() 
to be invoked unnecessarily. I already had a NETDEV_TX_DROPPED within
batching drivers, so i made that global and make the batching drivers
return it if they drop packets. The core calls dev->hard_end_xmit()
when at least one packet makes it through. 


Things i am gonna say that nobody will see (wink)
-------------------------------------------------
Dave please let me know if this meets your desires to allow devices
which are SG and able to compute CSUM benefit just in case i
misunderstood. 
Herbert, if you can look at at least patch 3 i will appreaciate it
(since it kills dev->gso_skb that you introduced).

UPCOMING PATCHES
---------------
As before:
More patches to follow later if i get some feedback - i didnt want to 
overload people by dumping too many patches. Most of these patches 
mentioned below are ready to go; some need some re-testing and others 
need a little porting from an earlier kernel: 
- tg3 driver 
- tun driver
- pktgen
- netiron driver
- e1000e driver (non-LLTX)
- ethtool interface
- There is at least one other driver promised to me

Theres also a driver-howto that i will post soon today. 

PERFORMANCE TESTING
--------------------

System under test hardware is still a 2xdual core opteron with a 
couple of tg3s. 
A test tool generates udp traffic of different sizes for upto 60 
seconds per run or a total of 30M packets. I have 4 threads each 
running on a specific CPU which keep all the CPUs as busy as they can 
sending packets targetted at a directly connected box's udp discard
port.
All 4 CPUs target a single tg3 to send. The receiving box has a tc rule 
which counts and drops all incoming udp packets to discard port - this
allows me to make sure that the receiver is not the bottleneck in the
testing. Packet sizes sent are {8B, 32B, 64B, 128B, 256B, 512B, 1024B}. 
Each packet size run is repeated 10 times to ensure that there are no
transients. The average of all 10 runs is then computed and collected.

I do plan also to run forwarding and TCP tests in the future when the
dust settles.

cheers,
jamal
