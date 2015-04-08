From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 07:43:15 -0400
Message-ID: <55251453.2070503@mojatatu.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com> <1428455025-5945-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33446 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbbDHLnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:43:17 -0400
Received: by iebmp1 with SMTP id mp1so71307197ieb.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 04:43:17 -0700 (PDT)
In-Reply-To: <1428455025-5945-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

Sorry havent had the opportunity to rejoin the discussion on the other
emails (I plan to still). Let me get my head out of the sand
and respond to this one because it is a new thread.

This change is a little intrusive.
Summary: my view is a NACK for this change. It will break existing
assumptions and adds unnecessary costs.
Fix bpf_xxx. If cls_rsvp doesnt work, then it needs fixing too[1].

Longer version (to help move forward):

1) Some netdevs show up at the ingress with Link layer headers and
others dont. The assumption of doing blind pull/push is not going
to work. mirred and a few other users care where their packets
are being seen and in my opinion it is their job to handle those
cases. Besides that i am uncomfortable adding this new per-packet cost.
Why are you not able to achieve your goal using the indicators
of where the packet showed up at? Refer to the AT bit definitions
and how they are used elsewhere. Context: There are three paths the
packet sources from:
ingress, egress and packets coming from the stack (when it is
neither from ingress or egress). One of your changes assumed "if
we are not at egress" to mean "we are at ingress". It missed
the case where packets came from the stack.
The good news is that we have consistent behavior depending
where we are seeing packets, so it is easy to special case things
as mirred does.

2) Actions should be self contained if they are to be used in
conjunction with other actions in a policy. They do some small
thing and do it well. Adding semantics of checksum knowledge
in an action whose role is merely to send link level packets out
a netdev seems a little of an overkill. To be honest i am conflicted;
on one side i see the value being not much different than a netdev
that does csum recomputation - otoh i am seeing it as unnecessary
computation that only few preceding actions need. If it can be made
optional and policy defined with reasonable datapath cost (eg a single
if check when there is no interest) then i think it will be more
palatable.

3) The role of mirred is to send link layer packets. It cares about
making sure that the packets are in the proper link layer format
before sending them on the "wire". So the push is there merely to work
around cases where some netdevs have their link layers stripped off.
Anything else that cares about offsets should take of them as well.
IOW, all things you mentioned as not working need to be fixed.

cheers,
jamal

[1] I looked quickly at tests i ran against rsvp and i dont see any that
test at ingress - so i think you are right, it needs fixing (dont
have time right now, be my guest and i will test).

On 04/07/15 21:03, Alexei Starovoitov wrote:
> TC classifers and actions attached to ingress and egress qdiscs see
> inconsistent skb->data. For ingress L2 header is already pulled, whereas
> for egress it's present. Make them consistent by pushing L2 before calling
> into classifiers/actions and pulling L2 back afterwards.
>
> The following cls/act assume L2 and were broken on ingress before this commit:
> cls_bpf, act_bpf, cls_rsvp, cls_cgroup, act_csum, act_nat, all of ematch.
>
> All other in-tree cls/act use skb_network_offset() accessors for skb data
> and work regardless whether L2 was pulled or not.
>
> Since L2 is now present on ingress update act_mirred (the only action that
> was aware of L2 differences) and fix two bugs in it:
> - it was forwarding packets with L2 present to tunnel devices if used
>    with egress qdisc
> - it wasn't updating skb->csum with ingress qdisc
> Also rename 'ok_push' to 'needs_l2' to make it more readable.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
