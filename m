From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: add complete rcu protection around np->opt
Date: Wed, 02 Dec 2015 21:35:48 -0800
Message-ID: <1449120948.6379.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854677.24696.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151202.233821.139368757119113563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, wdauchy@gmail.com,
	rweikusat@mobileactivedefense.com, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151202.233821.139368757119113563.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-02 at 23:38 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 29 Nov 2015 19:37:57 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > This patch addresses multiple problems :
> > 
> > UDP/RAW sendmsg() need to get a stable struct ipv6_txoptions
> > while socket is not locked : Other threads can change np->opt
> > concurrently. Dmitry posted a syzkaller
> > (http://github.com/google/syzkaller) program desmonstrating
> > use-after-free.
> > 
> > Starting with TCP/DCCP lockless listeners, tcp_v6_syn_recv_sock()
> > and dccp_v6_request_recv_sock() also need to use RCU protection
> > to dereference np->opt once (before calling ipv6_dup_options())
> > 
> > This patch adds full RCU protection to np->opt
> > 
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied and queued up for -stable.

Thanks David.

I will send a followup patch, as I missed the sctp part, now triggering
following sparse warnings.

  CHECK   net/sctp/ipv6.c
net/sctp/ipv6.c:223:41: warning: incorrect type in argument 4 (different address spaces)
net/sctp/ipv6.c:223:41:    expected struct ipv6_txoptions *opt
net/sctp/ipv6.c:223:41:    got struct ipv6_txoptions [noderef] <asn:4>*opt
net/sctp/ipv6.c:265:41: warning: incorrect type in argument 2 (different address spaces)
net/sctp/ipv6.c:265:41:    expected struct ipv6_txoptions const *opt
net/sctp/ipv6.c:265:41:    got struct ipv6_txoptions [noderef] <asn:4>*opt
net/sctp/ipv6.c:324:49: warning: incorrect type in argument 2 (different address spaces)
net/sctp/ipv6.c:324:49:    expected struct ipv6_txoptions const *opt
net/sctp/ipv6.c:324:49:    got struct ipv6_txoptions [noderef] <asn:4>*opt
