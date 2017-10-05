From: "Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH 03/13] timer: Remove init_timer_on_stack() in favor of timer_setup_on_stack()
Date: Thu, 5 Oct 2017 15:18:32 +0200
Message-ID: <CAJZ5v0iMxSDj0gR0n3YF+zRvR3e2XHpiMR9hKjjon_EXSbB89w@mail.gmail.com>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org> <1507159627-127660-4-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Michael Reed <mdr@sgi.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Linux PM <linux-pm@vger.kernel.org>,
        linux1394-devel@lists.sourceforge.net, linux-s390@vger.kernel.org,
        "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>,
        Andrew Morton <akpm@lin
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-4-git-send-email-keescook@chromium.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, Oct 5, 2017 at 1:26 AM, Kees Cook <keescook@chromium.org> wrote:
> Remove uses of init_timer_on_stack() with open-coded function and data
> assignments that could be expressed using timer_setup_on_stack(). Several
> were removed from the stack entirely since there was a one-to-one mapping
> of parent structure to timer, those are switched to using timer_setup()
> instead. All related callbacks were adjusted to use from_timer().
>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Cc: Michael Reed <mdr@sgi.com>
> Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
> Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-pm@vger.kernel.org
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-s390@vger.kernel.org
> Cc: linux-scsi@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  drivers/base/power/main.c           |  8 +++-----
>  drivers/firewire/core-transaction.c | 10 +++++-----
>  drivers/parport/ieee1284.c          | 21 +++++++--------------
>  drivers/s390/char/tape.h            |  1 +
>  drivers/s390/char/tape_std.c        | 18 ++++++------------
>  drivers/s390/net/lcs.c              | 16 ++++++----------
>  drivers/s390/net/lcs.h              |  1 +
>  drivers/scsi/qla1280.c              | 14 +++++---------
>  drivers/scsi/qla1280.h              |  1 +
>  include/linux/parport.h             |  1 +
>  include/linux/timer.h               |  2 --
>  11 files changed, 36 insertions(+), 57 deletions(-)
>
> diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
> index 770b1539a083..ae47b2ec84b4 100644
> --- a/drivers/base/power/main.c
> +++ b/drivers/base/power/main.c
> @@ -478,9 +478,9 @@ struct dpm_watchdog {
>   * There's not much we can do here to recover so panic() to
>   * capture a crash-dump in pstore.
>   */
> -static void dpm_watchdog_handler(unsigned long data)
> +static void dpm_watchdog_handler(struct timer_list *t)
>  {
> -       struct dpm_watchdog *wd = (void *)data;
> +       struct dpm_watchdog *wd = from_timer(wd, t, timer);
>
>         dev_emerg(wd->dev, "**** DPM device timeout ****\n");
>         show_stack(wd->tsk, NULL);
> @@ -500,11 +500,9 @@ static void dpm_watchdog_set(struct dpm_watchdog *wd, struct device *dev)
>         wd->dev = dev;
>         wd->tsk = current;
>
> -       init_timer_on_stack(timer);
> +       timer_setup_on_stack(timer, dpm_watchdog_handler, 0);
>         /* use same timeout value for both suspend and resume */
>         timer->expires = jiffies + HZ * CONFIG_DPM_WATCHDOG_TIMEOUT;
> -       timer->function = dpm_watchdog_handler;
> -       timer->data = (unsigned long)wd;
>         add_timer(timer);
>  }

For the above:

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
