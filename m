From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Fri, 10 Feb 2017 09:42:44 -0800
Message-ID: <20170210094244.6feb9c47@cakuba.netronome.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
        <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
        <20170209172223.405b9e2f@cakuba.netronome.com>
        <CAJ3xEMh_2PdQXb01NmMnvaRyMzxC8VtNnu8XCqvPLQYRwYJPuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:22027 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752519AbdBJRv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 12:51:26 -0500
In-Reply-To: <CAJ3xEMh_2PdQXb01NmMnvaRyMzxC8VtNnu8XCqvPLQYRwYJPuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Feb 2017 18:33:13 +0200, Or Gerlitz wrote:
> On Fri, Feb 10, 2017 at 3:22 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Thu,  9 Feb 2017 16:18:08 +0200, Or Gerlitz wrote:  
> >> Currently there is no way of querying whether a filter is
> >> offloaded to HW or not when using both policy (no flag).
> >>
> >> Reuse the skip flags to show the insertion status by setting
> >> the skip_hw flag in case the filter wasn't offloaded.
> >>
> >> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> >> ---
> >>  net/sched/cls_bpf.c | 17 +++++++++++++----
> >>  1 file changed, 13 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> >> index d9c9701..91ba90d 100644
> >> --- a/net/sched/cls_bpf.c
> >> +++ b/net/sched/cls_bpf.c
> >> @@ -185,14 +185,23 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
> >>                       return -EINVAL;
> >>               }
> >>       } else {
> >> -             if (!tc_should_offload(dev, tp, prog->gen_flags))
> >> -                     return skip_sw ? -EINVAL : 0;
> >> +             if (!tc_should_offload(dev, tp, prog->gen_flags)) {
> >> +                     if (tc_skip_sw(prog->gen_flags))
> >> +                             return -EINVAL;
> >> +                     prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
> >> +                     return 0;
> >> +             }
> >>               cmd = TC_CLSBPF_ADD;
> >>       }
> >>
> >>       ret = cls_bpf_offload_cmd(tp, obj, cmd);
> >> -     if (ret)
> >> -             return skip_sw ? ret : 0;
> >> +
> >> +     if (ret) {
> >> +             if (skip_sw)
> >> +                     return ret;
> >> +             prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
> >> +             return 0;
> >> +     }
> >>
> >>       obj->offloaded = true;  
> >
> > In cls_bpf we do store information about whether program is offloaded or
> > not already (see the @offloaded member).  Could we simplify the code
> > thanks to this?  
> 
> yeah, I felt like I don't fully understand the role of the offloaded
> member. As I wrote, this patch is compile tested only, I will be happy
> if you can test it post here a better version, I don't think we need
> to add/change the flags semantics, see next

The @offloaded member just tells us whether the program is offloaded.
We need it because unlike u32 and flower (I think) we have explicit
ADD and REPLACE.  Other filters just always do REPLACE.  I assume the
driver keeps track if there is already an associated rule in that case?

> > I'm obviously all for reporting whether tc objects are offloaded or not
> > but let me ask perhaps the silly question of why reuse the SKIP_HW flag?
> > We don't have to worry about flag bits running out, could it be clearer
> > to users to report whether object is present in HW using a new flag?  Or
> > even two flags for present/non-present so user doesn't have to ponder
> > what no flag means (old kernel or not offloaded?). I don't really mind
> > either way I'm just wondering what the motivation was and maybe how
> > others feel.  
> 
> yeah, the flags are a bit confusing to some people, but it's all about
> polarity..
> 
> when the flags were introduced few of us where in favor of "positive"
> polarity, that is with possibly three values: "sw only" "hw only" and
> "both" but that JJJ (Jiri/John/Jamal) consensus was to pick a
> "negative" polarity of "skip sw" "skip hw" and "default" which means
> the filter is in SW and possibly in HW. I think we can live with that
> semantics and this small series just helps for the default case, allow
> user-space to know if the filter was offloaded using the existing
> fields.
> 
> I am not in favor of making this more complex...

I'm 100% with you.  Restating my proposal was to leave the SKIP_* flags
with all their existing semantics and complexity and for reporting to
user space whether something got offloaded add new ones.  My opinion
is that it would make things simpler, but I'm happy with your version
if none else thinks this way.

To spell it out with this patchset we would get the following semantics
of flags in dumps:
 - no flags - offloaded || old kernel;
 - skip_hw - not offloaded (either on user request || no flag
   was set but offload could not happen);
 - skip_sw - offload only on explicit request.

What we could do if we want to add flags would be:
 - no flags - old kernel;
 - no_offload - not offloaded;
 - skip_hw | no_offload - not offloaded on explicit user request;
 - offload - offloaded opportunistically;
 - skip_sw | offload - offloaded on explicit request. 

Because of dealing with distributor's kernels and various other
backports checking if kernel is old is a pain in practice :|

> thanks for the feedback and review

I will try to test and provide a simplified version if possible soon
(sorry for taking long, I got relocated and I'm still sorting out my
setup).
