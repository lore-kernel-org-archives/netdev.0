From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Mon, 12 Dec 2016 16:10:42 -0800
Message-ID: <CAM_iQpUejChnsMWx3Z59GTuxZMeBjgrs2rhd7gsQAKoxE8YuDg@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca> <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
 <20161212100215.GA1305@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-audit@redhat.com, Paul Moore <pmoore@redhat.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161212100215.GA1305@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2016 at 2:02 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-12-09 20:13, Cong Wang wrote:
>> Netlink notifier can safely be converted to blocking one, I will send
>> a patch.
>
> I had a quick look at how that might happen.  The netlink notifier chain
> is atomic.  Would the registered callback funciton need to spawn a
> one-time thread to avoid blocking?

It is already non-atomic now:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=efa172f42836477bf1ac3c9a3053140df764699c


> I had a look at your patch.  It looks attractively simple.  The audit
> next tree has patches queued that add an audit_reset function that will
> require more work.  I still see some potential gaps.
>
> - If the process messes up (or the sock lookup messes up) it is reset
>   in the kauditd thread under the audit_cmd_mutex.
>
> - If the process exits normally or is replaced due to an audit_replace
>   error, it is reset from audit_receive_skb under the audit_cmd_mutex.
>
> - If the process dies before the kauditd thread notices, either reap it
>   via notifier callback or it needs a check on net exit to reset.  This
>   last one appears necessary to decrement the sock refcount so the sock
>   can be released in netlink_kernel_release().
>
> If we want to be proactive and use the netlink notifier, we assume the
> overhead of adding to the netlink notifier chain and eliminate all the
> other reset calls under the kauditd thread.  If we are ok being
> reactionary, then we'll at least need the net exit check on audit_sock.
>

I don't see why we need to check it in net exit if we use refcnt,
because we have two different users of audit_sock: kauditd and
netns, if both take care of refcnt properly, we don't need to worry
about who is the last, no matter what failures occur in what order.
