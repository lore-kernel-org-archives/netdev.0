From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netlink: fix a limit in NETLINK_LIST_MEMBERSHIPS
Date: Fri, 13 Nov 2015 17:20:44 +0300
Message-ID: <20151113142044.GA1445@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This condition doesn't work when len is smaller than expected and not a
multiple of 4.  In that situation "len - pos" is negative and type
promoted to a high unsigned value and we do not break out of the loop.
It causes the program calling it to crash.

Fixes: b42be38b2778 ('netlink: add API to retrieve all group memberships')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af..76a8466 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2373,7 +2373,7 @@ static int netlink_getsockopt(struct socket *sock, int level, int optname,
 		err = 0;
 		netlink_lock_table();
 		for (pos = 0; pos * 8 < nlk->ngroups; pos += sizeof(u32)) {
-			if (len - pos < sizeof(u32))
+			if (len < pos + sizeof(u32))
 				break;
 
 			idx = pos / sizeof(unsigned long);
