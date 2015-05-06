From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Wed, 06 May 2015 15:42:38 -0700
Message-ID: <1430952158.14545.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de>
	 <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com>
	 <1430939400.14545.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2723870.nq54KKjWkm@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2723870.nq54KKjWkm@h2o.as.studentenwerk.mhn.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-07 at 00:04 +0200, Wolfgang Walter wrote:
> Am Mittwoch, 6. Mai 2015, 12:10:00 schrieb Eric Dumazet:
> > On Wed, 2015-05-06 at 11:15 -0700, Cong Wang wrote:
> > > (Cc'ing netdev.)
> > > 
> > > On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wrote:
> > > > Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> > > >> Hello,
> > > >> 
> > > >> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute6 with
> > > >> an
> > > >> isatap-tunnel.
> > > > 
> > > > I did some further tests. To trigger the crash you need
> > > > 
> > > > * isatap-tunnel (probably any sit-tunnel will do it)
> > > > * raw-socket
> > > > * udp
> > > > 
> > > > Using icmpv6 or tcp i.e. does not trigger it.
> > > 
> > > Do you have a script to reproduce it?
> > > 
> > > 
> > > Thanks for the bug report!
> > > --
> > 
> > Please Wolfgang try to revert 32dce968dd987adfb0c00946d78dad9154f64759
> > ("ipv6: Allow for partial checksums on non-ufo packets")
> 
> Indeed, that fixes the problem.

Yes, setting skb->csum to 0 is clearly wrong for CHECKSUM_PARTIAL

Would you try :

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7fde1f265c90e90f16291e6c861b6e242111c25b..694ae630e1ca67e25ab1e5f6dd0b3597db3669b0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1416,6 +1416,10 @@ alloc_new_skb:
 			data += fragheaderlen;
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
+			if (csummode == CHECKSUM_PARTIAL) {
+				skb->csum_start = skb_transport_header(skb) - skb->head;
+				skb->csum_offset = offsetof(struct udphdr, check);
+			}
 			if (fraggap) {
 				skb->csum = skb_copy_and_csum_bits(
 					skb_prev, maxfraglen,
