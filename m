From: Paul Moore <paul@paul-moore.com>
Subject: Re: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Mon, 24 Jul 2017 22:00:25 -0400
Message-ID: <CAHC9VhQC1Bpm9VdE2sBC4VLmnzu_B7kLEkgBtnDKvwKf5w1HyA@mail.gmail.com>
References: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
 <1500899117.2458.2.camel@redhat.com> <CAHC9VhRjju-_3V21x+BogdRg-brDho1g_HzW+0CvU0PbhEtQqw@mail.gmail.com>
 <1500912555.2458.12.camel@redhat.com> <CAHC9VhSAifQtx3eaQD42XMx8beC08JBGQ9SaKFvkD9qVsT8VCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35928 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdGYCA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 22:00:28 -0400
Received: by mail-lf0-f67.google.com with SMTP id t128so3880222lff.3
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 19:00:27 -0700 (PDT)
In-Reply-To: <CAHC9VhSAifQtx3eaQD42XMx8beC08JBGQ9SaKFvkD9qVsT8VCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 3:00 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Mon, Jul 24, 2017 at 12:09 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>> Hi,
>>
>> On Mon, 2017-07-24 at 10:42 -0400, Paul Moore wrote:
>>> The change in behavior for userspace makes me a little nervous as
>>> there is no way of knowing how any random application may be coded.
>>> Even if we are confident that the majority of applications set
>>> IP_PASSSEC before calling bind(), we are likely still stuck with a few
>>> that will break, and that means a lot of hard to debug problem
>>> reports.
>>>
>>> I would feel much more comfortable if we could preserve the existing behavior.
>>
>> I agree, we must preserve the original behavior.
>>
>> Re-thinking about the problem, checking skb->sp in the BH, and storing
>> the status in the scratch area should both fix the issue in a sane way
>> and preserve the optimization.
>>
>> Something like the code below. Could you please try in your
>> environment? (or point me to simple reproducer ;-)
>
> I'm happy to test this, but if you are curious, you can find the
> selinux-testsuite at the link below; the "inet_socket" tests are the
> ones relevant to this problem.
>
> * https://github.com/SELinuxProject/selinux-testsuite
>
> However, I believe there is a problem with this patch, see below.
>
>> ---
>> diff --git a/include/net/udp.h b/include/net/udp.h
>> index 972ce4b..8d2c406 100644
>> --- a/include/net/udp.h
>> +++ b/include/net/udp.h
>> @@ -305,33 +305,44 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
>>  /* UDP uses skb->dev_scratch to cache as much information as possible and avoid
>>   * possibly multiple cache miss on dequeue()
>>   */
>> -#if BITS_PER_LONG == 64
>> -
>> -/* truesize, len and the bit needed to compute skb_csum_unnecessary will be on
>> - * cold cache lines at recvmsg time.
>> - * skb->len can be stored on 16 bits since the udp header has been already
>> - * validated and pulled.
>> - */
>>  struct udp_dev_scratch {
>> -       u32 truesize;
>> +       /* skb->truesize and the stateless bit embeded in a single field;
>> +        * do not use a bitfield since the compiler emits better/smaller code
>> +        * this way
>> +        */
>> +       u32 _tsize_state;
>> +
>> +#if BITS_PER_LONG == 64
>> +       /* len and the bit needed to compute skb_csum_unnecessary
>> +        * will be on cold cache lines at recvmsg time.
>> +        * skb->len can be stored on 16 bits since the udp header has been
>> +        * already validated and pulled.
>> +        */
>>         u16 len;
>>         bool is_linear;
>>         bool csum_unnecessary;
>> +#endif
>>  };
>
> ...
>
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index b057653..d243772 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1163,34 +1163,32 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>>         return ret;
>>  }
>>
>> -#if BITS_PER_LONG == 64
>> +#define UDP_SKB_IS_STATELESS 0x80000000
>> +
>>  static void udp_set_dev_scratch(struct sk_buff *skb)
>>  {
>> -       struct udp_dev_scratch *scratch;
>> +       struct udp_dev_scratch *scratch = udp_skb_scratch(skb);
>>
>>         BUILD_BUG_ON(sizeof(struct udp_dev_scratch) > sizeof(long));
>
> The BUILD_BUG_ON() assertion no longer appears to be correct with this patch.

Nevermind, I just took a closer look at this and realized I made a
mistake when applying your patch (had to apply manually for some
reason).  I'm building a test kernel now.

-- 
paul moore
www.paul-moore.com
