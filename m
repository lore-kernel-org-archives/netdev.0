From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: [Question]when work == weight in net_rx_action
Date: Tue, 6 Jan 2015 11:28:36 +0800
Message-ID: <CA+U0gVgRa2vXqB-47O9-W=ayEZ8PQXK85cz4hp8NJPbnt-n8Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39325 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbbAFD24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 22:28:56 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so13865498pdb.11
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 19:28:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in net_rx_action() function, I found that if the work done returned
from the n->poll() equal the weight, then it will enter the following
path:
if (unlikely(work == weight)) {
            if (unlikely(napi_disable_pending(n))) {
                local_irq_enable();
                napi_complete(n);
                local_irq_disable();
            } else {
                if (n->gro_list) {
                    /* flush too old packets
                     * If HZ < 1000, flush all packets.
                     */
                    local_irq_enable();
                    napi_gro_flush(n, HZ >= 1000);
                    local_irq_disable();
                }
                list_move_tail(&n->poll_list, &sd->poll_list);
            }
        }

suppose the napi instance is not disabled and n->gro_list = NULL, so
this function just moves the napi instance node to the tail of the
sd->poll_list, because the context here is device interrupt disabled,
is there any chance for the net_rx_action will be called again?

-- 
Den
