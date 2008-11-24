From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: avoid a pair of dst_hold()/dst_release() in ip_append_data()
Date: Mon, 24 Nov 2008 12:24:53 +0100
Message-ID: <492A8F05.3080509@cosmosbay.com>
References: <492A6C94.7030308@cosmosbay.com> <87y6z9h33h.fsf@basil.nowhere.org> <492A7E85.3060502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050603000406000307030608"
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Corey Minyard <minyard@acm.org>,
	Christian Bell <christian@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35188 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbYKXLZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 06:25:12 -0500
In-Reply-To: <492A7E85.3060502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050603000406000307030608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Andi Kleen a =E9crit :
>> Eric Dumazet <dada1@cosmosbay.com> writes:
>>
>>> tbench has hard time incrementing decrementing the route cache refcou=
nt
>>> shared by all communications on localhost.
>>
>> iirc there was a patch some time ago to use per CPU loopback devices=20
>> to avoid this, but it was considered too much a benchmark hack.
>> As core counts increase it might stop being that though.
>=20
> Well, you probably mention Stephen patch to avoid dirtying other conten=
ded
> cache lines (one napi structure per cpu)
>=20
> Having multiple loopback dev would really be a hack I agree.
>=20
>>
>>> On real world, we also have this problem on RTP servers sending many =
UDP
>>> frames to mediagateways, especially big ones handling thousand of=20
>>> streams.
>>>
>>> Given that route entries are using RCU, we probably can avoid=20
>>> incrementing
>>> their refcount in case of connected sockets ?
>>
>> Normally they can be hold over sleeps or queuing of skbs too, and RCU
>> doesn't handle that. To make it handle that you would need to define a=

>> custom RCU period designed for this case, but this would be probably
>> tricky and fragile: especially I'm not sure even if you had a "any
>> packet queued" RCU method it be guaranteed to always finish because=20
>> there is no fixed upper livetime of a packet.
>>
>> The other issue is that on preemptible kernels you would need to=20
>> disable preemption all the time such a routing entry is hold, which
>> could be potentially quite long.
>>
>=20
> Well, in case of UDP, we call ip_push_pending_frames() and this one
> does the increment of refcount (again). I was not considering
> avoiding the refcount hold we do when queing a skb in transmit
> queue, only during a short period of time. Oh well, ip_append_data()
> might sleep, so this cannot work...
>=20
> I agree avoiding one refcount increment/decrement is probably
> not a huge gain, considering we *have* to do the increment,
> but when many cpus are using UDP send/receive in //, this might
> show a gain somehow.
>=20
> So maybe we could make ip_append_data() (or its callers) a
> litle bit smarter, avoiding increment/decrement if possible.

Here is a patch to remove one dst_hold()/dst_release() pair
in UDP/RAW transmit path.

[PATCH] net: avoid a pair of dst_hold()/dst_release() in ip_append_data()=


We can reduce pressure on dst entry refcount that slowdown UDP transmit
path on SMP machines. This pressure is visible on RTP servers when
delivering content to mediagateways, especially big ones, handling
thousand of streams. Several cpus send UDP frames to the same
destination, hence use the same dst entry.

This patch makes ip_append_data() eventually steal the refcount its
callers had to take on the dst entry.

This doesnt avoid all refcounting, but still gives speedups on SMP,
on UDP/RAW transmit path

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/ip.h     |    2 +-
 net/ipv4/icmp.c      |    8 ++++----
 net/ipv4/ip_output.c |   11 ++++++++---
 net/ipv4/raw.c       |    2 +-
 net/ipv4/udp.c       |    2 +-
 5 files changed, 15 insertions(+), 10 deletions(-)

--------------050603000406000307030608
Content-Type: text/plain;
 name="ip_append_data.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_append_data.patch"

diff --git a/include/net/ip.h b/include/net/ip.h
index bc026ec..ddef10c 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -110,7 +110,7 @@ extern int		ip_append_data(struct sock *sk,
 						   int odd, struct sk_buff *skb),
 				void *from, int len, int protolen,
 				struct ipcm_cookie *ipc,
-				struct rtable *rt,
+				struct rtable **rt,
 				unsigned int flags);
 extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
 extern ssize_t		ip_append_page(struct sock *sk, struct page *page,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 21e497e..7b88be9 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -321,12 +321,12 @@ static int icmp_glue_bits(void *from, char *to, int offset, int len, int odd,
 }
 
 static void icmp_push_reply(struct icmp_bxm *icmp_param,
-			    struct ipcm_cookie *ipc, struct rtable *rt)
+			    struct ipcm_cookie *ipc, struct rtable **rt)
 {
 	struct sock *sk;
 	struct sk_buff *skb;
 
-	sk = icmp_sk(dev_net(rt->u.dst.dev));
+	sk = icmp_sk(dev_net((*rt)->u.dst.dev));
 	if (ip_append_data(sk, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
@@ -392,7 +392,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	}
 	if (icmpv4_xrlim_allow(net, rt, icmp_param->data.icmph.type,
 			       icmp_param->data.icmph.code))
-		icmp_push_reply(icmp_param, &ipc, rt);
+		icmp_push_reply(icmp_param, &ipc, &rt);
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
@@ -635,7 +635,7 @@ route_done:
 		icmp_param.data_len = room;
 	icmp_param.head_len = sizeof(struct icmphdr);
 
-	icmp_push_reply(&icmp_param, &ipc, rt);
+	icmp_push_reply(&icmp_param, &ipc, &rt);
 ende:
 	ip_rt_put(rt);
 out_unlock:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 46d7be2..da9b819 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -778,7 +778,7 @@ int ip_append_data(struct sock *sk,
 		   int getfrag(void *from, char *to, int offset, int len,
 			       int odd, struct sk_buff *skb),
 		   void *from, int length, int transhdrlen,
-		   struct ipcm_cookie *ipc, struct rtable *rt,
+		   struct ipcm_cookie *ipc, struct rtable **rtp,
 		   unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -793,6 +793,7 @@ int ip_append_data(struct sock *sk,
 	int offset = 0;
 	unsigned int maxfraglen, fragheaderlen;
 	int csummode = CHECKSUM_NONE;
+	struct rtable *rt;
 
 	if (flags&MSG_PROBE)
 		return 0;
@@ -812,7 +813,11 @@ int ip_append_data(struct sock *sk,
 			inet->cork.flags |= IPCORK_OPT;
 			inet->cork.addr = ipc->addr;
 		}
-		dst_hold(&rt->u.dst);
+		rt = *rtp;
+		/*
+		 * We steal reference to this route, caller should not release it
+		 */
+		*rtp = NULL;
 		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
 					    rt->u.dst.dev->mtu :
 					    dst_mtu(rt->u.dst.path);
@@ -1391,7 +1396,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
 	ip_append_data(sk, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
-		       &ipc, rt, MSG_DONTWAIT);
+		       &ipc, &rt, MSG_DONTWAIT);
 	if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
 		if (arg->csumoffset >= 0)
 			*((__sum16 *)skb_transport_header(skb) +
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 998fcff..dff8bc4 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -572,7 +572,7 @@ back_from_confirm:
 			ipc.addr = rt->rt_dst;
 		lock_sock(sk);
 		err = ip_append_data(sk, ip_generic_getfrag, msg->msg_iov, len, 0,
-					&ipc, rt, msg->msg_flags);
+					&ipc, &rt, msg->msg_flags);
 		if (err)
 			ip_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE))
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index da869ce..5491144 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -719,7 +719,7 @@ do_append_data:
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
-			sizeof(struct udphdr), &ipc, rt,
+			sizeof(struct udphdr), &ipc, &rt,
 			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_flush_pending_frames(sk);

--------------050603000406000307030608--
