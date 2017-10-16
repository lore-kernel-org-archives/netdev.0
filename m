From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] netlink: use NETLINK_CB(in_skb).sk instead of looking it up
Date: Mon, 16 Oct 2017 16:57:49 +0200
Message-ID: <20171016145749.31793-1-johannes@sipsolutions.net>
Cc: "Eric W . Biederman" <ebiederman-1v8oiQdgUNlBDgjK7y7TUQ@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

When netlink_ack() reports an allocation error to the sending
socket, there's no need to look up the sending socket since
it's available in the SKB's CB. Use that instead of going to
the trouble of looking it up.

Note that the pointer is only available since Eric Biederman's
commit 3fbc290540a1 ("netlink: Make the sending netlink socket availabe in NETLINK_CB")
which is far newer than the original lookup code (Oct 2003)
(though the field was called 'ssk' in that commit and only got
renamed to 'sk' later, I'd actually argue 'ssk' was better - or
perhaps it should've been 'source_sk' - since there are so many
different 'sk's involved.)

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/netlink/af_netlink.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f34750691c5c..336d9c6dcad9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2336,16 +2336,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 
 	skb = nlmsg_new(payload + tlvlen, GFP_KERNEL);
 	if (!skb) {
-		struct sock *sk;
