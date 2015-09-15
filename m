From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: v2 of seccomp filter c/r patches
Date: Tue, 15 Sep 2015 15:38:17 -0600
Message-ID: <20150915213817.GN31864@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
 <CALCETrWxLMSgdsdT9gTL80LSovONmCcTYjzqrHqF-WdJ4BN1Uw@mail.gmail.com>
 <20150911172806.GA7244@smitten>
 <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
 <20150915160738.GJ31864@smitten>
 <CALCETrVxhNvmEdMq0XRy1YZ+oJLDwcmE1y6prs7FGGhsS-Y5gg@mail.gmail.com>
 <20150915182626.GK31864@smitten>
 <CALCETrVED+pUDzSEurgrjjqMZpvO2vxG-uAf3ZJHHAYCbqS6YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Oleg Nesterov <oleg@redhat.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Linux API <linux-api@vger.kernel.org>,
	Will Drewry <wad@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32935 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbIOViT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 17:38:19 -0400
Received: by iofh134 with SMTP id h134so213143546iof.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:38:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALCETrVED+pUDzSEurgrjjqMZpvO2vxG-uAf3ZJHHAYCbqS6YQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Tue, Sep 15, 2015 at 01:01:23PM -0700, Andy Lutomirski wrote:
> On Tue, Sep 15, 2015 at 11:26 AM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > Hi Andy,
> >
> > On Tue, Sep 15, 2015 at 11:13:51AM -0700, Andy Lutomirski wrote:
> >> On Tue, Sep 15, 2015 at 9:07 AM, Tycho Andersen
> >> <tycho.andersen@canonical.com> wrote:
> >> > Hi Andy,
> >> >
> >> > On Mon, Sep 14, 2015 at 10:52:46AM -0700, Andy Lutomirski wrote:
> >> >>
> >> >> I'm not sure I entirely like this solution...
> >> >
> >> > Ok. Since we also aren't going to do all the eBPF stuff now, how about
> >> > something that looks like this:
> >> >
> >> > struct seccomp_layer {
> >> >   unsigned int size;
> >> >   unsigned int type; /* SECCOMP_BPF_CLASSIC or SECCOMP_EBPF or ... */
> >> >   bool inherited;
> >> >   union {
> >> >     unsigned int insn_cnt;
> >> >     struct bpf_insn *insns;
> >> >   };
> >> > };
> >> >
> >> > with a ptrace command:
> >> >
> >> > ptrace(PTRACE_SECCOMP_DUMP_LAYER, pid, i, &layer);
> >> >
> >> > If we save a pointer to the current seccomp filter on fork (if there
> >> > is one), then I think the inherited flag is just,
> >> >
> >> > inherited = is_ancestor(child->seccomp.filter, child->seccomp.inherited_filter)
> >> >
> >>
> >> I'm lost.  What is the inherited flag for?
> >
> > We need some way to expose the seccomp hierarchy, specifically which
> > filters are inherited, so that we can correctly restore the filter
> > tree for tasks that may use TSYNC in the future. You've mentioned that
> > you don't like kcmp, so this is an alternative to that.
> >
> 
> My only objection to kcmp is that IMO it's a suboptimal interface and
> could be better.  I have no problem with the general principle of
> asking to compare two objects.

Ok, in that case I think we can get rid of all the inherited stuff,
and use kcmp to figure it out.

> The thing I really don't have a good handle on is whether the seccomp
> filter hierarchy should look more like A:
> 
> struct seccomp_filter {
>     ...;
>     struct seccomp_filter *prev;
> };
> 
> with the seccomp_filter being the user-visible object
> 
> Or B:
> 
> struct seccomp_layer {
>    ...;  /* BPF program, etc. */
> }
> 
> struct seccomp_filter {
>    struct seccomp_layer *layer;
>    struct seccomp_filter *prev;
> };  /* or equivalent */
> 
> with seccomp_layer being the user-visible object.
> 
> A is simpler to implement in a memory-efficient way, but it's less
> flexible.  I haven't come up with a compelling use case for B where A
> doesn't work, with the caveat that, if an fd points to a
> seccomp_filter in model A, you can't attach it unless your current
> state matches its "prev" state (or an ancestor thereof), which might
> be a little bit awkward.

Perhaps, although I don't think it would be an issue for c/r.

> Am I making more sense now?

Yes, thanks for the clarifications. I guess personally I'd probably
choose option A. If this (using kcmp and one of A/B) sounds good to
you, I'll start working on a set to do c/r that way.

Tycho
