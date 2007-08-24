From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Thu, 23 Aug 2007 23:18:20 -0400
Message-ID: <20070823231820.2ae52cc0.billfink@mindspring.com>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<1187907903.4279.28.camel@localhost> <46CE0BA1.60206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46CE0BA1.60206@hp.com>
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

On Thu, 23 Aug 2007, Rick Jones wrote:

> jamal wrote:
> > [TSO already passed - iirc, it has been
> > demostranted to really not add much to throughput (cant improve much
> > over closeness to wire speed) but improve CPU utilization].
> 
> In the one gig space sure, but in the 10 Gig space, TSO on/off does make a 
> difference for throughput.

Not too much.

TSO enabled:

[root@lang2 ~]# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11813.4375 MB /  10.00 sec = 9906.1644 Mbps 99 %TX 80 %RX

TSO disabled:

[root@lang2 ~]# ethtool -K eth2 tso off
[root@lang2 ~]# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.2500 MB /  10.00 sec = 9910.0176 Mbps 100 %TX 78 %RX

Pretty negligible difference it seems.

This is with a 2.6.20.7 kernel, Myricom 10-GigE NICs, and 9000 byte
jumbo frames, in a LAN environment.

For grins, I also did a couple of tests with an MSS of 1460 to
emulate a standard 1500 byte Ethernet MTU.

TSO enabled:

[root@lang2 ~]# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5102.8503 MB /  10.06 sec = 4253.9124 Mbps 39 %TX 99 %RX

TSO disabled:

[root@lang2 ~]# ethtool -K eth2 tso off
[root@lang2 ~]# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5399.5625 MB /  10.00 sec = 4527.9070 Mbps 99 %TX 76 %RX

Here you can see there is a major difference in the TX CPU utilization
(99 % with TSO disabled versus only 39 % with TSO enabled), although
the TSO disabled case was able to squeeze out a little extra performance
from its extra CPU utilization.  Interestingly, with TSO enabled, the
receiver actually consumed more CPU than with TSO disabled, so I guess
the receiver CPU saturation in that case (99 %) was what restricted
its performance somewhat (this was consistent across a few test runs).

						-Bill
