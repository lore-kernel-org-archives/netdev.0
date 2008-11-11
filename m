From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 15:59:45 +0100
Message-ID: <7e0dd21a0811110659p1bd7a765jd8afb49a1f51472@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6116F@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110656yff651afp8ff0f9928b79f545@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:47387 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009AbYKKO7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 09:59:47 -0500
Received: by fg-out-1718.google.com with SMTP id 19so42981fgg.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 06:59:45 -0800 (PST)
In-Reply-To: <7e0dd21a0811110656yff651afp8ff0f9928b79f545@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

>> You don't reset the tp_status flag when you reject a message for being too short.
>> You incorrectly calculate to_write in the situation of sock->type == SOCK_DGRAM.

I've changed this code already, I'll will share my changes.

>>
>> You don't check for the MAX_SKB_FRAGS condition.

Thanks, I'll will add this check.

>>
>> Not your code, but in packet_set_ring, it's redundant to clear the status for all the frames to TP_STATUS_KERNEL (0) since the pages are allocated with kzalloc (pages are already zeroed).  I surrounded this with a CONFIG_DEBUG_KERNEL block.

Ok, so we can skip below block according to this assumption:
                for (i = 0; i < req->tp_block_nr; i++) {
                        void *ptr = pg_vec[i];
                        int k;

                        for (k = 0; k < rb->frames_per_block; k++) {
                                __packet_set_status(po, ptr, TP_STATUS_KERNEL);
                                ptr += req->tp_frame_size;
                        }
                }

>>
>> Earlier, I think I had said that the mapped variable should be placed in packet_ring_buffer struct - I was wrong.  It's correct where it is.  I had forgotten that rx & tx are mapped contiguously and simultaneously.  There needs to be a note in the doc that the rings should be set up before mapping (i.e. cannot set up the rx or tx ring buffer first, mmap, and then try to change it).

 Yes, we can also add a check for po->mapped in
 PACKET_TX_RING/PACKET_RX_RING cases of packet_setsockopt() switch.


>> We do need still need a check for tx_pending_skb when sizing the ring buffer (in the situation where we unfreed skbs created by a call to send from Thread B, while Thread A unmaps the ring buffer and trys a resize). Also, in tpacket_snd, we need to increment mapped before allocating the skb and test if the original value was 0 (we decrement after incrementing tx_pending_skb).  If it was, then that indicates that the user had unmapped the ring buffer, which means we should stop sending.  No need for additional locking because of the atomic relationship this sets up between tx_pending_skb and mapped.

 I'm not sure to understand:

 Let me, sum up :
 * when setting or resizing the ring: we have to return an error if:
 - someone has mapped the socket (1.a)
 - sending is ongoing - tx_pending_skb != 0 (1.b)
 - a send() procedure is ongoing (1.c)

 * when closing the socket, we have to return an error if:
 - sending is ongoing - tx_pending_skb != 0 (2.a)
 - a send() procedure is ongoing (2.b)

 * during do-while loop of send(),:
 - protect ring against simultaneous send() (3.a)
 - ensure that ring is not resized (3.b) (linked with 1.c)
 Our main issue is when: tx_pending_skb = 0, Thread A starts to send a
 packet while Thread B unmaps and resizes the ring.
  Thread B can potentially resizes the ring until increment of
 tx_pending_skb in Thread A.
 - loop can continue even if ring is not mapped (3.c), this has no
 sense but it is not critical

 * when executing the destructor callback:
 - we must ensure that ring structure has not changed since send() (4.a)

 (1.a) can be done with po->mmaped check in packet_setsockopt()
 (1.b) and (2.a) can be done as you said :  tx_pending_skb != 0 check
 when sizing buffer in packet_set_ring()
 (3.a) by a mutex M outside of the do-while loop
 (1.c), (2.b) and (3.b) can be performed thanks to the same mutex M and
 mutex_trylock() in packet_set_ring(). An error is returned if we can't
 take the mutex . The mutex is released at the end of packet_set_ring()
 call.
 (4.a) is validated with tx_pending_skb increment, (3.b),(1.b) and (2.a)

 Do I miss something?

 Many thanks,
 Johann
