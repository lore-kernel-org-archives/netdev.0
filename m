From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 2/4] lib: update single-char callers of strtobool
Date: Thu, 4 Feb 2016 15:01:55 -0800
Message-ID: <CAGXu5jKAivzpyq5qN2zLj0bcM-mswv=r83X65_MrBLVk8bedbA@mail.gmail.com>
References: <1454619643-14444-1-git-send-email-keescook@chromium.org>
	<1454619643-14444-3-git-send-email-keescook@chromium.org>
	<CAHp75VcJjm4xSdon1AWo=0QL1mmgttoL9Q_R=7DRmgFWkhzKWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VcJjm4xSdon1AWo=0QL1mmgttoL9Q_R=7DRmgFWkhzKWg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 2:59 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Thu, Feb 4, 2016 at 11:00 PM, Kees Cook <keescook@chromium.org> wrote:
>> Some callers of strtobool were passing a pointer to unterminated strings.
>> In preparation of adding multi-character processing to kstrtobool, update
>> the callers to not pass single-character pointers, and switch to using the
>> new kstrtobool_from_user helper where possible.
>
> Looks much better now!
> My comment below.
>
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Cc: Amitkumar Karwar <akarwar@marvell.com>
>> Cc: Nishant Sarmukadam <nishants@marvell.com>
>> Cc: Kalle Valo <kvalo@codeaurora.org>
>> Cc: Steve French <sfrench@samba.org>
>> Cc: linux-cifs@vger.kernel.org
>> ---
>>  drivers/net/wireless/marvell/mwifiex/debugfs.c | 10 ++---
>>  fs/cifs/cifs_debug.c                           | 58 +++++++-------------------
>>  fs/cifs/cifs_debug.h                           |  2 +-
>>  fs/cifs/cifsfs.c                               |  6 +--
>>  fs/cifs/cifsglob.h                             |  4 +-
>>  5 files changed, 26 insertions(+), 54 deletions(-)
>>
>> diff --git a/drivers/net/wireless/marvell/mwifiex/debugfs.c b/drivers/net/wireless/marvell/mwifiex/debugfs.c
>> index 0b9c580af988..bd061b02bc04 100644
>> --- a/drivers/net/wireless/marvell/mwifiex/debugfs.c
>> +++ b/drivers/net/wireless/marvell/mwifiex/debugfs.c
>> @@ -880,14 +880,12 @@ mwifiex_reset_write(struct file *file,
>>  {
>>         struct mwifiex_private *priv = file->private_data;
>>         struct mwifiex_adapter *adapter = priv->adapter;
>> -       char cmd;
>>         bool result;
>> +       int rc;
>>
>> -       if (copy_from_user(&cmd, ubuf, sizeof(cmd)))
>> -               return -EFAULT;
>> -
>> -       if (strtobool(&cmd, &result))
>> -               return -EINVAL;
>> +       rc = kstrtobool_from_user(ubuf, count, 0, &result);
>> +       if (rc)
>> +               return rc;
>>
>>         if (!result)
>>                 return -EINVAL;
>> diff --git a/fs/cifs/cifs_debug.c b/fs/cifs/cifs_debug.c
>> index 50b268483302..6ee59abcb69b 100644
>> --- a/fs/cifs/cifs_debug.c
>> +++ b/fs/cifs/cifs_debug.c
>> @@ -255,7 +255,6 @@ static const struct file_operations cifs_debug_data_proc_fops = {
>>  static ssize_t cifs_stats_proc_write(struct file *file,
>>                 const char __user *buffer, size_t count, loff_t *ppos)
>>  {
>> -       char c;
>>         bool bv;
>>         int rc;
>>         struct list_head *tmp1, *tmp2, *tmp3;
>> @@ -263,11 +262,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
>>         struct cifs_ses *ses;
>>         struct cifs_tcon *tcon;
>>
>> -       rc = get_user(c, buffer);
>> -       if (rc)
>> -               return rc;
>> -
>> -       if (strtobool(&c, &bv) == 0) {
>> +       rc = kstrtobool_from_user(buffer, count, 0, &bv);
>> +       if (rc == 0) {
>>  #ifdef CONFIG_CIFS_STATS2
>>                 atomic_set(&totBufAllocCount, 0);
>>                 atomic_set(&totSmBufAllocCount, 0);
>> @@ -290,6 +286,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
>>                         }
>>                 }
>>                 spin_unlock(&cifs_tcp_ses_lock);
>> +       } else {
>> +               return rc;
>>         }
>>
>>         return count;
>> @@ -433,17 +431,17 @@ static int cifsFYI_proc_open(struct inode *inode, struct file *file)
>>  static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
>>                 size_t count, loff_t *ppos)
>>  {
>> -       char c;
>> +       char c[2] = { '\0' };
>>         bool bv;
>>         int rc;
>>
>> -       rc = get_user(c, buffer);
>> +       rc = get_user(c[0], buffer);
>
>>         if (rc)
>>                 return rc;
>> -       if (strtobool(&c, &bv) == 0)
>> +       if (strtobool(c, &bv) == 0)
>>                 cifsFYI = bv;
>> -       else if ((c > '1') && (c <= '9'))
>> -               cifsFYI = (int) (c - '0'); /* see cifs_debug.h for meanings */
>> +       else if ((c[0] > '1') && (c[0] <= '9'))
>> +               cifsFYI = (int) (c[0] - '0'); /* see cifs_debug.h for meanings */
>>
>>         return count;
>>  }
>> @@ -471,20 +469,12 @@ static int cifs_linux_ext_proc_open(struct inode *inode, struct file *file)
>>  static ssize_t cifs_linux_ext_proc_write(struct file *file,
>>                 const char __user *buffer, size_t count, loff_t *ppos)
>>  {
>> -       char c;
>> -       bool bv;
>>         int rc;
>>
>> -       rc = get_user(c, buffer);
>> +       rc = kstrtobool_from_user(buffer, count, 0, &linuxExtEnabled);
>>         if (rc)
>>                 return rc;
>>
>> -       rc = strtobool(&c, &bv);
>> -       if (rc)
>> -               return rc;
>> -
>> -       linuxExtEnabled = bv;
>> -
>>         return count;
>>  }
>>
>> @@ -511,20 +501,12 @@ static int cifs_lookup_cache_proc_open(struct inode *inode, struct file *file)
>>  static ssize_t cifs_lookup_cache_proc_write(struct file *file,
>>                 const char __user *buffer, size_t count, loff_t *ppos)
>>  {
>> -       char c;
>> -       bool bv;
>>         int rc;
>>
>> -       rc = get_user(c, buffer);
>> +       rc = kstrtobool_from_user(buffer, count, 0, &lookupCacheEnabled);
>>         if (rc)
>>                 return rc;
>>
>> -       rc = strtobool(&c, &bv);
>> -       if (rc)
>> -               return rc;
>> -
>> -       lookupCacheEnabled = bv;
>> -
>>         return count;
>>  }
>>
>> @@ -551,20 +533,12 @@ static int traceSMB_proc_open(struct inode *inode, struct file *file)
>>  static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
>>                 size_t count, loff_t *ppos)
>>  {
>> -       char c;
>> -       bool bv;
>>         int rc;
>>
>> -       rc = get_user(c, buffer);
>> +       rc = kstrtobool_from_user(buffer, count, 0, &traceSMB);
>>         if (rc)
>>                 return rc;
>>
>> -       rc = strtobool(&c, &bv);
>> -       if (rc)
>> -               return rc;
>> -
>> -       traceSMB = bv;
>> -
>>         return count;
>>  }
>>
>> @@ -622,7 +596,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
>>         int rc;
>>         unsigned int flags;
>>         char flags_string[12];
>> -       char c;
>> +       char c[2] = { '\0' };
>
> Can we use flag_string directly here?
>
>>         bool bv;
>>
>>         if ((count < 1) || (count > 11))
>> @@ -635,11 +609,11 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
>>
>>         if (count < 3) {
>>                 /* single char or single char followed by null */
>> -               c = flags_string[0];
>> -               if (strtobool(&c, &bv) == 0) {
>> +               c[0] = flags_string[0];
>
>> +               if (strtobool(c, &bv) == 0) {
>
>
>>                         global_secflags = bv ? CIFSSEC_MAX : CIFSSEC_DEF;
>>                         return count;
>> -               } else if (!isdigit(c)) {
>> +               } else if (!isdigit(c[0])) {
>>                         cifs_dbg(VFS, "Invalid SecurityFlags: %s\n",
>>                                         flags_string);
>>                         return -EINVAL;

Hah, yes, durrr. I will send a fix-up for akpm. Thanks!

-Kees


-- 
Kees Cook
Chrome OS & Brillo Security
