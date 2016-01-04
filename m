From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [iproute PATCH v3 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Mon, 4 Jan 2016 10:54:33 +0900
Message-ID: <CAKD1Yr1VQxVkQKpGxrtGmWd=_Z9Q2eBp1L313bqSddDXG9nNxg@mail.gmail.com>
References: <20151221214222.5ee87383@xeon-e3> <1450773094-7978-1-git-send-email-lorenzo@google.com>
 <1450773094-7978-3-git-send-email-lorenzo@google.com> <20151230123414.008f5e35@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:33096 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbcADByx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 20:54:53 -0500
Received: by mail-yk0-f179.google.com with SMTP id k129so212506823yke.0
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 17:54:53 -0800 (PST)
In-Reply-To: <20151230123414.008f5e35@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 31, 2015 at 5:34 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>> +     req.nlh.nlmsg_type = SOCK_DESTROY;
>> +     req.nlh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
>> +     req.nlh.nlmsg_seq = ++rth->seq;
>> +     req.r.sdiag_family = d->idiag_family;
>> +     req.r.sdiag_protocol = diag_arg->protocol;
>> +     req.r.id = d->id;
>> +
>> +     return rtnl_send_check_ack(rth, &req.nlh, req.nlh.nlmsg_len, 1);
>
> Just use rtnl_talk() instead, it does request/reply.

The reason I did not use rtnl_talk is that it prints all errors to
stderr. This does not
fit well with SOCK_DESTROY, for which it is expected that some
operations will fail.

For example, if you type "ss -a -K dport = :443", you probably don't
want to see one "RTNETLINK answers: Operation not supported" error for
every TIME-WAIT socket to port 443, and you don't want to see
"RTNETLINK answers: No such file or directory" if one of those sockets
happens to be closed during the scan. Silently ignoring these errors
seemed best.

I could also add a parameter to rtnl_talk to suppress printing errors,
though the patch to do so would be roughly equivalent to the patch
where I added rtnl_send_check_ack. I can also just use rtnl_talk as
you suggest and not care about the errors.

Let me know what you prefer.
