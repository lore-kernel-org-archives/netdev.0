From: Isaac Boukris <iboukris@gmail.com>
Subject: Re: [PATCH] unix: escape all null bytes in abstract unix domain socket
Date: Tue, 1 Nov 2016 02:56:59 +0200
Message-ID: <CAC-fF8QA6KwXGsL2dx6PpQLqc0rDH2y57rVcRL7N-xAnVa3M6A@mail.gmail.com>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
 <1477768820-1295-2-git-send-email-iboukris@gmail.com> <20161031.153117.1954668010224339938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36492 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948343AbcKAA5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 20:57:02 -0400
In-Reply-To: <20161031.153117.1954668010224339938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, thanks for looking at it.

On Mon, Oct 31, 2016 at 9:31 PM, David Miller <davem@davemloft.net> wrote:
> From: Isaac Boukris <iboukris@gmail.com>
> Date: Sat, 29 Oct 2016 22:20:20 +0300
>
>> Abstract unix domain socket may embed null characters,
>> these should be translated to '@' when printed out to
>> proc the same way the null prefix is currently being
>> translated.
>>
>> This helps for tools such as netstat, lsof and the proc
>> based implementation in ss to show all the significant
>> bytes of the name (instead of getting cut at the first
>> null occurrence).
>>
>> Signed-off-by: Isaac Boukris <iboukris@gmail.com>
>  ...
>> @@ -2805,14 +2805,19 @@ static int unix_seq_show(struct seq_file *seq, void *v)
>>
>>                       i = 0;
>>                       len = u->addr->len - sizeof(short);
>> -                     if (!UNIX_ABSTRACT(s))
>> +                     if (!UNIX_ABSTRACT(s)) {
>>                               len--;
>> -                     else {
>> +                             for ( ; i < len; i++)
>> +                                     seq_putc(seq,
>> +                                              u->addr->name->sun_path[i]);
>> +                     } else {
>>                               seq_putc(seq, '@');
>>                               i++;
>> +                             for ( ; i < len; i++)
>> +                                     seq_putc(seq,
>> +                                              u->addr->name->sun_path[i] ?:
>> +                                              '@');
>>                       }
>> -                     for ( ; i < len; i++)
>> -                             seq_putc(seq, u->addr->name->sun_path[i]);
>
> I think this patch is simpler if you just do the "@" translation
> unconditionally, if it'll never trigger for the !UNIX_ABSTRACT case
> that is perfectly fine.

I've sent an updated patch.
Logically now, the 'else' block just above could be removed, but it
isn't obvious from the code that 'sun_path[0] == 0' so I left it as
is.
