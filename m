From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Tue, 20 Oct 2015 11:43:18 -0700
Message-ID: <CANr6G5xW7m2SXFiU22pFVD6uvDj5ymX=jZkRJk2vMYQoJykvLw@mail.gmail.com>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <CANr6G5zvmj_tL5Pt6-70GQ4dTJXLewX9A4uMGC_0OFzXYQVdew@mail.gmail.com> <20151020081716.GH4386@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151020081716.GH4386@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20 October 2015 at 01:17, Florian Westphal <fw@strlen.de> wrote:
> Joe Stringer <joestringer@nicira.com> wrote:
>> On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
>> > [ CC netdev since patch #2 isn't nf-specific.  Dave, if you want
>> >   I can resubmit that one after the next nf-pull request; let me know if
>> >   you would prefer that ].
>> >
>> > Openvswitch seems broken wrt. to defragmentation, it doesn't call
>> > nf_ct_frag6_consume_orig to free the original fragments.
>>
>> This will need to be fixed for 'net' as well, do you have a path in
>> mind for that?
>
> Good point.  No, I don't.  Any suggestions?
> I can try to just re-target -nf tree (sans patch #2).  Pablo?

The smallest change seems to be adding the nf_ct_frag6_consume_orig()
call to OVS, plus the morph logic from patch 3. Alternatively if Pablo
is fine with having the series re-targeted, then that sounds
reasonable to me too.

> ipv4 side seems broken as well (ip_defrag frees skb on errors other than
> -EINPROGRESS, so it looks like we will double-free in
> do_execute_actions)

Oh dear. Thanks for the report. I propose wrapping the ip_defrag()
with an skb_get()/skb_consume() as this seems to require the least
invasive changes:

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index a5ec34f8502f..0d2d24c99fd5 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -303,7 +303,11 @@ static int handle_fragments(struct net *net,
struct sw_flow_key *key,
                int err;

                memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+
+               skb_get(skb);
                err = ip_defrag(skb, user);
+               if (!err || err == -EINPROGRESS)
+                       consume_skb(skb);
                if (err)
                        return err;

I don't have a test environment to verify this at the moment though.
Let me know if you'll take this with your patch series or if you'd
like me to send it out.

>> Patch 3 when taken independently from patch 4 hides user-visible error
>> codes on the OVS side. The OVS conntrack action hides -EINPROGRESS
>> from userspace, treating it as a successful execution. All other
>> errors are returned up. With that patch, all errors will be hidden. I
>> see that it's fixed in Patch 4, so maybe it's not a biggie but those
>> two patches should be tightly coupled.
>
> You're right, we can't signal "skb unchanged".  I guess one could
> just test wheter skb is a fragment and -EINVAL if it is, not sure
> if its worth doing given that such test would be removed again
> by the very next patch?

On second thought, this would only affect 'net', and if we're
considering the solution for that tree too then it really doesn't
matter.
