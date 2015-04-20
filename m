From: Petr Mladek <pmladek@suse.cz>
Subject: Re: [PATCH 02/16] printk: factor out message formatting from
 devkmsg_read()
Date: Mon, 20 Apr 2015 14:30:12 +0200
Message-ID: <20150420123012.GF4368@pathway.suse.cz>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429225433-11946-3-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2015-04-16 19:03:39, Tejun Heo wrote:
> The extended message formatting used for /dev/kmsg will be used
> implement extended consoles.  Factor out msg_print_ext_header() and
> msg_print_ext_body() from devkmsg_read().
> 
> This is pure restructuring.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Reviewed-by: Petr Mladek <pmladek@suse.cz>

I like the split of the long function.

Best Regards,
Petr

> Cc: Kay Sievers <kay@vrfy.org>
> Cc: Petr Mladek <pmladek@suse.cz>
> ---
>  kernel/printk/printk.c | 157 ++++++++++++++++++++++++++-----------------------
>  1 file changed, 85 insertions(+), 72 deletions(-)
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index b6e24af..5ea6709 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -505,6 +505,86 @@ int check_syslog_permissions(int type, bool from_file)
>  	return security_syslog(type);
>  }
>  
> +static void append_char(char **pp, char *e, char c)
> +{
> +	if (*pp < e)
> +		*(*pp)++ = c;
> +}
> +
> +static ssize_t msg_print_ext_header(char *buf, size_t size,
> +				    struct printk_log *msg, u64 seq,
> +				    enum log_flags prev_flags)
> +{
> +	u64 ts_usec = msg->ts_nsec;
> +	char cont = '-';
> +
> +	do_div(ts_usec, 1000);
> +
> +	/*
> +	 * If we couldn't merge continuation line fragments during the print,
> +	 * export the stored flags to allow an optional external merge of the
> +	 * records. Merging the records isn't always neccessarily correct, like
> +	 * when we hit a race during printing. In most cases though, it produces
> +	 * better readable output. 'c' in the record flags mark the first
> +	 * fragment of a line, '+' the following.
> +	 */
> +	if (msg->flags & LOG_CONT && !(prev_flags & LOG_CONT))
> +		cont = 'c';
> +	else if ((msg->flags & LOG_CONT) ||
> +		 ((prev_flags & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
> +		cont = '+';
> +
> +	return scnprintf(buf, size, "%u,%llu,%llu,%c;",
> +		       (msg->facility << 3) | msg->level, seq, ts_usec, cont);
> +}
> +
> +static ssize_t msg_print_ext_body(char *buf, size_t size,
> +				  char *dict, size_t dict_len,
> +				  char *text, size_t text_len)
> +{
> +	char *p = buf, *e = buf + size;
> +	size_t i;
> +
> +	/* escape non-printable characters */
> +	for (i = 0; i < text_len; i++) {
> +		unsigned char c = text[i];
> +
> +		if (c < ' ' || c >= 127 || c == '\\')
> +			p += scnprintf(p, e - p, "\\x%02x", c);
> +		else
> +			append_char(&p, e, c);
> +	}
> +	append_char(&p, e, '\n');
> +
> +	if (dict_len) {
> +		bool line = true;
> +
> +		for (i = 0; i < dict_len; i++) {
> +			unsigned char c = dict[i];
> +
> +			if (line) {
> +				append_char(&p, e, ' ');
> +				line = false;
> +			}
> +
> +			if (c == '\0') {
> +				append_char(&p, e, '\n');
> +				line = true;
> +				continue;
> +			}
> +
> +			if (c < ' ' || c >= 127 || c == '\\') {
> +				p += scnprintf(p, e - p, "\\x%02x", c);
> +				continue;
> +			}
> +
> +			append_char(&p, e, c);
> +		}
> +		append_char(&p, e, '\n');
> +	}
> +
> +	return p - buf;
> +}
>  
>  /* /dev/kmsg - userspace message inject/listen interface */
>  struct devkmsg_user {
> @@ -565,30 +645,17 @@ static ssize_t devkmsg_write(struct kiocb *iocb, struct iov_iter *from)
>  	return ret;
>  }
>  
> -static void append_char(char **pp, char *e, char c)
> -{
> -	if (*pp < e)
> -		*(*pp)++ = c;
> -}
> -
>  static ssize_t devkmsg_read(struct file *file, char __user *buf,
>  			    size_t count, loff_t *ppos)
>  {
>  	struct devkmsg_user *user = file->private_data;
>  	struct printk_log *msg;
> -	char *p, *e;
> -	u64 ts_usec;
> -	size_t i;
> -	char cont = '-';
>  	size_t len;
>  	ssize_t ret;
>  
>  	if (!user)
>  		return -EBADF;
>  
> -	p = user->buf;
> -	e = user->buf + sizeof(user->buf);
> -
>  	ret = mutex_lock_interruptible(&user->lock);
>  	if (ret)
>  		return ret;
> @@ -618,71 +685,17 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
>  	}
>  
>  	msg = log_from_idx(user->idx);
> -	ts_usec = msg->ts_nsec;
> -	do_div(ts_usec, 1000);
> -
> -	/*
> -	 * If we couldn't merge continuation line fragments during the print,
> -	 * export the stored flags to allow an optional external merge of the
> -	 * records. Merging the records isn't always neccessarily correct, like
> -	 * when we hit a race during printing. In most cases though, it produces
> -	 * better readable output. 'c' in the record flags mark the first
> -	 * fragment of a line, '+' the following.
> -	 */
> -	if (msg->flags & LOG_CONT && !(user->prev & LOG_CONT))
> -		cont = 'c';
> -	else if ((msg->flags & LOG_CONT) ||
> -		 ((user->prev & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
> -		cont = '+';
> +	len = msg_print_ext_header(user->buf, sizeof(user->buf),
> +				   msg, user->seq, user->prev);
> +	len += msg_print_ext_body(user->buf + len, sizeof(user->buf) - len,
> +				  log_dict(msg), msg->dict_len,
> +				  log_text(msg), msg->text_len);
>  
> -	p += scnprintf(p, e - p, "%u,%llu,%llu,%c;",
> -		       (msg->facility << 3) | msg->level,
> -		       user->seq, ts_usec, cont);
>  	user->prev = msg->flags;
> -
> -	/* escape non-printable characters */
> -	for (i = 0; i < msg->text_len; i++) {
> -		unsigned char c = log_text(msg)[i];
> -
> -		if (c < ' ' || c >= 127 || c == '\\')
> -			p += scnprintf(p, e - p, "\\x%02x", c);
> -		else
> -			append_char(&p, e, c);
> -	}
> -	append_char(&p, e, '\n');
> -
> -	if (msg->dict_len) {
> -		bool line = true;
> -
> -		for (i = 0; i < msg->dict_len; i++) {
> -			unsigned char c = log_dict(msg)[i];
> -
> -			if (line) {
> -				append_char(&p, e, ' ');
> -				line = false;
> -			}
> -
> -			if (c == '\0') {
> -				append_char(&p, e, '\n');
> -				line = true;
> -				continue;
> -			}
> -
> -			if (c < ' ' || c >= 127 || c == '\\') {
> -				p += scnprintf(p, e - p, "\\x%02x", c);
> -				continue;
> -			}
> -
> -			append_char(&p, e, c);
> -		}
> -		append_char(&p, e, '\n');
> -	}
> -
>  	user->idx = log_next(user->idx);
>  	user->seq++;
>  	raw_spin_unlock_irq(&logbuf_lock);
>  
> -	len = p - user->buf;
>  	if (len > count) {
>  		ret = -EINVAL;
>  		goto out;
> -- 
> 2.1.0
> 
