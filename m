From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: concurrent rhashtable test failure
Date: Wed, 26 Oct 2016 13:45:48 +0200
Message-ID: <CAMuHMdXQoXc9=TccFQk==p9WnGNYz=JNHcPvva+KT8U_UghNiQ@mail.gmail.com>
References: <CAMuHMdWTqXaJAM-O+mmha=JbuyvvNxYyHuV6e4YK7oUkh9rCkA@mail.gmail.com>
 <20161026095139.GA16590@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Phil Sutter <phil@nwl.cc>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35379 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932218AbcJZLpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 07:45:49 -0400
Received: by mail-it0-f66.google.com with SMTP id f129so722710itc.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 04:45:49 -0700 (PDT)
In-Reply-To: <20161026095139.GA16590@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Wed, Oct 26, 2016 at 11:51 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/24/16 at 02:11pm, Geert Uytterhoeven wrote:
>> On m68k/ARAnyM, test_rhashtable fails with:
>>
>>     Test failed: thread 0 returned: -4
>>
>> (-4 = -EINTR)
>
> The error is returned by kthread_stop(), I suspect we are running into
> this:
>
> static int kthread(void *_create)
> {
>         [...]
>         complete(done);
>         schedule();
>
>         ret = -EINTR;
>
>         if (!test_bit(KTHREAD_SHOULD_STOP, &self.flags)) {
>                 __kthread_parkme(&self);
>                 ret = threadfn(data);
>         }
>         /* we can't just return, we must preserve "self" on stack */
>         do_exit(ret);
> }

Looks reasonable. Adding a small delay like in the (whitespace-damaged)
patch below fixes the issue for me.

However, shouldn't the prestart_sem take care of making sure that
all threads have been started?

--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -13,6 +13,7 @@
  * Self Test
  **************************************************************************/

+#include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/jhash.h>
 #include <linux/kernel.h>
@@ -403,6 +404,7 @@ static int __init test_rht_init(void)
                pr_err("  down interruptible failed\n");
        for (i = 0; i < tcount; i++)
                up(&startup_sem);
+       msleep(1000);
        for (i = 0; i < tcount; i++) {
                if (IS_ERR(tdata[i].task))
                        continue;

Gr{oetje,eeting}s,

                        Geert
