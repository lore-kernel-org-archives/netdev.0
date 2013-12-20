From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] llc: fix checkpatch errors with space
Date: Thu, 19 Dec 2013 19:48:25 -0800
Message-ID: <1387511305.2353.34.camel@joe-AO722>
References: <1387509300-11940-1-git-send-email-chenweilong@huawei.com>
	 <1387509300-11940-2-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0069.hostedemail.com ([216.40.44.69]:40867 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751832Ab3LTDs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 22:48:28 -0500
In-Reply-To: <1387509300-11940-2-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 11:15 +0800, Chen Weilong wrote:
> From: Weilong Chen <chenweilong@huawei.com>
[]
> diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
> index 1a3c7e0..abf28eb 100644
> --- a/net/llc/llc_proc.c
> +++ b/net/llc/llc_proc.c
> @@ -142,7 +142,7 @@ static int llc_seq_socket_show(struct seq_file *seq, void *v)
>  	if (llc->dev)
>  		llc_ui_format_mac(seq, llc->dev->dev_addr);
>  	else {
> -		u8 addr[6] = {0,0,0,0,0,0};
> +		u8 addr[6] = {0, 0, 0, 0, 0, 0};
>  		llc_ui_format_mac(seq, addr);

No need to constantly reinitialize addr and the
static function llc_ui_format_mac is pretty useless.

Perhaps this instead?

Consolidate multiple seq_printfs to a single call.
Remove unnecessary llc_ui_format_mac and use %pM directly.

---
 net/llc/llc_proc.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 1a3c7e0..f264038 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -26,11 +26,6 @@
 #include <net/llc_c_st.h>
 #include <net/llc_conn.h>
 
-static void llc_ui_format_mac(struct seq_file *seq, u8 *addr)
-{
-	seq_printf(seq, "%pM", addr);
-}
-
 static struct sock *llc_get_sk_idx(loff_t pos)
 {
 	struct llc_sap *sap;
@@ -125,6 +120,7 @@ static void llc_seq_stop(struct seq_file *seq, void *v)
 
 static int llc_seq_socket_show(struct seq_file *seq, void *v)
 {
+	static const u8 null_addr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 	struct sock* sk;
 	struct llc_sock *llc;
 
@@ -137,17 +133,11 @@ static int llc_seq_socket_show(struct seq_file *seq, void *v)
 	llc = llc_sk(sk);
 
 	/* FIXME: check if the address is multicast */
-	seq_printf(seq, "%2X  %2X ", sk->sk_type, 0);
-
-	if (llc->dev)
-		llc_ui_format_mac(seq, llc->dev->dev_addr);
-	else {
-		u8 addr[6] = {0,0,0,0,0,0};
-		llc_ui_format_mac(seq, addr);
-	}
-	seq_printf(seq, "@%02X ", llc->sap->laddr.lsap);
-	llc_ui_format_mac(seq, llc->daddr.mac);
-	seq_printf(seq, "@%02X %8d %8d %2d %3u %4d\n", llc->daddr.lsap,
+	seq_printf(seq, "%2X  %2X %pM@%02X %pM@%02X %8d %8d %2d %3u %4d\n",
+		   sk->sk_type, 0,
+		   llc->dev ? llc->dev->dev_addr : null_addr,
+		   llc->sap->laddr.lsap,
+		   llc->daddr.mac, llc->daddr.lsap,
 		   sk_wmem_alloc_get(sk),
 		   sk_rmem_alloc_get(sk) - llc->copied_seq,
 		   sk->sk_state,
