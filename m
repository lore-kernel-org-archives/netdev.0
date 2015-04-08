From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 09:44:16 -0700
Message-ID: <55255AE0.2060606@plumgrid.com>
References: <55252FEF.40201@iogearbox.net>	<55253289.8020306@mojatatu.com>	<552556BC.8020108@plumgrid.com> <20150408.123208.890310178000649038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36413 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbbDHQoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:44:19 -0400
Received: by iebrs15 with SMTP id rs15so79299664ieb.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 09:44:19 -0700 (PDT)
In-Reply-To: <20150408.123208.890310178000649038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/15 9:32 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Wed, 08 Apr 2015 09:26:36 -0700
>
>> My preference is to add 'needs_l2' flag to ingress qdisc.
>
> The problem is that needs_l2 is not property of individual qdisc,
> but conditionally 1 or more things sitting behind it.
>
> You can mix u32 and bpf classifiers.  One wants need_L2 another
> does not, and you therefore cannot handle this problem in this
> manner.

that is still ok.
I'm proposing multiple flags. One for ingress qdisc and another
flag for all cls/acts whether they care about l2 or not.
Then when cls is attached to ingress_with_l2 we will check whether
this cls is ready or not.
so cls_bpf will have flag L2_ONLY
whereas cls_u32 will be L2 | L3
and 50% of other cls/acts will be L2 | L3
some cls/acts will be L3 only until they're fixed.

The users will create ingress qdisc with 'needs_l2' flag only
when they need to attach cls_bpf to it. All existing users
won't notice the change.
Looks pretty clean to me.

> Face it, we're stuck with what we have.  And I think you will
> have to adjust generated bpf program based upon whether it is
> being attacked to ingress or egress qdisc.

Presence of L2 is fundamental in bpf architecture. I'd rather
disable them on ingress than face this mess, since it will be
horrendous in the long run.
