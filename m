From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] xfrm ip6ip6 (revised)
Date: Fri, 13 Jun 2003 12:19:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.121958.78710614.davem@redhat.com>
References: <20030601.013040.116362760.davem@redhat.com>
	<87smqerml5.wl@karaba.org>
	<20030613.120702.71089628.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <20030613.120702.71089628.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "David S. Miller" <davem@redhat.com>
   Date: Fri, 13 Jun 2003 12:07:02 -0700 (PDT)

   You need to add refcount to hash table entries, so that SPI can be
   shared by different xfrm6 tunnels with same address.
   
Mitsuru, here is some example code showing what my
idea looks like.  I apologize for not making something
like this for you earlier.

struct v6spi_entry {
	struct v6spi_entry *next;
	struct in6_addr addr;
	u32 spi;
	atomic_t refcnt;
};

u32 spi v6spi_alloc(struct in6_addr *addr)
{
	int h = v6_hashfn(addr);
	struct v6spi_entry *ent;

	for (ent = hash_table[h]; ent; ent = ent->next) {
		if (!ipv6_addr_cmp(addr, &ent->addr)) {
			atomic_inc(&ent->refcnt);
			return ent->spi;
		}
	}
	ent = kmalloc(sizeof(*ent), GFP_ATOMIC);
	ent->spi = alloc_unique_spi();
	ipv6_addr_copy(&ent->addr, addr);
	atomic_set(&ent->refcnt, 1);
	ent->next = hash_table[h];
	hash_table[h] = ent;

	return ent->spi;
}
