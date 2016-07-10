From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [BUG?] tcp regression in v4.7-r1: c14ac9451c34832554db33386a4393be8bba3a7b
 breaks pulseaudio over TCP
Date: Sun, 10 Jul 2016 12:32:15 -0400
Message-ID: <CACSApvZ5knQi06f3wzqo4W78ip2G1yNV7=DHf_4GjB5rjHf4wQ@mail.gmail.com>
References: <20160710124240.7d484f44@sf> <CACSApvbeMfzgbLyfBNBG=VyJXJWJ2W48NA=BLodQMyjYpiwDOQ@mail.gmail.com>
 <20160710172510.4ec29e3e@sf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Tanu Kaskinen <tanuk@iki.fi>
To: Sergei Trofimovich <slyfox@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36780 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbcGJQcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 12:32:55 -0400
Received: by mail-oi0-f46.google.com with SMTP id n8so17421173oif.3
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 09:32:55 -0700 (PDT)
In-Reply-To: <20160710172510.4ec29e3e@sf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 12:25 PM, Sergei Trofimovich <slyfox@gentoo.org> wrote:
> On Sun, 10 Jul 2016 11:15:01 -0400
> Soheil Hassas Yeganeh <soheil@google.com> wrote:
>
>> On Sun, Jul 10, 2016 at 7:42 AM, Sergei Trofimovich <slyfox@gentoo.org> wrote:
>> > Hi netdev folk!
>> >
>> > Commit c14ac9451c34832554db33386a4393be8bba3a7b
>> > broke pulseaudio (PA) over TCP.
>>
>> Sorry that my patch broke your app and thanks for the bug report.
>> Breaking PA was certainly not my intention.
>>
>> > PA does unusual thing: it calls
>> >     sendmsg(cmsg_type=SCM_CREDENTIALS)
>> >
>> > on a TCP socket. It's not a new PA behaviour though.
>> >
>> > Originally reported as PA bug (has more details)
>> >     https://bugs.freedesktop.org/show_bug.cgi?id=96873
>> >
>> > It looks like kernel used to ignore control messages
>> > but now it does not:
>> >     http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/diff/net/ipv4/tcp.c?id=c14ac9451c34832554db33386a4393be8bba3a7b
>> >
>> > +       if (msg->msg_controllen) {
>> > +               err = sock_cmsg_send(sk, msg, &sockc);
>> > +               if (unlikely(err)) {
>> > +                       err = -EINVAL;
>> > +                       goto out_err;
>> > +               }
>> > +       }
>> >
>> > This change breaks streaming of pulse clients.
>> >
>> > Pulseaudio will be fixed at some point.
>> >
>> > But kernel change does not look like intentional
>> > breakage of old behaviour.
>> >
>> > Perhaps kernel should have a grace period and only
>> > warn about unsupported control messages for a socket?
>>
>> We have discussed ignoring certain control messages in another context:
>> https://patchwork.ozlabs.org/patch/621837/
>>
>> But the counter-argument (which I agree with) is that: we used to
>> accept garbage in control messages before, but that doesn't mean we
>> should give up on strict checking.
>>
>> This new problem is a bit different though. We always ignore control
>> messages of other layers:
>>
>> ip_cmsg_send:
>>                  if (cmsg->cmsg_level != SOL_IP)
>>                          continue;
>>
>> sock_cmsg_send:
>>                  if (cmsg->cmsg_level != SOL_SOCKET)
>>                          continue;
>>
>> Semantically SCM_RIGHTS and SCM_CREDENTIALS belong to the SOL_UNIX
>> layer but they are historically sent on SOL_SOCKET. I believe we
>> should ignore them as we would if they were sent on SOL_UNIX:
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 08bf97e..6239abf 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1938,6 +1938,13 @@ int __sock_cmsg_send(struct sock *sk, struct
>> msghdr *msg, struct cmsghdr *cmsg,
>>                 sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
>>                 sockc->tsflags |= tsflags;
>>                 break;
>> +       /* SCM_RIGHTS and SCM_CREDENTIALS are semantically in SOL_UNIX
>> +        * yet they are sent on SOL_SOCKET. We should ignore them as
>> +        * we do for control messages not in the SOL_SOCKET layers.
>> +        */
>> +       case SCM_RIGHTS:
>> +       case SCM_CREDENTIALS:
>
> Fixes PA for me. That was quick!

Thanks so much for the confirmation, Sergei!

> Perhaps to have those applications a change be fixed in future something like
>
> +                       net_info_ratelimited("TCP(%s:%d): Application bug, <some meaningful explanation>\n",
> +                                           current->comm,
> +                                           task_pid_nr(current));
>
> could signal the breakage? WDYT?

IMHO, for consistency, we should simply ignore control messages of
other layers, and shouldn't log anything. That's the way Linux has
been ignoring control messages.

I'll mail the patch against `net` to have David's thoughts.

Thanks again!
Soheil


> --
>
>   Sergei
