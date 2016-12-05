From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Mon, 5 Dec 2016 17:48:07 +0300
Message-ID: <CACVxJT8axg6i0Lvem=fvKqrjTuOzwg63BDbAuR6bzTPrtLuP+g@mail.gmail.com>
References: <20161202012132.GD31170@avx2> <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xemul@openvz.org" <xemul@openvz.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34910 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751427AbcLEOsJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:48:09 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so16453302wme.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:48:08 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2016 at 3:49 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexey Dobriyan
>> Sent: 02 December 2016 01:22
>> net_generic() function is both a) inline and b) used ~600 times.
>>
>> It has the following code inside
>>
>>               ...
>>       ptr = ng->ptr[id - 1];
>>               ...
>>
>> "id" is never compile time constant so compiler is forced to subtract 1.
>> And those decrements or LEA [r32 - 1] instructions add up.
>>
>> We also start id'ing from 1 to catch bugs where pernet sybsystem id
>> is not initialized and 0. This is quite pointless idea (nothing will
>> work or immediate interference with first registered subsystem) in
>> general but it hints what needs to be done for code size reduction.
>>
>> Namely, overlaying allocation of pointer array and fixed part of
>> structure in the beginning and using usual base-0 addressing.
>>
>> Ids are just cookies, their exact values do not matter, so lets start
>> with 3 on x86_64.
> ...
>>  struct net_generic {
>> -     struct {
>> -             unsigned int len;
>> -             struct rcu_head rcu;
>> -     } s;
>> -
>> -     void *ptr[0];
>> +     union {
>> +             struct {
>> +                     unsigned int len;
>> +                     struct rcu_head rcu;
>> +             } s;
>> +
>> +             void *ptr[0];
>> +     };
>>  };
>
> That union is an accident waiting to happen.

I kind of disagree. Module authors should not be given matches,
but it is hard to screw up if net_generic() is all you're given.

> What might work is to offset the Ids by
> (offsetof(struct net_generic, ptr)/sizeof (void *)) instead of by 1.
> The subtract from the offset will then counter the structure offset
> - which is what you are trying to achieve.

If you suggest this layout

struct net_generic {
        struct {
        } s;
        void *ptr[0];
};

then is it not optimal because offset of "ptr" needs to be somewhere in code
either in some LEA or imm8 of the final MOV which is 1 byte more bloaty.

Here is test program

struct ng1 {
        union {
                struct {
                        unsigned int len;
                } s;
                void *ptr[0];
        };
};
struct ng2 {
        struct {
                unsigned int len;
        } s;
        void *ptr[0];
};
struct net {
        int x;
        struct ng1 *gen1;
        struct ng2 *gen2;
};
void *ng1(const struct net *net, unsigned int id)
{
        return net->gen1->ptr[id];
}
void *ng2(const struct net *net, unsigned int id)
{
        return net->gen2->ptr[id];
}


0000000000000000 <ng1>:
   0:   48 8b 47 08             mov    rax,QWORD PTR [rdi+0x8]
   4:   89 f6                   mov    esi,esi
   6:   48 8b 04 f0             mov    rax,QWORD PTR [rax+rsi*8]
   a:   c3                      ret


0000000000000010 <ng2>:
  10:   48 8b 47 10             mov    rax,QWORD PTR [rdi+0x10]
  14:   89 f6                   mov    esi,esi
  16:   48 8b 44 f0 [[[08]]]          mov    rax,QWORD PTR [rax+rsi*8+0x8]
  1b:   c3                      ret

I can send more type checking if you can tolerate "_" identifier

    struct {
        unsigned int _;
    } pernet_ops_id_t;
