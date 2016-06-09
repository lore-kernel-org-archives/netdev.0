From: Su Xuemin <suxm@chinanetcenter.com>
Subject: Re: [PATCH v2] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Thu, 09 Jun 2016 09:43:36 +0800
Message-ID: <1465436616.2825.39.camel@chinanetcenter.com>
References: <1465357219-34240-1-git-send-email-suxm@chinanetcenter.com>
	 <1465400620.7945.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465400620.7945.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 2016-06-08 at 08:43 -0700, Eric Dumazet wrote:
> I am not convinced this is the right way to fix the issue.
> 
> Fact that you did not change udp4_lib_lookup2() is telling me something.
> 
> 
> 1) If host has 100 different IP, and 10 sockets bound to 0.0.0.0:53 
> 2) If we receive datagrams from SRCIP:srcport send to IP{1..100}:53
> will all be hashed on same slot.
> 
> See the hash used in soreuseport logic as an equivalent of a 4-tuple
> hash really, not a 3-tuple one.
> 

This is my understanding of __udp4_lib_lookup(), see the comments below,
please kindly review it.
The problem of the current code is:
  In Path 1, we pass daddr to udp_ehashfn() inside udp4_lib_lookup2().
  In Path 2, we pass 0.0.0.0 to udp_ehashfn() inside udp4_lib_lookup2().
  In Path 3, we pass daddr to udp_ehashfn(), even if inet->inet_rcv_saddr
is 0.0.0.0.
  The hash value returned by udp_ehashfn() is used as a random seed to
select socket from the sockets of a hslot. In Path 2 and Path 3, this
hash value is different, so we will select different sockets.
  Pass inet->inet_rcv_saddr to udp_ehashfn() in Path 3 will make the
logic consistent in all these three Pathes.
--------
        ...
        if (hslot->count > 10) {
                /* Xuemin:
                 * for udptable->hash2[], sockets bound to specific ip and
                 * sockets bound to 0.0.0.0 may be placed in different hslot,
                 * so we may have to search two hslots. */
                ...
                /* Xuemin Path 1:
                 * for udptable->hash2[], firstly try to find the socket
                 * bound to the specific daddr. */
                result = udp4_lib_lookup2(net, saddr, sport,
                                          daddr, hnum, dif,
                                          hslot2, slot2, skb);
                if (!result) {
                        /* Xuemin Path 2:
                         * for udptable->hash2[], if we can not find the
                         * socket bound to the specific daddr, we then
                         * try to find the socket bound to 0.0.0.0. */
                        result = udp4_lib_lookup2(net, saddr, sport,
                                                  htonl(INADDR_ANY), hnum, dif,
                                                  hslot2, slot2, skb);
                }
                return result;
        }
        /* Xuemin:
         * for udptable->hash[], all sockets bound to the same
         * port(no matter they are bound to specific ip or to 0.0.0.0)
         * are placed in the same hslot, so we only need to search one
         * hslot. */
begin:
        result = NULL;
        badness = 0;
        sk_for_each_rcu(sk, &hslot->head) {
                score = compute_score(sk, net, saddr, hnum, sport,
                                      daddr, dport, dif);
                if (score > badness) {
                        reuseport = sk->sk_reuseport;
                        if (reuseport) {
                                /* Xuemin Path 3:
                                 * when inet_sk(sk)->inet_rcv_saddr is 0.0.0.0,
                                 * we should not pass daddr here. */
                                hash = udp_ehashfn(net, daddr, hnum,
                                                   saddr, sport);
                                result = reuseport_select_sock(sk, hash, skb,
                                                        sizeof(struct udphdr));
