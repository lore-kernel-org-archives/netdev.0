From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gro_cells: mark napi struct as not busy poll candidates
Date: Mon, 14 Nov 2016 16:28:42 -0800
Message-ID: <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
         <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
         <20161110212404.GB4127@linux.vnet.ibm.com>
         <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
         <20161112002347.GL4127@linux.vnet.ibm.com>
         <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
         <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
         <20161114162417.GJ4127@linux.vnet.ibm.com>
         <CAM_iQpXL+JaVG86+h2ucYs4Dm0zJKHq+4Nm+gk75wESGOzTmJQ@mail.gmail.com>
         <20161114181425.GN4127@linux.vnet.ibm.com> <87y40lhfrt.fsf@xmission.com>
         <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35568 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752852AbcKOAl1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 19:41:27 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so10224917pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 16:41:27 -0800 (PST)
In-Reply-To: <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Rolf Neugebauer reported very long delays at netns dismantle.

Eric W. Biederman was kind enough to look at this problem
and noticed synchronize_net() occurring from netif_napi_del() that was
added in linux-4.5

Busy polling makes no sense for tunnels NAPI.
If busy poll is used for sessions over tunnels, the poller will need to
poll the physical device queue anyway.

netif_tx_napi_add() could be used here, but function name is misleading,
and renaming it is not stable material, so set NAPI_STATE_NO_BUSY_POLL
bit directly.

This will avoid inserting gro_cells napi structures in napi_hash[]
and avoid the problematic synchronize_net() (per possible cpu) that
Rolf reported.

Fixes: 93d05d4a320c ("net: provide generic busy polling to all NAPI drivers")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
Reported-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/gro_cells.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index d15214d673b2e8e08fd6437b572278fb1359f10d..2a1abbf8da74368cd01adc40cef6c0644e059ef2 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -68,6 +68,9 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
 		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
 
 		__skb_queue_head_init(&cell->napi_skbs);
+
+		set_bit(NAPI_STATE_NO_BUSY_POLL, &cell->napi.state);
+
 		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
 		napi_enable(&cell->napi);
 	}
