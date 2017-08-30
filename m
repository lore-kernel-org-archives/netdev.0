From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next] net_sched: add reverse binding for tc class
Date: Thu, 31 Aug 2017 00:45:16 +0200
Message-ID: <59A73FFC.5070803@iogearbox.net>
References: <20170830213036.24250-1-xiyou.wangcong@gmail.com> <59A732B8.6020405@iogearbox.net> <CAM_iQpU9B71C5cWs969k464T7HvNhcwps7NYNQx8Q3KCijOfnA@mail.gmail.com> <59A73AAE.509@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58265 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdH3Wpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:45:30 -0400
In-Reply-To: <59A73AAE.509@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 12:22 AM, Daniel Borkmann wrote:
> On 08/31/2017 12:01 AM, Cong Wang wrote:
>> On Wed, Aug 30, 2017 at 2:48 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> On 08/30/2017 11:30 PM, Cong Wang wrote:
>>> [...]
>>>>
>>>> Note, we still can NOT totally get rid of those class lookup in
>>>> ->enqueue() because cgroup and flow filters have no way to determine
>>>> the classid at setup time, they still have to go through dynamic lookup.
>>>
>>> [...]
>>>>
>>>> ---
>>>>    include/net/sch_generic.h |  1 +
>>>>    net/sched/cls_basic.c     |  9 +++++++
>>>>    net/sched/cls_bpf.c       |  9 +++++++
>>>
>>> Same is for cls_bpf as well, so bind_class wouldn't work there
>>> either as we could return dynamic classids. bind_class cannot
>>> be added here, too.
>>
>> I think you are probably right, but the following code is
>> misleading there:
>>
>>          if (tb[TCA_BPF_CLASSID]) {
>>                  prog->res.classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
>>                  tcf_bind_filter(tp, &prog->res, base);
>>          }
>>
>> If the classid is dynamic, why this tb[TCA_BPF_CLASSID]?
>
> The prog->res.classid is the default one, but can be overridden
> later depending on the specified program. cls_bpf_classify() does
> after prog return (filter_res holds return code):
>
>      [...]
>          if (filter_res == 0)
>              continue;
>          if (filter_res != -1) {
>              res->class   = 0;
>              res->classid = filter_res;
>          } else {
>              *res = prog->res;
>          }
>      [...]
>
> Meaning in case of a match (-1), we use the default bound one,
> but prog may as well return an alternative found classid if it
> wants to. So both versions are possible.

But even for that case your patch looks fine to me actually, since
for dynamic classid we set class to 0. No objections from my side
then.
