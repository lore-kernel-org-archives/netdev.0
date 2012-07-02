From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwlegacy: print how long queue was actually stuck
Date: Mon, 2 Jul 2012 11:06:17 +0200
Message-ID: <20120702090602.GA8286@redhat.com>
References: <1340786187.1911.24.camel@x61.thuisdomein>
 <1341062406.1911.76.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932689Ab2GBJGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 05:06:38 -0400
Content-Disposition: inline
In-Reply-To: <1341062406.1911.76.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 30, 2012 at 03:20:06PM +0200, Paul Bolle wrote:
> On Wed, 2012-06-27 at 10:36 +0200, Paul Bolle wrote:
> > Every now and then, after resuming from suspend, the iwlegacy driver
> > prints
> >     iwl4965 0000:03:00.0: Queue 2 stuck for 2000 ms.
> >     iwl4965 0000:03:00.0: On demand firmware reload
> > 
> > I have no idea what causes these errors. But the code currently uses
> > wd_timeout in the first error. wd_timeout will generally be set at
> > IL_DEF_WD_TIMEOUT (ie, 2000). Perhaps printing for how long the queue
> > was actually stuck can clarify the cause of these errors.
> 
> 0) It's not just after resume! I just found the following lines through
> dmesg (note that it's a period that all messages in dmesg were wlan
> related, for some reason):
> 
> [115840.219977] wlan0: authenticate with [...]
> [115840.228865] wlan0: send auth to [...] (try 1/3)
> [115840.429054] wlan0: send auth to [...] (try 2/3)
> [115840.630026] wlan0: send auth to [...] (try 3/3)
> [115840.831051] wlan0: authentication with [...] timed out
> [115848.022336] wlan0: authenticate with [...]
> [115848.022495] wlan0: direct probe to [...] (try 1/3)
> [115848.223052] wlan0: direct probe to [...] (try 2/3)
> [115848.424052] wlan0: direct probe to [...] (try 3/3)
> [115848.625048] wlan0: authentication with [...] timed out
> [115855.702461] wlan0: authenticate with [...]
> [115855.702623] wlan0: direct probe to [...] (try 1/3)
> [115855.903053] wlan0: direct probe to [...] (try 2/3)
> [115856.104061] wlan0: direct probe to [...] (try 3/3)
> [115856.305050] wlan0: authentication with [...] timed out
> [115863.464067] wlan0: authenticate with [...]
> [115863.464221] wlan0: direct probe to [...] (try 1/3)
> [115863.665054] wlan0: direct probe to [...] (try 2/3)
> [115863.866058] wlan0: direct probe to [...] (try 3/3)
> [115864.067051] wlan0: authentication with [...] timed out
> [115871.267216] wlan0: authenticate with [...]
> [115871.267376] wlan0: send auth to [...] (try 1/3)
> [115871.269191] wlan0: authenticated
> [115871.279459] wlan0: associate with [...] (try 1/3)
> [115871.281715] wlan0: RX AssocResp from [...] (capab=0x411 status=0 aid=2)
> [115871.281723] wlan0: associated
> [115871.457043] iwl4965 0000:03:00.0: Queue 2 stuck for 33487 ms.
> [115871.457048] iwl4965 0000:03:00.0: On demand firmware reload
For some reason we are not able to authenticate, what itself is a
problem. Maybe this is wrong key offset problem and that will
be fixed by Emmanuel patch.

Regarding "Queue 2 stuck", there is another fix in iwlwifi that
did not make to iwlegacy, which perhaps could help. If not here
then maybe on suspend.  

commit 342bbf3fee2fa9a18147e74b2e3c4229a4564912
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Sun Mar 4 08:50:46 2012 -0800

    iwlwifi: always monitor for stuck queues

I'm attaching iwlegacy version of it.

> 2) It's always "Queue 2" that's stuck. What does that queue do?

It's TX queue, probably one used for default traffic i.e. for Best
Effort category (others are Video, Voice and Background).

Stanislaw

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="iwlegacy-allways-monitor-for-stuck-queues.patch"

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index cbf2dc1..5d4807c 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4767,14 +4767,12 @@ il_bg_watchdog(unsigned long data)
 		return;
 
 	/* monitor and check for other stuck queues */
-	if (il_is_any_associated(il)) {
-		for (cnt = 0; cnt < il->hw_params.max_txq_num; cnt++) {
-			/* skip as we already checked the command queue */
-			if (cnt == il->cmd_queue)
-				continue;
-			if (il_check_stuck_queue(il, cnt))
-				return;
-		}
+	for (cnt = 0; cnt < il->hw_params.max_txq_num; cnt++) {
+		/* skip as we already checked the command queue */
+		if (cnt == il->cmd_queue)
+			continue;
+		if (il_check_stuck_queue(il, cnt))
+			return;
 	}
 
 	mod_timer(&il->watchdog,

--r5Pyd7+fXNt84Ff3--
