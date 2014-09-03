From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Wed, 3 Sep 2014 16:14:31 -0700
Message-ID: <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	<54078FBC.5050402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:45160 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933504AbaICXOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 19:14:32 -0400
Received: by mail-qa0-f47.google.com with SMTP id x12so8716750qac.34
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 16:14:31 -0700 (PDT)
In-Reply-To: <54078FBC.5050402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 3:01 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 09/03/2014 11:08 PM, Denis Kirjanov wrote:
>>
>
>> +static int __init init_pkt_type_offset(void)
>>   {
>>         struct sk_buff skb_probe = { .pkt_type = ~0, };
>>         u8 *ct = (u8 *) &skb_probe;
>>         unsigned int off;
>>
>> +       pkt_type_offset = -1;
>>         for (off = 0; off < sizeof(struct sk_buff); off++) {
>> -               if (ct[off] == PKT_TYPE_MAX)
>> +               if (ct[off] == PKT_TYPE_MAX) {
>> +                       pkt_type_offset = off;
>>                         return off;
>> +               }
>>         }
>
>
> Why not BUG_ON() when pkt_type_offset could not be found?
>
> That way we would know that something is broken and you can
> spare the checks for negative offsets everywhere ...

also such BUG_ON will be right in the face, since the kernel
won't even boot :)
I guess we can only hit it if compiler changes and starts
doing crazing things with bitfields.
Eric, you're the original author of this function, thoughts?

>>         case SKF_AD_OFF + SKF_AD_PKTTYPE:
>> +               if (pkt_type_offset < 0)
>> +                       return false;

with BUG_ON we wouldn't need this check.

>>                 *insn = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
>> -                                   pkt_type_offset());
>> +                                   pkt_type_offset);
>>                 if (insn->off < 0)
>>                         return false;

and this one too.
and other checks in arch/*/jit
