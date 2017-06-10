From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RFC 1/1] net netlink: Add new type NLA_FLAG_BITS
Date: Sat, 10 Jun 2017 08:33:28 -0400
Message-ID: <3173015e-cc6a-dc31-a2c7-5e919613cc31@mojatatu.com>
References: <1493562519-15563-1-git-send-email-jhs@emojatatu.com>
 <20170502.150345.954488149548327006.davem@davemloft.net>
 <a719bd37-9e60-8ce2-c5d5-cbc9195a4f62@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33333 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFJMdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 08:33:32 -0400
Received: by mail-it0-f66.google.com with SMTP id l6so8122909iti.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 05:33:31 -0700 (PDT)
In-Reply-To: <a719bd37-9e60-8ce2-c5d5-cbc9195a4f62@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Ping.. Following up

On 17-05-02 09:52 PM, Jamal Hadi Salim wrote:
> On 17-05-02 03:03 PM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Sun, 30 Apr 2017 10:28:39 -0400
>>
>>> Generic bitflags attribute content sent to the kernel by user.
>>> With this type the user can either set or unset a flag in the
>>> kernel.
>>
>> You asked for feedback, here it is :-)
>>
>> I think this is overengineered.
>>
>> Just define a u32 for the value, and mask which defines which bits are
>> legitimate and defined.  Any bit outside of the legitimate mask must
>> be zero.
>>
> 
> That is what it does but as a nla type. It has a validator ops() in
> case someone wants to override the default validator.
> Is the ops the over-engineering you refer to or merely making it an
> nla type is a problem?
>

Since its been a month, a reminder of what the patch introduced a
new netlink type, NLA_FLAG_BITS

UAPI structure:

struct nla_bit_flags {
        u32 nla_flag_values;
        u32 nla_flag_selector;
}

User to kernel example:
---
     nla_flag_values = 0x0, and nla_flag_selector = 0x1
     implies we are selecting bit 1 and we want to set its value to 0.

     nla_flag_values = 0x2, and nla_flag_selector = 0x2
     implies we are selecting bit 2 and we want to set its value to 1.
---

A kernel subsystem specifies validation rules of the following
nature:
----
  [ATTR_GOO] = { .type = NLA_FLAG_BITS,
                 .validation_data = &myvalidflags },

where myvalidflags is the bit mask of the flags the kernel understands.
We reject any bitmask of values that dont fit myvalidflags.

The user can also specify their own validation callback as so:

     [ATTR_GOO] = { .type = MYTYPE,
                    .validation_data = &myvalidation_data,
                    .validate_content = mycontent_validator },

     myvalidation_data is the allowed bitmap as before
     With validator callback looking like:

     int mycontent_validator(const struct nlattr *nla, void *valid_data)
     {
            const struct myattribute *user_data = nla_data(nla);
            struct myvalidation_struct *valid_data_constraint = valid_data;

           ... validate user_data against valid_data_constraint ...
           ... return appropriate error code etc ...
     }
-------

So Dave ;-> Are you suggesting I get rid of the validation op?

cheers,
jamal
