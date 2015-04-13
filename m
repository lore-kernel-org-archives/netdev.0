From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 10:37:37 -0700
Message-ID: <552BFEE1.2070600@plumgrid.com>
References: <1428708792-5872-1-git-send-email-ast@plumgrid.com> <1428708792-5872-2-git-send-email-ast@plumgrid.com> <552BCFA1.7020502@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37404 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbbDMRhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:37:40 -0400
Received: by igblo3 with SMTP id lo3so50428187igb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 10:37:40 -0700 (PDT)
In-Reply-To: <552BCFA1.7020502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/15 7:16 AM, Jamal Hadi Salim wrote:
>
> To repeat what i said earlier:
> The only known user at this point is bpf. cls_bpf and cls_act could both
> look at the AT field, find where they are being invoked from and react
> accordingly. This is not very hard for a coder to do and the user
> injecting the policy doesnt need to know about it.

It is hard. That's my experience coding in bpf clearly tells me.
Burdening users will have long term consequences.
If Dave doesn't like ingress_l2 approach, my only choice left is to
abandon ld_abs/ld_ind instructions for tc+bpf programs (since ld_abs
must use skb->data) and introduce new helpers that always use
skb->mac_header. That is the ugly choice and the deeper you look the
uglier it becomes. Like I cannot reject programs with ld_abs in
verifier, since ld_abs with skf_ll_off negative offset is still usable,
but slower than new helpers, but regular ld_abs shouldn't be used and
user will be finding bugs the hard way. I cannot recode ld_abs
offsets on the fly either, since the same program can be attached to
both ingress and egress. I cannot pass l3-l2 delta into the program,
since negative offsets in ld_abs have different meaning, so ld_abs -14
cannot work. I cannot push/pull/skb_share_check when program is already
running. Etc, etc.
ingress_l2 cleanly solves it and it also makes ingress and egress
_consistent_ for all existing and future classifiers and actions.
I don't see it as being bpf specific. imo it should have been this way
from the beginning. That's why I tried to do it unconditionally in v2
patch, but ingress was this way for too long, so we have to add a flag.

> If you do that then i think you need to also inform users downstream
> from bpf that they should expect to see the packet at the Link header
> and not the network header.

I've analyzed all classifiers and actions. Few assume starting at l2
and I marked them as such in v3. In this v4 patch I dropped the marking,
since my reading of Dave's recommendation was to fix them to work
with/without l2. That's my plan. So nothing will be affected by this
ingress_l2. imo it's a good generic feature. I can see future non-bpf
actions that would also want to use TCA_NEEDS_L2 to avoid dealing with
ingress/egress differences.
