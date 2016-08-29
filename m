From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/3] strp: Generalize stream parser to work with
 other socket types
Date: Mon, 29 Aug 2016 08:52:52 -0700
Message-ID: <CALx6S37ycej_hnEEU95VN6gDAT_Q8mWcCpddqujWXeYtCWye3g@mail.gmail.com>
References: <1472420599-510735-1-git-send-email-tom@herbertland.com> <20160828.233450.783176953748442286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Dave Watson <davejwatson@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36333 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753088AbcH2Pwx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 11:52:53 -0400
Received: by mail-it0-f53.google.com with SMTP id e63so111925397ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 08:52:53 -0700 (PDT)
In-Reply-To: <20160828.233450.783176953748442286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 8:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Sun, 28 Aug 2016 14:43:16 -0700
>
>> Add a read_sock protocol operation function that allows something like
>> tcp_read_sock to be called for other protocol types.
>>
>> Specific changes in this patch set:
>>   - Add read_sock function to proto_ops. This has the same signature as
>>     tcp_read_sock. sk_read_actor_t is also defined in net.h.
>>   - Set peek_len and read_sock proto_op functions for TCPv4 and TCPv6
>>     stream ops.
>>   - Remove references to tcp in strparser.
>>   - Call peek_len and read_sock operations from strparser instead of
>>     calling TCP specific functions.
>
> I'll apply this, but I want you to shore up these new ops.
>
> A check has to happen somewhere to make sure the proto_ops in
> question have a non-NULL read_sock and peek_len method before
> starting to use it.

Is the check in strp_init not enough?...

@@ -424,9 +429,14 @@ static void strp_rx_msg_timeout(unsigned long arg)
 int strp_init(struct strparser *strp, struct sock *csk,
              struct strp_callbacks *cb)
 {
+       struct socket *sock = csk->sk_socket;
+
        if (!cb || !cb->rcv_msg || !cb->parse_msg)
                return -EINVAL;

+       if (!sock->ops->read_sock || !sock->ops->peek_len)
+               return -EAFNOSUPPORT;
+
