From: "Matan Barak (External)" <matanb@mellanox.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Wed, 15 Feb 2017 16:52:43 +0200
Message-ID: <82f68be0-95fb-0d61-9d0a-4c74afb626b5@mellanox.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Tariq Toukan" <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, <jackm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0085.outbound.protection.outlook.com ([104.47.0.85]:27904
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751352AbdBOOxL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 09:53:11 -0500
In-Reply-To: <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/2017 13:10, Saeed Mahameed wrote:
> On Fri, Feb 10, 2017 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> All rx and rx netdev interrupts are handled by respectively
>> by mlx4_en_rx_irq() and mlx4_en_tx_irq() which simply schedule a NAPI.
>>
>> But mlx4_eq_int() also fires a tasklet to service all items that were
>> queued via mlx4_add_cq_to_tasklet(), but this handler was not called
>> unless user cqe was handled.
>>
>> This is very confusing, as "mpstat -I SCPU ..." show huge number of
>> tasklet invocations.
>>
>> This patch saves this overhead, by carefully firing the tasklet directly
>> from mlx4_add_cq_to_tasklet(), removing four atomic operations per IRQ.
>>

So, in case of RDMA CQs, we add some per-CQE overhead of comparing the 
list pointers and condition upon that. Maybe we could add an 
invoke_tasklet boolean field on mlx4_cq and return its value from 
mlx4_cq_completion.
That's way we could do invoke_tasklet |= mlx4_cq_completion(....);

Outside the while loop we could just
if (invoke_tasklet)
     tasklet_schedule

Anyway, I guess that even with per-CQE overhead, the performance impact 
here is pretty negligible - so I guess that's fine too :)
