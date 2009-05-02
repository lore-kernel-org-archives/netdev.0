From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 3/5] initdev:kernel: Await console discovery, v5
Date: Sat, 2 May 2009 11:38:25 +0800
Message-ID: <20090502113825.11bc7876@linux-lm>
References: <20090502022756.GA15838@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:26666 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbZEBDii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 23:38:38 -0400
In-Reply-To: <20090502022756.GA15838@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1 May 2009 19:27:56 -0700
David VomLehn <dvomlehn@cisco.com> wrote:

> The patch has been re-written to use the init device synchronization
> infrastructure. This ensures that we can detect console
> initialization when the devices become available, as well as
> determining that no console is attached at boot time.
> 
> History
> v5	Change bootdev_* to initdev_*.
> v4	Use new hotplug synchronization infrastructure. Include
> Braille console support.
> v3.2	Use only a single new command line parameter by adding
> the possible value "forever".  Add message specifying the parameter
> to modify to increase the delay for console initialization
> v3.1	Correct the abbreviation for milliseconds in
> 	Documentation/kernel-parameters.txt to be "ms", not "mS".
> Thanks to Peter Anvin for this.
> v3	Increase the default delay to 1 second and add kernel
> command line parameters to override the default delay. Thanks to
> David Brownell for his helpful suggestions.
> v2	Wait for the preferred console rather than any console.
> Make the delay interval a tunable.
> v1	Initial version
> 
> Signed-off-by: David VomLehn <dvomlehn@cisco.com>
> ---
>  drivers/accessibility/braille/braille_console.c |    3 ++
>  kernel/printk.c                                 |   29
> ++++++++++++++++++++++- 2 files changed, 31 insertions(+), 1
> deletions(-)
> 
> diff --git a/drivers/accessibility/braille/braille_console.c
> b/drivers/accessibility/braille/braille_console.c index
> d672cfe..4420ac3 100644 ---
> a/drivers/accessibility/braille/braille_console.c +++
> b/drivers/accessibility/braille/braille_console.c @@ -35,6 +35,7 @@
>  #include <linux/keyboard.h>
>  #include <linux/kbd_kern.h>
>  #include <linux/input.h>
> +#include <linux/initdev.h>
>  
>  MODULE_AUTHOR("samuel.thibault@ens-lyon.org");
>  MODULE_DESCRIPTION("braille device");
> @@ -378,6 +379,8 @@ int braille_register_console(struct console
> *console, int index, braille_co = console;
>  	register_keyboard_notifier(&keyboard_notifier_block);
>  	register_vt_notifier(&vt_notifier_block);
> +
> +	initdev_register(BOOTDEV_CONSOLE);

Should it be initdev_registered(BOOTDEV_CONSOLE)?


>  	return 0;
>  }
>  
> diff --git a/kernel/printk.c b/kernel/printk.c
> index 5052b54..e6a9379 100644
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
> @@ -33,6 +33,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/syscalls.h>
>  #include <linux/kexec.h>
> +#include <linux/device.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -1075,8 +1076,10 @@ void console_unblank(void)
>  
>  /*
>   * Return the console tty driver structure and its associated index
> + * @index:	Pointer to the device index
> + * Returns NULL if no driver available, otherwise a pointer to the
> TTY driver. */
> -struct tty_driver *console_device(int *index)
> +struct tty_driver *_console_device(int *index)
>  {
>  	struct console *c;
>  	struct tty_driver *driver = NULL;
> @@ -1094,6 +1097,29 @@ struct tty_driver *console_device(int *index)
>  }
>  
>  /*
> + * Returns true if all specific consoles are registered, false
> otherwise
> + */
> +static bool have_all_consoles(void)
> +{
> +	struct tty_driver *driver;
> +	int		index;
> +
> +	driver = _console_device(&index);
> +
> +	return driver != NULL;
> +}
> +
> +struct tty_driver *console_device(int *index)
> +{
> +	struct tty_driver *driver;
> +	initdev_wait(BOOTDEV_CONSOLE, have_all_consoles);
> +
> +	driver = _console_device(index);
> +
> +	return driver;
> +}
> +
> +/*
>   * Prevent further output on the passed console device so that (for
> example)
>   * serial drivers can disable console output before suspending a
> port, and can
>   * re-enable output afterwards.
> @@ -1230,6 +1256,7 @@ void register_console(struct console *console)
>  		spin_unlock_irqrestore(&logbuf_lock, flags);
>  	}
>  	release_console_sem();
> +	initdev_registered(BOOTDEV_CONSOLE);
>  }
>  EXPORT_SYMBOL(register_console);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi"
> in the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Lei Ming
