From: Unai Uribarri <unai.uribarri@optenet.com>
Subject: Re: [PATCH 1/1] af_packet: don't enable timestamps in mmap'ed
	sockets
Date: Thu, 09 Aug 2007 20:50:50 +0200
Message-ID: <1186685450.24669.81.camel@localhost.localdomain>
References: <1186669314.24669.56.camel@localhost.localdomain>
	 <20070809143322.GA5345@2ka.mipt.ru>
	 <1186683234.24669.65.camel@localhost.localdomain>
	 <20070809181823.GA32449@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipsec.mad.optenet.com ([213.27.232.70]:42013 "EHLO
	mta-mad.optenet.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1759037AbXHISux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 14:50:53 -0400
In-Reply-To: <20070809181823.GA32449@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not enable timestamps automatically on mmap'ed AF_PACKET sockets.

---
commit d1d6e6bf196e31b6306fd0fef95f4190983c8a86
tree 22637506c0aafeabfbe05faf5352d0358c4d9460
parent 6a302358d87fedaf7bda12b8e909265ebf1ce674
author Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:38:42 +0200
committer Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:38:42 +0200

 net/packet/af_packet.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1322d62..a4f2da3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -640,10 +640,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
        h->tp_snaplen = snaplen;
        h->tp_mac = macoff;
        h->tp_net = netoff;
-       if (skb->tstamp.tv64 == 0) {
-               __net_timestamp(skb);
-               sock_enable_timestamp(sk);
-       }
        tv = ktime_to_timeval(skb->tstamp);
        h->tp_sec = tv.tv_sec;
        h->tp_usec = tv.tv_usec;




!-------------------------------------------------------------flip-


Effectively disable timestamping when requested by SO_TIMESTAMP

---
commit 1fdf6bb534dfbc6e9bdf8958620b05d5334b15eb
tree ec4b577c1704f178f0f7c5d8d69af41454fc8f14
parent d1d6e6bf196e31b6306fd0fef95f4190983c8a86
author Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:43:00 +0200
committer Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:43:00 +0200

 net/core/sock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index cfed7d4..3af2322 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -561,6 +561,7 @@ set_rcvbuf:
                } else {
                        sock_reset_flag(sk, SOCK_RCVTSTAMP);
                        sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
+                       sock_disable_timestamp(sk);
                }
                break;





!-------------------------------------------------------------flip-


Automatically enable timestamping on mmap'ed AF_PACKET sockets.

---
commit 4564f367ff054bd8837cc6cb1cfb9a927c57054a
tree 3475d56cc7ea74052677c944ec0a6bf6e9f4817c
parent 1fdf6bb534dfbc6e9bdf8958620b05d5334b15eb
author Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:43:59 +0200
committer Unai Uribarri <unai.uribarri@optenet.com> Tue, 31 Jul 2007 20:43:59 +0200

 net/packet/af_packet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a4f2da3..5179daf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1750,6 +1750,7 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing

                po->pg_vec_pages = req->tp_block_size/PAGE_SIZE;
                po->prot_hook.func = po->pg_vec ? tpacket_rcv : packet_rcv;
+               sock_enable_timestamp(sk);
                skb_queue_purge(&sk->sk_receive_queue);
 #undef XC
                if (atomic_read(&po->mapped))




!-------------------------------------------------------------flip-



On jue, 2007-08-09 at 22:18 +0400, Evgeniy Polyakov wrote:
> On Thu, Aug 09, 2007 at 08:13:54PM +0200, Unai Uribarri (unai.uribarri@optenet.com) wrote:
> > On jue, 2007-08-09 at 18:33 +0400, Evgeniy Polyakov wrote:
> > > On Thu, Aug 09, 2007 at 04:21:54PM +0200, Unai Uribarri (unai.uribarri@optenet.com) wrote:
> > > > The attached patch removes the automatic timestamp activation, that
> > > > only mmap'ed AF_PACKET sockets perform. I known it can break user
> > > > applications, but I believe that it's the correct solution.
> > > 
> > > How tcpdump with mmap libpcap will work with it?
> > 
> > In Linux, you can enable timestamps on any socket executing:
> > 
> > int val = 1;
> > setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &val, sizeof(val));
> > 
> > PD: Current release of tcpdump doesn't mmap the reception ring and
> > timestamps packets at user space with gettimeofday. It isn't the best
> > performing alternative, but it's portable.
>  
> IIRC, there was/is a libpcap which worked with mapped sockets, mybe not 
> official though. Any application which depened on having timestamps with
> packets will not work now. Why not to implement an
> absolutely_turn_off_timestamps option instead of breaking compatibility?
> 


