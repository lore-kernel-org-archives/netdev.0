From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [PATCH RFC net-next v2 1/4] skbuff: add stub to help computing
 crc32c on SCTP packets
Date: Mon, 06 Mar 2017 22:51:17 +0100
Message-ID: <1488837077.3068.13.camel@redhat.com>
References: <1488202783.2713.67.camel@redhat.com>
         <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
         <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Laight <David.Laight@aculab.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754460AbdCFVvv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 16:51:51 -0500
In-Reply-To: <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 14:46 -0800, Alexander Duyck wrote:
> On Tue, Feb 28, 2017 at 2:32 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> > 
> > sctp_compute_checksum requires crc32c symbol (provided by libcrc32c), so
> > it can't be used in net core. Like it has been done previously with other
> > symbols (e.g. ipv6_dst_lookup), introduce a stub struct skb_checksum_ops
> > to allow computation of SCTP checksum in net core after sctp.ko (and thus
> > libcrc32c) has been loaded.
> 
> At a minimum the name really needs to change.  SCTP does not do
> checksums.  It does a CRC, and a CRC is a very different thing.  The
> fact that somebody decided that offloading a CRC could use the same
> framework is very unfortunate, and your patch descriptions in this
> whole set are calling out a CRC as checksums which it is not.

hello Alexander,

thank you for contributing to this topic. I see there has been a similar
discussion some months ago
(https://www.mail-archive.com/netdev@vger.kernel.org/msg94955.html).

> I don't want to see anything "checksum" or "csum" related in the
> naming when it comes to dealing with SCTP unless we absolutely have
> to have it.  So any function names or structures with sctp in the name
> should call out "crc32" or "crc", please don't use checksum.

On Wed, 2017-03-01 at 10:53 +0000, David Laight wrote:
> Then also change all the places that refer the IP 1's compliment
> checksum to ipchecksum.

(but crc32 uses a different polynomial than crc32c! :-) ) I understand 
your concerns, nevertheless we are writing to a member of struct sctphdr
whose name is 'checksum' since the earliest introduction of SCTP; moreover,
similar terminology ('crc32c checksum') is used throughout all RFC4960.
That's why I don't think anybody will be confused by usage of 'csum' or
'checksum' words.

On Tue, 2017-02-28 at 19:17 -0800, Tom Herbert wrote:
> I agree that internal functions to sctp should not refer to checksum,
> but I think we need to take care to be consistent with any external
> API (even if somebody made a mistake defining it this way :-) ). As
> you know the checksum interface must be very precisely defined, there
> is no leeway for ambiguity.

We can make the new symbols more generic removing 'sctp' from the
symbol name, and writing explicitly that skb needs crc32c (rather than
skb does not need internet checksum).

Proposal:
we use crc32c, possibly combined with 'csum' or 'checksum', just like
it has been done in RFC4960.  So, symbol names can be replaced as follows:

RFC v2 name              | RFC v3 name
-------------------------+-----------------------------
warn_sctp_csum_update    | warn_crc32c_csum_update
warn_sctp_csum_combine   | warn_crc32c_csum_combine
sctp_csum_stub           | crc32c_csum_stub
sctp_csum_ops            | crc32c_csum_ops
skb_sctp_csum_help       | skb_crc32c_csum_help
skb->csum_not_inet       | skb->crc32c_csum

please let me know if the proposal can be acceptable from your point of view.

On Tue, 2017-02-28 at 11:50 -0800, Tom Herbert wrote:
> Unfortunately this potentially pushes the skbuf flags over 32 bits if
> I count correctly. I suggest that you rename csum_bad to
> csum_not_inet. Looks like csum_bad is only set by a grand total of one
> driver and I don't believe that is enough to justify its existence.
> It's probably a good time to remove it.

you are right: find below the current layout obtained with 'allyesconfig':

short unsigned int         queue_mapping;                   /*   140     2 */
unsigned char              __cloned_offset[0];              /*   142     0 */
unsigned char              cloned:1;                        /*   142: 7  1 */
unsigned char              nohdr:1;                         /*   142: 6  1 */
unsigned char              fclone:2;                        /*   142: 4  1 */
unsigned char              peeked:1;                        /*   142: 3  1 */
unsigned char              head_frag:1;                     /*   142: 2  1 */
unsigned char              xmit_more:1;                     /*   142: 1  1 */
unsigned char              __unused:1;                      /*   142: 0  1 */

/* XXX 1 byte hole, try to pack */
unsigned int               headers_start[0];                /*   144     0 */
unsigned char              __pkt_type_offset[0];            /*   144     0 */
unsigned char              pkt_type:3;                      /*   144: 5  1 */

<...>

unsigned char              ipvs_property:1;                 /*   147: 7  1 */
unsigned char              inner_protocol_type:1;           /*   147: 6  1 */
unsigned char              remcsum_offload:1;               /*   147: 5  1 */
unsigned char              offload_fwd_mark:1;              /*   147: 4  1 */
unsigned char              tc_skip_classify:1;              /*   147: 3  1 */
unsigned char              tc_at_ingress:1;                 /*   147: 2  1 */
unsigned char              tc_redirected:1;                 /*   147: 1  1 */
unsigned char              tc_from_ingress:1;               /*   147: 0  1 */
short unsigned int         tc_index;                        /*   148     2 */

/* XXX 2 bytes hole, try to pack */
union {
                unsigned int       csum;                    /*           4 */
                struct {
                        short unsigned int csum_start;      /*   152     2 */
                       short unsigned int csum_offset;      /*   154     2 */
        };                                                  /*           4 */
}                                                           /*   152     4 */

skb->tc_from_ingress is the last element of the 32 bits starting at
skb->pkt_type. There are 16 bits free before skb->csum, and 9 free bits
before skb->pkt_type. I don't think I can easily make room by removing
'csum_bad' as per your suggestion, because it is used by GRO and
netfilter code also (see users of __skb_mark_checksum_bad()). So, either
I place 'csum_not_inet' in one of the two above intervals (i.e replacing
__unused with csum_not_inet AKA crc32c_csum), or I have to give up the
(good) idea of using a bit in sk_buff.

BTW: unlike what I see with other NICs, using ixgbe driver I don't see
corrupted L4 packets, even when SCTP CRC offload is turned off. Looking
at the code, I see ixgbe_tx_csum does a simple test to identify SCTP in
packets with CHECKSUM_PARTIAL and have their checksum resolved by the 
hardware:

switch (skb->csum_offset) {
	case offsetof(struct tcphdr, check):
		/* it's TCP */
		/* fall-through */
	case offsetof(struct udphdr, check)
		/* it's UDP */
		break;
	case offsetof(struct scphdr, checksum):
		if (/* an ipv4 or ipv6 header with protocol equal to
		     * IPPOROTO_SCTP is found
		     */)
		    /* it's SCTP */
			break;
		}
		/* fall through */
	default:
		skb_checksum_help(skb);
}

The above code is functionally similar to what I did in patch 4/5 of the
initial series (http://www.spinics.net/lists/linux-sctp/msg05608.html).
Should we consider it again for fixing wrong CRC32c issues in case using
a bit in struct sk_buff is not viable?

On Tue, 2017-02-28 at 11:50 -0800, Tom Herbert wrote:
> Return value looks complex. Maybe we should just change
> skb_csum_*_help to return bool, true of checksum was handled false if
> not.

These functions can return -EINVAL if skb is a GSO packet, or -ENOMEM if
skb_linearize(skb) or pskb_expand_head(skb) fail, or 0. I would preserve the
return value of skb_checksum_help() and provide similar range of return values
for skb_sctp_csum_help() (also known as skb_crc32c_csum_help()): this can
help eventual future attempts to remove skb_warn_bad_offload(). It makes
sense to make boolean the return value of skb_csum_hwoffload_help(),
since we are using it only for non-GSO packets.  
	
Thank you in advance for the feedbacks,

regards,
