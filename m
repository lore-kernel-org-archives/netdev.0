From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/04: nf_ct_ftp: fix out of bounds read in update_nl_seq()
Date: Fri,  8 Jan 2010 17:42:12 +0100 (MET)
Message-ID: <20100108164208.28066.62669.sendpatchset@x2.localnet>
References: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit aaff23a95aea5f000895f50d90e91f1e2f727002
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 7 18:33:18 2010 +0100

    netfilter: nf_ct_ftp: fix out of bounds read in update_nl_seq()
    
    As noticed by Dan Carpenter <error27@gmail.com>, update_nl_seq()
    currently contains an out of bounds read of the seq_aft_nl array
    when looking for the oldest sequence number position.
    
    Fix it to only compare valid positions.
    
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 38ea7ef..f0732aa 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -323,24 +323,24 @@ static void update_nl_seq(struct nf_conn *ct, u32 nl_seq,
 			  struct nf_ct_ftp_master *info, int dir,
 			  struct sk_buff *skb)
 {
-	unsigned int i, oldest = NUM_SEQ_TO_REMEMBER;
+	unsigned int i, oldest;
 
 	/* Look for oldest: if we find exact match, we're done. */
 	for (i = 0; i < info->seq_aft_nl_num[dir]; i++) {
 		if (info->seq_aft_nl[dir][i] == nl_seq)
 			return;
-
-		if (oldest == info->seq_aft_nl_num[dir] ||
-		    before(info->seq_aft_nl[dir][i],
-			   info->seq_aft_nl[dir][oldest]))
-			oldest = i;
 	}
 
 	if (info->seq_aft_nl_num[dir] < NUM_SEQ_TO_REMEMBER) {
 		info->seq_aft_nl[dir][info->seq_aft_nl_num[dir]++] = nl_seq;
-	} else if (oldest != NUM_SEQ_TO_REMEMBER &&
-		   after(nl_seq, info->seq_aft_nl[dir][oldest])) {
-		info->seq_aft_nl[dir][oldest] = nl_seq;
+	} else {
+		if (before(info->seq_aft_nl[dir][0], info->seq_aft_nl[dir][1]))
+			oldest = 0;
+		else
+			oldest = 1;
+
+		if (after(nl_seq, info->seq_aft_nl[dir][oldest]))
+			info->seq_aft_nl[dir][oldest] = nl_seq;
 	}
 }
 
