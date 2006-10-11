From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] Question about potential problem in net/ipv4/route.c
Date: Wed, 11 Oct 2006 15:11:18 +0200
Message-ID: <200610111511.19028.dada1@cosmosbay.com>
References: <20061010.191547.83619974.davem@davemloft.net> <20061011090504.GC2938@mellanox.co.il> <20061011.022015.63051509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:6869 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751276AbWJKNLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 09:11:17 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061011.022015.63051509.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

While browsing net/ipv4/route.c  I discovered compare_keys() function, and a 
potential bug in it.

static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
{
        return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, 
sizeof(fl1->nl_u.ip4_u)) == 0 &&
               fl1->oif     == fl2->oif &&
               fl1->iif     == fl2->iif;
}


Using memcmp(ptr1, ptr2, sizeof(SOMEFIELD)) is dangerous because 
sizeof(SOMEFIELD) can be larger than the underlying object, because of 
alignment constraints.

In this case, sizeof(fl1->nl_u.ip4_u) is 16, while fl1->nl_u.ip4_u is :

                struct {
                        __u32                   daddr;
                        __u32                   saddr;
                        __u32                   fwmark;
                        __u8                    tos;
                        __u8                    scope;
                } ip4_u;

So 14 bytes are really initialized, and 2 padding bytes might contain random 
values...

So at the very minimum, we should avoid doing the memcmp() including those 
last two bytes : It would be less bugy, and faster too...  (But to get really 
fast comparison, we should do some clever long/int XOR operations to avoid 
many test/branches, like the optim we did in compare_ether_addr())

As shown in profiles, "repz cmpsb" is really a dog... (and its use of 
esi/edi/ecx registers a high pressure for the compiler/optimizer)

Eric

