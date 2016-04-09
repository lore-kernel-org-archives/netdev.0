From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: How do I avoid recvmsg races with IP_RECVERR?
Date: Fri, 8 Apr 2016 17:02:10 -0700
Message-ID: <CALCETrVyzOFU9cF0raDOmFxcSOmOWxBGhBEmjE3=PjM7pT+Mag@mail.gmail.com>
References: <CALCETrW-jkMrEjidwCTraeAaHCHA_+9eExQAz2phvn=OB8RMhQ@mail.gmail.com>
 <1433279822.2479038.285136017.7DD69CC6@webmail.messagingengine.com>
 <CALCETrXHLZKVuhSRdi1NvqjFbRf0-PKTt1PYPN6Dw=sXeRA4iw@mail.gmail.com>
 <1433281373.2485127.285160441.6F17A081@webmail.messagingengine.com>
 <1433281844.2487226.285170105.063B7084@webmail.messagingengine.com>
 <CALCETrU3EXkxANKQYHYpB-cELeOGKAwB-8wTxX+xJ0Ms+kx4Bg@mail.gmail.com> <1433291591.3300318.285256449.713A7E1E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34594 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbcDIACb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 20:02:31 -0400
Received: by mail-oi0-f43.google.com with SMTP id s79so153522683oie.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 17:02:31 -0700 (PDT)
In-Reply-To: <1433291591.3300318.285256449.713A7E1E@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 5:33 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Jun 3, 2015, at 02:03, Andy Lutomirski wrote:
>> On Tue, Jun 2, 2015 at 2:50 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> >> My proposal would be to make the error conversion lazy:
>> >>
>> >> Keeping duplicate data is not a good idea in general: So we shouldn't
>> >> use sk->sk_err if IP_RECVERR is set at all but let sock_error just use
>> >> the sk_error_queue and extract the error code from there.
>> >>
>> >> Only if IP_RECVERR was not set, we use sk->sk_err logic.
>> >>
>> >> What do you think?
>> >
>> > I just noticed that this will probably break existing user space
>> > applications which require that icmp errors are transient even with
>> > IP_RECVERR. We can mark that with a bit in the sk_error_queue pointer
>> > and xchg the pointer, hmmm....
>>
>> Do you mean to fix the race like this but to otherwise leave the
>> semantics
>> alone?  That would be an improvement, but it might be nice to also add
>> a non-crappy API for this, too.
>
> Yes, keep current semantics but fix the race you reported.
>
> I currently don't have good proposals for a decent API to handle this
> besides adding some ancillary cmsg data to msg_control. This still would
> not solve the problem fundamentally, as a -EFAULT/-EINVAL return value
> could also mean that msg_control should not be touched, thus we end up
> again relying on errno checking. :/ Thus checking error queue after
> receiving an error indications is my best hunch so far.
>
> Your proposal with MSG_IGNORE_ERROR seems reasonable so far for ping or
> udp, but I haven't fully grasped the TCP semantics of sk->sk_err, yet.

I was looking at this a bit, and I was thinking about adding a new
socket option, but I'm a bit vague on how all this fits together.

One option would be a socket option that simply causes sock_error to
return 0 (and change SO_ERROR to peek at sk_err directly).  But there
seem to be sock_error callers all over the place, and maybe this
change would cause problems.

Another option would be to add a socket option that explicitly turns
off everything that queues soft errors to sk_err.

I think that, for IP datagrams at least, the ideal semantics would be
for soft errors not to affect sk_err and for POLLERR to be set if the
error queue is nonempty.

--Andy
