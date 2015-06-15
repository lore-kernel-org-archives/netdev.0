From: subashab@codeaurora.org
Subject: [PATCH] rps: Handle double list_add at __napi_schedule
Date: Mon, 15 Jun 2015 21:46:38 -0000
Message-ID: <21d3b5e617ed44d217ce7f82e9fafa06.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55937 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbbFOVqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 17:46:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NAPI_STATE_SCHED state is not set, enqueue_to_backlog()
will queue an IPI and add the backlog queue to the poll list. A packet
added by RPS onto the core could also add the NAPI backlog struct to the
poll list. This double addition to the list causes a crash -

2920.540304:   <2> list_add double add: new=ffffffc076ed2930,
prev=ffffffc076ed2930, next=ffffffc076ed2850.
   [<ffffffc000460dd4>] __list_add+0xcc/0xf0
2921.064962:   <2> [<ffffffc000b44880>] rps_trigger_softirq+0x1c/0x40
2921.070779:   <2> [<ffffffc000284a14>]
generic_smp_call_function_single_interrupt+0xe8/0x12c
2921.078678:   <2> [<ffffffc00020d9ac>] handle_IPI+0x8c/0x1ec
2921.083796:   <2> [<ffffffc000200714>] gic_handle_irq+0x94/0xb0

Fix this race for double addition to list by checking the NAPI state.

Acked-by: Sharat Masetty <smasetty@qti.qualcomm.com>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f561de..57d6d39 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3225,7 +3225,8 @@ static void rps_trigger_softirq(void *data)
 {
        struct softnet_data *sd = data;

-       ____napi_schedule(sd, &sd->backlog);
+       if (!test_bit(NAPI_STATE_SCHED, &sd->backlog.state))
+               ____napi_schedule(sd, &sd->backlog);
        sd->received_rps++;
 }
