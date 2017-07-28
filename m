From: isdn@linux-pingi.de
Subject: Re: Possible race in hysdn.ko
Date: Fri, 28 Jul 2017 06:46:59 +0200
Message-ID: <2f35ddaf-88d9-e848-f83b-3001b36b2883@linux-pingi.de>
References: <8178d591-2b1a-334d-fdd1-4c6b98abad72@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org, khoroshilov@ispras.ru
To: Anton Volkov <avolkov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8178d591-2b1a-334d-fdd1-4c6b98abad72@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Anton,

first of all, this code was developed by other people and I
never managed to get one of these cards - so I do not know so much about
this driver at all.
Unfortunately the firm behind hysdn do not longer exist and
was taken over by Hermstedt AG years ago and even Hermstedt AG is not
longer active in this businesss I think (ISDN is a obsolete technology).

Am 27.07.2017 um 18:19 schrieb Anton Volkov:
> Hello.
> 
> While searching for races in the Linux kernel I've come across
> "drivers/isdn/hysdn/hysdn.ko" module. Here is a question that I came up
> with while analysing results. Lines are given using the info from Linux
> v4.12.
> 
> In hysdn_proclog.c file in put_log_buffer function a non-standard type
> of synchronization is employed. It uses pd->del_lock as some kind of
> semaphore (hysdn_proclog.c: lines 129 and 143). Consider the following
> case:
> 
> Thread 1:                    Thread 2:
> hysdn_log_write
> -> hysdn_add_log
>     -> put_log_buffer
>          spin_lock()          hysdn_conf_open
>          i = pd->del_lock++   -> hysdn_add_log
>          spin_unlock()           -> put_log_buffer
>          if (!i) <delete-loop>        spin_lock()
>          pd->del_lock--               i = pd->del_lock++
>                                       spin_unlock()
>                                       if (!i) <delete-loop>
>                                       pd->del_lock--
> 
> <delete-loop> - the loop that deletes unused buffer entries
> (hysdn_proclog.c: lines 134-142).
> pd->del_lock-- is not an atomic operation and is executed without any
> locks. Thus it may interfere in the increment process of pd->del_lock in
> another thread. There may be cases that lead to the inability of any
> thread going through the <delete-loop>.

Good catch.

> 
> I see several possible solutions to this problem:
> 1) move the <delete-loop> under the spin_lock and delete
> pd->del_lock synchronization;
> 2) wrap pd->del_lock-- with spin_lock protection.
> 
> What do you think should be done about it?

I think the intention to have this construct was to not hold the card
lock for long times from /proc/ access to log data, since that may
disrupt the normal function. This is only a guess - I did not really
analyzed the code deeply enough, but I fear here are other critical
problems with this code, since without extra protection the list could
be damaged during the deletion loop I think.
So maybe to have the complete loop under the lock is a good idea.


Best regards
Karsten
