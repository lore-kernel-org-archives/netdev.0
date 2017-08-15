From: Anton Volkov <avolkov@ispras.ru>
Subject: Possible race in c4.ko
Date: Tue, 15 Aug 2017 16:22:16 +0300
Message-ID: <b839c418-9c1d-aba7-4d00-e9c7786870bf@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org,
        Alexey Khoroshilov <khoroshilov@ispras.ru>
To: isdn@linux-pingi.de, davem@davemloft.net, calle@calle.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:45372 "EHLO mail.ispras.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750859AbdHONWS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 09:22:18 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

While searching for races in the Linux kernel I've come across 
"drivers/isdn/hardware/avm/c4.ko" module. Here is a question that I came 
up with while analyzing results. Lines are given using the info from 
Linux v4.12.

Consider the following case:

Thread 1:                  Thread 2:
c4_probe
->c4_add_card
     request_irq()
                            c4_interrupt
                            ->c4_handle_interrupt
                              ->c4_handle_rx
     card->cardnr = ...         cidx = f(card->cardnr)
     (c4.c: line 1227)          (c4.c: line 526)
                                if (cidx >= card->nlogcontr) cidx = 0;
                                ctrl = &card->ctrlinfo[cidx].capi_ctrl

card->cardnr is 0 until it is initialized in c4_add_card(). If at the 
moment of read access in c4_handle_rx() it is still 0, cidx may then be 
assigned an undesirable value and wrong controller may handle messages. 
Is this case feasible from your point of view?

Thank you for your time.

-- Anton Volkov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: avolkov@ispras.ru
