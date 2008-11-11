From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 11:05:07 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611D5@NASANEXMB10.na.qualcomm.com>
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
 <7e0dd21a0811110659p1bd7a765jd8afb49a1f51472@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:23890 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbYKKTFK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 14:05:10 -0500
In-Reply-To: <7e0dd21a0811110659p1bd7a765jd8afb49a1f51472@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

> Ok, so we can skip below block according to this assumption:
> 		for (i = 0; i < req->tp_block_nr; i++) {
> 			void *ptr = pg_vec[i];
> 			int k;
> 
> 			for (k = 0; k < rb->frames_per_block; k++) {
> 				__packet_set_status(po, ptr, TP_STATUS_KERNEL);
> 				ptr += req->tp_frame_size;
> 			}
> 		}
>
Yes.

> >
> > Earlier, I think I had said that the mapped variable should be placed
> in packet_ring_buffer struct - I was wrong.  It's correct where it is.
> I had forgotten that rx & tx are mapped contiguously and
> simultaneously.  There needs to be a note in the doc that the rings
> should be set up before mapping (i.e. cannot set up the rx or tx ring
> buffer first, mmap, and then try to change it).
> 
> Yes, we can also add a check for po->mapped in
> PACKET_TX_RING/PACKET_RX_RING cases of packet_setsockopt() switch.
Since those call in to packet_set_ring, we can just fix the logic there - there's no need to complicate packet_setsockopt unnecessarily.

> 
> 
> > We do need still need a check for tx_pending_skb when sizing the ring
> buffer (in the situation where we unfreed skbs created by a call to
> send from Thread B, while Thread A unmaps the ring buffer and trys a
> resize). Also, in tpacket_snd, we need to increment mapped before
> allocating the skb and test if the original value was 0 (we decrement
> after incrementing tx_pending_skb).  If it was, then that indicates
> that the user had unmapped the ring buffer, which means we should stop
> sending.  No need for additional locking because of the atomic
> relationship this sets up between tx_pending_skb and mapped.
> 
> I'm not sure to understand:
Sorry - I do realize I rambled a bit.  I'll try to clarify.

> 
> Let me, sum up :
> * when setting or resizing the ring: we have to return an error if:
> - someone has mapped the socket (1.a)
> - sending is ongoing - tx_pending_skb != 0 (1.b)
> - a send() procedure is ongoing (1.c)
Yes.

> 
> * when closing the socket, we have to return an error if:
> - sending is ongoing - tx_pending_skb != 0 (2.a)
> - a send() procedure is ongoing (2.b)
Only 2.a should be a reason to fail to close.  With 2.b, send should abort, recognizing the socket is closing, without sending anything out.  Realistically however, it's probably too hard to co-ordinate since 2.b causes 2.a.  So a more realistic approach is that closing never fails.  Instead, we add a flag field into packet_sock.  In send, we atomically set bit 0.  When closing, we atomically set bit 1.  If in closing bit 0 is also set, then we defer the actual closing of the socket to send.  If send sees bit 1 & bit 0 set & tx_pending_skb == 0, then it frees the actual socket.  Otherwise, the skb destructor is responsible for closing the socket once tx_pending_skb drops to 0 & bit 1 is set. Calls to send fail if bit 1 is set.
> 	
> * during do-while loop of send(),:
> - protect ring against simultaneous send() (3.a)
> - ensure that ring is not resized (3.b) (linked with 1.c)
> Our main issue is when: tx_pending_skb = 0, Thread A starts to send a
> packet while Thread B unmaps and resizes the ring.
>  Thread B can potentially resizes the ring until increment of
> tx_pending_skb in Thread A.
> - loop can continue even if ring is not mapped (3.c), this has no
> sense but it is not critical
3.a can be protected through the flag field as above - atomically set the 0th bit if it's not set (test_and_set_bit).  Otherwise, return with -EBUSY or similar error code.  After this protection, atomically increment (atomic_inc_return).  If it is 1, then abort send because the user has unmapped the memory.  Don't forget to atomically decrement it again (and clear the 0th flag bit) regardless before exiting from send.

> 
> * when executing the destructor callback:
> - we must ensure that ring structure has not changed since send() (4.a)
This is a consequence of the above logic. 
> 
> (1.a) can be done with po->mmaped check in packet_setsockopt()
> (1.b) and (2.a) can be done as you said :  tx_pending_skb != 0 check
> when sizing buffer in packet_set_ring()
> (3.a) by a mutex M outside of the do-while loop
> (1.c), (2.b) and (3.b) can be performed thanks to the same mutex M and
> mutex_trylock() in packet_set_ring(). An error is returned if we can't
> take the mutex . The mutex is released at the end of packet_set_ring()
> call.
> (4.a) is validated with tx_pending_skb increment, (3.b),(1.b) and (2.a)
> 
> Do I miss something?
I hope I covered everything above.  I'm not sure if send, setsockopt, etc are in an interrupt context or not.  My guess is they are and thus mutexes are not allowed - spinlocks only.  However, there's also no need for mutexes or spinlocks because I believe the above atomic algorithm should work.  I should be able to post a patch by the end of the day.

Thanks,
Vitali
