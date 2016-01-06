From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Wed, 6 Jan 2016 23:11:41 +0300
Message-ID: <CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
	<CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35341 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbcAFULn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:11:43 -0500
In-Reply-To: <CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 10:59 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Jan 6, 2016 at 11:15 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> Looks like this happens because ip_options_fragment() relies on
>> correct ip options length in ip control block in skb. But in
>> ip_finish_output_gso() control block in segments is reused by
>> skb_gso_segment(). following ip_fragment() sees some garbage.
>>
>> In my case there was no ip options but length becomes non-zero and
>> ip_options_fragment() picked some bytes from payload and decides to
>> fill huge range with IPOPT_NOOP (1). One of that ones flipped nr_frags
>> in skb_shared_info at the end of data =)
>>
>
> Hmm, it looks like SKB_GSO_CB should be cleared after skb_gso_segment()
> since all the gso information should be saved in shared_info after it finishes.
>
> Does a memset(0) on SKB_GSO_CB after skb_gso_segment() work as well?

This will break present logic around ip_options_fragment() - it clears
options from
second and following fragments. With zeroed cb it will do nothing.

ip_options_fragment() can get required information directly from ip header but
it also resets fields in IPCB -- probably it should stay valid here
and somebody else will use it later.
