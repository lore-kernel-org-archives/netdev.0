From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 10:50:09 -0700
Message-ID: <54284A51.5080805@gmail.com>
References: <5425A545.1040907@gmail.com> <5425ED2D.1000005@mojatatu.com> <5425F5CC.4070507@intel.com> <542823CE.9020301@mojatatu.com> <CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:43550 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaI1Ruf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 13:50:35 -0400
Received: by mail-oi0-f46.google.com with SMTP id h136so1214163oig.5
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 10:50:35 -0700 (PDT)
In-Reply-To: <CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2014 10:15 AM, Cong Wang wrote:
> On Sun, Sep 28, 2014 at 8:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 09/26/14 19:25, John Fastabend wrote:
>>>
>>> On 09/26/2014 03:48 PM, Jamal Hadi Salim wrote:
>>
>>
>>>> Hrm  - poking inside there and this seems to be one of those
>>>> classifiers that hasnt been getting a lot of love. Doesnt
>>>> support actions well for example.
>>>>
>>>> It seems to work for me:
>>>
>>>
>>> This works for me as well try adding two or more policers and
>>> check if they all get printed.
>>>
>>
>> Multiple actions wont work for this classifier. I have time,
>> will send patch.
>>
>
> Hmm, looks like there is a bug in police dump. Please
> try the attached patch.
>
> Thanks.
>


I don't think we need this change, (or perhaps it needs to be a bit
more complete if something is missing) take a look a
tcf_exts_validate(), notice the policer is added to act->list so the
if block in dump() work out,


  int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct 
nlattr **tb,
                    struct nlattr *rate_tlv, struct tcf_exts *exts, bool 
ovr)
  {
  #ifdef CONFIG_NET_CLS_ACT
          {
                  struct tc_action *act;

                  INIT_LIST_HEAD(&exts->actions);
                  if (exts->police && tb[exts->police]) {
                          act = tcf_action_init_1(net, tb[exts->police], 
rate_tlv,
                                                  "police", ovr,
                                                  TCA_ACT_BIND);
                          if (IS_ERR(act))
                                  return PTR_ERR(act);

                          act->type = exts->type = TCA_OLD_COMPAT;
                          list_add(&act->list, &exts->actions);
			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

                  } else if (exts->action && tb[exts->action]) {
                          int err;
                          err = tcf_action_init(net, tb[exts->action], 
rate_tlv,
                                                NULL, ovr,
                                                TCA_ACT_BIND, 
&exts->actions);
                          if (err)
                                  return err;
                  }
          }

[...]



-- 
John Fastabend         Intel Corporation
