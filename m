From: "Matwey V. Kornilov" <matwey-TTlVxmypnbovJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH RFC] drivers: parport: Ask user for irqreturn_t value
Date: Sun, 28 Sep 2014 18:30:35 +0400
Message-ID: <CAJs94EbA0DhqQXXfYLh_k1fqn0gzn6YoBKNN6a-w4vSfZfM9Ng@mail.gmail.com>
References: <1411891335-3677-1-git-send-email-matwey@sai.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-parport <linux-parport-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	arnd <arnd-r2nGTMty4D4@public.gmane.org>, Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>,
	linux-i2c <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dmitry.torokhov" <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-input <linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"t.sailer" <t.sailer-aAjG49QhEdKVRmA6MYkXiA@public.gmane.org>,
	linux-hams <linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	linuxpps <linuxpps-fMOxgv769XvBG6Z5cez8fA@public.gmane.org>,
	"m.chehab" <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	linux-media <linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Matwey V. Kornilov" <matwey-TTlVxmypnbovJsYlp49lxw@public.gmane.org>
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411891335-3677-1-git-send-email-matwey-TTlVxmypnbovJsYlp49lxw@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Forget it, I invented something strange.

2014-09-28 12:02 GMT+04:00 Matwey V. Kornilov <matwey-TTlVxmypnbovJsYlp49lxw@public.gmane.org>:
> Current parport_irq_handler behaviour is not correct when IRQ is shared.
> LDDv3 on page 279 requires us:
>
> "Be sure to return IRQ_NONE whenever your handler is called and finds
> the device is not interrupting."
>
> This is not the case of parport_irq_handler.
> Current implementation of IRQ handling use this to optimize shared IRQ processing.
> When an action returns IRQ_HANDLED no other actions are processed.
>
> Modify callback function void (*irq_func)(void *) to irqreturn_t (*irq_func)(void *) and return the value in parport_irq_handler
>
> This also fixes https://bugzilla.kernel.org/show_bug.cgi?id=85221
>
> Signed-off-by: Matwey V. Kornilov <matwey-TTlVxmypnbovJsYlp49lxw@public.gmane.org>
> ---
>  drivers/char/ppdev.c                       |  4 +++-
>  drivers/i2c/busses/i2c-parport.c           |  5 ++++-
>  drivers/input/joystick/walkera0701.c       |  6 ++++--
>  drivers/net/hamradio/baycom_par.c          |  4 +++-
>  drivers/net/plip/plip.c                    |  8 +++++---
>  drivers/parport/share.c                    |  6 ++----
>  drivers/pps/clients/pps_parport.c          |  6 +++---
>  drivers/staging/media/lirc/lirc_parallel.c | 12 +++++++-----
>  include/linux/parport.h                    | 12 ++++++++----
>  9 files changed, 39 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/char/ppdev.c b/drivers/char/ppdev.c
> index ae0b42b..61fec51 100644
> --- a/drivers/char/ppdev.c
> +++ b/drivers/char/ppdev.c
> @@ -264,7 +264,7 @@ static ssize_t pp_write (struct file * file, const char __user * buf,
>         return bytes_written;
>  }
>
> -static void pp_irq (void *private)
> +static irqreturn_t pp_irq (void *private)
>  {
>         struct pp_struct *pp = private;
>
> @@ -275,6 +275,8 @@ static void pp_irq (void *private)
>
>         atomic_inc (&pp->irqc);
>         wake_up_interruptible (&pp->irq_wait);
> +
> +       return IRQ_HANDLED;
>  }
>
>  static int register_device (int minor, struct pp_struct *pp)
> diff --git a/drivers/i2c/busses/i2c-parport.c b/drivers/i2c/busses/i2c-parport.c
> index a27aae2..7549e10 100644
> --- a/drivers/i2c/busses/i2c-parport.c
> +++ b/drivers/i2c/busses/i2c-parport.c
> @@ -151,7 +151,7 @@ static const struct i2c_algo_bit_data parport_algo_data = {
>
>  /* ----- I2c and parallel port call-back functions and structures --------- */
>
> -static void i2c_parport_irq(void *data)
> +static irqreturn_t i2c_parport_irq(void *data)
>  {
>         struct i2c_par *adapter = data;
>         struct i2c_client *ara = adapter->ara;
> @@ -159,9 +159,12 @@ static void i2c_parport_irq(void *data)
>         if (ara) {
>                 dev_dbg(&ara->dev, "SMBus alert received\n");
>                 i2c_handle_smbus_alert(ara);
> +               return IRQ_HANDLED;
>         } else
>                 dev_dbg(&adapter->adapter.dev,
>                         "SMBus alert received but no ARA client!\n");
> +
> +       return IRQ_NONE;
>  }
>
>  static void i2c_parport_attach(struct parport *port)
> diff --git a/drivers/input/joystick/walkera0701.c b/drivers/input/joystick/walkera0701.c
> index b76ac58..f3903a6 100644
> --- a/drivers/input/joystick/walkera0701.c
> +++ b/drivers/input/joystick/walkera0701.c
> @@ -124,7 +124,7 @@ static inline int read_ack(struct pardevice *p)
>  }
>
>  /* falling edge, prepare to BIN value calculation */
> -static void walkera0701_irq_handler(void *handler_data)
> +static irqreturn_t walkera0701_irq_handler(void *handler_data)
>  {
>         u64 pulse_time;
>         struct walkera_dev *w = handler_data;
> @@ -136,7 +136,7 @@ static void walkera0701_irq_handler(void *handler_data)
>         /* cancel timer, if in handler or active do resync */
>         if (unlikely(0 != hrtimer_try_to_cancel(&w->timer))) {
>                 w->counter = NO_SYNC;
> -               return;
> +               return IRQ_HANDLED;
>         }
>
>         if (w->counter < NO_SYNC) {
> @@ -166,6 +166,8 @@ static void walkera0701_irq_handler(void *handler_data)
>                 w->counter = 0;
>
>         hrtimer_start(&w->timer, ktime_set(0, BIN_SAMPLE), HRTIMER_MODE_REL);
> +
> +       return IRQ_HANDLED;
>  }
>
>  static enum hrtimer_restart timer_handler(struct hrtimer
> diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
> index acb6369..1fd9a7b 100644
> --- a/drivers/net/hamradio/baycom_par.c
> +++ b/drivers/net/hamradio/baycom_par.c
> @@ -269,7 +269,7 @@ static __inline__ void par96_rx(struct net_device *dev, struct baycom_state *bc)
>
>  /* --------------------------------------------------------------------- */
>
> -static void par96_interrupt(void *dev_id)
> +static irqreturn_t par96_interrupt(void *dev_id)
>  {
>         struct net_device *dev = dev_id;
>         struct baycom_state *bc = netdev_priv(dev);
> @@ -292,6 +292,8 @@ static void par96_interrupt(void *dev_id)
>         hdlcdrv_transmitter(dev, &bc->hdrv);
>         hdlcdrv_receiver(dev, &bc->hdrv);
>          local_irq_disable();
> +
> +       return IRQ_HANDLED;
>  }
>
>  /* --------------------------------------------------------------------- */
> diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
> index 040b897..00a8b3a 100644
> --- a/drivers/net/plip/plip.c
> +++ b/drivers/net/plip/plip.c
> @@ -143,7 +143,7 @@ static void plip_bh(struct work_struct *work);
>  static void plip_timer_bh(struct work_struct *work);
>
>  /* Interrupt handler */
> -static void plip_interrupt(void *dev_id);
> +static irqreturn_t plip_interrupt(void *dev_id);
>
>  /* Functions for DEV methods */
>  static int plip_tx_packet(struct sk_buff *skb, struct net_device *dev);
> @@ -900,7 +900,7 @@ plip_error(struct net_device *dev, struct net_local *nl,
>  }
>
>  /* Handle the parallel port interrupts. */
> -static void
> +static irqreturn_t
>  plip_interrupt(void *dev_id)
>  {
>         struct net_device *dev = dev_id;
> @@ -919,7 +919,7 @@ plip_interrupt(void *dev_id)
>                 if ((dev->irq != -1) && (net_debug > 1))
>                         printk(KERN_DEBUG "%s: spurious interrupt\n", dev->name);
>                 spin_unlock_irqrestore (&nl->lock, flags);
> -               return;
> +               return IRQ_NONE;
>         }
>
>         if (net_debug > 3)
> @@ -948,6 +948,8 @@ plip_interrupt(void *dev_id)
>         }
>
>         spin_unlock_irqrestore(&nl->lock, flags);
> +
> +       return IRQ_HANDLED;
>  }
>
>  static int
> diff --git a/drivers/parport/share.c b/drivers/parport/share.c
> index 3fa6624..1fd8dc2 100644
> --- a/drivers/parport/share.c
> +++ b/drivers/parport/share.c
> @@ -523,7 +523,7 @@ void parport_remove_port(struct parport *port)
>  struct pardevice *
>  parport_register_device(struct parport *port, const char *name,
>                         int (*pf)(void *), void (*kf)(void *),
> -                       void (*irq_func)(void *),
> +                       irqreturn_t (*irq_func)(void *),
>                         int flags, void *handle)
>  {
>         struct pardevice *tmp;
> @@ -1006,9 +1006,7 @@ irqreturn_t parport_irq_handler(int irq, void *dev_id)
>  {
>         struct parport *port = dev_id;
>
> -       parport_generic_irq(port);
> -
> -       return IRQ_HANDLED;
> +       return parport_generic_irq(port);
>  }
>
>  /* Exported symbols for modules. */
> diff --git a/drivers/pps/clients/pps_parport.c b/drivers/pps/clients/pps_parport.c
> index 38a8bbe..9acf376 100644
> --- a/drivers/pps/clients/pps_parport.c
> +++ b/drivers/pps/clients/pps_parport.c
> @@ -64,7 +64,7 @@ static inline int signal_is_set(struct parport *port)
>  }
>
>  /* parport interrupt handler */
> -static void parport_irq(void *handle)
> +static irqreturn_t parport_irq(void *handle)
>  {
>         struct pps_event_time ts_assert, ts_clear;
>         struct pps_client_pp *dev = handle;
> @@ -122,7 +122,7 @@ out_assert:
>         /* fire assert event */
>         pps_event(dev->pps, &ts_assert,
>                         PPS_CAPTUREASSERT, NULL);
> -       return;
> +       return IRQ_HANDLED;
>
>  out_both:
>         /* fire assert event */
> @@ -131,7 +131,7 @@ out_both:
>         /* fire clear event */
>         pps_event(dev->pps, &ts_clear,
>                         PPS_CAPTURECLEAR, NULL);
> -       return;
> +       return IRQ_HANDLED;
>  }
>
>  static void parport_attach(struct parport *port)
> diff --git a/drivers/staging/media/lirc/lirc_parallel.c b/drivers/staging/media/lirc/lirc_parallel.c
> index 672858a..63fdc27 100644
> --- a/drivers/staging/media/lirc/lirc_parallel.c
> +++ b/drivers/staging/media/lirc/lirc_parallel.c
> @@ -219,7 +219,7 @@ static void rbuf_write(int signal)
>         wptr = nwptr;
>  }
>
> -static void lirc_lirc_irq_handler(void *blah)
> +static irqreturn_t lirc_lirc_irq_handler(void *blah)
>  {
>         struct timeval tv;
>         static struct timeval lasttv;
> @@ -230,10 +230,10 @@ static void lirc_lirc_irq_handler(void *blah)
>         unsigned int timeout;
>
>         if (!is_open)
> -               return;
> +               return IRQ_NONE;
>
>         if (!is_claimed)
> -               return;
> +               return IRQ_NONE;
>
>  #if 0
>         /* disable interrupt */
> @@ -241,7 +241,7 @@ static void lirc_lirc_irq_handler(void *blah)
>           out(LIRC_PORT_IRQ, in(LIRC_PORT_IRQ) & (~LP_PINTEN));
>  #endif
>         if (check_pselecd && (in(1) & LP_PSELECD))
> -               return;
> +               return IRQ_NONE;
>
>  #ifdef LIRC_TIMER
>         if (init) {
> @@ -265,7 +265,7 @@ static void lirc_lirc_irq_handler(void *blah)
>                          */
>                         timer = init_lirc_timer();
>                         /* enable_irq(irq); */
> -                       return;
> +                       return IRQ_HANDLED;
>                 }
>                 init = 1;
>         }
> @@ -314,6 +314,8 @@ static void lirc_lirc_irq_handler(void *blah)
>           enable_irq(irq);
>           out(LIRC_PORT_IRQ, in(LIRC_PORT_IRQ)|LP_PINTEN);
>         */
> +
> +       return IRQ_HANDLED;
>  }
>
>  /*** file operations ***/
> diff --git a/include/linux/parport.h b/include/linux/parport.h
> index c22f125..2ab774c 100644
> --- a/include/linux/parport.h
> +++ b/include/linux/parport.h
> @@ -141,7 +141,7 @@ struct pardevice {
>         int (*preempt)(void *);
>         void (*wakeup)(void *);
>         void *private;
> -       void (*irq_func)(void *);
> +       irqreturn_t (*irq_func)(void *);
>         unsigned int flags;
>         struct pardevice *next;
>         struct pardevice *prev;
> @@ -298,7 +298,7 @@ extern void parport_put_port (struct parport *);
>  struct pardevice *parport_register_device(struct parport *port,
>                           const char *name,
>                           int (*pf)(void *), void (*kf)(void *),
> -                         void (*irq_func)(void *),
> +                         irqreturn_t (*irq_func)(void *),
>                           int flags, void *handle);
>
>  /* parport_unregister unlinks a device from the chain. */
> @@ -429,13 +429,17 @@ extern void parport_daisy_deselect_all (struct parport *port);
>  extern int parport_daisy_select (struct parport *port, int daisy, int mode);
>
>  /* Lowlevel drivers _can_ call this support function to handle irqs.  */
> -static inline void parport_generic_irq(struct parport *port)
> +static inline irqreturn_t parport_generic_irq(struct parport *port)
>  {
> +       irqreturn_t ret = IRQ_NONE;
> +
>         parport_ieee1284_interrupt (port);
>         read_lock(&port->cad_lock);
>         if (port->cad && port->cad->irq_func)
> -               port->cad->irq_func(port->cad->private);
> +               ret = port->cad->irq_func(port->cad->private);
>         read_unlock(&port->cad_lock);
> +
> +       return ret;
>  }
>
>  /* Prototypes from parport_procfs */
> --
> 2.1.0
>



-- 
With best regards,
Matwey V. Kornilov.
Sternberg Astronomical Institute, Lomonosov Moscow State University, Russia
