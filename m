From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU
 related)
Date: Mon, 14 Nov 2016 15:09:27 -0800
Message-ID: <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33268 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934108AbcKNXJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 18:09:30 -0500
In-Reply-To: <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 14:46 -0800, Eric Dumazet wrote:
> On Mon, 2016-11-14 at 16:12 -0600, Eric W. Biederman wrote:
> 
> > synchronize_rcu_expidited is not enough if you have multiple network
> > devices in play.
> > 
> > Looking at the code it comes down to this commit, and it appears there
> > is a promise add rcu grace period combining by Eric Dumazet.
> > 
> > Eric since people are hitting noticable stalls because of the rcu grace
> > period taking a long time do you think you could look at this code path
> > a bit more?
> > 
> > commit 93d05d4a320cb16712bb3d57a9658f395d8cecb9
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Wed Nov 18 06:31:03 2015 -0800
> 
> Absolutely, I will take a loop asap.

The worst offender should be fixed by the following patch.

busy poll needs to poll the physical device, not a virtual one...

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
