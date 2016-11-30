From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: Re: Receive offloads, small RCVBUF and zero TCP window
Date: Wed, 30 Nov 2016 10:10:45 -0500
Message-ID: <3885970.YN3y5yqlgB@zbook>
References: <2080597.A38JFJZ1AD@zbook> <20161128.155459.1527519991492144879.davem@davemloft.net> <15427752.RvQkb5CQdb@zbook>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hpe.com ([15.241.140.75]:41270 "EHLO
        g4t3426.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933754AbcK3PKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:10:53 -0500
In-Reply-To: <15427752.RvQkb5CQdb@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, November 28, 2016 4:14:04 PM EST Alex Sidorenko wrote:
> On Monday, November 28, 2016 3:54:59 PM EST David Miller wrote:
> > From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
> > Date: Mon, 28 Nov 2016 15:49:26 -0500
> > 
> > > Now the question is whether is is OK to have icsk->icsk_ack.rcv_mss
> > > larger than MTU.
> > 
> > It absolutely is not OK.
> > 
> > If VMWare wants to receive large frames for batching purposes it must
> > use GRO or similar to achieve that, not just send vanilla frames into
> > the stack which are larger than the device MTU.
> > 
> 
> As VMWare's vmxnet3 driver is open-sourced and part of generic kernel, do you think the problem is in that driver or elsewhere? I looked at vmxnet3 sources and see that it uses LRO/GRO subroutines. Unfortunately, I don't understand its logic enough to see whether they are doing anything incorrectly.

I think this has been already fixed in recent versions of vmxnet3 driver (but not in RHEL6). VMWare/ESX can pass us aggregated large SKBs indeed (> MTU) if LRO is enabled, but the driver takes care of that in vmxnet3_rq_rx_complete():

			} else if (segCnt != 0 || skb->len > mtu) {
				u32 hlen;

				hlen = vmxnet3_get_hdr_len(adapter, skb,
					(union Vmxnet3_GenericDesc *)rcd);
				if (hlen == 0)
					goto not_lro;

				skb_shinfo(skb)->gso_type =
					rcd->v4 ? SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
				if (segCnt != 0) {
					skb_shinfo(skb)->gso_segs = segCnt;
					skb_shinfo(skb)->gso_size =
						DIV_ROUND_UP(skb->len -
							hlen, segCnt);
				} else {
					skb_shinfo(skb)->gso_size = mtu - hlen;
				}
			}


So if packets have been aggregated, 

	u8		segCnt;       /* Number of aggregated packets */


we compute gso_size by dividing large skb->len by the number.

I still like Marcelo's idea of printing a warning when icsk->icsk_ack.rcv_mss looks unreasonable, should really help with detecting buggy drivers.
