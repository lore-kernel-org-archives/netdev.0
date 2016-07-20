From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Wed, 20 Jul 2016 02:23:03 +0200
Message-ID: <578EC467.2010808@iogearbox.net>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com> <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net> <578CAA96.2090501@mojatatu.com> <578E2960.7080709@iogearbox.net> <578E3172.9020601@mojatatu.com> <578E414C.1080501@iogearbox.net> <CAM_iQpWX5HT_yF3guCbQLMo2GSVGA8BTcJ3_bucHrnBrMQbjqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57383 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcGTAXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 20:23:07 -0400
In-Reply-To: <CAM_iQpWX5HT_yF3guCbQLMo2GSVGA8BTcJ3_bucHrnBrMQbjqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2016 08:04 PM, Cong Wang wrote:
> On Tue, Jul 19, 2016 at 8:03 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 07/19/2016 03:56 PM, Jamal Hadi Salim wrote:
>> [...]
>>>>
>>>> But apart from this,
>>>> neither pedit nor tcf_skbmod_run() here handle checksum complete, so
>>>> you'll
>>>> potentially get false positives wrt csum corruption and drops as a result
>>>> when using either of the two.
>>>
>>> pedit maybe tricky. Any suggestions?
>>> On tcf_skbmod_run, mostly ignorance: while doing only ethernet updates;
>>> is it still needed to do the checksum complete?
>>
>> Well, what Cong recently fixed with mirred was related to mac header ...
>>
>> You probably need skb_postpull_rcsum(), skb_postpush_rcsum() pair.
>>
>> Also, what about skb_try_make_writable()?
>
> I don't think so. 1) checksum is supposed to be done by csum action
> rather than pedit (or skbmod if it matters), 2) csum action currently
> already handles that correctly for both egress and ingress: 2a)
> CHECKSUM_COMPLETE is meaningless on egress; 2b) it forces
> CHECKSUM_COMPLETE to be CHECKSUM_NONE on ingress
> and it is correctly respected.

Ahh, right, so it redoes entire csums when worst-case changing one byte
only, since it cannot know what other actions like pedit did previously.
But it also means for your l2 mac addr changes to force a CHECKSUM_COMPLETE
into CHECKSUM_NONE with csum action that you need to call into one of the
l3/l4 helpers as far as I see.
