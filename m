From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmicro: stmac: do not grab a mutex in irq off section
Date: Wed, 26 Feb 2014 11:00:59 +0100
Message-ID: <530DBB5B.2030405@st.com>
References: <1392744843-6324-1-git-send-email-bigeasy@linutronix.de> <20140219.152328.351287968861448469.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@redhat.com>, <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:57193 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750799AbaBZKBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 05:01:16 -0500
In-Reply-To: <20140219.152328.351287968861448469.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/2014 9:23 PM, David Miller wrote:
> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Date: Tue, 18 Feb 2014 18:34:03 +0100
>

Re: [PATCH] net: stmicro: stmac: do not grab a mutex in irq off section
                          ^^^^^^^ stmmac

>> I captured this:
>>
>> |libphy: stmmac-0:04 - Link is Up - 1000/Full
>> |BUG: sleeping function called from invalid context at kernel/mutex.c:616
>> |in_atomic(): 1, irqs_disabled(): 128, pid: 31, name: kworker/1:1
>> |CPU: 1 PID: 31 Comm: kworker/1:1 Not tainted 3.12.0-00324-g28301d2-dirty #5
>> |[<8042f8e8>] (mutex_lock_nested+0x28/0x3cc) from [<802a226c>] (mdiobus_read+0x38/0x64)
>> |[<802a226c>] (mdiobus_read+0x38/0x64) from [<802a1968>] (genphy_update_link+0x18/0x50)
>> |[<802a1968>] (genphy_update_link+0x18/0x50) from [<802a19ac>] (genphy_read_status+0xc/0x180)
>> |[<802a19ac>] (genphy_read_status+0xc/0x180) from [<8029fb0c>] (phy_init_eee+0x4c/0x2ac)
>> |[<8029fb0c>] (phy_init_eee+0x4c/0x2ac) from [<802a7550>] (stmmac_eee_init+0x40/0x104)
>> |[<802a7550>] (stmmac_eee_init+0x40/0x104) from [<802a8678>] (stmmac_adjust_link+0x118/0x228)
>> |[<802a8678>] (stmmac_adjust_link+0x118/0x228) from [<802a0af4>] (phy_state_machine+0x23c/0x39c)
>> |[<802a0af4>] (phy_state_machine+0x23c/0x39c) from [<800371b8>] (process_one_work+0x1a4/0x44c)
>> |[<800371b8>] (process_one_work+0x1a4/0x44c) from [<80037884>] (worker_thread+0x138/0x390)
>> |[<80037884>] (worker_thread+0x138/0x390) from [<8003e850>] (kthread+0xb4/0xb8)
>> |[<8003e850>] (kthread+0xb4/0xb8) from [<8000e5a8>] (ret_from_fork+0x14/0x2c)
>> |stmmac: Energy-Efficient Ethernet initialized
>>
>> stmmac_eee_init() is called in other places without this lock.
>> phy_print_status() is just a printk() and the if condition is not
>> protected by the lock so I moved the unlock part just before that.
>>
>> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>
> It does look like a problem though, two concurrent calls into
> stmmac_eee_init would be really bad.  Two threads could see
> eee enabled being false at the same time, and both try to
> initialize the eee state.
>
> stmmac_hw_setup()'s invocation is fine because we doing something like
> bringing the device up or bringing it back after resume, and thus are
> synchonized by the RTNL semaphore.
>
> Actually, the same "mutex in irq off section" problem exists in that
> code path, because stmmac_resume() invokes stmmac_hw_setup() with
> the priv->lock held.
>
> This is a much deeper problem then what your patch is tackling, and
> thus a lot more thought about how to fix this is needed.

David, I will take care about this problem and provide a patch
in case of I realize the problem. I need to review the stmmac_hw_setup
function and suspend/resume and I will follow your advice.

Peppe

>
> I'm not applying this, sorry.
>
>
