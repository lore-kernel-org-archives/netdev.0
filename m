From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 13 Dec 2016 23:17:01 -0500
Message-ID: <20161214041701.GN22660@madcap2.tricolour.ca>
References: <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca>
 <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca>
 <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
 <20161212100215.GA1305@madcap2.tricolour.ca>
 <CAM_iQpUejChnsMWx3Z59GTuxZMeBjgrs2rhd7gsQAKoxE8YuDg@mail.gmail.com>
 <20161213105233.GG1305@madcap2.tricolour.ca>
 <CAM_iQpVPEJ2t29ENpT4qcBznwE83w_PEBOxStwyzDH27Si2Ppw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, linux-audit@redhat.com,
        syzkaller <syzkaller@googlegroups.com>,
        David Miller <davem@davemloft.net>,
        Dmitry Vyukov <dvyukov@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpVPEJ2t29ENpT4qcBznwE83w_PEBOxStwyzDH27Si2Ppw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-13 16:17, Cong Wang wrote:
> On Tue, Dec 13, 2016 at 2:52 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > It is actually the audit_pid and audit_nlk_portid that I care about
> > more.  The audit daemon could vanish or close the socket while the
> > kernel sock to which it was attached is still quite valid.  Accessing
> > the set of three atomically is the urge.  I wonder if it makes more
> > sense to test for the presence of auditd using audit_sock rather than
> > audit_pid, but still keep audit_pid for our reporting and replacement
> > strategy.  Another idea would be to put the three in one struct.
> 
> Note, the process has audit_pid should hold a refcnt to the netns too,
> so the netns can't be gone until that process is gone.

I noted that.  I did wonder if there might be a problem if all the
processes were moved to another netns with the struct sock stuck in the
now process-void netns.

This is alluded-to in 6f285b19d09f ("audit: Send replies in the proper
network namespace.").

> > Can someone explain how they think the original test was able to trigger
> > this GPF?  Network namespace shutdown while something pretended to set
> > up a new auditd?  That's impressive for a fuzzer if that's the case...
> > Is there an strace?  I guess it is all in test().
> 
> I am surprised you still don't get the race condition even when you
> are now working on v2...
> 
> The race happens in this scenarios :
> 
> 1) Create a new netns
> 
> 2) In the new netns, communicate with kauditd to set audit_sock
> 
> 3) Generate some audit messages, so kauditd will keep sending them
> via audit_sock
> 
> 4) exit the netns
> 
> 5) the previous audit_sock is now going away, but kaudit_sock could still
> access it in this small window.

Ah ok that fits...

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
