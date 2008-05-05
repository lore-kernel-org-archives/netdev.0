From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Mon, 5 May 2008 10:27:16 +0800
Message-ID: <a8e1da0805041927qb0635e2p506837cc73e2679c@mail.gmail.com>
References: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
	 <1209912447.16966.42.camel@localhost>
	 <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.241]:32793 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510AbYEEC1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 22:27:19 -0400
Received: by ag-out-0708.google.com with SMTP id 31so1989295agc.10
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 19:27:16 -0700 (PDT)
In-Reply-To: <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2008 at 9:37 AM, Dave Young <hidave.darkstar@gmail.com> wrote:
> Hi,
>  Thanks for comment.
>
>
>  On Sun, May 4, 2008 at 10:47 PM, Joe Perches <joe@perches.com> wrote:
>  > On Sun, 2008-05-04 at 15:07 +0800, Dave Young wrote:
>  >  > diff -uprN linux/include/linux/kernel.h linux.new/include/linux/kernel.h
>  >  > --- linux/include/linux/kernel.h      2008-04-30 17:33:59.000000000 +0800
>  >  > +++ linux.new/include/linux/kernel.h  2008-04-30 17:33:52.000000000 +0800
>  >  > @@ -14,6 +14,7 @@
>  >  >  #include <linux/compiler.h>
>  >  >  #include <linux/bitops.h>
>  >  >  #include <linux/log2.h>
>  >  > +#include <linux/ratelimit.h>
>  >  >  #include <asm/byteorder.h>
>  >  >  #include <asm/bug.h>
>  >
>  >  Good idea.
>  >
>  >  I think #include <linux/printk.h>
>  >  and a reorganization of all the printk related
>  >  elements from kernel.h to printk.h would be better
>  >  and should be done first.

If split printk.h from kernel.h, then kernel.h had better don't
include printk.h.
Instead every printk user include "printk.h". This seems too much changes.

Right?

>
>  Sounds good.
>
>
>  >
>  >  I think your changes should then be done in
>  >  printk.h not creating a new ratelimit.h.
>
>  IMO ratelimit is not just for printk use now, so a standalone head
>  file is necessary.
>
>
>
>  >
>  >  Signed-off-by: Joe Perches <joe@perches.com>
>  >  ---
>  >   include/linux/kernel.h |  113 +---------------------------------------
>  >   include/linux/printk.h |  137 ++++++++++++++++++++++++++++++++++++++++++++++++
>  >   2 files changed, 138 insertions(+), 112 deletions(-)
>  >
>  >  diff --git a/include/linux/kernel.h b/include/linux/kernel.h
>  >  index 4d46e29..51ae259 100644
>  >  --- a/include/linux/kernel.h
>  >  +++ b/include/linux/kernel.h
>  >
>  > @@ -14,6 +14,7 @@
>  >   #include <linux/compiler.h>
>  >   #include <linux/bitops.h>
>  >   #include <linux/log2.h>
>  >  +#include <linux/printk.h>
>  >
>  >  #include <asm/byteorder.h>
>  >   #include <asm/bug.h>
>  >
>  >  @@ -70,29 +71,6 @@ extern const char linux_proc_banner[];
>  >   */
>  >   #define upper_32_bits(n) ((u32)(((n) >> 16) >> 16))
>  >
>  >  -#define        KERN_EMERG      "<0>"   /* system is unusable                   */
>  >  -#define        KERN_ALERT      "<1>"   /* action must be taken immediately     */
>  >  -#define        KERN_CRIT       "<2>"   /* critical conditions                  */
>  >  -#define        KERN_ERR        "<3>"   /* error conditions                     */
>  >  -#define        KERN_WARNING    "<4>"   /* warning conditions                   */
>  >  -#define        KERN_NOTICE     "<5>"   /* normal but significant condition     */
>  >  -#define        KERN_INFO       "<6>"   /* informational                        */
>  >  -#define        KERN_DEBUG      "<7>"   /* debug-level messages                 */
>  >  -
>  >  -/*
>  >  - * Annotation for a "continued" line of log printout (only done after a
>  >  - * line that had no enclosing \n). Only to be used by core/arch code
>  >  - * during early bootup (a continued line is not SMP-safe otherwise).
>  >  - */
>  >  -#define        KERN_CONT       ""
>  >  -
>  >  -extern int console_printk[];
>  >  -
>  >  -#define console_loglevel (console_printk[0])
>  >  -#define default_message_loglevel (console_printk[1])
>  >  -#define minimum_console_loglevel (console_printk[2])
>  >  -#define default_console_loglevel (console_printk[3])
>  >  -
>  >   struct completion;
>  >   struct pt_regs;
>  >   struct user;
>  >  @@ -179,56 +157,8 @@ extern int kernel_text_address(unsigned long addr);
>  >   struct pid;
>  >   extern struct pid *session_of_pgrp(struct pid *pgrp);
>  >
>  >  -#ifdef CONFIG_PRINTK
>  >  -asmlinkage int vprintk(const char *fmt, va_list args)
>  >  -       __attribute__ ((format (printf, 1, 0)));
>  >  -asmlinkage int printk(const char * fmt, ...)
>  >  -       __attribute__ ((format (printf, 1, 2))) __cold;
>  >  -extern int log_buf_get_len(void);
>  >
>  > -extern int log_buf_read(int idx);
>  >  -extern int log_buf_copy(char *dest, int idx, int len);
>  >  -
>  >  -extern int printk_ratelimit_jiffies;
>  >  -extern int printk_ratelimit_burst;
>  >  -extern int printk_ratelimit(void);
>  >
>  > -extern int __ratelimit(int ratelimit_jiffies, int ratelimit_burst);
>  >  -extern int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst);
>  >  -extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
>  >  -                                  unsigned int interval_msec);
>  >  -#else
>  >  -static inline int vprintk(const char *s, va_list args)
>  >  -       __attribute__ ((format (printf, 1, 0)));
>  >  -static inline int vprintk(const char *s, va_list args) { return 0; }
>  >  -static inline int printk(const char *s, ...)
>  >  -       __attribute__ ((format (printf, 1, 2)));
>  >  -static inline int __cold printk(const char *s, ...) { return 0; }
>  >  -static inline int log_buf_get_len(void) { return 0; }
>  >  -static inline int log_buf_read(int idx) { return 0; }
>  >
>  > -static inline int log_buf_copy(char *dest, int idx, int len) { return 0; }
>  >  -static inline int printk_ratelimit(void) { return 0; }
>  >  -static inline int __printk_ratelimit(int ratelimit_jiffies, \
>  >  -                                    int ratelimit_burst) { return 0; }
>  >  -static inline bool printk_timed_ratelimit(unsigned long *caller_jiffies, \
>  >  -                                         unsigned int interval_msec)   \
>  >  -               { return false; }
>  >  -#endif
>  >  -
>  >  -extern void __attribute__((format(printf, 1, 2)))
>  >  -       early_printk(const char *fmt, ...);
>  >  -
>  >   unsigned long int_sqrt(unsigned long);
>  >
>  >  -static inline void console_silent(void)
>  >  -{
>  >  -       console_loglevel = 0;
>  >  -}
>  >  -
>  >  -static inline void console_verbose(void)
>  >  -{
>  >  -       if (console_loglevel)
>  >  -               console_loglevel = 15;
>  >  -}
>  >  -
>  >   extern void bust_spinlocks(int yes);
>  >   extern void wake_up_klogd(void);
>  >   extern int oops_in_progress;           /* If set, an oops, panic(), BUG() or die() is in progress */
>  >  @@ -261,47 +191,6 @@ extern enum system_states {
>  >   #define TAINT_OVERRIDDEN_ACPI_TABLE    (1<<8)
>  >   #define TAINT_WARN                     (1<<9)
>  >
>  >  -extern void dump_stack(void) __cold;
>  >  -
>  >  -enum {
>  >  -       DUMP_PREFIX_NONE,
>  >  -       DUMP_PREFIX_ADDRESS,
>  >  -       DUMP_PREFIX_OFFSET
>  >  -};
>  >  -extern void hex_dump_to_buffer(const void *buf, size_t len,
>  >  -                               int rowsize, int groupsize,
>  >  -                               char *linebuf, size_t linebuflen, bool ascii);
>  >  -extern void print_hex_dump(const char *level, const char *prefix_str,
>  >  -                               int prefix_type, int rowsize, int groupsize,
>  >  -                               const void *buf, size_t len, bool ascii);
>  >  -extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
>  >  -                       const void *buf, size_t len);
>  >  -#define hex_asc(x)     "0123456789abcdef"[x]
>  >  -
>  >  -#define pr_emerg(fmt, arg...) \
>  >  -       printk(KERN_EMERG fmt, ##arg)
>  >  -#define pr_alert(fmt, arg...) \
>  >  -       printk(KERN_ALERT fmt, ##arg)
>  >  -#define pr_crit(fmt, arg...) \
>  >  -       printk(KERN_CRIT fmt, ##arg)
>  >  -#define pr_err(fmt, arg...) \
>  >  -       printk(KERN_ERR fmt, ##arg)
>  >  -#define pr_warning(fmt, arg...) \
>  >  -       printk(KERN_WARNING fmt, ##arg)
>  >  -#define pr_notice(fmt, arg...) \
>  >  -       printk(KERN_NOTICE fmt, ##arg)
>  >  -#define pr_info(fmt, arg...) \
>  >  -       printk(KERN_INFO fmt, ##arg)
>  >  -
>  >  -#ifdef DEBUG
>  >  -/* If you are writing a driver, please use dev_dbg instead */
>  >  -#define pr_debug(fmt, arg...) \
>  >  -       printk(KERN_DEBUG fmt, ##arg)
>  >  -#else
>  >  -#define pr_debug(fmt, arg...) \
>  >  -       ({ if (0) printk(KERN_DEBUG fmt, ##arg); 0; })
>  >  -#endif
>  >  -
>  >   /*
>  >   *      Display an IP address in readable format.
>  >   */
>  >  diff --git a/include/linux/printk.h b/include/linux/printk.h
>  >  new file mode 100644
>  >  index 0000000..732ee9c
>  >  --- /dev/null
>  >  +++ b/include/linux/printk.h
>  >  @@ -0,0 +1,137 @@
>  >  +#ifndef _LINUX_PRINTK_H
>  >  +#define _LINUX_PRINTK_H
>  >  +
>  >  +#define        KERN_EMERG      "<0>"   /* system is unusable                   */
>  >  +#define        KERN_ALERT      "<1>"   /* action must be taken immediately     */
>  >  +#define        KERN_CRIT       "<2>"   /* critical conditions                  */
>  >  +#define        KERN_ERR        "<3>"   /* error conditions                     */
>  >  +#define        KERN_WARNING    "<4>"   /* warning conditions                   */
>  >  +#define        KERN_NOTICE     "<5>"   /* normal but significant condition     */
>  >  +#define        KERN_INFO       "<6>"   /* informational                        */
>  >  +#define        KERN_DEBUG      "<7>"   /* debug-level messages                 */
>  >  +
>  >  +/*
>  >  + * Annotation for a "continued" line of log printout (only done after a
>  >  + * line that had no enclosing \n). Only to be used by core/arch code
>  >  + * during early bootup (a continued line is not SMP-safe otherwise).
>  >  + */
>  >  +#define        KERN_CONT       ""
>  >  +
>  >  +extern int console_printk[];
>  >  +
>  >  +#define console_loglevel (console_printk[0])
>  >  +#define default_message_loglevel (console_printk[1])
>  >  +#define minimum_console_loglevel (console_printk[2])
>  >  +#define default_console_loglevel (console_printk[3])
>  >  +
>  >  +#ifdef CONFIG_PRINTK
>  >  +asmlinkage int vprintk(const char *fmt, va_list args)
>  >  +       __attribute__ ((format (printf, 1, 0)));
>  >  +asmlinkage int printk(const char *fmt, ...)
>  >  +       __attribute__ ((format (printf, 1, 2))) __cold;
>  >  +extern int log_buf_get_len(void);
>  >
>  > +extern int log_buf_read(int idx);
>  >  +extern int log_buf_copy(char *dest, int idx, int len);
>  >  +
>  >  +extern int printk_ratelimit_jiffies;
>  >  +extern int printk_ratelimit_burst;
>  >  +extern int printk_ratelimit(void);
>  >
>  > +extern int __ratelimit(int ratelimit_jiffies, int ratelimit_burst);
>  >  +extern int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst);
>  >  +extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
>  >  +                                  unsigned int interval_msec);
>  >  +#else
>  >  +static inline int __attribute__ ((format (printf, 1, 0)))
>  >  +vprintk(const char *s, va_list args)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int __attribute__ ((format (printf, 1, 2))) __cold
>  >  +printk(const char *s, ...)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int log_buf_get_len(void)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int log_buf_read(int idx)
>  >
>  > +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int log_buf_copy(char *dest, int idx, int len)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int printk_ratelimit(void)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline int __printk_ratelimit(int ratelimit_jiffies,
>  >  +                                    int ratelimit_burst)
>  >  +{
>  >  +       return 0;
>  >  +}
>  >  +static inline bool printk_timed_ratelimit(unsigned long *caller_jiffies,
>  >  +                                         unsigned int interval_msec)
>  >  +{
>  >  +       return false;
>  >  +}
>  >  +#endif
>  >  +
>  >  +extern void __attribute__((format(printf, 1, 2)))
>  >  +       early_printk(const char *fmt, ...);
>  >  +
>  >  +static inline void console_silent(void)
>  >  +{
>  >  +       console_loglevel = 0;
>  >  +}
>  >  +
>  >  +static inline void console_verbose(void)
>  >  +{
>  >  +       if (console_loglevel)
>  >  +               console_loglevel = 15;
>  >  +}
>  >  +
>  >  +extern void dump_stack(void) __cold;
>  >  +
>  >  +enum {
>  >  +       DUMP_PREFIX_NONE,
>  >  +       DUMP_PREFIX_ADDRESS,
>  >  +       DUMP_PREFIX_OFFSET
>  >  +};
>  >  +extern void hex_dump_to_buffer(const void *buf, size_t len,
>  >  +                              int rowsize, int groupsize,
>  >  +                              char *linebuf, size_t linebuflen, bool ascii);
>  >  +extern void print_hex_dump(const char *level, const char *prefix_str,
>  >  +                          int prefix_type, int rowsize, int groupsize,
>  >  +                          const void *buf, size_t len, bool ascii);
>  >  +extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
>  >  +                                const void *buf, size_t len);
>  >  +#define hex_asc(x)     "0123456789abcdef"[x]
>  >  +
>  >  +#define pr_emerg(fmt, arg...) \
>  >  +       printk(KERN_EMERG fmt, ##arg)
>  >  +#define pr_alert(fmt, arg...) \
>  >  +       printk(KERN_ALERT fmt, ##arg)
>  >  +#define pr_crit(fmt, arg...) \
>  >  +       printk(KERN_CRIT fmt, ##arg)
>  >  +#define pr_err(fmt, arg...) \
>  >  +       printk(KERN_ERR fmt, ##arg)
>  >  +#define pr_warning(fmt, arg...) \
>  >  +       printk(KERN_WARNING fmt, ##arg)
>  >  +#define pr_notice(fmt, arg...) \
>  >  +       printk(KERN_NOTICE fmt, ##arg)
>  >  +#define pr_info(fmt, arg...) \
>  >  +       printk(KERN_INFO fmt, ##arg)
>  >  +
>  >  +#ifdef DEBUG
>  >  +/* If you are writing a driver, please use dev_dbg instead */
>  >  +#define pr_debug(fmt, arg...) \
>  >  +       printk(KERN_DEBUG fmt, ##arg)
>  >  +#else
>  >  +#define pr_debug(fmt, arg...) \
>  >  +       ({ if (0) printk(KERN_DEBUG fmt, ##arg); 0; })
>  >  +#endif
>  >  +
>  >  +#endif
>  >
>  >
>  >
>
