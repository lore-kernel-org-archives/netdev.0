From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Mon, 16 Jun 2008 23:34:18 +0200
Message-ID: <20080616213417.GA14988@ami.dom.local>
References: <1213446954.17870.154.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Graf <tgraf@suug.ch>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:21578 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755852AbYFPVcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:32:47 -0400
Received: by ug-out-1314.google.com with SMTP id h2so471377ugf.16
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 14:32:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1213446954.17870.154.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote, On 06/14/2008 02:35 PM:
...
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.26-rc2 #5
> -------------------------------------------------------
> hcid/4136 is trying to acquire lock:
>  (genl_mutex){--..}, at: [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174
> 
> but task is already holding lock:
>  (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c
> 
> which lock already depends on the new lock.
...

Hi,

IMHO it looks like a real lockup threat. Probably it needs something
better, but for now here is my simplistic patch proposal for testing.

Thanks,
Jarek P.

---

 net/netlink/genetlink.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f5aa23c..bf939ba 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -32,6 +32,11 @@ static inline void genl_unlock(void)
 	mutex_unlock(&genl_mutex);
 }
 
+static inline int genl_trylock(void)
+{
+	return mutex_trylock(&genl_mutex);
+}
+
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
@@ -603,8 +608,9 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
-	if (chains_to_skip != 0)
-		genl_lock();
+	/* genl_lock vs. cb_mutex inversion threatens here */
+	if (chains_to_skip != 0 && !genl_trylock())
+		return skb->len;
 
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
