From: Julia Lawall <julia.lawall@lip6.fr>
Subject: unused code in net/netfilter/ipset/ip_set_bitmap_ipmac.c
Date: Mon, 29 Feb 2016 12:14:39 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1602291202590.2600@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The file net/netfilter/ipset/ip_set_bitmap_ipmac.c seems to contain a lot
of static functions that are not used in the file:

bitmap_ipmac_add_timeout
bitmap_ipmac_do_add
bitmap_ipmac_do_del
bitmap_ipmac_do_head
bitmap_ipmac_do_list
bitmap_ipmac_do_test
bitmap_ipmac_gc_test
bitmap_ipmac_is_filled
bitmap_ipmac_kadt
bitmap_ipmac_same_set
bitmap_ipmac_uadt

Have I overooked something?

I was looking at this code, with Daniel Borkmann, because there seems to
be a bug in the function bitmap_ipmac_uadt:

	if (tb[IPSET_ATTR_ETHER]) {
                memcpy(e.ether, nla_data(tb[IPSET_ATTR_ETHER]), ETH_ALEN);
                e.add_mac = 1;
        }

Later in the same file, there is:

static struct ip_set_type bitmap_ipmac_type = {
	...
        .adt_policy     = {
		...
		[IPSET_ATTR_ETHER]      = { .type = NLA_BINARY,
                                            .len  = ETH_ALEN },
		...},
	...
};

The type NLA_BINARY indicates that the length is a maximum possible
length, and thus a check of the actual length is needed before the memcpy.

The file net/netfilter/ipset/ip_set_hash_mac.c seems to have a similar
problem.  The following static functions are not used:

hash_mac4_data_equal
hash_mac4_data_list
hash_mac4_data_next
hash_mac4_kadt
hash_mac4_uadt

And the following code:

ether_addr_copy(e.ether, nla_data(tb[IPSET_ATTR_ETHER]));

in hash_mac4_uadt does not seem to have a check on the length, and the
field is defined in the same way as above.

julia
