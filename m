From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Fri, 20 Nov 2015 15:20:33 -0800
Message-ID: <CALx6S36tzYiW1tWs1kuRcj9XcD5wgtzsVejsEHAERfKTQRZyeQ@mail.gmail.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	<1448054520-1464587-5-git-send-email-tom@herbertland.com>
	<20151120231053.GA46238@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38276 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbbKTXUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 18:20:34 -0500
Received: by igbxm8 with SMTP id xm8so23119173igb.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 15:20:33 -0800 (PST)
In-Reply-To: <20151120231053.GA46238@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 3:10 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Nov 20, 2015 at 01:21:58PM -0800, Tom Herbert wrote:
>> +
>> +     while (eaten < orig_len) {
>> +             /* Always clone since we will consume something */
>> +             skb = skb_clone(orig_skb, GFP_ATOMIC);
>> +             if (!skb) {
>> +                     desc->error = -ENOMEM;
>> +                     break;
>> +             }
> ...
>> +             if (!pskb_pull(skb, offset + eaten)) {
>
> pskb_pull after clone == pskb_expand_head
> meaning that we'll be linearizing things all the time.
> can we try skb_share_check() first ?
> the packet shouldn't be shared at this point, so it might save a lot.
>
Yes it might. This pull does seem to be expensive.

>> +                     kfree_skb(skb);
>> +                     desc->error = -ENOMEM;
>> +                     break;
>> +             }
> ...
>> +             /* Need to trim, should be rare? */
>> +             err = pskb_trim(skb, orig_len - eaten);
> ...
>> +             if (!rxm->full_len) {
>> +                     ssize_t len;
>> +
>> +                     len = KCM_RUN_FILTER(psock->bpf_prog, head);
>
> bpf can read packet beyond linear header just fine.
> It's slower than reads from header, since extra calls invovled,
> but if that becomes a bottle neck we can optimize the way we do JIT there.
>
