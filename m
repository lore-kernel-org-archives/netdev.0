From: Patrick McHardy <kaber@trash.net>
Subject: Re: off by one in update_nl_seq()
Date: Tue, 05 Jan 2010 08:43:24 +0100
Message-ID: <4B42ED9C.6070304@trash.net>
References: <20091227131229.GH6075@bicker>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050805020004060408090803"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091227131229.GH6075@bicker>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050805020004060408090803
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Dan Carpenter wrote:
> net/netfilter/nf_conntrack_ftp.c
>    321  /* We don't update if it's older than what we have. */
>    322  static void update_nl_seq(struct nf_conn *ct, u32 nl_seq,
>    323                            struct nf_ct_ftp_master *info, int dir,
>    324                            struct sk_buff *skb)
>    325  {
>    326          unsigned int i, oldest = NUM_SEQ_TO_REMEMBER;
> 
> Should this be oldest = NUM_SEQ_TO_REMEMBER - 1;?  The array is 
> defined as:
> u_int32_t seq_aft_nl[IP_CT_DIR_MAX][NUM_SEQ_TO_REMEMBER];

That would break the logic further down below.

>    327
>    328          /* Look for oldest: if we find exact match, we're done. */
>    329          for (i = 0; i < info->seq_aft_nl_num[dir]; i++) {
>    330                  if (info->seq_aft_nl[dir][i] == nl_seq)
>    331                          return;
>    332
>    333                  if (oldest == info->seq_aft_nl_num[dir] ||
>    334                      before(info->seq_aft_nl[dir][i],
>    335                             info->seq_aft_nl[dir][oldest]))  
> 
> Line 335 has the possible array out of bounds I am concerned about. 

Good catch, this is definitely a bug. The entire function seems
overly complicated to select one of two possible positions. I'll
commit the attached patch to fix this after some testing.


--------------050805020004060408090803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 38ea7ef..44b8d67 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -323,24 +323,25 @@ static void update_nl_seq(struct nf_conn *ct, u32 nl_seq,
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
+		if (before(info->seq_aft_nl[dir][0],
+			   info->seq_aft_nl[dir][1]))
+			oldest = 0;
+		else
+			oldest = 1;
+
+		if (after(nl_seq, info->seq_aft_nl[dir][oldest]))
+			info->seq_aft_nl[dir][oldest] = nl_seq;
 	}
 }
 

--------------050805020004060408090803--
