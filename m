From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 7 Sep 2005 23:52:13 +0200
Message-ID: <20050907215213.GB8222@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
	<431F5CD2.8020905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <431F5CD2.8020905@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 11:34:10PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> > I think I have the LOG target compiled into the kernel. After the echo, I got
> > this within a matter of seconds:
> > 
> >    printk: 614 messages suppressed.
> >    ip_ct_tcp: bad TCP checksum IN= OUT= SRC=xxxxxxxxxxxx DST=84.56.231.206 LEN=105 TOS=0x00 PREC=0x00 TTL=53 ID=33989 DF PROTO=TCP SPT=119 DPT=41349 SEQ=495763142 ACK=177548929 WINDOW=56677 RES=0x00 ACK PSH URGP=0 OPT (0101080A0986EF9D00E16123) 
> 
> Interesting .. if this isn't real there is most likely some problem with
> HW checksumming in netfilter. What does ethtool -k <dev> show?

It happens both with ppp(oe) as well as with ethernet, but the above message
originate son the ppp interface.

In any case, the ethtool output for eth1 (which is used by the pppoe
connection):

   Offload parameters for eth1:
   Cannot get device tcp segmentation offload settings: Operation not supported
   rx-checksumming: on
   tx-checksumming: on
   scatter-gather: on
   tcp segmentation offload: off

> > The weird thing is that it works on tap, but not on ethernet/ppp. Maybe
> > the kernel code gets some offset wrong?
> 
> Another sign pointing to HW checksumming ..

It's also a 64-bit-only problem. To verify, I tried this:

ethtool -K eth1 rx off tx off sg off

Where eth1 is the interface where pppoe runs over.

ethtool -k eth1 then displayed:

   rx-checksumming: off
   tx-checksumming: off
   scatter-gather: off
   tcp segmentation offload: off

And ICMP, TCP etc. starts working again.

Thanks for the analysis and the hint, I guess that verifies that its hw
checksumming. (Weird that hw checksumming on the underlying device somehow
changes the ppp packets, but nevertheless).

If I can be of further assistance in tracking down this problem, please
rely on me. I can easily live with hw checksumming switched off on that
if, though.

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
