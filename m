From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 2/8] S2io: sw bug fixes
Date: Thu, 14 Oct 2004 10:44:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E90C5.2090307@pobox.com>
References: <004201c4b18b$14b2f720$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <004201c4b18b$14b2f720$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Hi,
> Attached is the second patch in this submission. It contains the following
> software bug fixes.
> 
> 1. In free_rx_buffers clearing out RxDs not owned by Xena.
> 
> 2. In alarm_intr_handler, when a serr error occurs, schedule a task to reset
> the card rather than stopping Tx queue.
> 
> 3. In s2io_close freeing IRQ before calling s2io_reset also added a new call
> to flush queued tasks. This is not done if the s2io_close itself is called
> from a queued task like s2io_restart_nic.
> 
> 4. read_eeprom function has been changed such that data to be returned is
> sent as an input argument and the return value represents a pass/fail. The
> previous implementation as Randy had pointed out was error prone as on
> failure it returned -1 which can be interpreted as all ff's, so any data
> area which contained ff's in the eeprom was likely to be treated as an
> error.
> 
> 5. Added a flag "task_flag" to track if the call to s2io_close is coming
> from the s2io_restart_nic function or from the ifconfig <I/F> down called by
> user.
> 
> 6. Moved register_netdev call from just after setting entry points to the
> end of the s2io_init_nic function.
> 
> 7. In s2io.h field added a new member into the s2io_nic structure called
> "task_flag".
> 
> 
> Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>


Comments:

1) the following code looks wrong:

>                 DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
>                 DBG_PRINT(ERR_DBG, "serious error!!\n");
> -               netif_stop_queue(dev);
> +               schedule_work(&nic->rst_timer_task);

Typically you want to stop the queue _and_ schedule_work().  Otherwise, 
the net stack will continually call your ->hard_start_xmit() hook with 
new skbs, _during_ your rst_timer_task.

2) can this 'if' test be removed?  there is no harm in unconditionally 
calling flush_scheduled_work()

> +       /* Flush all scheduled tasks */
> +       if (sp->task_flag == 1) {
> +               DBG_PRINT(INFO_DBG, "%s: Calling close from a task\n",
> +                         dev->name);
> +       } else {
> +               flush_scheduled_work();
> +       }

3) I do not think that s2io_close should be called from anywhere except 
the net stack...

The following code should not be needed, unless I am missing something:
> 
>         nic_t *sp = dev->priv;
>  
> +       sp->task_flag = 1;
>         s2io_close(dev);
> +       sp->task_flag = 0;
>         sp->device_close_flag = TRUE;


4) the following code is correct, but should additional propagate the 
register_netdev() error code back to its caller, upon failure:

>         sp->rx_csum = 1;        /* Rx chksum verify enabled by default */
>  
> +       if (register_netdev(dev)) {
> +               DBG_PRINT(ERR_DBG, "Device registration failed\n");
> +               goto register_failed;
> +       }
> +
