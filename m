From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 2/8] S2io: sw bug fixes
Date: Fri, 15 Oct 2004 14:52:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41701C61.2090109@pobox.com>
References: <200410141735.i9EHZJ39006121@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@s2io.com, "'Francois Romieu'" <romieu@fr.zoreil.com>,
        netdev@oss.sgi.com, leonid.grossman@s2io.com, rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Raghavendra Koushik <raghavendra.koushik@s2io.com>
In-Reply-To: <200410141735.i9EHZJ39006121@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Raghavendra Koushik wrote:
> As I said the s2io_close can be called from stack or by the reset task. If
> called from the task (or work) is it still Ok to flush all scheduled works?
[...]
> I believe the best way to restart the NIC is to call s2io_close and
> s2io_open sequentially.


Look at other drivers, e.g. drivers/net/tulip/tulip_core.c.  You will 
see two levels of functions:

	tulip_open() -- net stack dev->open() hook
	tulip_close() -- net stack dev->stop() hook

	tulip_up() -- reset-and-start-hardware helper function
	tulip_down() -- stop-hardware helper function

If S2IO follows this model, all good.

If you have both the net stack and your own code directly calling the 
net stack dev->stop() hook, that will lead to problems.  If you are 
doing this, you must _precisely duplicate_ the code in dev_close() in 
order to avoid races; but even then, you are really interfering with the 
code that synchronizes and manages reference-counted objects (struct 
net_device), which is unwise.

	Jeff
