From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 13 Dec 2016 05:52:33 -0500
Message-ID: <20161213105233.GG1305@madcap2.tricolour.ca>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
 <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca>
 <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca>
 <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
 <20161212100215.GA1305@madcap2.tricolour.ca>
 <CAM_iQpUejChnsMWx3Z59GTuxZMeBjgrs2rhd7gsQAKoxE8YuDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpUejChnsMWx3Z59GTuxZMeBjgrs2rhd7gsQAKoxE8YuDg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-12 16:10, Cong Wang wrote:
> On Mon, Dec 12, 2016 at 2:02 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > On 2016-12-09 20:13, Cong Wang wrote:
> >> Netlink notifier can safely be converted to blocking one, I will send
> >> a patch.
> >
> > I had a quick look at how that might happen.  The netlink notifier chain
> > is atomic.  Would the registered callback funciton need to spawn a
> > one-time thread to avoid blocking?
> 
> It is already non-atomic now:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=efa172f42836477bf1ac3c9a3053140df764699c

Ok, that is recent...  It is still less attractive as you point out due
to the overhead, but still worth considering if we can't find another
way.

> > I had a look at your patch.  It looks attractively simple.  The audit
> > next tree has patches queued that add an audit_reset function that will
> > require more work.  I still see some potential gaps.
> >
> > - If the process messes up (or the sock lookup messes up) it is reset
> >   in the kauditd thread under the audit_cmd_mutex.
> >
> > - If the process exits normally or is replaced due to an audit_replace
> >   error, it is reset from audit_receive_skb under the audit_cmd_mutex.
> >
> > - If the process dies before the kauditd thread notices, either reap it
> >   via notifier callback or it needs a check on net exit to reset.  This
> >   last one appears necessary to decrement the sock refcount so the sock
> >   can be released in netlink_kernel_release().
> >
> > If we want to be proactive and use the netlink notifier, we assume the
> > overhead of adding to the netlink notifier chain and eliminate all the
> > other reset calls under the kauditd thread.  If we are ok being
> > reactionary, then we'll at least need the net exit check on audit_sock.
> 
> I don't see why we need to check it in net exit if we use refcnt,
> because we have two different users of audit_sock: kauditd and
> netns, if both take care of refcnt properly, we don't need to worry
> about who is the last, no matter what failures occur in what order.

It is actually the audit_pid and audit_nlk_portid that I care about
more.  The audit daemon could vanish or close the socket while the
kernel sock to which it was attached is still quite valid.  Accessing
the set of three atomically is the urge.  I wonder if it makes more
sense to test for the presence of auditd using audit_sock rather than
audit_pid, but still keep audit_pid for our reporting and replacement
strategy.  Another idea would be to put the three in one struct.

Can someone explain how they think the original test was able to trigger
this GPF?  Network namespace shutdown while something pretended to set
up a new auditd?  That's impressive for a fuzzer if that's the case...
Is there an strace?  I guess it is all in test().

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
