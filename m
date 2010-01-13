From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Subject: BUG? possible race due to the absence of barrier
Date: Wed, 13 Jan 2010 13:35:07 +0900
Message-ID: <2014bcab1001122035x57717821tac399330fd29883c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:34728 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab0AMEfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 23:35:08 -0500
Received: by pwj9 with SMTP id 9so2593767pwj.21
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2010 20:35:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I am reporting a type of suspected bugs due to
the lack of enforcing operation order by memory barrier.

I found this issue while I read the code, so that
it might not be real. But, please examine this issue.

We often allocate an object, initialize it, and then link it to a data
structure.
Then any thread can access the object.

For this pattern of programming, it seems to be necessary that
memory barrier should confirm that the initializations and the linking
to global data structures are not disordered by CPU or compilers.

atm_add_addr() in /net/atm/addr.c has the following code:

 88   this = kmalloc(sizeof(struct atm_dev_addr), GFP_ATOMIC);
 89   if (!this) {
 90     spin_unlock_irqrestore(&dev->lock, flags);
 91     return -ENOMEM;
 92   }
 93   this->addr = *addr;
 94   list_add(&this->entry, head);

The operation at line 93 might be executed earlier than that of line 94.
Then, the other thread might read uninitialized value of this
if there is other concurrent thread which iterates the list.

Please examine this issue and let me know your opinions.
Thank you.

Sincerely
Shin Hong
