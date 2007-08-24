From: Bill Fink <billfink@mindspring.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Fri, 24 Aug 2007 14:08:42 -0400
Message-ID: <20070824140842.05bc316e.billfink@mindspring.com>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<1187907903.4279.28.camel@localhost> <46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
	<1187957657.4255.35.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1187957657.4255.35.camel@localhost>
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

On Fri, 24 Aug 2007, jamal wrote:

> On Thu, 2007-23-08 at 23:18 -0400, Bill Fink wrote:
> 
> [..]
> > Here you can see there is a major difference in the TX CPU utilization
> > (99 % with TSO disabled versus only 39 % with TSO enabled), although
> > the TSO disabled case was able to squeeze out a little extra performance
> > from its extra CPU utilization.  
> 
> Good stuff. What kind of machine? SMP?

Tyan Thunder K8WE S2895ANRF motherboard with Nvidia nForce
Professional 2200+2050 chipset, 2 AMD Opteron 254 2.8 GHz CPUs,
4 GB PC3200 ECC REG-DDR 400 memory, and 2 PCI-Express x16 slots
(2 buses).

It is SMP but both the NIC interrupts and nuttcp are bound to
CPU 0.  And all other non-kernel system processes are bound to
CPU 1.

> Seems the receive side of the sender is also consuming a lot more cpu
> i suspect because receiver is generating a lot more ACKs with TSO.

Odd.  I just reran the TCP CUBIC "-M1460" tests, and with TSO enabled
on the transmitter, there were about 153709 eth2 interrupts on the
receiver, while with TSO disabled there was actually a somewhat higher
number (164988) of receiver side eth2 interrupts, although the receive
side CPU utilization was actually lower in that case.

On the transmit side (different test run), the TSO enabled case had
about 161773 eth2 interrupts whereas the TSO disabled case had about
165179 eth2 interrupts.

> Does the choice of the tcp congestion control algorithm affect results?
> it would be interesting to see both MTUs with either TCP BIC vs good old
> reno on sender (probably without changing what the receiver does). BIC
> seems to be the default lately.

These tests were with the default TCP CUBIC (with initial_ssthresh
set to 0).

With TCP BIC (and initial_ssthresh set to 0):

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11751.3750 MB /  10.00 sec = 9853.9839 Mbps 100 %TX 83 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 4999.3321 MB /  10.06 sec = 4167.7872 Mbps 38 %TX 100 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.1875 MB /  10.00 sec = 9910.0682 Mbps 99 %TX 81 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5502.6250 MB /  10.00 sec = 4614.3297 Mbps 100 %TX 84 %RX

And with TCP Reno:

TSO enabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11782.6250 MB /  10.00 sec = 9880.2613 Mbps 100 %TX 77 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5024.6649 MB /  10.06 sec = 4191.6574 Mbps 38 %TX 99 %RX

TSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.2500 MB /  10.00 sec = 9910.0860 Mbps 99 %TX 77 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5284.0000 MB /  10.00 sec = 4430.9604 Mbps 99 %TX 79 %RX

Very similar results to the original TCP CUBIC tests.

> > Interestingly, with TSO enabled, the
> > receiver actually consumed more CPU than with TSO disabled, 
> 
> I would suspect the fact that a lot more packets making it into the
> receiver for TSO contributes.
> 
> > so I guess
> > the receiver CPU saturation in that case (99 %) was what restricted
> > its performance somewhat (this was consistent across a few test runs).
> 
> Unfortunately the receiver plays a big role in such tests - if it is
> bottlenecked then you are not really testing the limits of the
> transmitter. 

It might be interesting to see what affect the LRO changes would have
on this.  Once they are in a stable released kernel, I might try that
out, or maybe even before if I get some spare time (but that's in very
short supply right now).

						-Thanks

						-Bill
