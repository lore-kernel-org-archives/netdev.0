From: Miklos Szeredi <mszeredi@redhat.com>
Subject: Re: [PATCH] af_unix: fix garbage collect vs. MSG_PEEK
Date: Mon, 19 Dec 2016 12:21:16 +0100
Message-ID: <CAOssrKfKuie9BXKs_bmT+48ba25Jd3+Y+W3FcuXyw8X7-2NW=w@mail.gmail.com>
References: <1475150954-10152-1-git-send-email-mszeredi@redhat.com> <20161003.215103.2267442887041931968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Borisov <kernel@kyup.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161003.215103.2267442887041931968.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 4, 2016 at 3:51 AM, David Miller <davem@davemloft.net> wrote:
> From: Miklos Szeredi <mszeredi@redhat.com>
> Date: Thu, 29 Sep 2016 14:09:14 +0200
>
>> @@ -1550,6 +1550,17 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>>       return max_level;
>>  }
>>
>> +static void unix_peek_fds(struct scm_cookie *scm, struct sk_buff *skb)
>> +{
>> +     scm->fp = scm_fp_dup(UNIXCB(skb).fp);
>> +     /*
>> +      * During garbage collection it is assumed that in-flight sockets don't
>> +      * get a new external reference.  So we need to wait until current run
>> +      * finishes.
>> +      */
>> +     unix_gc_barrier();
>> +}
>  ...
>> @@ -266,6 +266,11 @@ void wait_for_unix_gc(void)
>>       wait_event(unix_gc_wait, gc_in_progress == false);
>>  }
>>
>> +void unix_gc_barrier(void)
>> +{
>> +     spin_unlock_wait(&unix_gc_lock);
>> +}
>
> Can you explain why wait_for_unix_gc() isn't appropriate?  I'm a little
> bit uncomfortable with a spinlock wait like this, and would rather see
> something like the existing helper used.

Missed this mail, sorry for the late reply...

AFAICS wait_for_unix_gc() lacks a barrier that the spin lock provides.

The ordering needs to be strictly:

A: duplicate file pointers
B: garbage collect

Also wait_for_unix_gc() is an overkill since the complete garbage
collect (including purging the trash) will take longer than the
collection stage, which we need to have ordering with.  This probably
doesn't matter much in practice.

Thanks,
Miklos
