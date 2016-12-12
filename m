From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Mon, 12 Dec 2016 11:07:41 +0100
Message-ID: <CACT4Y+Yn0ZUv0=g4t5BYQC5tUqqmNFreUyB3nw=vx1GXEn1NSQ@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca> <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
 <CAM_iQpVcHGywXn90EpiSz-LsUDgKVqs-7BY-L7UBCu2VxkC31Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Guy Briggs <rgb@redhat.com>, linux-audit@redhat.com,
        Paul Moore <pmoore@redhat.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVcHGywXn90EpiSz-LsUDgKVqs-7BY-L7UBCu2VxkC31Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 10, 2016 at 8:40 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On 2016-12-08 22:57, Cong Wang wrote:
>>>> On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
>>>> > I also tried to extend Cong Wang's idea to attempt to proactively respond to a
>>>> > NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
>>>> > stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
>>>> > Eliminating the lock since the sock is dead anways eliminates the error.
>>>> >
>>>> > Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
>>>> > get the test case to compile.
>>>>
>>>> It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
>>>> are updated as a whole and race between audit_receive_msg() and
>>>> NETLINK_URELEASE.
>>>
>>> This is what I expected and why I originally added the mutex lock in the
>>> callback...  The dumps I got were bare with no wrapper identifying the
>>> process context or specific error, so I'm at a bit of a loss how to
>>> solve this (without thinking more about it) other than instinctively
>>> removing the mutex.
>>
>> Netlink notifier can safely be converted to blocking one, I will send
>> a patch.
>>
>> But I seriously doubt you really need NETLINK_URELEASE here,
>> it adds nothing but overhead, b/c the netlink notifier is called on
>> every netlink socket in the system, but for net exit path, that is
>> relatively a slow path.
>>
>> Also, kauditd_send_skb() needs audit_cmd_mutex too.
>
> Please let me know what you think about the attached patch?

Applied the patch locally and have not seen the bug since then (~24
hours of testing).
