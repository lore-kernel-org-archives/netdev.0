From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Fri, 16 Dec 2011 05:27:56 +0100
Message-ID: <1324009676.2562.9.camel@edumazet-laptop>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	 <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA3D58.5010101@hp.com>
	 <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
	 <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA730E.5010405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44157 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab1LPE2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 23:28:00 -0500
Received: by werm1 with SMTP id m1so274785wer.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 20:27:59 -0800 (PST)
In-Reply-To: <4EEA730E.5010405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 14:22 -0800, Rick Jones a =C3=A9c=
rit :
> On 12/15/2011 11:00 AM, Eric Dumazet wrote:
> >> Device's work better if the driver proactively manages stop_queue/=
wake_queue.
> >> Old devices used TX_BUSY, but newer devices tend to manage the que=
ue
> >> themselves.
> >>
> >
> > Some 'new' drivers like igb can be fooled in case skb is gso segmen=
ted ?
> >
> > Because igb_xmit_frame_ring() needs skb_shinfo(skb)->nr_frags + 4
> > descriptors, igb should stop its queue not at MAX_SKB_FRAGS + 4, bu=
t
> > MAX_SKB_FRAGS*4
> >
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/ne=
t/ethernet/intel/igb/igb_main.c
> > index 89d576c..989da36 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > @@ -4370,7 +4370,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buf=
f *skb,
> >   	igb_tx_map(tx_ring, first, hdr_len);
> >
> >   	/* Make sure there is space in the ring for the next send. */
> > -	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
> > +	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS * 4);
> >
> >   	return NETDEV_TX_OK;
>=20
>=20
> Is there a minimum transmit queue length here?  I get the impression=20
> that MAX_SKB_FRAGS is at least 16 and is 18 on a system with 4096 byt=
e=20
> pages.  The previous addition then would be OK so long as the TX queu=
e=20
> was always at least 22 entries in size, but now it would have to alwa=
ys=20
> be at least 72?
>=20
> I guess things are "OK" at the moment:
>=20
> raj@tardy:~/net-next/drivers/net/ethernet/intel/igb$ grep IGB_MIN_TXD=
 *.[ch]
> igb_ethtool.c:	new_tx_count =3D max_t(u16, new_tx_count, IGB_MIN_TXD)=
;
> igb.h:#define IGB_MIN_TXD                       80
>=20
> but is that getting a little close?
>=20
> rick jones

Sure !

I only pointed out a possible problem, and not gave a full patch, since
we also need to change the opposite threshold (when we XON the queue at
TX completion)

You can see its not even consistent with the minimum for a single TSO
frame ! Most probably your high requeue numbers come from this too low
value given the real requirements of the hardware (4 + nr_frags
descriptors per skb)

/* How many Tx Descriptors do we need to call netif_wake_queue ? */=20
#define IGB_TX_QUEUE_WAKE   16


Maybe we should CC Intel guys

Could you try following patch ?

Thanks !

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/etherne=
t/intel/igb/igb.h
index c69feeb..93ce118 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -51,8 +51,8 @@ struct igb_adapter;
 /* TX/RX descriptor defines */
 #define IGB_DEFAULT_TXD                  256
 #define IGB_DEFAULT_TX_WORK		 128
-#define IGB_MIN_TXD                       80
-#define IGB_MAX_TXD                     4096
+#define IGB_MIN_TXD		max_t(unsigned, 80U, IGB_TX_QUEUE_WAKE * 2)
+#define IGB_MAX_TXD             4096
=20
 #define IGB_DEFAULT_RXD                  256
 #define IGB_MIN_RXD                       80
@@ -121,8 +121,11 @@ struct vf_data_storage {
 #define IGB_RXBUFFER_16384 16384
 #define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
=20
-/* How many Tx Descriptors do we need to call netif_wake_queue ? */
-#define IGB_TX_QUEUE_WAKE	16
+/* How many Tx Descriptors should be available
+ * before calling netif_wake_subqueue() ?
+ */
+#define IGB_TX_QUEUE_WAKE	(MAX_SKB_FRAGS * 4)
+
 /* How many Rx Buffers do we bundle into one write to the hardware ? *=
/
 #define IGB_RX_BUFFER_WRITE	16	/* Must be power of 2 */
=20
