From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Thu, 18 Feb 2016 07:14:24 -0500
Message-ID: <56C5B5A0.7010305@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
 <56C4528E.5090505@mojatatu.com> <56C48295.9030806@gmail.com>
 <56C4FD2B.9000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34063 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425638AbcBRMO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 07:14:27 -0500
Received: by mail-ig0-f180.google.com with SMTP id g6so12116125igt.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 04:14:27 -0800 (PST)
In-Reply-To: <56C4FD2B.9000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 06:07 PM, John Fastabend wrote:
> [...]
>

> Actually thinking about this a bit more I wrote this thinking
> that there existed some hardware that actually cared if it was
> a new rule or an existing rule. For me it doesn't matter I do
> the same thing in the new/replace cases I just write into the
> slot on the hardware table and if it happens to have something
> in it well its overwritten e.g. "replaced". This works because
> the cls_u32 layer protects us from doing something unexpected.
>

You are describing create-or-update which is a reasonable default
BUT: counting on the user to specify the htid+bktid+nodeid
for every filter and knowing what that means is prone to mistakes
when for example (using your big hammer approach right now) they
dont specify the handle and the kernel creates one for them.

IMO, it would be better at this early stage to enforce the correct
behavior for future generations.
To follow the netlink semantics which a lot of people are already
trained to think in.

Current netlink behavior is supposed to be:

1) NEW ==> "Create".
Ambigous - could mean a)"create if it doesnt exist" or b) "fail if it 
exists otherwise create"
Unfortunately different parts of the kernel often assume some
default from either #a or #b.

2) NEW|REPLACE flag ==> "Create if it doesnt exist and replace
if it exists"

3)NEW|EXCLUSIVE ==> "Create if it doesnt exist and fail if it
exists"

4)NEW|APPEND ==> "just fscking create; i dont care if it exists".

IOW, just add the flag field which is intepreted from whatever
the user explicitly asks for. And reject say what the hardware
doesnt support.
I have worked with tcams where we support #3. It is a bit inefficient
because you have to check if a rule exists first. And i have worked
in cases where #1 is assumed to mean #2 and at times #4. It is better
user experience to be explicit.

cheers,
jamal
