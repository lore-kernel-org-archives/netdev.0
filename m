From: Andy Whitcroft <apw@canonical.com>
Subject: x25: possible skb leak on bad facilities
Date: Mon, 31 Jan 2011 13:08:26 +0000
Message-ID: <20110131130826.GC16804@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Hughes <john@calva.com>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tim Gardner <tim.gardner@canonical.com>
To: Andrew Hendry <andrew.hendry@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking at the changes introduced in the commit below, we seem to
introduce an skb leak when a packet with bad facilities are present:

    commit a6331d6f9a4298173b413cf99a40cc86a9d92c37
    Author: andrew hendry <andrew.hendry@gmail.com>
    Date:   Wed Nov 3 12:54:53 2010 +0000

        memory corruption in X.25 facilities parsing

If I am understanding things correctly then we trigger a -1 return to
the main packet dispatch loop, this being non-zero implies that we have
requeued the skb and it should not be freed.  As it was not requeued,
I believe the skb is no longer referenced and then is leaked.

Perhaps someone better aquainted with this code could review my analysis
in the patch leader below.  If accurate I believe we need the patch below
to resolve this.  If it is not then I suspect a comment is required on
the -1 return.

Thoughts?

-apw

>From 5728c05fb669e8ee1e6d20fb7a71916362039411 Mon Sep 17 00:00:00 2001
From: Andy Whitcroft <apw@canonical.com>
Date: Mon, 31 Jan 2011 10:37:36 +0000
Subject: [PATCH] x25: drop packet on invalid facility headers

The commit below introduced additional checks for invalid facilities,
and a new return path when these were detected:

    commit a6331d6f9a4298173b413cf99a40cc86a9d92c37
    Author: andrew hendry <andrew.hendry@gmail.com>
    Date:   Wed Nov 3 12:54:53 2010 +0000

	memory corruption in X.25 facilities parsing

This new return path short circuits packet handling, the new return -1
below:

    static int x25_state1_machine(struct sock *sk, struct sk_buff *skb,
							    int frametype)
    {
    [...]
                        len = x25_parse_facilities(skb, &x25->facilities,
                                                &x25->dte_facilities,
                                                &x25->vc_facil_mask);
                        if (len > 0)
                                skb_pull(skb, len);
                        else
                                return -1;
    [...]

This return code is passed back up the chain (via x25_process_rx_frame)
and is interpreted as below by the caller:

    int x25_backlog_rcv(struct sock *sk, struct sk_buff *skb)
    {
        int queued = x25_process_rx_frame(sk, skb);

        if (!queued)
                kfree_skb(skb);

        return 0;
    }

Here we interpret the non-zero status as indicating the skb has been
requeued and should be preserved.  As we have not actually done so it
will be leaked.

Fix this up by indicating that the packet should be dropped.

Signed-off-by: Andy Whitcroft <apw@canonical.com>
---
 net/x25/x25_in.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index f729f02..213b93a 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -120,7 +120,7 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			if (len > 0)
 				skb_pull(skb, len);
 			else
-				return -1;
+				return 0;
 			/*
 			 *	Copy any Call User Data.
 			 */
-- 
1.7.1
