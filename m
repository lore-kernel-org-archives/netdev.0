From: Petr Mladek <pmladek@suse.cz>
Subject: Re: [PATCH 04/16] printk: implement support for extended console
 drivers
Date: Mon, 20 Apr 2015 17:43:07 +0200
Message-ID: <20150420154120.GA4589@pathway.suse.cz>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43456 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbbDTPlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 11:41:04 -0400
Content-Disposition: inline
In-Reply-To: <1429225433-11946-5-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu 2015-04-16 19:03:41, Tejun Heo wrote:
> printk log_buf keeps various metadata for each message including its
> sequence number and timestamp.  The metadata is currently available
> only through /dev/kmsg and stripped out before passed onto console
> drivers.  We want this metadata to be available to console drivers
> too.  Immediately, it's to implement reliable netconsole but may be
> useful for other console devices too.
> 
> This patch implements support for extended console drivers.  Consoles
> can indicate that they process extended messages by setting the new
> CON_EXTENDED flag and they'll fed messages formatted the same way as
> /dev/kmsg output as follows.
> 
>  <level>,<sequnum>,<timestamp>,<contflag>;<message text>
> 
> One special case is fragments.  Message fragments are output
> immediately to consoles to avoid losing them in case of crashes.  For
> normal consoles, this is handled by later suppressing the assembled
> result and /dev/kmsg only shows fully assembled message; however,
> extended consoles would need both the fragments, to avoid losing
> message in case of a crash, and the assembled result, to tell how the
> fragments are assembled and which sequence number got assigned to it.
> 
> To help matching up the fragments with the resulting message,
> fragments are emitted in the following format.
> 
>  <level>,-,<timestamp>,-,fragid=<fragid>;<message fragment>
> 
> And later when the assembly is complete, the following is transmitted,
> 
>  <level>,<sequnum>,<timestamp>,<contflag>,fragid=<fragid>;<message text>
> 
> * Extended message formatting for console drivers is enabled iff there
                                                               ^^^

s/iff/if/

>   are registered extended consoles.
> 
> * Comment describing extended message formats updated to help
>   distinguishing variable with verbatim terms.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Kay Sievers <kay@vrfy.org>
> Cc: Petr Mladek <pmladek@suse.cz>
> ---
>  include/linux/console.h |   1 +
>  kernel/printk/printk.c  | 141 +++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 123 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/console.h b/include/linux/console.h
> index 7571a16..04bbd09 100644
> --- a/include/linux/console.h
> +++ b/include/linux/console.h
> @@ -115,6 +115,7 @@ static inline int con_debug_leave(void)
>  #define CON_BOOT	(8)
>  #define CON_ANYTIME	(16) /* Safe to call when cpu is offline */
>  #define CON_BRL		(32) /* Used for a braille device */
> +#define CON_EXTENDED	(64) /* Use the extended output format a la /dev/kmsg */
>  
>  struct console {
>  	char	name[16];
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 0175c46..349a37b 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -84,6 +84,8 @@ static struct lockdep_map console_lock_dep_map = {
>  };
>  #endif
>  
> +static int nr_ext_console_drivers;
> +
>  /*
>   * Helper macros to handle lockdep when locking/unlocking console_sem. We use
>   * macros instead of functions so that _RET_IP_ contains useful information.
> @@ -195,14 +197,28 @@ static int console_may_schedule;
>   * need to be changed in the future, when the requirements change.
>   *
>   * /dev/kmsg exports the structured data in the following line format:
> - *   "level,sequnum,timestamp;<message text>\n"
> + *   "<level>,<sequnum>,<timestamp>,<contflag>;<message text>\n"
>   *
>   * The optional key/value pairs are attached as continuation lines starting
>   * with a space character and terminated by a newline. All possible
>   * non-prinatable characters are escaped in the "\xff" notation.
>   *
>   * Users of the export format should ignore possible additional values
> - * separated by ',', and find the message after the ';' character.
> + * separated by ',', and find the message after the ';' character. All
> + * optional header fields should have the form "<key>=<value>".
> + *
> + * For consoles with CON_EXTENDED set, a message formatted like the
> + * following may also be printed. This is a continuation fragment which are
> + * being assembled and will be re-transmitted with a normal header once
> + * assembly finishes. The fragments are sent out immediately to avoid
> + * losing them over a crash.
> + *   "<level>,-,<timestamp>,-,fragid=<fragid>;<message fragment>\n"
> + *
> + * On completion of assembly, the following is transmitted.
> + *   "<level>,<sequnum>,<timestamp>,<contflag>,fragid=<fragid>;<message text>\n"
> + *
> + * Extended consoles should identify and handle duplicates by matching the
> + * fragids of the fragments and assembled messages.
>   */
>  
>  enum log_flags {
> @@ -210,6 +226,7 @@ enum log_flags {
>  	LOG_NEWLINE	= 2,	/* text ended with a newline */
>  	LOG_PREFIX	= 4,	/* text started with a prefix */
>  	LOG_CONT	= 8,	/* text is a fragment of a continuation line */
> +	LOG_DICT_META	= 16,	/* dict contains console meta information */
>  };
>  
>  struct printk_log {
> @@ -292,6 +309,12 @@ static char *log_dict(const struct printk_log *msg)
>  	return (char *)msg + sizeof(struct printk_log) + msg->text_len;
>  }
>  
> +/* if LOG_DICT_META is set, the dict buffer carries printk internal info */
> +static size_t log_dict_len(const struct printk_log *msg)
> +{
> +	return (msg->flags & LOG_DICT_META) ? 0 : msg->dict_len;

We should document somewhere that the internal info and user-provided
dictionary newer could by stored in the same message.

It is because the internal info is used only with cont buffers.
And cont buffer is always stored into the log buffer separately,
see cont_flush() in vprintk_emit(). It took me a lot of time
to confirm this by reading the code.

> +}
> +
>  /* get record by index; idx must point to valid msg */
>  static struct printk_log *log_from_idx(u32 idx)
>  {
> @@ -516,7 +539,9 @@ static ssize_t msg_print_ext_header(char *buf, size_t size,
>  				    enum log_flags prev_flags)
>  {
>  	u64 ts_usec = msg->ts_nsec;
> +	u64 fragid;
>  	char cont = '-';
> +	char fragid_buf[32] = "";
>  
>  	do_div(ts_usec, 1000);
>  
> @@ -534,8 +559,14 @@ static ssize_t msg_print_ext_header(char *buf, size_t size,
>  		 ((prev_flags & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
>  		cont = '+';
>  
> -	return scnprintf(buf, size, "%u,%llu,%llu,%c;",
> -		       (msg->facility << 3) | msg->level, seq, ts_usec, cont);
> +	/* see cont_flush() */
> +	if ((msg->flags & LOG_DICT_META) && msg->dict_len &&
> +	    sscanf(log_dict(msg), "FRAGID=%llu", &fragid))

I was afraid that there might be a potential buffer overflow because
the user-provided dict need not be limited by '\0'. But LOG_DICT_META
is used only with the internal data that are safe. We might document
this as well.

BTW: Do you want to print the internal dict when calling this function
in devkmsg_read()?


> +		scnprintf(fragid_buf, sizeof(fragid_buf),
> +			  ",fragid=%llu", fragid);
> +	return scnprintf(buf, size, "%u,%llu,%llu,%c%s;",
> +			 (msg->facility << 3) | msg->level, seq, ts_usec, cont,
> +			 fragid_buf);

The above comment suggests that  "cont" and "fragid_buf" are delimited
by a comma but it is not used here. Is it by intention.

>  }
>  
>  static ssize_t msg_print_ext_body(char *buf, size_t size,
> @@ -688,7 +719,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
>  	len = msg_print_ext_header(user->buf, sizeof(user->buf),
>  				   msg, user->seq, user->prev);
>  	len += msg_print_ext_body(user->buf + len, sizeof(user->buf) - len,
> -				  log_dict(msg), msg->dict_len,
> +				  log_dict(msg), log_dict_len(msg),
>  				  log_text(msg), msg->text_len);
>  
>  	user->prev = msg->flags;
> @@ -1418,6 +1449,7 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
>   * The console_lock must be held.
>   */
>  static void call_console_drivers(int level, bool nocons,
> +				 const char *ext_text, size_t ext_len,
>  				 const char *text, size_t len)
>  {
>  	struct console *con;
> @@ -1440,13 +1472,16 @@ static void call_console_drivers(int level, bool nocons,
>  		    !(con->flags & CON_ANYTIME))
>  			continue;
>  		/*
> -		 * Skip record we have buffered and already printed
> -		 * directly to the console when we received it.
> +		 * For !ext consoles, skip record we have buffered and
> +		 * already printed directly when we received it.  Ext
> +		 * consoles are responsible for filtering on their ends.
>  		 */
> -		if (nocons)
> -			continue;
> -
> -		con->write(con, text, len);
> +		if (con->flags & CON_EXTENDED) {
> +			if (ext_len)
> +				con->write(con, ext_text, ext_len);
> +		} else if (!nocons) {
> +			con->write(con, text, len);
> +		}
>  	}
>  }
>  
> @@ -1546,6 +1581,7 @@ static inline void printk_delay(void)
>   */
>  static struct cont {
>  	char buf[LOG_LINE_MAX];
> +	u64 fragid;			/* unique fragment id */
>  	size_t len;			/* length == 0 means unused buffer */
>  	size_t cons;			/* bytes written to console */
>  	struct task_struct *owner;	/* task of first print*/
> @@ -1564,13 +1600,23 @@ static void cont_flush(enum log_flags flags)
>  		return;
>  
>  	if (cont.cons) {
> +		char dict_buf[32];
> +		size_t dict_len;
> +
>  		/*
>  		 * If a fragment of this line was directly flushed to the
>  		 * console; wait for the console to pick up the rest of the
> -		 * line. LOG_NOCONS suppresses a duplicated output.
> +		 * line. LOG_NOCONS suppresses a duplicated output for !ext
> +		 * consoles. ext consoles handle the duplicates themselves
> +		 * and expect fragid in the header of the duplicate
> +		 * messages for that. Record the fragid in the dict buffer
> +		 * which fragmented messages never use.
>  		 */
> -		log_store(cont.facility, cont.level, flags | LOG_NOCONS,
> -			  cont.ts_nsec, NULL, 0, cont.buf, cont.len);
> +		dict_len = scnprintf(dict_buf, sizeof(dict_buf), "FRAGID=%llu",
> +				     cont.fragid);
> +		log_store(cont.facility, cont.level,
> +			  flags | LOG_NOCONS | LOG_DICT_META,
> +			  cont.ts_nsec, dict_buf, dict_len, cont.buf, cont.len);

I wonder if it would make sense to restart fragid here. Another line
will get distinguished by "seqnum".

By other words, the first fragment for each seqnum would be "0".
The whole lines (without cont buffer) could always print "0".

Sigh, the whole mess is caused by the fact that we could not extend
struct printk_log easily. It would be much better if we could put
fragid there. I finally understand why you need to reuse the dict.


Sigh, it adds another twist into the already complex printk code.

Another solution would be to allow to disable the continuous buffer
via some boot option or /sys/kernel/debug entry if you want to debug
such a problem and have problem with the partial flushing.

Hmm, I wonder what are the typical values passed via "dict" and if we
need to handle this entry such a special way. It would make sense to
always print dict values to the ext consoles and handle this as a
yet another "normal" dict value. It would allow us to remove
some hacks at least.

Best Regards,
Petr



>  		cont.flags = flags;
>  		cont.flushed = true;
>  	} else {
> @@ -1596,6 +1642,9 @@ static bool cont_add(int facility, int level, const char *text, size_t len)
>  	}
>  
>  	if (!cont.len) {
> +		static u64 fragid;
> +
> +		cont.fragid = fragid++;
>  		cont.facility = facility;
>  		cont.level = level;
>  		cont.owner = current;
> @@ -1920,14 +1969,28 @@ static u32 log_first_idx;
>  static u64 log_next_seq;
>  static enum log_flags console_prev;
>  static struct cont {
> +	char buf[1];
> +	u64 fragid;
>  	size_t len;
>  	size_t cons;
> +	u64 ts_nsec;
>  	u8 level;
> +	u8 facility;
>  	bool flushed:1;
>  } cont;
> +static char *log_text(const struct printk_log *msg) { return NULL; }
> +static char *log_dict(const struct printk_log *msg) { return NULL; }
> +static size_t log_dict_len(const struct printk_log *msg) { return 0; }
>  static struct printk_log *log_from_idx(u32 idx) { return NULL; }
>  static u32 log_next(u32 idx) { return 0; }
> +static ssize_t msg_print_ext_header(char *buf, size_t size,
> +				    struct printk_log *msg, u64 seq,
> +				    enum log_flags prev_flags) { return 0; }
> +static ssize_t msg_print_ext_body(char *buf, size_t size,
> +				  char *dict, size_t dict_len,
> +				  char *text, size_t text_len) { return 0; }
>  static void call_console_drivers(int level, bool nocons,
> +				 const char *ext_text, size_t ext_len,
>  				 const char *text, size_t len) {}
>  static size_t msg_print_text(const struct printk_log *msg, enum log_flags prev,
>  			     bool syslog, char *buf, size_t size) { return 0; }
> @@ -2178,10 +2241,11 @@ int is_console_locked(void)
>  	return console_locked;
>  }
>  
> -static void console_cont_flush(char *text, size_t size)
> +static void console_cont_flush(char *ext_text, size_t ext_size,
> +			       char *text, size_t size)
>  {
>  	unsigned long flags;
> -	size_t len;
> +	size_t len, ext_len = 0;
>  
>  	raw_spin_lock_irqsave(&logbuf_lock, flags);
>  
> @@ -2196,10 +2260,30 @@ static void console_cont_flush(char *text, size_t size)
>  	if (console_seq < log_next_seq && !cont.cons)
>  		goto out;
>  
> +	/*
> +	 * Fragment dump for consoles. Will be printed again when the
> +	 * assembly is complete.
> +	 */
> +	if (nr_ext_console_drivers && cont.len > cont.cons) {
> +		u64 ts_usec = cont.ts_nsec;
> +
> +		do_div(ts_usec, 1000);
> +
> +		ext_len = scnprintf(ext_text, ext_size,
> +				    "%u,-,%llu,-,fragid=%llu;",
> +				    (cont.facility << 3) | cont.level, ts_usec,
> +				    cont.fragid);
> +		ext_len += msg_print_ext_body(ext_text + ext_len,
> +					      ext_size - ext_len, NULL, 0,
> +					      cont.buf + cont.cons,
> +					      cont.len - cont.cons);
> +	}
> +
>  	len = cont_print_text(text, size);
> +
>  	raw_spin_unlock(&logbuf_lock);
>  	stop_critical_timings();
> -	call_console_drivers(cont.level, false, text, len);
> +	call_console_drivers(cont.level, false, ext_text, ext_len, text, len);
>  	start_critical_timings();
>  	local_irq_restore(flags);
>  	return;
> @@ -2223,6 +2307,7 @@ out:
>   */
>  void console_unlock(void)
>  {
> +	static char ext_text[CONSOLE_EXT_LOG_MAX];
>  	static char text[LOG_LINE_MAX + PREFIX_MAX];
>  	static u64 seen_seq;
>  	unsigned long flags;
> @@ -2237,11 +2322,12 @@ void console_unlock(void)
>  	console_may_schedule = 0;
>  
>  	/* flush buffered message fragment immediately to console */
> -	console_cont_flush(text, sizeof(text));
> +	console_cont_flush(ext_text, sizeof(ext_text), text, sizeof(text));
>  again:
>  	for (;;) {
>  		struct printk_log *msg;
>  		size_t len;
> +		size_t ext_len = 0;
>  		int level;
>  		bool nocons;
>  
> @@ -2271,6 +2357,15 @@ again:
>  		nocons = msg->flags & LOG_NOCONS;
>  		len += msg_print_text(msg, console_prev, false,
>  				      text + len, sizeof(text) - len);
> +		if (nr_ext_console_drivers) {
> +			ext_len = msg_print_ext_header(ext_text,
> +						sizeof(ext_text),
> +						msg, console_seq, console_prev);
> +			ext_len += msg_print_ext_body(ext_text + ext_len,
> +						sizeof(ext_text) - ext_len,
> +						log_dict(msg), log_dict_len(msg),
> +						log_text(msg), msg->text_len);
> +		}
>  		console_idx = log_next(console_idx);
>  		console_seq++;
>  		console_prev = msg->flags;
> @@ -2285,7 +2380,8 @@ again:
>  		raw_spin_unlock(&logbuf_lock);
>  
>  		stop_critical_timings();	/* don't trace print latency */
> -		call_console_drivers(level, nocons, text, len);
> +		call_console_drivers(level, nocons,
> +				     ext_text, ext_len, text, len);
>  		start_critical_timings();
>  		local_irq_restore(flags);
>  	}
> @@ -2540,6 +2636,10 @@ void register_console(struct console *newcon)
>  		newcon->next = console_drivers->next;
>  		console_drivers->next = newcon;
>  	}
> +
> +	if (newcon->flags & CON_EXTENDED)
> +		nr_ext_console_drivers++;
> +
>  	if (newcon->flags & CON_PRINTBUFFER) {
>  		/*
>  		 * console_unlock(); will print out the buffered messages
> @@ -2612,6 +2712,9 @@ int unregister_console(struct console *console)
>  		}
>  	}
>  
> +	if (!res && (console->flags & CON_EXTENDED))
> +		nr_ext_console_drivers--;
> +
>  	/*
>  	 * If this isn't the last console and it has CON_CONSDEV set, we
>  	 * need to set it on the next preferred console.
> -- 
> 2.1.0
> 
