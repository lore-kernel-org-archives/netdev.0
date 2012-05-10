From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: Information leakage from RDS protocol
Date: Thu, 10 May 2012 10:38:32 -0500
Message-ID: <4FABE0F8.6070806@oracle.com>
References: <20120508161048.GE14179@redhat.com> <CA+55aFwzv5vjGsiZCjVfZkK3UL3K=Ha2pk_AweemZzsC6f-E9w@mail.gmail.com> <20120508182239.GA21089@redhat.com> <4FAA8AA5.2000709@oracle.com> <20120509155709.GA29413@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	security@kernel.org, eugene@redhat.com, pmatouse@redhat.com,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jay Fenlason <fenlason@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:29502 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab2EJPio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 11:38:44 -0400
In-Reply-To: <20120509155709.GA29413@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/9/2012 10:57 AM, Jay Fenlason wrote:
> On Wed, May 09, 2012 at 10:17:57AM -0500, Venkat Venkatsubra wrote:
>> On 5/8/2012 1:22 PM, Jay Fenlason wrote:
>>>> On Tue, May 8, 2012 at 9:10 AM, Jay Fenlason<fenlason@redhat.com>   wrote:
>>>>> recvfrom() on an RDS socket can return the contents of random(?)
>>>>> kernel memory to userspace if it was called with a address
>>>>> length larger than sizeof(struct sockaddr_in). ?rds_recvmsg() also
>>>>> fails to set the addr_len paramater properly before returning, but
>>>>> that's just a bug.
>>>>>
>>>>> There are also a number of cases wher recvfrom() can return an entirely
>>>>> bogus address. ?Anything in rds_recvmsg() that returns a
>>>>> non-negative value but does not go through the
>>>>> ? "sin = (struct sockaddr_in *)msg->msg_name;"
>>>>> code path at the end of the while(1) loop will return up to 128
>>>>> bytes of kernel memory to userspace.
>>>>>
>>>>> Also, on a receive race, the message that was copied to userspace but
>>>>> received by someone else is not zeroed, meaning that if the next
>>>>> message it receives is smaller, the tail of the raced message is
>>>>> leaked. ?I'm not sure how serious this is, but unexpectedly scribbling
>>>>> on userspace memory (even if it is part of a buffer that userspace
>>>>> asked us to write to) should be avoided.
>>>>>
>>> On Tue, May 08, 2012 at 11:04:01AM -0700, Linus Torvalds wrote:
>>>> Please cc David Miller too on these things, and make sure he knows
>>>> there's no embargo or anything (he won't touch it if there is). Maybe
>>>> you don't want public mailing lists, but in general, the more open we
>>>> can be, the better.
>>> Added.  Nobody has said anything about any embargo to me, either
>>> that they want one or that there shouldn't be one.  Personally, I
>>> don't see any reason to embargo this, but I'm not on any
>>> security-response teams.
>>>
>>>> This seems unfortunate, but at least the address thing is limited to
>>>> sizeof(sockaddr_storage) and is kernel stack - which in turn means
>>>> that while it potentially leaks kernel addresses (bad!), it almost
>>>> certainly won't leak anything fundamentally interesting (ie you can't
>>>> read arbitrary kernel memory and find plaintext passwords etc).
>>>>
>>>> I assume the fix is a trivial
>>>>
>>>>    msg->msg_namelen = sizeof(*sin);
>>>>
>>>> in rds_recvmsg() where it sets up the address?
>>> That fixes the case where it actually sets up the address, but won't
>>> fix the cases where it doesn't even do that.  I don't think anyone
>>> ever thought about what the source address should be for a message
>>> that was generated internally by the kernel.  I think the obvious
>>> possibilities are msg_namelen = 0 (no address) and 127.0.0.1
>>>
>>>> I do wonder if maybe recvmsg() should initialize msg_namelen to 0
>>>> instead of the size of the buffer before calling the low-level recvmsg
>>>> function - so that protocols would have to explicitly set the size to
>>>> the right value. But that would need much more validation.
>>> That would require checking/fixing all of the low-level functions,
>>> which will then have to know that the buffer pointed to by msg is at
>>> most sizeof(struct sockaddr_storage) bytes.  I think it's better to
>>> keep the size of the address buffer there, so the low-level functions
>>> can confirm that the address data they're about to stuff in there
>>> won't overflow the buffer.  (That way if we ever change the size of
>>> the buffer, only one place has to change.)
>>>
>>> And the whole rds recieve subsystem needs a bit of a rewrite to close
>>> the information-leaking receive race.  Keeping the semantics correct
>>> in regards to MSG_PEEK and multiple threads reading the socket at the
>>> same time may be tricky.
>>>
>>> 		-- JF
>>>
>> How about adding the suggested "msg->msg_namelen = sizeof(*sin);"
>> line at the top of rds_recvmsg ?
>> And "msg->msg_namelen = 0;" in the below "break;" cases ? I am
>> assuming the apps wouldn't need to look at msg_name in these cases.
>>                  if (!list_empty(&rs->rs_notify_queue)) {
>>                          ret = rds_notify_queue_get(rs, msg);
>>                          break;
>>                  }
>>
>>                  if (rs->rs_cong_notify) {
>>                          ret = rds_notify_cong(rs, msg);
>>                          break;
>>                  }
> Wouldn't it be better to set msg->msg_namelen = 0 at the top of the
> function, and only set it to sizeof(*sin) after msg->msg_name is
> filled in?  That'll prevent accidental disclosure of kernel memory via
> unanticipated code paths.
>
>> And, shouldn't an error be returned for the case below ? Currently
>> zero is returned.
>>
>>          if (msg_flags&  MSG_OOB)
>>                  goto out;
>> An error such as EOPNOTSUPP ?
> I don't know.  I'm not a networking expert.  From what I've found
> googling, EINVAL would be more correct that ENOTSUPP.
>
> This only leaves the datagram contents leak to userspace when multiple
> threads race on receiving a datagram and the subsequent datagram is
> smaller.  That one will be hard to fix, most notably because the
> obvious fixes I've looked at involve losing a datagram if either of
>    inc->i_conn->c_trans->inc_copy_to_user()
> or
>    rds_cmsg_recv()
> fail.  I don't know how likely either of those are, but losing
> datagrams seems like an inappropriate behavior for a reliable datagram
> subsystem.
>
Moving the discussion to netdev.

Venkat
