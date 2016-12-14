From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 13 Dec 2016 16:17:14 -0800
Message-ID: <CAM_iQpVPEJ2t29ENpT4qcBznwE83w_PEBOxStwyzDH27Si2Ppw@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
	<CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
	<20161130045207.GE26673@madcap2.tricolour.ca>
	<20161209060248.GT22655@madcap2.tricolour.ca>
	<CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
	<20161209110155.GW22655@madcap2.tricolour.ca>
	<CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
	<20161212100215.GA1305@madcap2.tricolour.ca>
	<CAM_iQpUejChnsMWx3Z59GTuxZMeBjgrs2rhd7gsQAKoxE8YuDg@mail.gmail.com>
	<20161213105233.GG1305@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, linux-audit@redhat.com,
        syzkaller <syzkaller@googlegroups.com>,
        David Miller <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20161213105233.GG1305@madcap2.tricolour.ca>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 2:52 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> It is actually the audit_pid and audit_nlk_portid that I care about
> more.  The audit daemon could vanish or close the socket while the
> kernel sock to which it was attached is still quite valid.  Accessing
> the set of three atomically is the urge.  I wonder if it makes more
> sense to test for the presence of auditd using audit_sock rather than
> audit_pid, but still keep audit_pid for our reporting and replacement
> strategy.  Another idea would be to put the three in one struct.

Note, the process has audit_pid should hold a refcnt to the netns too,
so the netns can't be gone until that process is gone.

>
> Can someone explain how they think the original test was able to trigger
> this GPF?  Network namespace shutdown while something pretended to set
> up a new auditd?  That's impressive for a fuzzer if that's the case...
> Is there an strace?  I guess it is all in test().
>

I am surprised you still don't get the race condition even when you
are now working on v2...

The race happens in this scenarios :

1) Create a new netns

2) In the new netns, communicate with kauditd to set audit_sock

3) Generate some audit messages, so kauditd will keep sending them
via audit_sock

4) exit the netns

5) the previous audit_sock is now going away, but kaudit_sock could still
access it in this small window.
