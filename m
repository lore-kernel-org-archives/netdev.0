From: Tom Herbert <tom@herbertland.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Mon, 27 Jun 2016 15:04:22 -0700
Message-ID: <CALx6S35QzfV8PUFqxF5pMyPbTo-NqgjL=0w9W2wjnmMqtewsDw@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
 <CALx6S37LNGZEc+zPOu4fnYEYZ36dMKiimsz2XhgFs_rMOyFigg@mail.gmail.com> <CAM_iQpU2RjMi9byMfk-CyaXuRwVVacqQfeOSTa4xmiqhnuZ_Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38828 "EHLO
	mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbcF0WEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 18:04:23 -0400
Received: by mail-it0-f45.google.com with SMTP id h190so1083012ith.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 15:04:23 -0700 (PDT)
In-Reply-To: <CAM_iQpU2RjMi9byMfk-CyaXuRwVVacqQfeOSTa4xmiqhnuZ_Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 2:49 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jun 27, 2016 at 2:47 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Jun 27, 2016 at 2:44 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Mon, Jun 27, 2016 at 2:08 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Mon, Jun 27, 2016 at 9:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>> The stack doesn't trust the complete csum by hardware
>>>>> even when it is correct.
>>>>
>>>> Can you explain that a little further?
>>>
>>> Sure, here is the code in __skb_checksum_complete():
>>>
>>>         /* skb->csum holds pseudo checksum */
>>>         sum = csum_fold(csum_add(skb->csum, csum));
>>>         if (likely(!sum)) {
>>>                 if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
>>>                     !skb->csum_complete_sw)
>>>                         netdev_rx_csum_fault(skb->dev);
>>>         }
>>>
>>> So when sum == 0, it means the checksum is correct. And
>>> we already set ->ip_summed to CHECKSUM_COMPLETE
>>> after check_csum(), and ->csum_complete_sw is initialized
>>> to 0 when we allocate the skb. This is why we trigger
>>> netdev_rx_csum_fault().
>>>
>> Yes, but this also means that the driver gave the stack a checksum
>> complete value that was incorrect. That's an error.
>
> That is the whole purpose of commit f8c6455bb04b944edb69e,
> isn't it?

No. Unless you've uncovered some other bug, what is probably happening
is that driver receives a packet with a checksum complete value. It
records the value in the skbuff and marks it as CHECKSUM_COMPLETE.
Subsequently, the stack tries to validate a transport layer checksum,
and the validation fails (checksum does not sum to zero). The stack
will then call __skb_checksum_complete from
__skb_checksum_validate_complete. In this case the stack computes that
transport checksum by hand and sees that transport checksum is valid--
so that means that the original value in checksum complete was not
correct, it is not set to the computed checksum of the whole packet.
This is an important error because it catches issues where checksum is
not correctly being pulled up.

Tom
