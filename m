From: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [2.6.20-rt8] "Neighbour table overflow."
Date: Wed, 21 Mar 2007 11:51:48 +0100 (CET)
Message-ID: <Pine.LNX.4.63.0703211130140.534@pcgl.dsa-ac.de>
References: <mtHxbRRF.1174407786.3649450.samuel@sortiz.org>
	<Pine.LNX.4.63.0703201759390.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0703210849570.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <Pine.LNX.4.63.0703210849570.534-pjC7uWgG1yLsj6RlE8knwQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

(Short recap for newly added to cc: netdev: I'm seeing an skb leak in 
2.6.20 during an IrDA IrNET+ppp UDP test with periodic connection 
disruptions)

On Wed, 21 Mar 2007, Guennadi Liakhovetski wrote:

> On Tue, 20 Mar 2007, Guennadi Liakhovetski wrote:
>
> Ok, looks like all leaked skbuffs come from ip_append_data(), like this:
>
> (sock_alloc_send_skb+0x2c8/0x2e4)
> (ip_append_data+0x7fc/0xa80)
> (udp_sendmsg+0x248/0x68c)
> (inet_sendmsg+0x60/0x64)
> (sock_sendmsg+0xb4/0xe4)
>  r4 = C3CB4960
> (sys_sendto+0xc8/0xf0)
>  r4 = 00000000
> (sys_socketcall+0x168/0x1f0)
> (ret_fast_syscall+0x0/0x2c)

This call to sock_alloc_send_skb() in ip_append_data() is not from the 
inlined ip_ufo_append_data(), it is here:

 			/* The last fragment gets additional space at tail.
 			 * Note, with MSG_MORE we overallocate on fragments,
 			 * because we have no idea what fragment will be
 			 * the last.
 			 */
 			if (datalen == length + fraggap)
 				alloclen += rt->u.dst.trailer_len;

 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,
 						(flags & MSG_DONTWAIT), &err);
 			} else {

Then, I traced a couple of paths how such a skbuff, coming down from 
ip_append_data() and allocated above get freed (when they do):

[<c0182380>] (__kfree_skb+0x0/0x170) from [<c0182514>] (kfree_skb+0x24/0x50)
  r5 = C332BC00  r4 = C332BC00 
[<c01824f0>] (kfree_skb+0x0/0x50) from [<bf0fac58>] (irlap_update_nr_received+0x94/0xc8 [irda])
[<bf0fabc4>] (irlap_update_nr_received+0x0/0xc8 [irda]) from [<bf0fda98>] (irlap_state_nrm_p+0x530/0x7c0 [irda])
  r7 = 00000001  r6 = C0367EC0  r5 = C332BC00  r4 = 00000000
[<bf0fd568>] (irlap_state_nrm_p+0x0/0x7c0 [irda]) from [<bf0fbd90>] (irlap_do_event+0x68/0x18c [irda])
[<bf0fbd28>] (irlap_do_event+0x0/0x18c [irda]) from [<bf1008cc>] (irlap_driver_rcv+0x1f0/0xd38 [irda])
[<bf1006dc>] (irlap_driver_rcv+0x0/0xd38 [irda]) from [<c01892c0>] (netif_receive_skb+0x244/0x338)
[<c018907c>] (netif_receive_skb+0x0/0x338) from [<c0189468>] (process_backlog+0xb4/0x194)
[<c01893b4>] (process_backlog+0x0/0x194) from [<c01895f8>] (net_rx_action+0xb0/0x210)
[<c0189548>] (net_rx_action+0x0/0x210) from [<c0042f7c>] (ksoftirqd+0x108/0x1cc)
[<c0042e74>] (ksoftirqd+0x0/0x1cc) from [<c0053614>] (kthread+0x10c/0x138)
[<c0053508>] (kthread+0x0/0x138) from [<c003f918>] (do_exit+0x0/0x8b0)
  r8 = 00000000  r7 = 00000000  r6 = 00000000  r5 = 00000000
  r4 = 00000000

and

[<c0182380>] (__kfree_skb+0x0/0x170) from [<c0182514>] (kfree_skb+0x24/0x50)
  r5 = C03909E0  r4 = C1A97400 
[<c01824f0>] (kfree_skb+0x0/0x50) from [<c0199bf8>] (pfifo_fast_enqueue+0xb4/0xd0)
[<c0199b44>] (pfifo_fast_enqueue+0x0/0xd0) from [<c0188c30>] (dev_queue_xmit+0x17c/0x25c)
  r8 = C1A2DCE0  r7 = FFFFFFF4  r6 = C3393114  r5 = C03909E0
  r4 = C3393000 
[<c0188ab4>] (dev_queue_xmit+0x0/0x25c) from [<c01a7c18>] (ip_output+0x150/0x254)
  r7 = C3717120  r6 = C03909E0  r5 = 00000000  r4 = C1A2DCE0
[<c01a7ac8>] (ip_output+0x0/0x254) from [<c01a93d0>] (ip_push_pending_frames+0x368/0x4d4)
[<c01a9068>] (ip_push_pending_frames+0x0/0x4d4) from [<c01c6954>] (udp_push_pending_frames+0x14c/0x310)
[<c01c6808>] (udp_push_pending_frames+0x0/0x310) from [<c01c70d8>] (udp_sendmsg+0x5c0/0x690)
[<c01c6b18>] (udp_sendmsg+0x0/0x690) from [<c01ceafc>] (inet_sendmsg+0x60/0x64)
[<c01cea9c>] (inet_sendmsg+0x0/0x64) from [<c017c970>] (sock_sendmsg+0xb4/0xe4)
  r7 = C2CEFDF4  r6 = 00000064  r5 = C2CEFEA8  r4 = C3C94080
[<c017c8bc>] (sock_sendmsg+0x0/0xe4) from [<c017dd9c>] (sys_sendto+0xc8/0xf0)
  r7 = 00000064  r6 = C3571580  r5 = C2CEFEC4  r4 = 00000000
[<c017dcd4>] (sys_sendto+0x0/0xf0) from [<c017e654>] (sys_socketcall+0x168/0x1f0)
[<c017e4ec>] (sys_socketcall+0x0/0x1f0) from [<c001ff40>] (ret_fast_syscall+0x0/0x2c)
  r5 = 00415344  r4 = 00000000

I would be greatful for any hints how I can identify which skbuff's get 
lost and why, and where and who should free them.

I am not subscribed to netdev, please keep in cc.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
