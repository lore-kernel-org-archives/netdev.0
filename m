From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 14:08:20 -0500
Message-ID: <CAEfhGixD83-XEB6Hc80cDctco9Br82AzcjJAXKsKPbNLF_+S4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35444 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbcASTIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:08:22 -0500
Received: by mail-lf0-f41.google.com with SMTP id c192so345135595lfe.2
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 11:08:21 -0800 (PST)
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com. [209.85.217.171])
        by smtp.gmail.com with ESMTPSA id rx3sm352736lbb.35.2016.01.19.11.08.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 11:08:20 -0800 (PST)
Received: by mail-lb0-f171.google.com with SMTP id cl12so151644349lbc.1
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 11:08:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 1:51 PM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
> On Tue, Jan 19, 2016 at 2:11 PM, Craig Gallek <kraig@google.com> wrote:
>> On Tue, Jan 19, 2016 at 12:08 PM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
>>> On Tue, Jan 19, 2016 at 12:31 PM, Craig Gallek <kraig@google.com> wrote:
>>>>
>>>> I need to think about how to handle setsockopt-after-bind condition a
>>>> bit more, but the NULL pointer dereference is obviously wrong.  Do you
>>>> have a way to easily reproduce this?  I've only managed to get it to
>>>> happen once so far...
>>>
>>> The attached code reliably triggers the crash for me.
>>
>> I think the patch below will address this issue (sorry in advance if
>> gmail screws up the whitespace...).  I'll send it for formal review
>> once I finish testing it.
>>
>> Craig
>>
>> diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
>> index 1df98c557440..004cb2c974ac 100644
>> --- a/net/core/sock_reuseport.c
>> +++ b/net/core/sock_reuseport.c
>> @@ -97,6 +97,11 @@ int reuseport_add_sock(struct sock *sk, const
>> struct sock *sk2)
>>  {
>>   struct sock_reuseport *reuse;
>>
>> +  if (!rcu_access_pointer(sk2->sk_reuseport_cb)) {
>> +   int err = reuseport_alloc(sk2);
>> +   if (err) return err;
>> +  }
>> +
>>   spin_lock_bh(&reuseport_lock);
>>   reuse = rcu_dereference_protected(sk2->sk_reuseport_cb,
>>    lockdep_is_held(&reuseport_lock)),
>
> That works fine, thanks..
>
> Just wondering though, is there a bit of a race there?  Seems like it
> might be safer to have a version of reuseport_alloc that doesn't take
> the lock and use it here, moving the block after the lock is taken.

Thanks for verifying.  The reuseport_lock really only protects the
contents of the sock_reuseport structure.  The pointer in the sk that
points to the structure is protected by the lock for the hlist slot
that both sk and sk2 belong to (which must be held anywhere
reuseport_add_sock is called).
