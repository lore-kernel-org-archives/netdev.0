From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v2] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Fri, 18 Aug 2017 13:52:03 -0400
Message-ID: <CAF=yD-L5DVQ-pDuk+B_CWkmQsZ8+L04SppkmCO0QahaiNWAaWw@mail.gmail.com>
References: <20170818021157.20070-1-matthew@mjdsystems.ca> <1503065118.3344.18.camel@redhat.com>
 <1789862.HUSStbeWG9@ring00> <1503078168.3344.54.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33922 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdHRRwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:52:44 -0400
Received: by mail-oi0-f65.google.com with SMTP id v11so9973492oif.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 10:52:44 -0700 (PDT)
In-Reply-To: <1503078168.3344.54.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 1:42 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Fri, 2017-08-18 at 12:39 -0400, Matthew Dawson wrote:
>> On Friday, August 18, 2017 10:05:18 AM EDT Paolo Abeni wrote:
>> > On Thu, 2017-08-17 at 22:11 -0400, Matthew Dawson wrote:
>> > > diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> > > index 7b52a380d710..be8982b4f8c0 100644
>> > > --- a/net/unix/af_unix.c
>> > > +++ b/net/unix/af_unix.c
>> > > @@ -2304,10 +2304,7 @@ static int unix_stream_read_generic(struct
>> > > unix_stream_read_state *state,>
>> > >    */
>> > >
>> > >   mutex_lock(&u->iolock);
>> > >
>> > > - if (flags & MSG_PEEK)
>> > > -         skip = sk_peek_offset(sk, flags);
>> > > - else
>> > > -         skip = 0;
>> > > + skip = max(sk_peek_offset(sk, flags), 0);
>> > >
>> > >   do {
>> > >
>> > >           int chunk;
>> >
>> > later we have:
>> >
>> >     chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
>> >
>> > without any call to __skb_try_recv_from_queue(), so we will get
>> > bad/unexpected values from the above assignment when 'skip' is
>> > negative.
>>
>> The assignment to skip should ensure it is never less then zero, thanks to the
>> max(sk...(), 0).  Thus that shouldn't be an issue?
>
> Right, I missed the max() call. Thanks for pointing it out.
> I'm fine with the above.
>
>> >
>> > Overall I still think that adding/using an explicit MSG_PEEK_OFF bit
>> > would produce a simpler code, but is just a personal preference.
>>
>> I don't mind either way, that just seemed to be the preference I saw from the
>> discussion around the patch.  I think either way will work, so whatever the
>> list prefers I'm happy with.
>
> I'm ok either way. Probably it's worth continue this way.

I don't think anyone cares too much, as long as this is fixed.

I have a slight subjective preference for directly passing the sk_peek_off
variable and relying on the negative value as signal for whether the
SO_PEEK_OFF mode is enabled or not, simply because that signal
already exists and we avoid an intermediate conversion step.

That said, I have a follow-on bug fix for __sk_queue_drop_skb where
that signal is not available, but the flags argument is. I believe that
we will need to take the same action in both cases, so that this is moot.
Just mentioning it in case that would sway opinion the other way.

As said, I'm fine with both. Will Ack this.
